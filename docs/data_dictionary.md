# Data Dictionary

Dictionary for the Healthcare Provider Fraud Detection dataset (Kaggle, Medicare-style claims). It describes the four source files, the keys that link them, and every cleaning step applied.

Last updated: 2026-11-25

## Cleaning status

| File | Rows x columns (raw) | Status | Cleaned table name |
| --- | --- | --- | --- |
| Beneficiary | 138,556 x 25 | Cleaned (complete) | `01_beneficiary_data_final` |
| Inpatient | 40,474 x 30 | Cleaned (complete) | `02_inpatient_data` |
| Outpatient | 517,737 x 27 | Cleaned (complete) | `03_outpatient_data_final` |
| Provider labels | 5,410 x 2 | Cleaned (complete) | `04_provider_labels_final` |

## Keys and relationships

| Key | Where it appears | Role |
| --- | --- | --- |
| `BeneID` | Beneficiary, Inpatient, Outpatient | One row per patient in Beneficiary; many claims per patient in the claim files |
| `Provider` | Inpatient, Outpatient, Provider labels | One row per provider in Provider labels (unique); many claims per provider |
| `ClaimID` | Inpatient, Outpatient | Identifies one claim |

## Code lookup

Meanings follow the CMS (Medicare) convention and are consistent with a check on the data. They are an assumption until confirmed in the CMS DE-SynPUF codebook.

| Column | Code | Meaning |
| --- | --- | --- |
| `ChronicCond_*` (all 11) | 1 | Yes (has the condition) |
| `ChronicCond_*` (all 11) | 2 | No |
| `Gender` | 1 | Male |
| `Gender` | 2 | Female |
| `Race` | 1 | White |
| `Race` | 2 | Black |
| `Race` | 3 | Other |
| `Race` | 4 | Asian (not present in the data; added for future entries) |
| `Race` | 5 | Hispanic |
| `RenalDiseaseIndicator` | Y | Yes |
| `RenalDiseaseIndicator` | 0 | No |

`State` and `County` stay as numeric codes and are not decoded.

## Beneficiary file

One row per patient (138,556 rows). Cleaned table: `01_beneficiary_data_final`.

| Column | Meaning | Raw values | Cleaned form |
| --- | --- | --- | --- |
| `BeneID` | Patient identifier (primary key) | Text ID | Unchanged |
| `DOB` | Date of birth | Date | Date |
| `DOD` | Date of death | Date, or text `NA` when alive | Date; null = alive |
| `Gender` | Patient sex | 1, 2 | Male, Female |
| `Race` | Patient race group | 1, 2, 3, 5 | White, Black, Other, Hispanic (4 = Asian reserved) |
| `RenalDiseaseIndicator` | Renal disease flag | `Y` or 0 (mixed types) | Yes, No |
| `State` | State code | Number (52 codes) | Kept as code |
| `County` | County code | Number (includes 0) | Kept as code |
| `NoOfMonths_PartACov` | Months of Part A (hospital) coverage in the year | 0-12 | Whole number |
| `NoOfMonths_PartBCov` | Months of Part B (medical) coverage in the year | 0-12 | Whole number |
| `ChronicCond_Alzheimer` | Alzheimer's flag | 1, 2 | Yes, No |
| `ChronicCond_HeartFailure` | Heart failure flag | 1, 2 | Yes, No |
| `ChronicCond_KidneyDisease` | Kidney disease flag | 1, 2 | Yes, No |
| `ChronicCond_Cancer` | Cancer flag | 1, 2 | Yes, No |
| `ChronicCond_ObstrPulmonary` | Obstructive pulmonary disease flag | 1, 2 | Yes, No |
| `ChronicCond_Depression` | Depression flag | 1, 2 | Yes, No |
| `ChronicCond_Diabetes` | Diabetes flag | 1, 2 | Yes, No |
| `ChronicCond_IschemicHeart` | Ischemic heart disease flag | 1, 2 | Yes, No |
| `ChronicCond_Osteoporosis` | Osteoporosis flag (renamed; the source spelled it Osteoporasis) | 1, 2 | Yes, No |
| `ChronicCond_RheumatoidArthritis` | Rheumatoid arthritis flag | 1, 2 | Yes, No |
| `ChronicCond_Stroke` | Stroke flag | 1, 2 | Yes, No |
| `IPAnnualReimbursementAmt` | Inpatient amount reimbursed in the year (USD) | Number, min -8,000 | Currency |
| `IPAnnualDeductibleAmt` | Inpatient deductible paid in the year (USD) | Number | Currency |
| `OPAnnualReimbursementAmt` | Outpatient amount reimbursed in the year (USD) | Number, min -70 | Currency |
| `OPAnnualDeductibleAmt` | Outpatient deductible paid in the year (USD) | Number | Currency |
| `NegativeIPFlag` (added) | Yes if `IPAnnualReimbursementAmt` is below 0 | Calculated | Yes, No |
| `NegativeOPFlag` (added) | Yes if `OPAnnualReimbursementAmt` is below 0 | Calculated | Yes, No |
| `ZeroPartAFlag` (added) | Yes if `NoOfMonths_PartACov` is 0 | Calculated | Yes, No |
| `ZeroPartBFlag` (added) | Yes if `NoOfMonths_PartBCov` is 0 | Calculated | Yes, No |

