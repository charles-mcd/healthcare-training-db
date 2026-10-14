"""Synthetic data for HealthcareTrainingDB, generated from a fixed seed.

scripts/build.py calls load() after creating the schema and loading the code
lists. Every person, email and organisation is fictional.

Rows are inserted directly rather than through the core procedures, because
past sessions need past booking and sign-in times. The constraints and the
trigger still check every row.

Seeded patterns:
- staff group 03 (Nursing and Midwifery Registered) has a higher DNA rate;
- about 5% of people change job role part-way through, and their earlier
  bookings keep the role they held when they booked (rule 15).
"""
import random
import re
from datetime import date, datetime, time, timedelta

from faker import Faker

SEED = 20230401

FIRST_DAY = date(2023, 4, 1)
LAST_DAY = date(2026, 12, 31)
UNITS_ACTIVE_FROM = date(2020, 4, 1)
ROLE_CHANGES_FROM = date(2024, 1, 1)
ROLE_CHANGES_TO = date(2025, 12, 31)

HOST = "Example University Hospitals NHS Trust"
PARTNERS = [
    "Example Community Health NHS Trust",
    "Example Mental Health NHS Foundation Trust",
    "Example Ambulance Service NHS Trust",
    "Example City Primary Care Network",
    "Example University",
    "Example Hospice",
]

# The host's divisions and their service units.
DIVISIONS = {
    "Medicine": ["Acute Medical Unit", "Emergency Department", "Cardiology Ward", "Respiratory Ward"],
    "Surgery": ["Main Theatres", "Surgical Assessment Unit", "Orthopaedic Ward", "Critical Care Unit"],
    "Women's and Children's": ["Maternity Unit", "Neonatal Unit", "Children's Ward", "Gynaecology Ward"],
    "Clinical Support Services": ["Radiology", "Pathology", "Pharmacy", "Therapies"],
    "Corporate Services": ["Estates and Facilities", "Finance", "Workforce", "Education and Training"],
}

# (name, activity type, default hours, default capacity)
COURSES = [
    ("Immediate Life Support", "C", 8, 12),
    ("Paediatric Immediate Life Support", "C", 8, 12),
    ("Basic Life Support Update", "C", 2, 16),
    ("Sepsis Recognition and Management", "C", 3, 16),
    ("Recognising the Deteriorating Adult", "C", 4, 12),
    ("Recognising the Deteriorating Child", "C", 4, 12),
    ("Venepuncture and Cannulation", "C", 4, 8),
    ("Blood Transfusion Practice", "C", 3, 16),
    ("Safe Medicines Administration", "C", 3, 16),
    ("Intravenous Drug Administration", "C", 6, 10),
    ("Catheterisation", "C", 3, 8),
    ("Nasogastric Tube Insertion", "C", 2, 8),
    ("Tracheostomy Care", "C", 4, 8),
    ("Wound Care and Pressure Ulcer Prevention", "C", 3, 16),
    ("Moving and Handling of People", "C", 3, 12),
    ("Falls Prevention", "C", 2, 16),
    ("Dementia Awareness", "C", 3, 20),
    ("Mental Capacity in Practice", "C", 3, 20),
    ("Safeguarding Adults Level 3", "C", 4, 20),
    ("Safeguarding Children Level 3", "C", 4, 20),
    ("Human Factors in Healthcare", "C", 6, 12),
    ("Simulation: Acute Medical Emergencies", "C", 8, 6),
    ("Simulation: Obstetric Emergencies", "C", 8, 8),
    ("Simulation: Paediatric Emergencies", "C", 8, 6),
    ("Neonatal Life Support", "C", 8, 10),
    ("Introduction to Point of Care Ultrasound", "C", 6, 6),
    ("Clinical Supervision Skills", "C", 6, 12),
    ("Preceptorship Study Day", "C", 7, 20),
    ("Infection Prevention and Control", "C", 2, 20),
    ("Breaking Bad News", "C", 4, 8),
    ("Clinical Skills Drop-in", "S", 2, 6),
    ("Revalidation Support", "S", 1, 8),
    ("OSCE Preparation", "S", 3, 6),
    ("Return to Practice Support", "S", 2, 4),
    ("Practice Assessor Update", "S", 2, 8),
    ("Nursing and Midwifery Conference", "E", 7, 60),
    ("Patient Safety Day", "E", 6, 50),
    ("Allied Health Professions Day", "E", 6, 40),
    ("Simulation Showcase", "E", 4, 30),
    ("Support Worker Celebration Event", "E", 4, 40),
]

