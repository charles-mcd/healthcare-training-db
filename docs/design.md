# Design

Healthcare Training DB records the courses a hospital trust's clinical training centre runs, who takes part in each session and in what role, and whether they attended. The trust, its people and all the data are fictional.

## Scope

This is a portfolio project for NHS data analyst and data science roles. It shows the SQL those roles use: a schema designed around national code lists, rules enforced by constraints, a trigger and procedures, and reporting views and procedures, queried in SQL Server Management Studio.

Database administration (history tables, security roles, backups, builds for several SQL Server versions), automated tests and CI, a working front end, and Power BI (planned for a later version) are out of scope.

The database enforces its own rules. A form can check early and give a friendlier message, but a row that breaks a rule is rejected by SQL Server itself.

## Schemas

| Schema | Holds |
| --- | --- |
| `ref` | Code lists: national NHS codes and fixed local codes |
| `core` | The operational tables and the procedures that write to them |
| `rpt` | The date table, and the views and procedures reporting reads |

## Tables

### ref

| Table | Columns | Notes |
| --- | --- | --- |
| `staff_group` | `staff_group_code char(2)` PK, `description nvarchar(100)`, `retired_on date` | [STAFF GROUP CODE (TRAINING ACTIVITY CLASSIFICATION)](https://www.datadictionary.nhs.uk/data_elements/staff_group_code_training_activity_classification.html), NHS Data Dictionary |
| `job_role` | `job_role_code char(5)` PK, `description nvarchar(150)`, `staff_group_code` FK, `retired_on date` | [JOB ROLE CODE](https://www.datadictionary.nhs.uk/attributes/job_role_code.html), NHS Data Dictionary; only the roles in use. The list people pick from |
| `activity_type` | `activity_type_code char(1)` PK, `description` | C course, S support, E event |
| `participant_role` | `role_code varchar(4)` PK, `description`, `is_faculty bit` | DEL delegate, LEAD lead faculty, FAC faculty, OBS observer, TECH technician |
| `attendance_outcome` | `outcome_code char(1)` PK, `description` | B booked, A attended, D did not attend, X cancelled |

### core

| Table | Columns | Notes |
| --- | --- | --- |
| `organisation` | `organisation_id int` PK, `name nvarchar(150)` unique, `is_host bit` | At most one host (filtered unique index) |
| `division` | `division_id int` PK, `organisation_id` FK, `name nvarchar(100)`, `active_from date`, `active_to date` | UNIQUE (`organisation_id`, `division_id`) as a key target |
| `service_unit` | `service_unit_id int` PK, `organisation_id`, `division_id`, `name nvarchar(100)`, `active_from`, `active_to` | FK (`organisation_id`, `division_id`) to division; UNIQUE (`organisation_id`, `service_unit_id`) |
| `person` | `person_id int` PK, `first_name nvarchar(50)`, `last_name nvarchar(50)`, `email nvarchar(254)` null, `organisation_id` FK, `job_role_code` FK, `service_unit_id` null, `modified_by sysname` | FK (`organisation_id`, `service_unit_id`) to service_unit |
| `course` | `course_id int` PK, `name nvarchar(150)` unique, `activity_type_code` FK, `default_duration_hours tinyint`, `default_capacity smallint`, `is_active bit` | |
| `session` | `session_id int` PK, `course_id` FK, `session_date date`, `duration_hours tinyint`, `capacity smallint`, `status_code char(1)` (S scheduled, X cancelled), `cancellation_reason nvarchar(200)` null, `notes nvarchar(500)` null | |
| `session_participant` | `participant_id int` PK, `session_id` FK, `person_id` FK, `role_code` FK, `outcome_code` FK default B, `signed_in_at datetime2(0)` null, `organisation_id` FK, `job_role_code` FK, `service_unit_id` null, `booked_at datetime2(0)`, `modified_by sysname` | Organisation, job role and unit are copied from person at booking. UNIQUE (`session_id`, `person_id`, `outcome_code`) is the key feedback references |
| `feedback` | `feedback_id int` PK, `session_id`, `person_id`, `outcome_code` computed as 'A' (persisted), `overall_score tinyint`, `comment nvarchar(500)` null, `submitted_at datetime2(0)` | FK (`session_id`, `person_id`, `outcome_code`) to session_participant. UNIQUE (`session_id`, `person_id`): one score per attendee. `overall_score` 1 to 5 |

Timestamps (`booked_at`, `signed_in_at`, `submitted_at`) are UK local time.

### rpt

| Table | Columns | Notes |
| --- | --- | --- |
| `dim_date` | `date_key int` PK (yyyymmdd), `calendar_date date`, `fy_label` ('2025/26'), `fy_quarter` (1 = April to June), `fy_quarter_label` ('2025/26 Q1'), `month_start date`, `is_weekend bit` | 1 April 2022 to 31 March 2027. Rows from `data/dim_date.py` at build time |

## Indexes

Each foreign key not already covered by the leading columns of a key gets one nonclustered index on its columns, named `ix_<table>_<columns>`. An index on a composite key also covers a single-column foreign key on its first column.

## Rules

| # | Rule | Enforced by | Result |
| --- | --- | --- | --- |
| 1 | A person is recorded once | Filtered unique index on `person.email` where not null | 2601 |
| 2 | Names can't be blank | NOT NULL, and CHECK (LEN(name) > 0) on first and last name | 547 |
| 3 | Emails look like emails | CHECK (`email` LIKE '%_@_%._%') | 547 |
| 4 | Job roles use national codes | FK person to job_role to staff_group; CHECK (LEFT(`job_role_code`, 2) = `staff_group_code`) on job_role | 547 |
| 5 | A unit belongs to the person's organisation | Composite FK (`organisation_id`, `service_unit_id`) on person and session_participant; (`organisation_id`, `division_id`) on service_unit | 547 |
| 6 | One row per person per session, whatever the role | UNIQUE (`session_id`, `person_id`) on session_participant | 2627 |
| 7 | One lead faculty per session | Filtered unique index on `session_id` where `role_code` = 'LEAD' | 2601 |
| 8 | A sign-in time only for attendance | CHECK: `signed_in_at` present if and only if `outcome_code` = 'A' | 547 |
| 9 | Cancelled sessions carry a reason | CHECK: `cancellation_reason` present if and only if `status_code` = 'X' | 547 |
| 10 | Session values stay in range | CHECK: 1 to 8 hours, capacity 1 to 60, on sessions and on course defaults | 547 |
| 11 | Feedback only from attendees | Composite FK to session_participant through the persisted outcome 'A' | 547 on insert, and 547 when an attendee who gave feedback is changed to D |
| 12 | Deleting a parent can't erase history | Every FK is ON DELETE NO ACTION | 547 |
| 13 | No booking over capacity or onto a cancelled session | `core.usp_book_participant`, locking the session row (UPDLOCK, HOLDLOCK); a trigger on session_participant as backstop | 50010 full, 50011 cancelled |
| 14 | No sign-in before the session day | `core.usp_record_attendance` | 50020 |
| 15 | Reports use the role held at the time | `core.usp_book_participant` copies organisation, job role and unit from person | Past sessions keep the old role after a change |
| 16 | Sessions inherit course defaults | `core.usp_create_session`: COALESCE(parameter, course default) | Omitted hours take the course's |

Capacity counts delegates whose outcome isn't X; faculty, observers and technicians don't take places.

Host-trust staff must have a service unit. That depends on another table's `is_host` flag, so `core.usp_add_person` and `core.usp_change_person_role` enforce it (50001).

## Write path

Everything a front end writes goes through a procedure in `core`. Procedures start with SET NOCOUNT ON and SET XACT_ABORT ON, use TRY/CATCH and THROW, and re-throw constraint errors unchanged; a front end maps error numbers to messages.

| Procedure | Does | Custom errors |
| --- | --- | --- |
| `usp_add_person` | Adds a person | 50001 |
| `usp_change_person_role` | Updates a person's organisation, job role and unit | 50001 |
| `usp_create_session` | Creates a session, taking the course's defaults for anything omitted | |
| `usp_cancel_session` | Sets status X with a reason; booked participants become X, in one transaction | |
| `usp_book_participant` | Books a person in a role and copies their current organisation, job role and unit | 50010, 50011 |
| `usp_record_attendance` | Sets A (with the sign-in time) or D | 50020; 50021 for any other outcome |
| `usp_add_feedback` | Records one score per attendee | |

## Reporting

| Object | Returns |
| --- | --- |
| `rpt.dim_date` | The date table above |
| `rpt.v_participation` | One row per participant: session, date key, course, activity type, role, outcome, organisation, host flag, division, and staff group and job role as held at the time |
| `rpt.v_session_summary` | One row per session: capacity, booked, attended, did not attend, fill rate (attended ÷ capacity) and DNA rate (D ÷ (A + D)), counting delegates only |
| `rpt.v_dna_by_staff_group` | Per financial quarter and staff group: delegates due, DNAs, DNA rate, and the change on the previous quarter |
| `rpt.v_today` | Today's sessions: capacity, booked, signed in |
| `rpt.usp_session_register` | For one session: each participant with staff group, job role, organisation and outcome, plus subtotals by staff group and a total (GROUP BY ROLLUP) |
| `core.usp_find_person` | A name search using LIKE and SOUNDEX; each match with its delegate count, faculty count and last session date |
| `rpt.v_faculty_load` | Per financial year: sessions taught per person, ranked |

A delegate has role DEL. Faculty roles are LEAD and FAC. "Trained" means a delegate with outcome A.

"Booked" means delegates who still hold a place (outcome not X), and "delegates due" means outcome A or D. Rates are percentages to one decimal place, and the change in DNA rate is in percentage points. The two reporting procedures only read, so they start with SET NOCOUNT ON and need no transaction.

## Front end

SQL Server Management Studio is the querying tool NHS analysts use. Reports and queries are shown with SSMS screenshots in `docs/images/`. No front end is built.

## Data

- `data/reference/`: the national codes in use, with source URL and retrieval date.
- `data/dim_date.py`: the calendar for `rpt.dim_date`, calculated at build time.
- `data/generate.py`: synthetic data from a fixed seed, loaded after the schema. It spans 1 April 2023 to 31 December 2026; sessions after today carry bookings only. It creates about 40 courses, 650 sessions, 2,200 people, 5,500 delegate rows and 1,600 faculty rows, with feedback from about half of attendees.
- Organisations: the host, "Example University Hospitals NHS Trust", with 5 divisions and about 20 service units, plus 6 fictional partner organisations.
- Seeded patterns, stated wherever results are shown: a higher DNA rate for staff group 03 (Nursing and Midwifery Registered), and about 5% of people changing job role mid-period.
- Names come from Faker (en_GB); emails use example.org.

## Build

- `python scripts/build.py` drops and recreates the database on the local SQL Server (collation Latin1_General_CI_AS), runs `sql/` in order, then loads the code lists, the calendar and the synthetic data.
- `python scripts/data_dictionary.py` writes `docs/data-dictionary.md` from the MS_Description extended properties.