### Cleaning steps performed (Excel Power Query)

| # | Column(s) | Step | Result |
| --- | --- | --- | --- |
| 1 | `BeneID` | Sorted ascending | Rows ordered by patient ID |
| 2 | Disease columns | Renamed to the pattern `ChronicCond_DiseaseName` | Consistent column names |
| 3 | `ChronicCond_Osteoporosis` | Fixed the spelling of the source name (Osteoporasis) | Correct column name |
| 4 | `Gender` | Changed type to text, replaced 1 with Male and 2 with Female | Male / Female |
| 5 | `ChronicCond_*` (all 11) | Changed type to text, replaced 1 with Yes and 2 with No | Yes / No |
| 6 | `Race` | Changed type to text, replaced 1 White, 2 Black, 3 Other, 5 Hispanic, plus 4 Asian for future entries | Text race groups |
| 7 | `RenalDiseaseIndicator` | Replaced the codes (Y, 0) with their text values | Yes / No |
| 8 | `State`, `County` | Left as codes on purpose | Unchanged |
| 9 | Four amount columns | Changed type from whole number to Currency | Currency format |
| 10 | Text columns | Trimmed extra spaces and checked spelling | Done (details not recorded) |
| 11 | Reimbursement amounts, coverage months | Reviewed negative amounts and patients with 0 months of coverage; kept all rows and values unchanged | Kept as is; flags added in steps 16 and 17 |
| 12 | `DOB`, `DOD`, coverage months | Set data types | Done |
| 13 | `BeneID` | Checked for duplicates | Done |
| 14 | All | Closed and loaded as an Excel table named `01_beneficiary_data_final` | Table loaded |
| 15 | `DOD` | Replaced the text `NA` with null, then set the type to Date; all rows kept | Null = patient alive (137,135 rows) |
| 16 | IP and OP reimbursement amounts | Kept negative values unchanged; added `NegativeIPFlag` and `NegativeOPFlag` | Negatives kept as adjustments and flagged |
| 17 | `NoOfMonths_PartACov`, `NoOfMonths_PartBCov` | Kept patients with 0 months; added `ZeroPartAFlag` and `ZeroPartBFlag` | Zero-coverage patients kept and flagged |

## Inpatient file

One row per inpatient claim (40,474 rows, 30 columns). Missing values are stored as the text `NA`.

| Column | Meaning |
| --- | --- |
| `BeneID` | Patient (links to Beneficiary) |
| `ClaimID` | Claim identifier |
| `ClaimStartDt`, `ClaimEndDt` | Claim start and end dates |
| `Provider` | Billing provider (links to Provider labels) |
| `InscClaimAmtReimbursed` | Amount the insurer reimbursed (USD) |
| `AttendingPhysician`, `OperatingPhysician`, `OtherPhysician` | Physician IDs on the claim |
| `AdmissionDt`, `DischargeDt` | Hospital admission and discharge dates |
| `ClmAdmitDiagnosisCode` | Diagnosis code at admission |
| `DeductibleAmtPaid` | Deductible paid by the patient (USD) |
| `DiagnosisGroupCode` | Diagnosis-related group (DRG) code |
| `ClmDiagnosisCode_1` to `_10` | Up to 10 diagnosis codes |
| `ClmProcedureCode_1` to `_5` | Up to 5 procedure codes (`ClmProcedureCode_6` was empty in every row and was dropped) |

Checks on the raw file: no duplicate rows or `ClaimID` values, no negative amounts, no end-before-start or discharge-before-admission dates, and every `BeneID` and `Provider` exists in the beneficiary and provider files. Claim dates run from 2008-11-27 to 2009-12-31. 1,085 claims have a reimbursement of 0.

### Cleaning steps performed (Excel Power Query)

