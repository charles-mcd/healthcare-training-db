/*
    ref.attendance_outcome: local code list for what happened to a booking.
*/
CREATE TABLE ref.attendance_outcome
(
    outcome_code char(1)       NOT NULL,
    description  nvarchar(100) NOT NULL,
    CONSTRAINT pk_attendance_outcome PRIMARY KEY (outcome_code)
);
GO

INSERT INTO ref.attendance_outcome (outcome_code, description)
VALUES
    ('B', N'Booked'),
    ('A', N'Attended'),
    ('D', N'Did not attend'),
    ('X', N'Cancelled');
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Outcomes of a booking.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'attendance_outcome';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Outcome code: B booked, A attended, D did not attend, X cancelled.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'attendance_outcome',
    @level2type = N'COLUMN', @level2name = N'outcome_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Description of the outcome.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'attendance_outcome',
    @level2type = N'COLUMN', @level2name = N'description';
GO
