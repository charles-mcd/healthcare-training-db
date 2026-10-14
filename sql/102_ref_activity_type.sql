/*
    ref.activity_type: local code list for kinds of training activity.
*/
CREATE TABLE ref.activity_type
(
    activity_type_code char(1)       NOT NULL,
    description        nvarchar(100) NOT NULL,
    CONSTRAINT pk_activity_type PRIMARY KEY (activity_type_code)
);
GO

INSERT INTO ref.activity_type (activity_type_code, description)
VALUES
    ('C', N'Course'),
    ('S', N'Support'),
    ('E', N'Event');
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Kinds of training activity a course can be.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'activity_type';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Activity type code: C course, S support, E event.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'activity_type',
    @level2type = N'COLUMN', @level2name = N'activity_type_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Description of the activity type.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'activity_type',
    @level2type = N'COLUMN', @level2name = N'description';
GO
