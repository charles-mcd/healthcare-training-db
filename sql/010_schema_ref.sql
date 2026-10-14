/*
    ref: code lists.
*/
CREATE SCHEMA ref;
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Code lists: national NHS codes and fixed local codes.',
    @level0type = N'SCHEMA', @level0name = N'ref';
GO
