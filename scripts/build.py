"""Drop and recreate HealthcareTrainingDB on the local SQL Server, run sql/ in order,
then load the code lists, the calendar and the synthetic data.

Usage: python scripts/build.py
"""
import csv
import re
import sys
from contextlib import closing
from pathlib import Path

import pyodbc

ROOT = Path(__file__).resolve().parent.parent
SQL_DIR = ROOT / "sql"
DATA_DIR = ROOT / "data"
# data/ holds the calendar and the synthetic data generator, imported below.
sys.path.insert(0, str(DATA_DIR))

CONNECTION = (
    "Driver={ODBC Driver 18 for SQL Server};Server=localhost;Database=HealthcareTrainingDB;"
    "Trusted_Connection=yes;Encrypt=yes;TrustServerCertificate=yes"
)
# The database can't drop itself, so the first script runs from master.
MASTER_CONNECTION = CONNECTION.replace("Database=HealthcareTrainingDB", "Database=master")
DATABASE_SCRIPT = SQL_DIR / "000_database.sql"

# Loaded in this order so each foreign key's parent rows exist first.
REFERENCE_TABLES = [
    ("ref.staff_group", DATA_DIR / "reference" / "staff_group.csv"),
    ("ref.job_role", DATA_DIR / "reference" / "job_role.csv"),
]

# A line holding only GO ends a batch, as in SSMS and sqlcmd.
GO_LINE = re.compile(r"^[ \t]*GO[ \t]*$", re.IGNORECASE | re.MULTILINE)


def run_script(conn, path):
    """Run a .sql file one batch at a time."""
    print(f"Running {path.name}")
    for batch in GO_LINE.split(path.read_text(encoding="utf-8-sig")):
        if batch.strip():
            cursor = conn.execute(batch)
            # Step through every result so an error in a later statement is raised.
            while cursor.nextset():
                pass


def load_reference(conn):
    """Insert the national code lists from data/reference/ into the ref tables."""
    cursor = conn.cursor()
    for table, path in REFERENCE_TABLES:
        print(f"Loading {path.name}")
        with open(path, newline="", encoding="utf-8") as f:
            reader = csv.reader(f)
            columns = next(reader)
            # An empty field is a NULL, e.g. retired_on for a current code.
            rows = [[value or None for value in row] for row in reader]
        placeholders = ", ".join("?" for _ in columns)
        cursor.executemany(
            f"INSERT INTO {table} ({', '.join(columns)}) VALUES ({placeholders})",
            rows,
        )


def load_dim_date(conn):
    """Insert the calendar from data/dim_date.py into rpt.dim_date."""
    import dim_date

    print("Loading the calendar")
    rows = dim_date.rows()
    columns = list(rows[0])
    placeholders = ", ".join("?" for _ in columns)
    conn.cursor().executemany(
        f"INSERT INTO rpt.dim_date ({', '.join(columns)}) VALUES ({placeholders})",
        [list(row.values()) for row in rows],
    )


def build_schema():
    """Recreate the database, create every object, and load the code lists and calendar."""
    with closing(pyodbc.connect(MASTER_CONNECTION, autocommit=True)) as conn:
        run_script(conn, DATABASE_SCRIPT)

    scripts = sorted(path for path in SQL_DIR.glob("*.sql") if path != DATABASE_SCRIPT)
    with closing(pyodbc.connect(CONNECTION, autocommit=True)) as conn:
        for path in scripts:
            run_script(conn, path)
        load_reference(conn)
        load_dim_date(conn)


def load_synthetic():
    """Load the synthetic data from data/generate.py in one transaction."""
    import generate

    with closing(pyodbc.connect(CONNECTION)) as conn:
        generate.load(conn)
        conn.commit()


if __name__ == "__main__":
    build_schema()
    load_synthetic()
    print("Build complete")
