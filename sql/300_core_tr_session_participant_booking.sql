/*
    core.tr_session_participant_booking: backstop for rule 13, catching
    writes that bypass core.usp_book_participant.
    50011: no booked row on a cancelled session.
    50010: delegates whose outcome isn't X can't exceed capacity.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE TRIGGER core.tr_session_participant_booking
ON core.session_participant
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted)
        RETURN;

    IF EXISTS (
        SELECT 1
        FROM inserted AS i
        JOIN core.session AS s ON s.session_id = i.session_id
        WHERE s.status_code = 'X'
          AND i.outcome_code = 'B'
    )
        THROW 50011, N'The session is cancelled.', 1;

    IF EXISTS (
        SELECT 1
        FROM core.session AS s
        WHERE s.session_id IN (
                SELECT i.session_id
                FROM inserted AS i
                WHERE i.role_code = 'DEL'
                  AND i.outcome_code <> 'X'
            )
          AND s.capacity < (
                SELECT COUNT(*)
                FROM core.session_participant AS sp
                WHERE sp.session_id = s.session_id
                  AND sp.role_code = 'DEL'
                  AND sp.outcome_code <> 'X'
            )
    )
        THROW 50010, N'The session is full.', 1;
END;
GO