| # | Column(s) | Step | Result |
| --- | --- | --- | --- |
| 1 | `BeneID` | Sorted ascending | Rows ordered by patient ID |
| 2 | Amount columns | Changed type from number to Currency | Currency format |
| 3 | Diagnosis and procedure code columns | Changed type from any to Text | Leading zeros and V/E letters kept |
| 4 | All text `NA` values | Replaced with null | Missing values are real nulls |
| 5 | `ClaimStartDt`, `ClaimEndDt`, `AdmissionDt`, `DischargeDt` | Set type to Date | Done |
| 6 | `ClaimID` | Checked for duplicates | None found |
| 7 | Reimbursement and deductible amounts | Checked for negatives | None found; nothing changed |
| 8 | ID columns (`BeneID`, `ClaimID`, `Provider`, physicians) | Set type to Text | Done |
| 9 | Text columns | Checked for extra spaces | None found |
| 10 | `ClmProcedureCode_6` | Deleted the column (empty in all 40,474 rows) | 29 columns remain |
| 11 | `DeductibleAmtPaid` | Converted the 899 null values to 0 (assumption: `NA` means no deductible) | No nulls; 0 = no deductible |
| 12 | `InscClaimAmtReimbursed` | Kept the 1,085 claims with a reimbursement of 0 | Zero-paid claims kept |
| 13 | Physician columns | Left the nulls as they are (most claims have no operating or other physician) | Nulls kept |
| 14 | Amount columns | Checked that `NA` was replaced before the Currency conversion; no error cells | Done |

## Outpatient file

One row per outpatient claim (517,737 rows, 27 columns). Same columns as Inpatient, minus `AdmissionDt`, `DischargeDt` and `DiagnosisGroupCode`, because there is no hospital stay. `ClmProcedureCode_5` and `ClmProcedureCode_6` were dropped because they were empty in every row, so 25 columns remain.

Checks on the raw file: no duplicate rows or `ClaimID` values, no negative amounts, no end-before-start dates, no extra spaces, and every `BeneID` and `Provider` exists in the beneficiary and provider files. Claim dates run from 2008-12-12 to 2009-12-31. 19,568 claims have a reimbursement of 0 and the largest is 102,500. `ClmAdmitDiagnosisCode` is already empty (not `NA`) in 412,312 rows.

### Cleaning steps performed (Excel Power Query)

| # | Column(s) | Step | Result |
| --- | --- | --- | --- |
| 1 | `BeneID` | Sorted ascending | Rows ordered by patient ID |
| 2 | `ClaimStartDt`, `ClaimEndDt` | Checked that both are in Date format | Done |
| 3 | All columns | Replaced the text `NA` with null | Missing values are real nulls |
| 4 | All columns except dates, IDs, `Provider` and amounts | Changed type to Text | Codes kept as text |
| 5 | Amount columns | Changed to Currency after replacing the `NA` values | Currency format |
| 6 | `ClmProcedureCode_5`, `ClmProcedureCode_6` | Deleted both columns (empty in all 517,737 rows) | 25 columns remain |
| 7 | Reimbursement and deductible amounts | Checked for negatives | None found; nothing changed |
| 8 | `ClmAdmitDiagnosisCode` | Already empty in the raw file (412,312 rows); converted to null like the other missing values | Consistent nulls |
| 9 | `BeneID`, `ClaimID`, `Provider` | Confirmed the type is Text | Done |
| 10 | `InscClaimAmtReimbursed` | Kept the 19,568 claims with a reimbursement of 0 and the largest claims as they are | Rows kept |
| 11 | All | Saved the cleaned table as `03_outpatient_data_final` | Table loaded |

## Provider labels file

One row per provider (5,410 rows); this is the fraud label used in the analysis.

| Column | Meaning | Values |
| --- | --- | --- |
| `Provider` | Provider identifier (unique, primary key) | Text ID |
| `PotentialFraud` | Flag for potentially fraudulent provider | No (4,904), Yes (506) |

Checks on the raw file: 5,410 unique providers, no blanks or `NA` values, no extra spaces. About 9.4% of providers are flagged.

### Cleaning steps performed (Excel Power Query)

| # | Column(s) | Step | Result |
| --- | --- | --- | --- |
| 1 | All | Promoted the first row to headers | Headers are `Provider` and `PotentialFraud` |
| 2 | `Provider`, `PotentialFraud` | Set type to Text | Done |
| 3 | Both columns | Checked for blanks and nulls | None found |
| 4 | `Provider` | Checked for duplicates | None found |
| 5 | `PotentialFraud` | Checked the distinct values | Only Yes and No |
| 6 | All | Checked for extra spaces | None found |
| 7 | All | Saved the cleaned table as `04_provider_labels_final` | Table loaded |

## Data-quality flags

| Flag | Where | Decision |
| --- | --- | --- |
| Missing values are the literal text `NA`, not empty cells | All files | Beneficiary: replaced with null in `DOD`. Other files: pending |
| `DOD` is `NA` for 137,135 rows | Beneficiary | Expected (patient alive); kept as null |
| Negative reimbursement in the raw file (IP: 15 rows, min -8,000; OP: 12 rows, min -70) | Beneficiary | Kept unchanged and flagged |
| 1,000 patients with 0 months Part A; 675 with 0 months Part B | Beneficiary | Kept and flagged |
| `RenalDiseaseIndicator` mixed `Y` and 0 | Beneficiary | Converted to Yes / No |
| `County` contains code 0 | Beneficiary | Treated as unknown; left as code |
