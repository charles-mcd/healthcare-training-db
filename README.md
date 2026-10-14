# Healthcare Training DB

A SQL Server database for a hospital trust's clinical training centre: the courses it runs, who takes part in each session and in what role, and whether they attended. It is a portfolio project for NHS data analyst roles.

It is based on a training database I built for an NHS trust, rebuilt from scratch. The trust, its people and all the data here are fictional.

## What it shows

- **Schema design around national code lists.** Staff groups and job roles use NHS Data Dictionary codes. Tables sit in three schemas: `ref` for code lists, `core` for operational data and `rpt` for reporting.
- **Rules the database enforces itself.** Sixteen business rules, listed in [docs/design.md](docs/design.md#rules). Most are enforced with keys, filtered unique indexes and CHECK constraints, SQL Server rejects a bad row. The rest are enforced by the stored procedures every write goes through, and a trigger backs up the capacity rule.
- **A write path of stored procedures**, with transactions, error handling and custom error numbers. Booking locks the session row, so two bookings at once can't overfill it.
- **Reports that use the role held at the time.** Each booking keeps the person's organisation, job role and unit as they were when they booked, so a promotion doesn't rewrite past reports.
- **Reporting views and procedures:**
  - participation, one row per booking
  - fill and DNA (did not attend) rates per session
  - DNA rate by staff group and financial quarter, with the change on the previous quarter (window functions)
  - a session register with subtotals by staff group (GROUP BY ROLLUP)
  - faculty teaching load, ranked per financial year
  - a name search that also finds similar-sounding names (SOUNDEX)
- **A repeatable build.** One Python script recreates the database, runs every SQL file in order, and loads the code lists, the calendar and seeded synthetic data.

## Contents

| Path | Holds |
| --- | --- |
| `sql/` | One object per file, numbered in build order |
| `data/reference/` | The NHS code lists, with their sources |
| `data/dim_date.py` | The reporting calendar, with NHS financial years |
| `data/generate.py` | The synthetic data generator |
| `scripts/build.py` | The build script |
| `docs/design.md` | The design: tables, rules and reports |
| `docs/data-dictionary.md` | Every table and column, generated from the database |

## Build it

You need SQL Server 2025 (the free Developer edition works), ODBC Driver 18 for SQL Server and Python 3.

```powershell
python -m pip install -r requirements.txt
python scripts/build.py
```

The build drops and recreates `HealthcareTrainingDB` on the local default instance, using Windows authentication. To regenerate the data dictionary afterwards, run `python scripts/data_dictionary.py`.

## The data

The data is synthetic, generated from a fixed seed: 2,200 people across a host trust and six partner organisations, and 650 sessions of 40 courses from April 2023 to December 2026. Sessions after the build date have bookings only. Two patterns are seeded in: staff group 03 (Nursing and Midwifery Registered) has a higher DNA rate, and about 5% of people change job role part-way through.

## Licence

Code is released under the MIT licence (see LICENSE). The national code lists in data/reference/ are © NHS England and are excluded.
