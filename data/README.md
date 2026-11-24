# Data

The data files are **not stored in this repository** because of their size (the outpatient file alone is about 67 MB and has over 500,000 rows). Download the original files from Kaggle and follow the steps below to reproduce the analysis.

## Source

- **Dataset:** Healthcare Provider Fraud Detection Analysis
- **Platform:** Kaggle ([dataset page](https://www.kaggle.com/datasets/rohitrox/healthcare-provider-fraud-detection-analysis))
- **Description:** Medicare-style insurance claims, used to identify providers with potentially fraudulent billing.
- **Licence and terms:** see the dataset page on Kaggle. The data is used here for educational and portfolio purposes only.

## Files

| File | Rows | Columns | Description |
| --- | --- | --- | --- |
| Beneficiary | 138,556 | 25 | One row per patient: demographics, coverage months, chronic conditions, annual amounts |
| Inpatient | 40,474 | 30 | One row per inpatient (hospital stay) claim |
| Outpatient | 517,737 | 27 | One row per outpatient claim |
| Provider labels | 5,410 | 2 | One row per provider, with the `PotentialFraud` label (Yes / No) |

Column meanings, code lookups and data quality notes are in [`../docs/data_dictionary.md`](../docs/data_dictionary.md).

## How the files link together

| Key | Files |
| --- | --- |
| `BeneID` | Beneficiary, Inpatient, Outpatient |
| `Provider` | Inpatient, Outpatient, Provider labels |
| `ClaimID` | Inpatient, Outpatient |

## Folder layout (on your computer)

```
data/
├── README.md        # this file (in the repository)
├── raw/             # original Kaggle files, unchanged (not in the repository)
├── processed/       # cleaned files produced by Power Query / SQL (not in the repository)
└── sample/          # small sample of each cleaned file (optional, in the repository)
```

## How to reproduce

1. Download the dataset from the Kaggle page above (a free Kaggle account is needed).
2. Unzip it and place the four files in `data/raw/`. Do not edit them.
3. Open the Excel workbook in `excel/` and point the Power Query connections to your `data/raw/` folder, then refresh.
4. Run the scripts in `sql/` in numbered order to build and query the database.

## Notes on the raw data

- Missing values are stored as the literal text `NA`, not as empty cells.
- Several columns use numeric codes (for example gender, race and the chronic condition flags). They were decoded during cleaning; the mapping is in the data dictionary and follows the CMS convention.
- Cleaning steps for every file are logged in the data dictionary.
