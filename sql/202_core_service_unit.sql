/*
    core.service_unit: service units within a division.
    Rule 5: the composite foreign key keeps a unit's division in the same
    organisation. UNIQUE (organisation_id, service_unit_id) is the target for
    the composite foreign keys on person and session_participant.
*/
CREATE TABLE core.service_unit
(
    service_unit_id int           NOT NULL IDENTITY(1, 1),
    organisation_id int           NOT NULL,
    division_id     int           NOT NULL,
    name            nvarchar(100) NOT NULL,
    active_from     date          NOT NULL,
    active_to       date          NULL,
    CONSTRAINT pk_service_unit PRIMARY KEY (service_unit_id),
    CONSTRAINT uq_service_unit_organisation_id_service_unit_id UNIQUE (organisation_id, service_unit_id),
    CONSTRAINT fk_service_unit_division FOREIGN KEY (organisation_id, division_id)
        REFERENCES core.division (organisation_id, division_id)
        ON DELETE NO ACTION
);
GO

CREATE NONCLUSTERED INDEX ix_service_unit_organisation_id_division_id
    ON core.service_unit (organisation_id, division_id);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Service units (wards, departments, teams) within a division.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'service_unit';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'service_unit',
    @level2type = N'COLUMN', @level2name = N'service_unit_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Organisation the unit belongs to; must match its division''s organisation.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'service_unit',
    @level2type = N'COLUMN', @level2name = N'organisation_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Division the unit belongs to.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'service_unit',
    @level2type = N'COLUMN', @level2name = N'division_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Service unit name.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'service_unit',
    @level2type = N'COLUMN', @level2name = N'name';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'First day the unit was active.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'service_unit',
    @level2type = N'COLUMN', @level2name = N'active_from';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Last day the unit was active; null while active.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'service_unit',
    @level2type = N'COLUMN', @level2name = N'active_to';
GO
