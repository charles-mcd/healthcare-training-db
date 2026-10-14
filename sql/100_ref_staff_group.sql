/*
    ref.staff_group: national staff groups.
    Rows are loaded by the build from data/reference/staff_group.csv.
*/
CREATE TABLE ref.staff_group
(
    staff_group_code char(2)       NOT NULL,
    description      nvarchar(100) NOT NULL,
    retired_on       date          NULL,
    CONSTRAINT pk_staff_group PRIMARY KEY (staff_group_code)
);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Staff groups: STAFF GROUP CODE (TRAINING ACTIVITY CLASSIFICATION), NHS Data Dictionary.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'staff_group';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'National two-character staff group code.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'staff_group',
    @level2type = N'COLUMN', @level2name = N'staff_group_code';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'National description of the staff group.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'staff_group',
    @level2type = N'COLUMN', @level2name = N'description';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date the code was retired nationally; null while current.',
    @level0type = N'SCHEMA', @level0name = N'ref',
    @level1type = N'TABLE',  @level1name = N'staff_group',
    @level2type = N'COLUMN', @level2name = N'retired_on';
GO
