"""The reporting calendar for rpt.dim_date: one row per day from 1 April 2022
to 31 March 2027, with NHS financial years running April to March.

scripts/build.py inserts these rows after creating the schema.
"""
from datetime import date, timedelta

FIRST_DAY = date(2022, 4, 1)
LAST_DAY = date(2027, 3, 31)


def calendar_row(day):
    """Return the rpt.dim_date columns for one day."""
    # The financial year starts on 1 April, so January to March belong to the year before.
    fy_start = day.year if day.month >= 4 else day.year - 1
    fy_label = f"{fy_start}/{str(fy_start + 1)[-2:]}"
    # Financial quarter 1 is April to June: the calendar quarter minus one,
    # except January to March, which is quarter 4.
    calendar_quarter = (day.month - 1) // 3 + 1
    fy_quarter = 4 if calendar_quarter == 1 else calendar_quarter - 1
    return {
        "date_key": day.year * 10000 + day.month * 100 + day.day,
        "calendar_date": day,
        "fy_label": fy_label,
        "fy_quarter": fy_quarter,
        "fy_quarter_label": f"{fy_label} Q{fy_quarter}",
        "month_start": day.replace(day=1),
        # weekday() counts Monday as 0, so Saturday is 5 and Sunday is 6.
        "is_weekend": day.weekday() >= 5,
    }


def rows():
    """Return one row per day, from the first day to the last."""
    days = (LAST_DAY - FIRST_DAY).days + 1
    return [calendar_row(FIRST_DAY + timedelta(days=n)) for n in range(days)]
