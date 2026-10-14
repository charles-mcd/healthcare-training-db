/*
    core.usp_cancel_session: cancels a session with a reason; its booked
    participants become X in the same transaction.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_cancel_session
    @session_id          int,
    @cancellation_reason nvarchar(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE core.session
        SET status_code         = 'X',
            cancellation_reason = @cancellation_reason
        WHERE session_id = @session_id;

        UPDATE core.session_participant
        SET outcome_code = 'X',
            modified_by  = SUSER_SNAME()
        WHERE session_id = @session_id
          AND outcome_code = 'B';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
