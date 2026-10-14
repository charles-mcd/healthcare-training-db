# Reference data sources

The national code lists loaded into `ref` by `scripts/build.py`.

| File | Source | Release | Retrieved |
| --- | --- | --- | --- |
| `staff_group.csv` | [STAFF GROUP CODE (TRAINING ACTIVITY CLASSIFICATION)](https://www.datadictionary.nhs.uk/data_elements/staff_group_code_training_activity_classification.html), NHS Data Dictionary | [May 2024 archive](https://archive.datadictionary.nhs.uk/DD%20Release%20May%202024/data_elements/staff_group_code__training_activity_classification_.html) | 2026-09-30 |
| `job_role.csv` | [JOB ROLE CODE](https://www.datadictionary.nhs.uk/attributes/job_role_code.html), NHS Data Dictionary | [May 2024 archive](https://archive.datadictionary.nhs.uk/DD%20Release%20May%202024/attributes/job_role_code.html) | 2026-09-30 |

## Notes

- `staff_group.csv` holds every staff group. Group 10 was retired nationally on 30 June 2023. It is kept, with `retired_on` set, so older records still resolve.
- `job_role.csv` holds only the job roles in use here, 34 of the national list. Each code's first two characters are its staff group code.
- Descriptions are copied as published, with the retirement notes moved into `retired_on`.
- Dates are ISO 8601 (`yyyy-mm-dd`). An empty `retired_on` means the code is current.
- Codes keep their leading zeros. Opening these files in a spreadsheet may strip them.

## Licence

The code lists are © NHS England and are excluded from the MIT licence that covers the rest of this repository.
