/*
    core.feedback: one score per attendee per session.
    Rule 11: the foreign key runs through the persisted outcome 'A', so only an
    attendee can give feedback, and an attendee who has given feedback can't
    be changed to another outcome.
*/
CREATE TABLE core.feedback
(
    feedback_id   int           NOT NULL IDENTITY(1, 1),
    session_id    int           NOT NULL,
    person_id     int           NOT NULL,
    outcome_code  AS CAST('A' AS char(1)) PERSISTED NOT NULL,
    overall_score tinyint       NOT NULL,
    comment       nvarchar(500) NULL,
    submitted_at  datetime2(0)  NOT NULL CONSTRAINT df_feedback_submitted_at DEFAULT (SYSDATETIME()),
    CONSTRAINT pk_feedback PRIMARY KEY (feedback_id),
    CONSTRAINT uq_feedback_session_id_person_id UNIQUE (session_id, person_id),
    CONSTRAINT ck_feedback_overall_score_range CHECK (overall_score BETWEEN 1 AND 5),
    CONSTRAINT fk_feedback_session_participant FOREIGN KEY (session_id, person_id, outcome_code)
        REFERENCES core.session_participant (session_id, person_id, outcome_code)
        ON DELETE NO ACTION
);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Feedback from attendees: one score per attendee per session.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback',
    @level2type = N'COLUMN', @level2name = N'feedback_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Session the feedback is about.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback',
    @level2type = N'COLUMN', @level2name = N'session_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Attendee who gave the feedback.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback',
    @level2type = N'COLUMN', @level2name = N'person_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Always A; persisted so the foreign key only matches attended participants.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback',
    @level2type = N'COLUMN', @level2name = N'outcome_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Overall score, 1 (poor) to 5 (excellent).',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback',
    @level2type = N'COLUMN', @level2name = N'overall_score';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Free-text comment.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback',
    @level2type = N'COLUMN', @level2name = N'comment';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Local time the feedback was submitted.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'feedback',
    @level2type = N'COLUMN', @level2name = N'submitted_at';
GO
