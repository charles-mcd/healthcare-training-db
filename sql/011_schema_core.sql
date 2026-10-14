/*
    core: operational tables and the procedures that write to them.
*/
CREATE SCHEMA core;
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The operational tables and the procedures that write to them.',
    @level0type = N'SCHEMA', @level0name = N'core';
GO
