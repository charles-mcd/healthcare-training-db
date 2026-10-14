/*
    core.usp_record_attendance: records a participant as attended (A), with
    the sign-in time, or did not attend (D).
    The sign-in time defaults to now when omitted.
    50020: sign-in before the session day (rule 14).
    50021: any outcome other than A or D.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_record_attendance
    @participant_id int,
    @outcome_code   char(1),
    @signed_in_at   datetime2(0) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @session_date date;

    BEGIN TRY
        IF @outcome_code IS NULL OR @outcome_code NOT IN ('A', 'D')
            THROW 50021, N'Attendance can only be recorded as A or D.', 1;

        IF @outcome_code = 'A'
            SET @signed_in_at = COALESCE(@signed_in_at, SYSDATETIME());

        BEGIN TRANSACTION;

        SELECT @session_date = s.session_date
        FROM core.session_participant AS sp
        JOIN core.session AS s ON s.session_id = sp.session_id
        WHERE sp.participant_id = @participant_id;

        IF @outcome_code = 'A' AND CAST(@signed_in_at AS date) < @session_date
            THROW 50020, N'Sign-in can''t be before the session day.', 1;

        UPDATE core.session_participant
        SET outcome_code = @outcome_code,
            signed_in_at = @signed_in_at,
            modified_by  = SUSER_SNAME()
        WHERE participant_id = @participant_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