# How often each activity type runs, relative to a course.
SESSION_WEIGHTS = {"C": 1.0, "S": 0.6, "E": 0.15}

# Relative share of people in each staff group.
STAFF_GROUP_WEIGHTS = {"01": 12, "02": 6, "03": 30, "04": 10, "05": 4, "06": 3, "07": 20, "08": 10, "09": 5}

# Career steps for the people who change job role.
PROGRESSIONS = {
    "02001": "03007",  # Student Nurse - Adult Branch -> Staff Nurse
    "02005": "03013",  # Student Midwife -> Midwife
    "02029": "01033",  # Medical Student -> Foundation Year 1
    "01033": "01034",  # Foundation Year 1 -> Foundation Year 2
    "01034": "01035",  # Foundation Year 2 -> Specialty Registrar
    "01035": "01005",  # Specialty Registrar -> Consultant
    "03007": "03006",  # Staff Nurse -> Sister or Charge Nurse
    "03006": "03004",  # Sister or Charge Nurse -> Modern Matron
    "07001": "07047",  # Health Care Support Worker -> Nursing Associate
    "07004": "07047",  # Healthcare Assistant -> Nursing Associate
    "07047": "03007",  # Nursing Associate -> Staff Nurse
}

# Job roles that teach: faculty are drawn from host staff in these roles.
FACULTY_ROLES = {"01005", "01032", "01035", "03002", "03004", "03006", "03024", "04037", "04041", "04067", "05003"}

PEOPLE = 2200
HOST_SHARE = 0.77
NO_EMAIL_SHARE = 0.05
ROLE_CHANGE_SHARE = 0.05
SESSIONS = 650
FACULTY_POOL = 120
CANCELLED_SHARE = 0.04
PLACE_CANCELLED_SHARE = 0.05
DNA_RATE = 0.08
DNA_RATE_GROUP_03 = 0.18
FEEDBACK_SHARE = 0.5
COMMENT_SHARE = 0.3
SCORES = [1, 2, 3, 4, 5]
SCORE_WEIGHTS = [3, 7, 20, 40, 30]

CANCELLATION_REASONS = ["Trainer unavailable", "Too few bookings", "Room unavailable", "Operational pressures"]
COMMENTS = [
    "Very practical and well paced.",
    "More hands-on time would help.",
    "Excellent scenarios and debrief.",
    "Room was too small for the group.",
    "Clear and relevant to my role.",
]

PERSON_COLUMNS = ["first_name", "last_name", "email", "organisation_id", "job_role_code", "service_unit_id"]


def insert(cursor, table, row, id_column):
    """Insert one row and return the identity value SQL Server gave it."""
    columns = ", ".join(row)
    placeholders = ", ".join("?" for _ in row)
    cursor.execute(
        f"INSERT INTO {table} ({columns}) OUTPUT INSERTED.{id_column} VALUES ({placeholders})",
        *row.values(),
    )
    return cursor.fetchone()[0]


def at(day, hour, minutes):
    """A time on a given day: the hour plus some minutes."""
    return datetime.combine(day, time(hour)) + timedelta(minutes=minutes)


def make_email(first_name, last_name, taken):
    """first.last@example.org, with a number added when that address is taken."""
    stem = ".".join(re.sub(r"[^a-z]", "", name.lower()) for name in (first_name, last_name))
    email, number = f"{stem}@example.org", 1
    while email in taken:
        number += 1
        email = f"{stem}{number}@example.org"
    taken.add(email)
    return email


def add_organisations(cursor):
    """The host with its divisions and units, and the partners. Returns their ids."""
    host_id = insert(cursor, "core.organisation", {"name": HOST, "is_host": 1}, "organisation_id")
    partner_ids = [
        insert(cursor, "core.organisation", {"name": name, "is_host": 0}, "organisation_id")
        for name in PARTNERS
    ]
    unit_ids = []
    for division, units in DIVISIONS.items():
        division_id = insert(
            cursor, "core.division",
            {"organisation_id": host_id, "name": division, "active_from": UNITS_ACTIVE_FROM},
            "division_id",
        )
        for unit in units:
            unit_ids.append(insert(
                cursor, "core.service_unit",
                {"organisation_id": host_id, "division_id": division_id, "name": unit, "active_from": UNITS_ACTIVE_FROM},
                "service_unit_id",
            ))
    return host_id, partner_ids, unit_ids


