/*
    core.session_participant: a person's place on a session, in one role.
    Organisation, job role and unit are copied from person at booking so
    reports use the role held at the time.
    Rule 5: the unit belongs to the copied organisation.
    Rule 6: one row per person per session, whatever the role.
    Rule 7: one lead faculty per session.
    Rule 8: a sign-in time only for attendance.
    UNIQUE (session_id, person_id, outcome_code) is the target for feedback's
    foreign key (rule 11).
*/
CREATE TABLE core.session_participant
(
    participant_id  int          NOT NULL IDENTITY(1, 1),
    session_id      int          NOT NULL,
    person_id       int          NOT NULL,
    role_code       varchar(4)   NOT NULL,
    outcome_code    char(1)      NOT NULL CONSTRAINT df_session_participant_outcome_code DEFAULT ('B'),
    signed_in_at    datetime2(0) NULL,
    organisation_id int          NOT NULL,
    job_role_code   char(5)      NOT NULL,
    service_unit_id int          NULL,
    booked_at       datetime2(0) NOT NULL CONSTRAINT df_session_participant_booked_at DEFAULT (SYSDATETIME()),
    modified_by     sysname      NOT NULL CONSTRAINT df_session_participant_modified_by DEFAULT (SUSER_SNAME()),
    CONSTRAINT pk_session_participant PRIMARY KEY (participant_id),
    CONSTRAINT uq_session_participant_session_id_person_id UNIQUE (session_id, person_id),
    CONSTRAINT uq_session_participant_session_id_person_id_outcome_code UNIQUE (session_id, person_id, outcome_code),
    CONSTRAINT ck_session_participant_signed_in_at CHECK (
        (outcome_code = 'A' AND signed_in_at IS NOT NULL)
        OR (outcome_code <> 'A' AND signed_in_at IS NULL)
    ),
    CONSTRAINT fk_session_participant_session FOREIGN KEY (session_id)
        REFERENCES core.session (session_id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_session_participant_person FOREIGN KEY (person_id)
        REFERENCES core.person (person_id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_session_participant_participant_role FOREIGN KEY (role_code)
        REFERENCES ref.participant_role (role_code)
        ON DELETE NO ACTION,
    CONSTRAINT fk_session_participant_attendance_outcome FOREIGN KEY (outcome_code)
        REFERENCES ref.attendance_outcome (outcome_code)
        ON DELETE NO ACTION,
    CONSTRAINT fk_session_participant_organisation FOREIGN KEY (organisation_id)
        REFERENCES core.organisation (organisation_id)
        ON DELETE NO ACTION,
    CONSTRAINT fk_session_participant_job_role FOREIGN KEY (job_role_code)
        REFERENCES ref.job_role (job_role_code)
        ON DELETE NO ACTION,
    CONSTRAINT fk_session_participant_service_unit FOREIGN KEY (organisation_id, service_unit_id)
        REFERENCES core.service_unit (organisation_id, service_unit_id)
        ON DELETE NO ACTION
);
GO

CREATE UNIQUE NONCLUSTERED INDEX ux_session_participant_session_id_lead
    ON core.session_participant (session_id)
    WHERE role_code = 'LEAD';
GO

CREATE NONCLUSTERED INDEX ix_session_participant_person_id
    ON core.session_participant (person_id);
GO

CREATE NONCLUSTERED INDEX ix_session_participant_role_code
    ON core.session_participant (role_code);
GO

CREATE NONCLUSTERED INDEX ix_session_participant_outcome_code
    ON core.session_participant (outcome_code);
GO

CREATE NONCLUSTERED INDEX ix_session_participant_organisation_id_service_unit_id
    ON core.session_participant (organisation_id, service_unit_id);
GO

CREATE NONCLUSTERED INDEX ix_session_participant_job_role_code
    ON core.session_participant (job_role_code);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'A person''s place on a session, in one role, with its attendance outcome.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Surrogate key.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'participant_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Session the person is booked on.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'session_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Person booked on the session.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'person_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Role in the session: DEL, LEAD, FAC, OBS or TECH.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'role_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'B booked, A attended, D did not attend, X cancelled.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'outcome_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Local time the person signed in; present only when outcome is A.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'signed_in_at';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Person''s organisation at booking.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'organisation_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Person''s job role code at booking.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'job_role_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Person''s service unit at booking, in the copied organisation.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'service_unit_id';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Local time the booking was made.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'booked_at';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Login that last changed the row.',
    @level0type = N'SCHEMA', @level0name = N'core',
    @level1type = N'TABLE',  @level1name = N'session_participant',
    @level2type = N'COLUMN', @level2name = N'modified_by';
GO
