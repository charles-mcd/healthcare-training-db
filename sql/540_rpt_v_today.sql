/*
    rpt.v_today: today's sessions, with places, delegates booked and
    delegates signed in. Built on rpt.v_session_summary, where attended
    means signed in.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE VIEW rpt.v_today
AS
SELECT
    session_id,
    course_name,
    status_code,
    capacity,
    booked,
    attended AS signed_in
FROM rpt.v_session_summary
WHERE session_date = CAST(GETDATE() AS date);
GO
