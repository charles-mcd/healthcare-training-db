/*
    rpt.v_participation: one row per participant, with the session, course,
    organisation and division, and the staff group and job role held when
    the booking was made (rule 15), so they come from session_participant,
    not person.
    Partner staff have no unit, so the unit and division are LEFT JOINs.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW rpt.v_participation
AS
SELECT
    sp.participant_id,
    sp.session_id,
    YEAR(s.session_date) * 10000 + MONTH(s.session_date) * 100 + DAY(s.session_date) AS date_key,
    c.name          AS course_name,
    a.description   AS activity_type,
    sp.role_code,
    sp.outcome_code,
    o.name          AS organisation_name,
    o.is_host,
    dv.name         AS division_name,
    jr.staff_group_code,
    sg.description  AS staff_group,
    sp.job_role_code,
    jr.description  AS job_role
FROM core.session_participant AS sp
JOIN core.session AS s            ON s.session_id = sp.session_id
JOIN core.course AS c             ON c.course_id = s.course_id
JOIN ref.activity_type AS a       ON a.activity_type_code = c.activity_type_code
JOIN core.organisation AS o       ON o.organisation_id = sp.organisation_id
JOIN ref.job_role AS jr           ON jr.job_role_code = sp.job_role_code
JOIN ref.staff_group AS sg        ON sg.staff_group_code = jr.staff_group_code
LEFT JOIN core.service_unit AS su ON su.service_unit_id = sp.service_unit_id
LEFT JOIN core.division AS dv     ON dv.division_id = su.division_id;
GO
