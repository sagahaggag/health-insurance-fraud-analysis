# Data Cleaning Log

A summary of what was found in each file and what was done about it. Cleaning was done in Excel Power Query, then each table was exported to CSV and loaded into SQL Server. Column-by-column steps are in [`data_dictionary.md`](data_dictionary.md).

## Beneficiary (138,556 rows) to `01_beneficiary_data_final`

| Issue found | Action | Reason |
| --- | --- | --- |
| Numeric codes for gender, race, 11 chronic conditions and renal disease | Replaced with text (Male/Female, White/Black/Other/Hispanic, Yes/No) | Readable results, no lookup needed |
| Inconsistent column names; `Osteoporasis` misspelled | Renamed to `ChronicCond_DiseaseName`; fixed the spelling | Consistent naming |
| Text `NA` in `DOD` (137,135 rows) | Replaced with null | Patient is alive; null is a real missing value |
| Negative reimbursement amounts (IP 15 rows, OP 12 rows) | Kept, added `NegativeIPFlag` and `NegativeOPFlag` | Likely adjustments; flagged so they can be filtered |
| Patients with 0 months of coverage (1,000 Part A, 675 Part B) | Kept, added `ZeroPartAFlag` and `ZeroPartBFlag` | Valid patients; flagged for analysis |
| Wrong data types, no currency format | Set dates, numbers, text and currency types | Correct calculations |
| `State` and `County` codes | Left as codes | Not needed for the analysis |

## Inpatient (40,474 rows) to `02_inpatient_data_final`

| Issue found | Action | Reason |
| --- | --- | --- |
| Text `NA` in physician, diagnosis and procedure columns | Replaced with null | Real missing values |
| `DeductibleAmtPaid` was `NA` in 899 rows | Set to 0 | Assumption: no deductible applied (the value is 1,068 whenever present) |
| `ClmProcedureCode_6` empty in every row | Deleted the column | No information |
| Diagnosis, procedure and ID columns read as numbers | Set to text | Keeps leading zeros and V/E codes |
| Dates stored as text | Set to Date | Date calculations |
| Duplicates, negative amounts, extra spaces, orphan keys | Checked: none found | Data integrity |

## Outpatient (517,737 rows) to `03_outpatient_data_final`

| Issue found | Action | Reason |
| --- | --- | --- |
| Text `NA` in physician, diagnosis and procedure columns | Replaced with null | Real missing values |
| `ClmProcedureCode_5` and `ClmProcedureCode_6` empty in every row | Deleted both columns | No information |
| `ClmAdmitDiagnosisCode` already empty in 412,312 rows | Converted to null like the other missing values | Consistent nulls |
| Codes and IDs read as numbers | Set to text | Keeps leading zeros and V/E codes |
| Duplicates, negative amounts, extra spaces, orphan keys | Checked: none found | Data integrity |

## Provider labels (5,410 rows) to `04_provider_labels_final`

| Issue found | Action | Reason |
| --- | --- | --- |
| Headers read as data | Promoted the first row to headers | Correct column names |
| Types not set | Set both columns to text | Consistent types |
| Duplicates, blanks, extra spaces; unexpected `PotentialFraud` values | Checked: none found; only Yes and No | Data integrity |

## Loading into SQL Server

- Each cleaned table was exported as CSV (UTF-8), with dates written as `yyyy-mm-dd` and amounts as plain numbers.
- The tables were created in `sql/01_create_tables.sql` and loaded with `sql/03_bulk_import.sql`.
- The import was checked with `sql/02_verify_import.sql` (row counts, totals, orphan checks).-9/*-
