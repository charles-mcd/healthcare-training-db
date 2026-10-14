/*
    rpt: the date table, and the views and procedures reporting reads.
*/
CREATE SCHEMA rpt;
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The date table, and the views and procedures reporting reads.',
    @level0type = N'SCHEMA', @level0name = N'rpt';
GO
