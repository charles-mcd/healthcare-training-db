/*
    core.usp_add_feedback: records an attendee's score for a session.
    The table enforces the rest: attendees only (rule 11), one score each,
    and a score of 1 to 5.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_add_feedback
    @session_id    int,
    @person_id     int,
    @overall_score tinyint,
    @comment       nvarchar(500) = NULL,
    @feedback_id   int           = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO core.feedback (session_id, person_id, overall_score, comment)
        VALUES (@session_id, @person_id, @overall_score, @comment);

        SET @feedback_id = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
