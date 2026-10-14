/*
    core.session: one run of a course on a date.
    Rule 9: a cancelled session carries a reason, and only a cancelled one does.
    Rule 10: 1 to 8 hours, capacity 1 to 60.
*/
CREATE TABLE core.session
(
    session_id          int           NOT NULL IDENTITY(1, 1),
    course_id           int           NOT NULL,
    session_date        date          NOT NULL,
    duration_hours      tinyint       NOT NULL,
    capacity            smallint      NOT NULL,
    status_code         char(1)       NOT NULL CONSTRAINT df_session_status_code DEFAULT ('S'),
    cancellation_reason nvarchar(200) NULL,
    notes               nvarchar(500) NULL,
    CONSTRAINT pk_session PRIMARY KEY (session_id),
    CONSTRAINT ck_session_status_code CHECK (status_code IN ('S', 'X')),
    CONSTRAINT ck_session_cancellation_reason CHECK (
        (status_code = 'X' AND cancellation_reason IS NOT NULL AND LEN(cancellation_reason) > 0)
        OR (status_code <> 'X' AND cancellation_reason IS NULL)
    ),
    CONSTRAINT ck_session_duration_hours_range CHECK (duration_hours BETWEEN 1 AND 8),
    CONSTRAINT ck_session_capacity_range CHECK (capacity BETWEEN 1 AND 60),
    CONSTRAINT fk_session_course FOREIGN KEY (course_id)
        REFERENCES core.course (course_id)
        ON DELETE NO ACTION
);
GO

CREATE NONCLUSTERED INDEX ix_session_course_id
    ON core.session (course_id);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'One run of a course on a date.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'session_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Course the session runs.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'course_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the session runs.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'session_date';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Length in hours; 1 to 8. Defaults to the course''s.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'duration_hours';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Places available; 1 to 60. Defaults to the course''s.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'capacity';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'S scheduled, X cancelled.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'status_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Why the session was cancelled; present only when status is X.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'cancellation_reason';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text notes for the session.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session',
    @level2type = N'COLUMN', @level2name = N'notes';
GO
