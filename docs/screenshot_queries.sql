/*
    The queries behind the screenshots in the write-up.

    Run against HealthcareTrainingDB after python scripts/build.py.
    In SSMS, select one numbered section and press F5.
    Section 1 tries to break rules inside transactions that are rolled back,
    so nothing is saved.
*/
USE HealthcareTrainingDB;
GO
SET NOCOUNT ON;
GO


/* =====================================================================
   1. Rules in action: one rule broken at each layer (Messages tab)
   ===================================================================== */

-- Rule 9, CHECK constraint: a cancelled session must carry a reason.
BEGIN TRANSACTION;
DECLARE @session_id int = (
    SELECT TOP (1) session_id
    FROM core.session
    WHERE status_code = 'S' AND session_date > CAST(GETDATE() AS date)
    ORDER BY session_date);
EXEC core.usp_cancel_session @session_id = @session_id, @cancellation_reason = NULL;
GO
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- Rule 7, filtered unique index: one lead faculty per session.
BEGIN TRANSACTION;
DECLARE @session_id int = (
    SELECT TOP (1) session_id
    FROM core.session
    WHERE status_code = 'S' AND session_date > CAST(GETDATE() AS date)
    ORDER BY session_date);
DECLARE @person_id int = (
    SELECT TOP (1) p.person_id
    FROM core.person AS p
    WHERE NOT EXISTS (SELECT 1 FROM core.session_participant AS sp
                      WHERE sp.session_id = @session_id AND sp.person_id = p.person_id)
    ORDER BY p.person_id);
EXEC core.usp_book_participant @session_id = @session_id, @person_id = @person_id, @role_code = 'LEAD';
GO
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- Rule 11, foreign key through the persisted outcome 'A': feedback only from attendees.
BEGIN TRANSACTION;
DECLARE @session_id int, @person_id int;
SELECT TOP (1) @session_id = session_id, @person_id = person_id
FROM core.session_participant
WHERE role_code = 'DEL' AND outcome_code = 'D'
ORDER BY participant_id;
EXEC core.usp_add_feedback @session_id = @session_id, @person_id = @person_id, @overall_score = 4;
GO
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- Rule 13, procedure: no booking over capacity. A one-place session, two bookings.
BEGIN TRANSACTION;
DECLARE @session_id int;
EXEC core.usp_create_session @course_id = 1, @session_date = '20261214', @capacity = 1,
     @session_id = @session_id OUTPUT;
EXEC core.usp_book_participant @session_id = @session_id, @person_id = 1, @role_code = 'DEL';
EXEC core.usp_book_participant @session_id = @session_id, @person_id = 2, @role_code = 'DEL';
GO
IF @@TRANCOUNT > 0 ROLLBACK;
GO

-- Rule 13, trigger backstop: the same overbooking by a direct INSERT that bypasses the procedure.
BEGIN TRANSACTION;
DECLARE @session_id int;
EXEC core.usp_create_session @course_id = 1, @session_date = '20261214', @capacity = 1,
     @session_id = @session_id OUTPUT;
INSERT INTO core.session_participant
    (session_id, person_id, role_code, organisation_id, job_role_code, service_unit_id)
SELECT @session_id, person_id, 'DEL', organisation_id, job_role_code, service_unit_id
FROM core.person
WHERE person_id IN (1, 2);
GO
IF @@TRANCOUNT > 0 ROLLBACK;
GO


/* =====================================================================
   2. Reports use the role held at the time (rule 15)
      A person who changed job role: each booking keeps the role they
      held when they booked.
   ===================================================================== */
DECLARE @person_id int = (
    SELECT TOP (1) sp.person_id
    FROM core.session_participant AS sp
    JOIN core.person AS p ON p.person_id = sp.person_id
    WHERE sp.job_role_code <> p.job_role_code
      AND EXISTS (SELECT 1 FROM core.session_participant AS later
                  WHERE later.person_id = sp.person_id
                    AND later.job_role_code = p.job_role_code)
    ORDER BY sp.person_id);

SELECT
    CONCAT(p.first_name, N' ', p.last_name) AS person,
    s.session_date,
    c.name            AS course,
    sp.role_code,
    jr_booked.description AS job_role_when_booked,
    jr_now.description    AS job_role_now
FROM core.session_participant AS sp
JOIN core.person AS p           ON p.person_id = sp.person_id
JOIN core.session AS s          ON s.session_id = sp.session_id
JOIN core.course AS c           ON c.course_id = s.course_id
JOIN ref.job_role AS jr_booked  ON jr_booked.job_role_code = sp.job_role_code
JOIN ref.job_role AS jr_now     ON jr_now.job_role_code = p.job_role_code
WHERE sp.person_id = @person_id
ORDER BY s.session_date;
GO


/* =====================================================================
   3a. DNA rate by staff group, all quarters together
       (staff group 03's higher rate is seeded into the synthetic data)
   ===================================================================== */
SELECT
    staff_group_code,
    staff_group,
    SUM(delegates_due) AS delegates_due,
    SUM(dnas)          AS dnas,
    CAST(100.0 * SUM(dnas) / SUM(delegates_due) AS decimal(5, 1)) AS dna_rate_pct
FROM rpt.v_dna_by_staff_group
GROUP BY staff_group_code, staff_group
ORDER BY dna_rate_pct DESC;
GO


/* =====================================================================
   3b. One staff group quarter by quarter, with the change on the
       previous quarter (LAG in rpt.v_dna_by_staff_group)
   ===================================================================== */
SELECT fy_quarter_label, delegates_due, dnas, dna_rate_pct, dna_rate_change_pts
FROM rpt.v_dna_by_staff_group
WHERE staff_group_code = '03'
ORDER BY fy_quarter_label;
GO


/* =====================================================================
   4. Session register with subtotals by staff group (GROUP BY ROLLUP)
      The fullest past session of an 8-place course.
   ===================================================================== */
DECLARE @session_id int = (
    SELECT TOP (1) session_id
    FROM rpt.v_session_summary
    WHERE status_code = 'S'
      AND session_date < CAST(GETDATE() AS date)
      AND capacity = 8
    ORDER BY booked DESC, session_date DESC);
EXEC rpt.usp_session_register @session_id = @session_id;
GO


/* =====================================================================
   5. Fill and DNA rates per session, most recent first
   ===================================================================== */
SELECT TOP (12)
    session_date, course_name, status_code, capacity, booked,
    attended, did_not_attend, fill_rate_pct, dna_rate_pct
FROM rpt.v_session_summary
WHERE session_date < CAST(GETDATE() AS date)
ORDER BY session_date DESC;
GO


/* =====================================================================
   6. Name search: LIKE for names starting with the text, SOUNDEX for
      names that sound like it ('Smyth' finds Smith)
   ===================================================================== */
EXEC core.usp_find_person @search = N'Smyth';
GO

-- If that finds nobody, pick a common surname from here and misspell it.
SELECT TOP (10) last_name, COUNT(*) AS people
FROM core.person
GROUP BY last_name
ORDER BY people DESC;
GO


/* =====================================================================
   7. Faculty teaching load in 2025/26, ranked (RANK gives ties the same rank)
   ===================================================================== */
SELECT fy_label, load_rank, faculty_name, sessions_taught
FROM rpt.v_faculty_load
WHERE fy_label = '2025/26' AND load_rank <= 10
ORDER BY load_rank, faculty_name;
GO
