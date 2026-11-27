# Healthcare Provider Fraud Detection Analysis

> Identifying which healthcare providers look suspicious by analysing Medicare-style insurance claims with **Excel (Power Query, charts)** and **SQL Server (T-SQL)**.

![Dashboard preview](images/dashboard.png)

## Project status

- [x] Dataset selected and data dictionary written
- [x] Beneficiary file cleaned (Excel Power Query)
- [x] Inpatient file cleaned
- [x] Outpatient file cleaned
- [x] Provider labels cleaned
- [x] SQL database built and data quality checks run
- [x] SQL analysis queries
- [x] Excel dashboard
- [x] Business questions answered
- [ ] ERD diagram

## Business problem

Health insurers lose a large amount of money to fraudulent billing. Reviewing every provider by hand is not realistic, so analysts look for patterns that separate providers flagged as potentially fraudulent from the rest. This project asks: **which claim and patient characteristics are associated with potentially fraudulent providers, and where should an investigation team look first?**

## Dataset

- **Source:** Kaggle, "Healthcare Provider Fraud Detection Analysis" ([link](https://www.kaggle.com/datasets/rohitrox/healthcare-provider-fraud-detection-analysis)).
- **Content:** Medicare-style claims data in four files.

| File | Rows | What it holds |
| --- | --- | --- |
| Beneficiary | 138,556 | One row per patient: demographics, coverage, chronic conditions, annual amounts |
| Inpatient | 40,474 | One row per hospital-stay claim |
| Outpatient | 517,737 | One row per outpatient claim |
| Provider labels | 5,410 | One row per provider with a `PotentialFraud` label (Yes 506, No 4,904) |

The files link through `BeneID`, `Provider` and `ClaimID`. Full column descriptions are in [`docs/data_dictionary.md`](docs/data_dictionary.md).

> The raw data is **not** stored in this repository because of its size. Download it from Kaggle and place the files in `data/raw/` (see [`data/README.md`](data/README.md)).

## Tools

| Tool | Used for |
| --- | --- |
| Excel (Power Query) | Cleaning and transforming the files, with every step recorded |
| Excel (charts) | Dashboard built from the SQL results |
| SQL Server (T-SQL) | Building the database, data quality checks, analysis queries |
| GitHub | Version control and portfolio |

## Repository structure

```
.
├── README.md
├── data/
│   ├── README.md              # where to download the data and how to use it
│   ├── raw/                   # original Kaggle files (not committed)
│   ├── processed/             # cleaned files (not committed if large)
│   └── sample/                # small sample of each cleaned file
├── sql/                       # numbered scripts: setup, quality checks, analysis
├── excel/                     # analysis workbook and dashboard
├── docs/
│   ├── data_dictionary.md     # columns, codes, cleaning steps
│   ├── data_cleaning_log.md   # what was cleaned and why
│   ├── business_questions.md  # questions and answers
│   └── assumptions_and_limitations.md
└── images/                    # dashboard and ERD screenshots
```

## Data preparation

Cleaning was done in Excel Power Query so every step is recorded in Applied Steps. Beneficiary file summary (full log in the data dictionary):

- Replaced numeric codes with text: gender, race, the 11 chronic condition flags and the renal disease indicator. State and County were left as codes.
- Standardised column names (`ChronicCond_DiseaseName`) and fixed a source spelling error (`Osteoporasis` to `Osteoporosis`).
- Replaced the text `NA` in the date-of-death column with null (blank means the patient is alive) and set correct data types.
- Trimmed extra spaces, checked for duplicate `BeneID` values, and formatted amount columns as currency.
- Kept negative reimbursement amounts (IP: 15 rows, OP: 12 rows) and patients with 0 months of coverage, and added flag columns (`NegativeIPFlag`, `NegativeOPFlag`, `ZeroPartAFlag`, `ZeroPartBFlag`) instead of deleting them.

Inpatient, outpatient and provider files:

- Replaced the text `NA` with null, set dates, IDs, codes and amounts to the correct types, and kept diagnosis and procedure codes as text.
- Deleted columns that were empty in every row (`ClmProcedureCode_6` in inpatient; `ClmProcedureCode_5` and `_6` in outpatient).
- Set the missing inpatient `DeductibleAmtPaid` (899 rows) to 0, an assumption explained in the docs.
- Checked for duplicates, negative amounts, extra spaces and orphan keys: none found.
- Promoted the first row to headers in the provider file; `PotentialFraud` holds only Yes and No.

## Analysis

### SQL

| Script | What it does |
| --- | --- |
| `01_create_tables.sql` | Creates the `FraudAnalysis` database and the four tables with primary keys |
| `02_verify_import.sql` | Checks row counts, totals and orphan keys after loading |
| `03_bulk_import.sql` | Loads the cleaned CSV files with `BULK INSERT` |
| `04_analysis_queries.sql` | Seven analysis queries (CTEs, window functions, `UNION ALL`, date arithmetic, segmentation) with findings |

### Excel

`excel/fraud_dashboard.xlsx` holds a **Data** sheet (results of the SQL queries) and a **Dashboard** sheet with headline numbers and four charts. Orange marks flagged providers, grey marks the rest.

## Key findings

1. **Flagged providers are 9.4% of providers (506 of 5,410) but account for 57.8% of inpatient claims and 53.1% of all money** (295.7 million of 556.5 million).
2. **All 10 providers who received the most money are flagged.**
3. **Flagged providers receive about 11 times more money each** (584,350 vs 53,194) and bill about 6 times more claims, while the average claim size is similar.
4. **Length of stay is almost the same** (5.74 vs 5.56 days), so it is not a useful signal on its own.
5. **Sicker patients cost far more, mostly through inpatient care:** average annual inpatient reimbursement rises from 273 (no chronic conditions) to 15,022 (10 conditions).

> `PotentialFraud` is a provider-level label, so these are associations, not proof of fraud.

## Recommendations

1. **Start with inpatient claims from the largest flagged providers.** About 82% of the money paid to flagged providers is inpatient.
2. **Screen providers by claim volume.** Flagged providers bill about 6 times more claims per provider.
3. **Account for patient mix next.** Compare providers after adjusting for the number of chronic conditions of their patients.

## How to reproduce

1. Download the dataset from Kaggle and place the four files in `data/raw/`.
2. Clean the files as described in `docs/data_cleaning_log.md` and export them as CSV.
3. Run `sql/01_create_tables.sql`, then `sql/03_bulk_import.sql` (update the folder path), then `sql/02_verify_import.sql` on SQL Server.
4. Run `sql/04_analysis_queries.sql` and compare with the dashboard.

## Limitations

- Fraud labels are provider-level, not claim-level, so a flagged provider's legitimate claims are labelled too.
- Code meanings (gender, race, conditions) follow the CMS convention and are an assumption until confirmed in the CMS codebook.
- Claims cover about one year (Nov 2008 to Dec 2009), and there are no investigation outcomes. See [`docs/assumptions_and_limitations.md`](docs/assumptions_and_limitations.md).

## Skills demonstrated

Data cleaning with Power Query, data dictionary and documentation, relational data modelling, T-SQL (joins, CTEs, window functions), dashboard design in Excel, business storytelling.

## Author

**[Saga Haggag]**, pharmacy graduate moving into data analytics.
[LinkedIn](www.linkedin.com/in/saga-mohamed-970111144) | [GitHub](https://github.com/sagahaggag)
