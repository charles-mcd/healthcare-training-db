"""Write docs/data-dictionary.md from the MS_Description extended properties
on every table and column.

Usage: python scripts/data_dictionary.py (after python scripts/build.py)
"""
from contextlib import closing

import pyodbc

from build import CONNECTION, ROOT

OUTPUT = ROOT / "docs" / "data-dictionary.md"

TABLES = """
SELECT s.name, t.name, t.object_id, CAST(ep.value AS nvarchar(4000))
FROM sys.tables AS t
JOIN sys.schemas AS s ON s.schema_id = t.schema_id
LEFT JOIN sys.extended_properties AS ep
    ON ep.class = 1 AND ep.major_id = t.object_id AND ep.minor_id = 0 AND ep.name = 'MS_Description'
ORDER BY CASE s.name WHEN 'ref' THEN 1 WHEN 'core' THEN 2 ELSE 3 END, t.name
"""

COLUMNS = """
SELECT c.name, TYPE_NAME(c.user_type_id), c.max_length, c.precision, c.scale, c.is_nullable,
       CAST(ep.value AS nvarchar(4000))
FROM sys.columns AS c
LEFT JOIN sys.extended_properties AS ep
    ON ep.class = 1 AND ep.major_id = c.object_id AND ep.minor_id = c.column_id AND ep.name = 'MS_Description'
WHERE c.object_id = ?
ORDER BY c.column_id
"""


def type_label(type_name, max_length, precision, scale):
    """Write a column type as it appears in CREATE TABLE, e.g. nvarchar(50)."""
    if type_name in ("nvarchar", "nchar", "varchar", "char"):
        if max_length == -1:
            return f"{type_name}(max)"
        # sys.columns gives the size in bytes, and the n types use two bytes per character.
        length = max_length // 2 if type_name.startswith("n") else max_length
        return f"{type_name}({length})"
    if type_name in ("decimal", "numeric"):
        return f"{type_name}({precision}, {scale})"
    if type_name == "datetime2":
        return f"{type_name}({scale})"
    return type_name


def cell(text):
    """Make text safe for a Markdown table cell."""
    return (text or "").replace("|", "\\|")


def main():
    lines = [
        "# Data dictionary",
        "",
        "Every table and column in HealthcareTrainingDB, generated from the MS_Description",
        "extended properties by `scripts/data_dictionary.py`.",
    ]
    with closing(pyodbc.connect(CONNECTION)) as conn:
        cursor = conn.cursor()
        tables = cursor.execute(TABLES).fetchall()
        for schema_name, table_name, object_id, description in tables:
            lines += [
                "",
                f"## {schema_name}.{table_name}",
                "",
                cell(description),
                "",
                "| Column | Type | Nulls | Description |",
                "| --- | --- | --- | --- |",
            ]
            for name, type_name, max_length, precision, scale, is_nullable, column_description in (
                cursor.execute(COLUMNS, object_id).fetchall()
            ):
                column_type = type_label(type_name, max_length, precision, scale)
                nulls = "Yes" if is_nullable else "No"
                lines.append(f"| `{name}` | {column_type} | {nulls} | {cell(column_description)} |")

    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote docs/{OUTPUT.name}: {len(tables)} tables")


if __name__ == "__main__":
    main()
