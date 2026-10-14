/*
    core.usp_change_person_role: updates a person's organisation, job role and unit.
    Past bookings keep the values copied at booking (rule 15).
    50001: host-trust staff must have a service unit.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE core.usp_change_person_role
    @person_id       int,
    @organisation_id int,
    @job_role_code   char(5),
    @service_unit_id int = NULL
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

        UPDATE core.person
        SET organisation_id = @organisation_id,
            job_role_code   = @job_role_code,
            service_unit_id = @service_unit_id,
            modified_by     = SUSER_SNAME()
        WHERE person_id = @person_id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
