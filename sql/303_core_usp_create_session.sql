/*
    core.usp_create_session: creates a session.
    Rule 16: hours and capacity default to the course's when omitted.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_create_session
    @course_id      int,
    @session_date   date,
    @duration_hours tinyint       = NULL,
    @capacity       smallint      = NULL,
    @notes          nvarchar(500) = NULL,
    @session_id     int           = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @default_duration_hours tinyint,
            @default_capacity       smallint;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @default_duration_hours = c.default_duration_hours,
               @default_capacity       = c.default_capacity
        FROM core.course AS c
        WHERE c.course_id = @course_id;

        INSERT INTO core.session (course_id, session_date, duration_hours, capacity, notes)
        VALUES (
            @course_id,
            @session_date,
            COALESCE(@duration_hours, @default_duration_hours),
            COALESCE(@capacity, @default_capacity),
            @notes
        );

        SET @session_id = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
