/*
    core.usp_find_person: a name search. It matches first or last names
    starting with the search text (LIKE), or last names that sound like it
    (SOUNDEX, so 'Morgen' finds 'Morgan'). Each match shows the person's
    current organisation and job role, the sessions they attended as a
    delegate and as faculty, and the date of the last one.

    Read-only, so it needs no transaction.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_find_person
    @search nvarchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        pe.person_id,
        pe.first_name,
        pe.last_name,
        pe.email,
        o.name         AS organisation_name,
        jr.description AS job_role,
        SUM(CASE WHEN sp.role_code = 'DEL' THEN 1 ELSE 0 END) AS sessions_as_delegate,
        SUM(CASE WHEN pr.is_faculty = 1 THEN 1 ELSE 0 END)    AS sessions_as_faculty,
        MAX(s.session_date)                                    AS last_attended_on
    FROM core.person AS pe
    JOIN core.organisation AS o ON o.organisation_id = pe.organisation_id
    JOIN ref.job_role AS jr     ON jr.job_role_code = pe.job_role_code
    -- Only attended sessions count. The condition sits in the ON clause, so
    -- people who have attended nothing are still listed, with zero counts.
    LEFT JOIN core.session_participant AS sp
        ON  sp.person_id = pe.person_id
        AND sp.outcome_code = 'A'
    LEFT JOIN ref.participant_role AS pr ON pr.role_code = sp.role_code
    LEFT JOIN core.session AS s          ON s.session_id = sp.session_id
    WHERE pe.first_name LIKE @search + N'%'
       OR pe.last_name LIKE @search + N'%'
       OR SOUNDEX(pe.last_name) = SOUNDEX(@search)
    GROUP BY pe.person_id, pe.first_name, pe.last_name, pe.email, o.name, jr.description
    ORDER BY pe.last_name, pe.first_name;
END;
GO
