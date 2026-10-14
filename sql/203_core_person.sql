/*
    core.person: staff who take part in training, as delegates or faculty.
    Rule 1: an email identifies one person.
    Rule 2: names can't be blank.
    Rule 3: emails look like emails.
    Rule 4: job roles use national codes.
    Rule 5: a unit belongs to the person's organisation.
*/
CREATE TABLE core.person
(
    person_id       int           NOT NULL IDENTITY(1, 1),
    first_name      nvarchar(50)  NOT NULL,
    last_name       nvarchar(50)  NOT NULL,
    email           nvarchar(254) NULL,
    organisation_id int           NOT NULL,
    job_role_code   char(5)       NOT NULL,
    service_unit_id int           NULL,
    modified_by     sysname       NOT NULL CONSTRAINT df_person_modified_by DEFAULT (SUSER_SNAME()),
    CONSTRAINT pk_person PRIMARY KEY (person_id),
    CONSTRAINT ck_person_first_name_not_blank CHECK (LEN(first_name) > 0),
    CONSTRAINT ck_person_last_name_not_blank CHECK (LEN(last_name) > 0),
    CONSTRAINT ck_person_email_format CHECK (email LIKE N'%_@_%._%'),
    CONSTRAINT fk_person_organisation FOREIGN KEY (organisation_id)
        REFERENCES core.organisation (organisation_id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_person_job_role FOREIGN KEY (job_role_code)
        REFERENCES ref.job_role (job_role_code)
        ON DELETE NO ACTION,
    CONSTRAINT fk_person_service_unit FOREIGN KEY (organisation_id, service_unit_id)
        REFERENCES core.service_unit (organisation_id, service_unit_id)
        ON DELETE NO ACTION
);
GO

CREATE UNIQUE NONCLUSTERED INDEX ux_person_email
    ON core.person (email)
    WHERE email IS NOT NULL;
GO

CREATE NONCLUSTERED INDEX ix_person_organisation_id_service_unit_id
    ON core.person (organisation_id, service_unit_id);
GO

CREATE NONCLUSTERED INDEX ix_person_job_role_code
    ON core.person (job_role_code);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Staff who take part in training, as delegates or faculty.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'person_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'First name; not blank.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'first_name';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Last name; not blank.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'last_name';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Work email; unique when present.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'email';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Organisation the person currently works for.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'organisation_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Current national job role code.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'job_role_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Current service unit, in the person''s organisation; required for host-trust staff.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'service_unit_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Login that last changed the row.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'person',
    @level2type = N'COLUMN', @level2name = N'modified_by';
GO
