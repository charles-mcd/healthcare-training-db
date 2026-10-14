/*
    rpt.v_faculty_load: per financial year, the sessions each person taught
    (a faculty role, LEAD or FAC, with outcome A), ranked within the year.
    RANK gives people with equal counts the same rank.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW rpt.v_faculty_load
AS
SELECT
    dd.fy_label,
    pe.person_id,
    CONCAT(pe.first_name, N' ', pe.last_name) AS faculty_name,
    COUNT(*)                                   AS sessions_taught,
    RANK() OVER (PARTITION BY dd.fy_label ORDER BY COUNT(*) DESC) AS load_rank
FROM core.session_participant AS sp
JOIN ref.participant_role AS pr ON pr.role_code = sp.role_code
JOIN core.session AS s          ON s.session_id = sp.session_id
JOIN rpt.dim_date AS dd         ON dd.calendar_date = s.session_date
JOIN core.person AS pe          ON pe.person_id = sp.person_id
WHERE pr.is_faculty = 1
  AND sp.outcome_code = 'A'
GROUP BY dd.fy_label, pe.person_id, pe.first_name, pe.last_name;
GO
