/*
    ref.participant_role: local code list for the part a person plays in a session.
    Faculty roles are LEAD and FAC.
*/
CREATE TABLE ref.participant_role
(
    role_code   varchar(4)    NOT NULL,
    description nvarchar(100) NOT NULL,
    is_faculty  bit           NOT NULL,
    CONSTRAINT pk_participant_role PRIMARY KEY (role_code)
);
GO

INSERT INTO ref.participant_role (role_code, description, is_faculty)
VALUES
    ('DEL',  N'Delegate',     0),
    ('LEAD', N'Lead faculty', 1),
    ('FAC',  N'Faculty',      1),
    ('OBS',  N'Observer',     0),
    ('TECH', N'Technician',   0);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Roles a person can hold in a session.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'participant_role';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Role code: DEL delegate, LEAD lead faculty, FAC faculty, OBS observer, TECH technician.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'participant_role',
    @level2type = N'COLUMN', @level2name = N'role_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Description of the role.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'participant_role',
    @level2type = N'COLUMN', @level2name = N'description';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'1 if the role teaches the session (LEAD, FAC); counted in faculty load.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'participant_role',
    @level2type = N'COLUMN', @level2name = N'is_faculty';
GO
