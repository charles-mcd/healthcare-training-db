/*
    core.usp_add_person: adds a person.
    50001: host-trust staff must have a service unit.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_add_person
    @first_name      nvarchar(50),
    @last_name       nvarchar(50),
    @organisation_id int,
    @job_role_code   char(5),
    @email           nvarchar(254) = NULL,
    @service_unit_id int           = NULL,
    @person_id       int           = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @service_unit_id IS NULL
           AND EXISTS (
                SELECT 1
                FROM core.organisation AS o
                WHERE o.organisation_id = @organisation_id
                  AND o.is_host = 1
            )
            THROW 50001, N'Host-trust staff must have a service unit.', 1;

        INSERT INTO core.person (first_name, last_name, email, organisation_id, job_role_code, service_unit_id)
        VALUES (@first_name, @last_name, @email, @organisation_id, @job_role_code, @service_unit_id);

        SET @person_id = SCOPE_IDENTITY();

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
