/*
    core.division: divisions within an organisation.
    UNIQUE (organisation_id, division_id) is the target for service_unit's
    composite foreign key (rule 5).
*/
CREATE TABLE core.division
(
    division_id     int           NOT NULL IDENTITY(1, 1),
    organisation_id int           NOT NULL,
    name            nvarchar(100) NOT NULL,
    active_from     date          NOT NULL,
    active_to       date          NULL,
    CONSTRAINT pk_division PRIMARY KEY (division_id),
    CONSTRAINT uq_division_organisation_id_division_id UNIQUE (organisation_id, division_id),
    CONSTRAINT fk_division_organisation FOREIGN KEY (organisation_id)
        REFERENCES core.organisation (organisation_id)
        ON DELETE NO ACTION
);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Divisions within an organisation.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'division';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'division',
    @level2type = N'COLUMN', @level2name = N'division_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Organisation the division belongs to.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'division',
    @level2type = N'COLUMN', @level2name = N'organisation_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Division name.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'division',
    @level2type = N'COLUMN', @level2name = N'name';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'First day the division was active.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'division',
    @level2type = N'COLUMN', @level2name = N'active_from';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Last day the division was active; null while active.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'division',
    @level2type = N'COLUMN', @level2name = N'active_to';
GO
