/*
    core.organisation: the host trust and its partner organisations.
    At most one organisation is the host.
*/
CREATE TABLE core.organisation
(
    organisation_id int           NOT NULL IDENTITY(1, 1),
    name            nvarchar(150) NOT NULL,
    is_host         bit           NOT NULL CONSTRAINT df_organisation_is_host DEFAULT (0),
    CONSTRAINT pk_organisation PRIMARY KEY (organisation_id),
    CONSTRAINT uq_organisation_name UNIQUE (name)
);
GO

CREATE UNIQUE NONCLUSTERED INDEX ux_organisation_is_host
    ON core.organisation (is_host)
    WHERE is_host = 1;
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Organisations whose staff take part in training: the host trust and its partners.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'organisation';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'organisation',
    @level2type = N'COLUMN', @level2name = N'organisation_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Organisation name; unique.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'organisation',
    @level2type = N'COLUMN', @level2name = N'name';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'1 for the host trust that runs the training centre; at most one row.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'organisation',
    @level2type = N'COLUMN', @level2name = N'is_host';
GO
