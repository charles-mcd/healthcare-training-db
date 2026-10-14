/*
    core.course: the courses, support activities and events the centre runs.
    Rule 10: default hours 1 to 8, default capacity 1 to 60.
*/
CREATE TABLE core.course
(
    course_id              int           NOT NULL IDENTITY(1, 1),
    name                   nvarchar(150) NOT NULL,
    activity_type_code     char(1)       NOT NULL,
    default_duration_hours tinyint       NOT NULL,
    default_capacity       smallint      NOT NULL,
    is_active              bit           NOT NULL CONSTRAINT df_course_is_active DEFAULT (1),
    CONSTRAINT pk_course PRIMARY KEY (course_id),
    CONSTRAINT uq_course_name UNIQUE (name),
    CONSTRAINT ck_course_default_duration_hours_range CHECK (default_duration_hours BETWEEN 1 AND 8),
    CONSTRAINT ck_course_default_capacity_range CHECK (default_capacity BETWEEN 1 AND 60),
    CONSTRAINT fk_course_activity_type FOREIGN KEY (activity_type_code)
        REFERENCES ref.activity_type (activity_type_code)
        ON DELETE NO ACTION
);
GO

CREATE NONCLUSTERED INDEX ix_course_activity_type_code
    ON core.course (activity_type_code);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Courses, support activities and events the training centre runs.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'course';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'course',
    @level2type = N'COLUMN', @level2name = N'course_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Course name; unique.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'course',
    @level2type = N'COLUMN', @level2name = N'name';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Kind of activity: C course, S support, E event.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'course',
    @level2type = N'COLUMN', @level2name = N'activity_type_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Hours a session lasts unless set otherwise; 1 to 8.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'course',
    @level2type = N'COLUMN', @level2name = N'default_duration_hours';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Places on a session unless set otherwise; 1 to 60.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'course',
    @level2type = N'COLUMN', @level2name = N'default_capacity';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'1 while the course is offered.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'course',
    @level2type = N'COLUMN', @level2name = N'is_active';
GO
