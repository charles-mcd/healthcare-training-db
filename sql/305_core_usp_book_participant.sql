/*
    core.usp_book_participant: books a person onto a session in a role.
    Rule 13: the session row is locked so concurrent bookings queue.
    Rule 15: the person's current organisation, job role and unit are copied.
    Capacity counts delegates whose outcome isn't X.
    50010: the session is full.
    50011: the session is cancelled.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_book_participant
    @session_id     int,
    @person_id      int,
    @role_code      varchar(4),
    @participant_id int = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @status_code     char(1),
            @capacity        smallint,
            @booked          int,
            @organisation_id int,
            @job_role_code   char(5),
            @service_unit_id int;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @status_code = s.status_code,
               @capacity    = s.capacity
        FROM core.session AS s WITH (UPDLOCK, HOLDLOCK)
        WHERE s.session_id = @session_id;

        IF @status_code = 'X'
            THROW 50011, N'The session is cancelled.', 1;

        IF @role_code = 'DEL'
        BEGIN
            SELECT @booked = COUNT(*)
            FROM core.session_participant AS sp
            WHERE sp.session_id = @session_id
              AND sp.role_code = 'DEL'
              AND sp.outcome_code <> 'X';

            IF @booked >= @capacity
                THROW 50010, N'The session is full.', 1;
        END;

        SELECT @organisation_id = p.organisation_id,
               @job_role_code   = p.job_role_code,
               @service_unit_id = p.service_unit_id
        FROM core.person AS p
        WHERE p.person_id = @person_id;

        INSERT INTO core.session_participant
            (session_id, person_id, role_code, organisation_id, job_role_code, service_unit_id)
        VALUES
            (@session_id, @person_id, @role_code, @organisation_id, @job_role_code, @service_unit_id);

        SET @participant_id = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
