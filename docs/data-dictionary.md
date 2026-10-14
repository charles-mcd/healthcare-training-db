# Data dictionary

Every table and column in HealthcareTrainingDB, generated from the MS_Description
extended properties by `scripts/data_dictionary.py`.

## ref.activity_type

Kinds of training activity a course can be.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `activity_type_code` | char(1) | No | Activity type code: C course, S support, E event. |
| `description` | nvarchar(100) | No | Description of the activity type. |

## ref.attendance_outcome

Outcomes of a booking.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `outcome_code` | char(1) | No | Outcome code: B booked, A attended, D did not attend, X cancelled. |
| `description` | nvarchar(100) | No | Description of the outcome. |

## ref.job_role

Job roles in use: JOB ROLE CODE, NHS Data Dictionary. The list people pick from.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `job_role_code` | char(5) | No | National five-character job role code; the first two characters are the staff group code. |
| `description` | nvarchar(150) | No | National description of the job role. |
| `staff_group_code` | char(2) | No | Staff group the job role belongs to. |
| `retired_on` | date | Yes | Date the code was retired nationally; null while current. |

## ref.participant_role

Roles a person can hold in a session.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `role_code` | varchar(4) | No | Role code: DEL delegate, LEAD lead faculty, FAC faculty, OBS observer, TECH technician. |
| `description` | nvarchar(100) | No | Description of the role. |
| `is_faculty` | bit | No | 1 if the role teaches the session (LEAD, FAC); counted in faculty load. |

## ref.staff_group

Staff groups: STAFF GROUP CODE (TRAINING ACTIVITY CLASSIFICATION), NHS Data Dictionary.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `staff_group_code` | char(2) | No | National two-character staff group code. |
| `description` | nvarchar(100) | No | National description of the staff group. |
| `retired_on` | date | Yes | Date the code was retired nationally; null while current. |

## core.course

Courses, support activities and events the training centre runs.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `course_id` | int | No | Surrogate key. |
| `name` | nvarchar(150) | No | Course name; unique. |
| `activity_type_code` | char(1) | No | Kind of activity: C course, S support, E event. |
| `default_duration_hours` | tinyint | No | Hours a session lasts unless set otherwise; 1 to 8. |
| `default_capacity` | smallint | No | Places on a session unless set otherwise; 1 to 60. |
| `is_active` | bit | No | 1 while the course is offered. |

## core.division

Divisions within an organisation.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `division_id` | int | No | Surrogate key. |
| `organisation_id` | int | No | Organisation the division belongs to. |
| `name` | nvarchar(100) | No | Division name. |
| `active_from` | date | No | First day the division was active. |
| `active_to` | date | Yes | Last day the division was active; null while active. |

## core.feedback

Feedback from attendees: one score per attendee per session.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `feedback_id` | int | No | Surrogate key. |
| `session_id` | int | No | Session the feedback is about. |
| `person_id` | int | No | Attendee who gave the feedback. |
| `outcome_code` | char(1) | No | Always A; persisted so the foreign key only matches attended participants. |
| `overall_score` | tinyint | No | Overall score, 1 (poor) to 5 (excellent). |
| `comment` | nvarchar(500) | Yes | Free-text comment. |
| `submitted_at` | datetime2(0) | No | Local time the feedback was submitted. |

## core.organisation

Organisations whose staff take part in training: the host trust and its partners.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `organisation_id` | int | No | Surrogate key. |
| `name` | nvarchar(150) | No | Organisation name; unique. |
| `is_host` | bit | No | 1 for the host trust that runs the training centre; at most one row. |

## core.person

Staff who take part in training, as delegates or faculty.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `person_id` | int | No | Surrogate key. |
| `first_name` | nvarchar(50) | No | First name; not blank. |
| `last_name` | nvarchar(50) | No | Last name; not blank. |
| `email` | nvarchar(254) | Yes | Work email; unique when present. |
| `organisation_id` | int | No | Organisation the person currently works for. |
| `job_role_code` | char(5) | No | Current national job role code. |
| `service_unit_id` | int | Yes | Current service unit, in the person's organisation; required for host-trust staff. |
| `modified_by` | sysname | No | Login that last changed the row. |

## core.service_unit

Service units (wards, departments, teams) within a division.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `service_unit_id` | int | No | Surrogate key. |
| `organisation_id` | int | No | Organisation the unit belongs to; must match its division's organisation. |
| `division_id` | int | No | Division the unit belongs to. |
| `name` | nvarchar(100) | No | Service unit name. |
| `active_from` | date | No | First day the unit was active. |
| `active_to` | date | Yes | Last day the unit was active; null while active. |

## core.session

One run of a course on a date.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `session_id` | int | No | Surrogate key. |
| `course_id` | int | No | Course the session runs. |
| `session_date` | date | No | Date the session runs. |
| `duration_hours` | tinyint | No | Length in hours; 1 to 8. Defaults to the course's. |
| `capacity` | smallint | No | Places available; 1 to 60. Defaults to the course's. |
| `status_code` | char(1) | No | S scheduled, X cancelled. |
| `cancellation_reason` | nvarchar(200) | Yes | Why the session was cancelled; present only when status is X. |
| `notes` | nvarchar(500) | Yes | Free-text notes for the session. |

## core.session_participant

A person's place on a session, in one role, with its attendance outcome.

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `participant_id` | int | No | Surrogate key. |
| `session_id` | int | No | Session the person is booked on. |
| `person_id` | int | No | Person booked on the session. |
| `role_code` | varchar(4) | No | Role in the session: DEL, LEAD, FAC, OBS or TECH. |
| `outcome_code` | char(1) | No | B booked, A attended, D did not attend, X cancelled. |
| `signed_in_at` | datetime2(0) | Yes | Local time the person signed in; present only when outcome is A. |
| `organisation_id` | int | No | Person's organisation at booking. |
| `job_role_code` | char(5) | No | Person's job role code at booking. |
| `service_unit_id` | int | Yes | Person's service unit at booking, in the copied organisation. |
| `booked_at` | datetime2(0) | No | Local time the booking was made. |
| `modified_by` | sysname | No | Login that last changed the row. |

## rpt.dim_date

Calendar for reporting: one row per day from 1 April 2022 to 31 March 2027, with NHS financial years (April to March).

| Column | Type | Nulls | Description |
| --- | --- | --- | --- |
| `date_key` | int | No | The date as an eight-digit yyyymmdd number, e.g. 20250401; primary key. |
| `calendar_date` | date | No | The calendar date. |
| `fy_label` | nvarchar(7) | No | NHS financial year, April to March, e.g. 2025/26. |
| `fy_quarter` | tinyint | No | Quarter of the financial year: 1 = April to June, 4 = January to March. |
| `fy_quarter_label` | nvarchar(10) | No | Financial year and quarter, e.g. 2025/26 Q1. |
| `month_start` | date | No | First day of the date's month. |
| `is_weekend` | bit | No | 1 for Saturday and Sunday. |
