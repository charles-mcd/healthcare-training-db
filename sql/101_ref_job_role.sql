/*
    ref.job_role: national job roles in use, the list people pick from.
    Rows are loaded by the build from data/reference/job_role.csv.
    Rule 4: a job role code starts with its staff group code.
*/
CREATE TABLE ref.job_role
(
    job_role_code    char(5)       NOT NULL,
    description      nvarchar(150) NOT NULL,
    staff_group_code char(2)       NOT NULL,
    retired_on       date          NULL,
    CONSTRAINT pk_job_role PRIMARY KEY (job_role_code),
    CONSTRAINT fk_job_role_staff_group FOREIGN KEY (staff_group_code)
        REFERENCES ref.staff_group (staff_group_code)
        ON DELETE NO ACTION,
    CONSTRAINT ck_job_role_code_prefix CHECK (LEFT(job_role_code, 2) = staff_group_code)
);
GO

CREATE NONCLUSTERED INDEX ix_job_role_staff_group_code
    ON ref.job_role (staff_group_code);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Job roles in use: JOB ROLE CODE, NHS Data Dictionary. The list people pick from.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'job_role';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'National five-character job role code; the first two characters are the staff group code.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'job_role',
    @level2type = N'COLUMN', @level2name = N'job_role_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'National description of the job role.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'job_role',
    @level2type = N'COLUMN', @level2name = N'description';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Staff group the job role belongs to.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'job_role',
    @level2type = N'COLUMN', @level2name = N'staff_group_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the code was retired nationally; null while current.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'job_role',
    @level2type = N'COLUMN', @level2name = N'retired_on';
GO
