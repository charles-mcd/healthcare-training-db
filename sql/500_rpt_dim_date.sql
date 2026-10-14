/*
    rpt.dim_date: the reporting calendar, one row per day from 1 April 2022
    to 31 March 2027, with NHS financial years (April to March).
    Rows are inserted by the build from data/dim_date.py.
*/
CREATE TABLE rpt.dim_date
(
    date_key         int          NOT NULL,
    calendar_date    date         NOT NULL,
    fy_label         nvarchar(7)  NOT NULL,
    fy_quarter       tinyint      NOT NULL,
    fy_quarter_label nvarchar(10) NOT NULL,
    month_start      date         NOT NULL,
    is_weekend       bit          NOT NULL,
    CONSTRAINT pk_dim_date PRIMARY KEY (date_key)
);
GO

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Calendar for reporting: one row per day from 1 April 2022 to 31 March 2027, with NHS financial years (April to March).',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The date as an eight-digit yyyymmdd number, e.g. 20250401; primary key.',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date',
    @level2type = N'COLUMN', @level2name = N'date_key';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'The calendar date.',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date',
    @level2type = N'COLUMN', @level2name = N'calendar_date';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'NHS financial year, April to March, e.g. 2025/26.',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date',
    @level2type = N'COLUMN', @level2name = N'fy_label';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Quarter of the financial year: 1 = April to June, 4 = January to March.',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date',
    @level2type = N'COLUMN', @level2name = N'fy_quarter';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Financial year and quarter, e.g. 2025/26 Q1.',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date',
    @level2type = N'COLUMN', @level2name = N'fy_quarter_label';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'First day of the date''s month.',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date',
    @level2type = N'COLUMN', @level2name = N'month_start';

EXEC sys.sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'1 for Saturday and Sunday.',
    @level0type = N'SCHEMA', @level0name = N'rpt',
    @level1type = N'TABLE',  @level1name = N'dim_date',
    @level2type = N'COLUMN', @level2name = N'is_weekend';
GO
