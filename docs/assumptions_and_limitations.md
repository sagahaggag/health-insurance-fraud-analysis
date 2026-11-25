# Assumptions and Limitations

## Assumptions

| # | Area | Assumption or decision | Why |
| --- | --- | --- | --- |
| 1 | Code meanings | Codes for gender, race and the 11 chronic conditions follow the CMS (Medicare) convention: Gender 1 = Male, 2 = Female; Race 1 = White, 2 = Black, 3 = Other, 5 = Hispanic (4 = Asian reserved, not present); chronic conditions 1 = Yes, 2 = No. | The Kaggle files do not include a codebook. The meanings fit the data, but they should be confirmed in the CMS DE-SynPUF codebook. |
| 2 | Missing values | The text `NA` in the source files means a missing value and was replaced with null. | The source files use the literal text `NA`, not empty cells. |
| 3 | Date of death | A null `DOD` means the patient is alive. | 137,135 of 138,556 patients have no date of death. |
| 4 | Inpatient deductible | A missing `DeductibleAmtPaid` in the inpatient file means no deductible and was set to 0. | When the value is present it is 1,068 in every row, so a missing value most likely means none was applied. This is an assumption. |
| 5 | Negative amounts | Negative annual reimbursement amounts in the beneficiary file were kept unchanged and flagged (`NegativeIPFlag`, `NegativeOPFlag`). | They most likely represent adjustments or refunds. IP: 15 rows, OP: 12 rows. |
| 6 | Zero coverage | Patients with 0 months of Part A or Part B coverage were kept and flagged (`ZeroPartAFlag`, `ZeroPartBFlag`). | 1,000 patients have 0 months of Part A and 675 have 0 months of Part B. |
| 7 | Zero-paid claims | Claims with a reimbursement of 0 were kept. | Inpatient: 1,085 claims; outpatient: 19,568 claims. They may be denied or fully offset claims, which is relevant to fraud analysis. |
| 8 | Empty columns | `ClmProcedureCode_6` (inpatient) and `ClmProcedureCode_5` and `_6` (outpatient) were dropped. | They were empty in every row. |
| 9 | State and County | State and County remain numeric codes. | Decoding them was not needed for the analysis. |

## Limitations

- **Provider-level labels.** `PotentialFraud` is assigned to providers, not to individual claims. Every claim from a flagged provider carries the label, including legitimate ones.
- **Class imbalance.** Only 506 of 5,410 providers (about 9.4%) are flagged, so percentages and rates are more reliable than raw counts when comparing groups.
- **Labels are potential, not proven.** A flag marks a provider for review. It is not a confirmed finding of fraud.
- **Short time window.** Claims cover about one year (November 2008 to December 2009), so trends and seasonality are limited.
- **No claim-level fraud indicators.** The data has no investigation outcomes or recovered amounts, so the analysis describes patterns, not causes.
- **Coded fields not decoded.** Diagnosis, procedure and DRG codes were kept as text and not translated into descriptions.
- **Associations only.** Differences between flagged and non-flagged providers show association, not causation.