def add_courses(cursor):
    """Insert the courses and return them with their defaults."""
    courses = []
    for name, activity_type, hours, capacity in COURSES:
        course_id = insert(
            cursor, "core.course",
            {"name": name, "activity_type_code": activity_type,
             "default_duration_hours": hours, "default_capacity": capacity},
            "course_id",
        )
        courses.append({"id": course_id, "activity_type": activity_type, "hours": hours, "capacity": capacity})
    return courses


def add_people(cursor, rng, fake, host_id, partner_ids, unit_ids):
    """Insert the people. Host staff get a unit; partner staff don't.
    Some people change role: their row holds the new role, and the old one is kept here."""
    cursor.execute("SELECT job_role_code FROM ref.job_role WHERE retired_on IS NULL ORDER BY job_role_code")
    roles_by_group = {}
    for (code,) in cursor.fetchall():
        # Rule 4: a job role code starts with its staff group code.
        roles_by_group.setdefault(code[:2], []).append(code)
    groups = list(STAFF_GROUP_WEIGHTS)
    group_weights = list(STAFF_GROUP_WEIGHTS.values())

    people, emails = [], set()
    for number in range(PEOPLE):
        first_name, last_name = fake.first_name(), fake.last_name()
        on_host = number < PEOPLE * HOST_SHARE
        group = rng.choices(groups, group_weights)[0]
        people.append({
            "first_name": first_name,
            "last_name": last_name,
            "email": None if rng.random() < NO_EMAIL_SHARE else make_email(first_name, last_name, emails),
            "organisation_id": host_id if on_host else rng.choice(partner_ids),
            "job_role_code": rng.choice(roles_by_group[group]),
            "service_unit_id": rng.choice(unit_ids) if on_host else None,
            "old_job_role_code": None,
            "changed_on": None,
        })

    eligible = [person for person in people if person["job_role_code"] in PROGRESSIONS]
    change_days = (ROLE_CHANGES_TO - ROLE_CHANGES_FROM).days
    for person in rng.sample(eligible, round(PEOPLE * ROLE_CHANGE_SHARE)):
        person["old_job_role_code"] = person["job_role_code"]
        person["job_role_code"] = PROGRESSIONS[person["job_role_code"]]
        person["changed_on"] = ROLE_CHANGES_FROM + timedelta(days=rng.randint(0, change_days))

    for person in people:
        row = {column: person[column] for column in PERSON_COLUMNS}
        person["id"] = insert(cursor, "core.person", row, "person_id")
    return people


def add_sessions(cursor, rng, courses):
    """Insert sessions on random weekdays, in date order, taking each course's defaults."""
    weights = [SESSION_WEIGHTS[course["activity_type"]] for course in courses]
    span = (LAST_DAY - FIRST_DAY).days
    planned = []
    while len(planned) < SESSIONS:
        day = FIRST_DAY + timedelta(days=rng.randint(0, span))
        if day.weekday() < 5:  # Monday to Friday
            planned.append((day, rng.choices(courses, weights)[0]))
    planned.sort(key=lambda item: (item[0], item[1]["id"]))

    sessions = []
    for day, course in planned:
        cancelled = rng.random() < CANCELLED_SHARE
        row = {
            "course_id": course["id"],
            "session_date": day,
            "duration_hours": course["hours"],
            "capacity": course["capacity"],
            "status_code": "X" if cancelled else "S",
            "cancellation_reason": rng.choice(CANCELLATION_REASONS) if cancelled else None,
        }
        session_id = insert(cursor, "core.session", row, "session_id")
        sessions.append({"id": session_id, "date": day, "capacity": course["capacity"], "cancelled": cancelled})
    return sessions


def role_held(person, on):
    """The person's job role on a date: the old one before a change."""
    if person["changed_on"] and on < person["changed_on"]:
        return person["old_job_role_code"]
    return person["job_role_code"]


