/*
    rpt.v_session_summary: one row per session, counting delegates only.
    Booked means delegates who still hold a place (outcome not X).
    Fill rate is attended / capacity, and DNA rate is D / (A + D), both as
    percentages. The DNA rate is empty until someone has an outcome.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW rpt.v_session_summary
AS
WITH counts AS
(
    SELECT
        s.session_id,
        s.session_date,
        c.name AS course_name,
        s.status_code,
        s.capacity,
        COUNT(sp.participant_id)                                AS booked,
        SUM(CASE WHEN sp.outcome_code = 'A' THEN 1 ELSE 0 END) AS attended,
        SUM(CASE WHEN sp.outcome_code = 'D' THEN 1 ELSE 0 END) AS did_not_attend
    FROM core.session AS s
    JOIN core.course AS c ON c.course_id = s.course_id
    -- The conditions sit in the ON clause so sessions with no delegates still appear.
    LEFT JOIN core.session_participant AS sp
        ON  sp.session_id = s.session_id
        AND sp.role_code = 'DEL'
        AND sp.outcome_code <> 'X'
    GROUP BY s.session_id, s.session_date, c.name, s.status_code, s.capacity
)
SELECT
    session_id,
    session_date,
    course_name,
    status_code,
    capacity,
    booked,
    attended,
    did_not_attend,
    -- 100.0 makes the division decimal; dividing two integers would round down.
    CAST(100.0 * attended / capacity AS decimal(5, 1)) AS fill_rate_pct,
    -- NULLIF turns a zero denominator into NULL instead of a divide-by-zero error.
    CAST(100.0 * did_not_attend / NULLIF(attended + did_not_attend, 0) AS decimal(5, 1)) AS dna_rate_pct
FROM counts;
GO
