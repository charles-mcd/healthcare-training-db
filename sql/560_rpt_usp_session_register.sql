/*
    rpt.usp_session_register: the register for one session. Each participant
    with their staff group, job role, organisation, role and outcome, then a
    subtotal for each staff group and a total for the session.

    GROUP BY ROLLUP adds the subtotal and total rows. The bracketed groups
    roll up together, so there are three levels: one row per participant,
    one per staff group, and one for the session. GROUPING() returns 1 on
    the rows ROLLUP added, which is how they get their labels.

    Read-only, so it needs no transaction.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE rpt.usp_session_register
    @session_id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CASE WHEN GROUPING(sg.staff_group_code) = 1 THEN N'All staff groups' ELSE sg.description END AS staff_group,
        CASE
            WHEN GROUPING(sg.staff_group_code) = 1 THEN N'Total'
            WHEN GROUPING(sp.participant_id) = 1 THEN N'Subtotal'
            ELSE CONCAT(pe.last_name, N', ', pe.first_name)
        END AS participant,
        jr.description AS job_role,
        o.name         AS organisation_name,
        sp.role_code,
        sp.outcome_code,
        COUNT(*)                                               AS participants,
        SUM(CASE WHEN sp.outcome_code = 'A' THEN 1 ELSE 0 END) AS attended
    FROM core.session_participant AS sp
    JOIN core.person AS pe      ON pe.person_id = sp.person_id
    JOIN core.organisation AS o ON o.organisation_id = sp.organisation_id
    JOIN ref.job_role AS jr     ON jr.job_role_code = sp.job_role_code
    JOIN ref.staff_group AS sg  ON sg.staff_group_code = jr.staff_group_code
    WHERE sp.session_id = @session_id
    GROUP BY ROLLUP (
        (sg.staff_group_code, sg.description),
        (sp.participant_id, pe.last_name, pe.first_name, jr.description, o.name, sp.role_code, sp.outcome_code)
    )
    ORDER BY
        GROUPING(sg.staff_group_code),
        sg.staff_group_code,
        GROUPING(sp.participant_id),
        pe.last_name,
        pe.first_name;
END;
GO