def outcome_for(rng, session, role_code, job_role_code, today):
    """B for sessions still to come, X on cancelled sessions, otherwise A, D or X."""
    if session["cancelled"]:
        return "X"
    if session["date"] > today:
        return "B"
    if role_code != "DEL":
        return "A"
    roll = rng.random()
    if roll < PLACE_CANCELLED_SHARE:
        return "X"
    dna_rate = DNA_RATE_GROUP_03 if job_role_code.startswith("03") else DNA_RATE
    return "D" if roll < PLACE_CANCELLED_SHARE + dna_rate else "A"


def book_sessions(sessions, people, faculty_pool, today, now):
    """Build the participant and feedback rows.

    Each session has its own random generator, so the day the build runs only
    changes the sessions it moves into the past, not who is booked on the rest.
    """
    participants, feedback = [], []
    for number, session in enumerate(sessions):
        rng = random.Random(SEED * 10_000 + number)
        faculty = rng.sample(faculty_pool, 1 + rng.randint(0, 3))
        faculty_ids = {person["id"] for person in faculty}
        candidates = [person for person in people if person["id"] not in faculty_ids]
        delegates = rng.sample(candidates, round(session["capacity"] * rng.uniform(0.35, 1.0)))

        bookings = (
            [(faculty[0], "LEAD")]
            + [(person, "FAC") for person in faculty[1:]]
            + [(person, "DEL") for person in delegates]
        )
        for person, role_code in bookings:
            booked_on = session["date"] - timedelta(days=rng.randint(7, 90))
            booked_at = min(at(booked_on, 9, rng.randint(0, 480)), now)
            # Rule 15: copy the job role held when the booking was made.
            job_role_code = role_held(person, booked_at.date())
            outcome = outcome_for(rng, session, role_code, job_role_code, today)
            signed_in_at = min(at(session["date"], 8, 30 + rng.randint(0, 40)), now) if outcome == "A" else None
            participants.append((
                session["id"], person["id"], role_code, outcome, signed_in_at,
                person["organisation_id"], job_role_code, person["service_unit_id"], booked_at,
            ))

            if role_code == "DEL" and outcome == "A" and rng.random() < FEEDBACK_SHARE:
                submitted_on = session["date"] + timedelta(days=rng.randint(0, 7))
                submitted_at = min(at(submitted_on, 12, rng.randint(0, 300)), now)
                comment = rng.choice(COMMENTS) if rng.random() < COMMENT_SHARE else None
                score = rng.choices(SCORES, SCORE_WEIGHTS)[0]
                feedback.append((session["id"], person["id"], score, comment, submitted_at))
    return participants, feedback


def load(conn):
    """Insert all the synthetic data on an open connection. The caller commits."""
    rng = random.Random(SEED)
    fake = Faker("en_GB")
    fake.seed_instance(SEED)
    today = date.today()
    now = datetime.now().replace(microsecond=0)
    cursor = conn.cursor()

    host_id, partner_ids, unit_ids = add_organisations(cursor)
    courses = add_courses(cursor)
    people = add_people(cursor, rng, fake, host_id, partner_ids, unit_ids)
    sessions = add_sessions(cursor, rng, courses)
    teachers = [
        person for person in people
        if person["organisation_id"] == host_id and person["job_role_code"] in FACULTY_ROLES
    ]
    faculty_pool = rng.sample(teachers, FACULTY_POOL)
    participants, feedback = book_sessions(sessions, people, faculty_pool, today, now)

    # Send the many-row inserts in batches rather than one round trip per row.
    cursor.fast_executemany = True
    cursor.executemany(
        "INSERT INTO core.session_participant "
        "(session_id, person_id, role_code, outcome_code, signed_in_at, "
        "organisation_id, job_role_code, service_unit_id, booked_at) "
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
        participants,
    )
    cursor.executemany(
        "INSERT INTO core.feedback (session_id, person_id, overall_score, comment, submitted_at) "
        "VALUES (?, ?, ?, ?, ?)",
        feedback,
    )

    delegate_rows = sum(1 for row in participants if row[2] == "DEL")
    print(
        f"Synthetic data: {len(people)} people, {len(sessions)} sessions, "
        f"{delegate_rows} delegate rows, {len(participants) - delegate_rows} faculty rows, "
        f"{len(feedback)} feedback"
    )
