/* =====================================================================
   04_analysis_queries.sql
   Project : Healthcare Provider Fraud Detection Analysis
   Database: FraudAnalysis (SQL Server / T-SQL)
   Purpose : Analysis queries on the cleaned claims data.
   Tables  : dbo.provider_labels, dbo.beneficiary, dbo.inpatient, dbo.outpatient
   Note    : PotentialFraud is a provider-level label, so results describe
             association with flagged providers, not proven fraud.
   ===================================================================== */

USE FraudAnalysis;
GO

/* ---------------------------------------------------------------------
   Query 1: How many providers are flagged for potential fraud?
   Technique: Part-to-whole (percentage of total with a window function)
   Result   : Yes 506 (9.35%), No 4,904 (90.65%)
   --------------------------------------------------------------------- */
WITH CTE_providers AS (
    SELECT
        PotentialFraud,
        COUNT(Provider) AS providers
    FROM dbo.provider_labels
    GROUP BY PotentialFraud
)
SELECT
    PotentialFraud,
    providers,
    ROUND(100.0 * providers / SUM(providers) OVER (), 2) AS pct_providers
FROM CTE_providers;
GO
-- Finding: Flagged providers are a small minority: 506 of 5,410 providers (9.35%).


/* ---------------------------------------------------------------------
   Query 2: How many inpatient claims and how much money come from
            flagged providers?
   Technique: Aggregation + part-to-whole (window function over grouped rows)
   Result   : Flagged: 23,402 claims (57.8%), 241,288,510 reimbursed (59.1%)
              Not flagged: 17,072 claims (42.2%), 167,008,510 reimbursed (40.9%)
   --------------------------------------------------------------------- */
WITH flag_summary AS (
    SELECT
        pr.PotentialFraud,
        COUNT(*)                         AS nr_of_claims,
        SUM(inp.InscClaimAmtReimbursed)  AS total_reimbursed,
        AVG(inp.InscClaimAmtReimbursed)  AS avg_reimbursed_per_claim
    FROM dbo.inpatient inp
    INNER JOIN dbo.provider_labels pr
        ON pr.Provider = inp.Provider
    GROUP BY pr.PotentialFraud
)
SELECT
    PotentialFraud,
    nr_of_claims,
    total_reimbursed,
    ROUND(avg_reimbursed_per_claim, 2)                                 AS avg_reimbursed_per_claim,
    ROUND(100.0 * nr_of_claims     / SUM(nr_of_claims)     OVER (), 1) AS pct_of_claims,
    ROUND(100.0 * total_reimbursed / SUM(total_reimbursed) OVER (), 1) AS pct_of_money
FROM flag_summary
ORDER BY PotentialFraud DESC;
GO
-- Finding: Flagged providers generate 57.8% of inpatient claims and 59.1% of inpatient money
-- while being only 9.4% of providers. The average claim is similar (10,311 vs 9,783),
-- so the difference comes from volume per provider, not from bigger claims.


/* ---------------------------------------------------------------------
   Query 3: Which 10 providers received the most money (inpatient and
            outpatient combined), and are they flagged?
   Technique: UNION ALL (stacking tables) + ranking with TOP
   Result   : PRV52019 first with 5,996,050 over 1,961 claims;
              all 10 are flagged Yes
   --------------------------------------------------------------------- */
WITH all_claims AS (
    SELECT ClaimID, Provider, InscClaimAmtReimbursed FROM dbo.inpatient
    UNION ALL
    SELECT ClaimID, Provider, InscClaimAmtReimbursed FROM dbo.outpatient
),
provider_totals AS (
    SELECT
        Provider,
        SUM(InscClaimAmtReimbursed) AS total_reimbursed,
        COUNT(ClaimID)              AS nr_of_claims
    FROM all_claims
    GROUP BY Provider
)
SELECT TOP 10
    pt.Provider,
    pt.total_reimbursed,
    pt.nr_of_claims,
    pr.PotentialFraud
FROM provider_totals pt
INNER JOIN dbo.provider_labels pr
    ON pr.Provider = pt.Provider
ORDER BY pt.total_reimbursed DESC;
GO
-- Finding: The 10 providers receiving the most money are all flagged. PRV52019 is first
-- with 5,996,050 over 1,961 claims, so the largest billers are the first place to investigate.


/* ---------------------------------------------------------------------
   Query 4: How many outpatient claims and how much money come from
            flagged providers?
   Technique: Aggregation + part-to-whole (window function over grouped rows)
   Result   : Flagged: 189,394 claims (36.58%), 54,392,610 reimbursed (36.69%)
              Not flagged: 328,343 claims (63.42%), 93,853,510 reimbursed (63.31%)
   --------------------------------------------------------------------- */
WITH flag_summary AS (
    SELECT
        pr.PotentialFraud,
        COUNT(*)                         AS nr_of_claims,
        SUM(op.InscClaimAmtReimbursed)   AS total_reimbursed,
        AVG(op.InscClaimAmtReimbursed)   AS avg_reimbursed_per_claim
    FROM dbo.outpatient op
    INNER JOIN dbo.provider_labels pr
        ON pr.Provider = op.Provider
    GROUP BY pr.PotentialFraud
)
SELECT
    PotentialFraud,
    nr_of_claims,
    total_reimbursed,
    ROUND(avg_reimbursed_per_claim, 2)                                  AS avg_reimbursed_per_claim,
    ROUND(100.0 * nr_of_claims     / SUM(nr_of_claims)     OVER (), 2)  AS pct_of_claims,
    ROUND(100.0 * total_reimbursed / SUM(total_reimbursed) OVER (), 2)  AS pct_of_money
FROM flag_summary
ORDER BY PotentialFraud DESC;
GO
-- Finding: Flagged providers account for 57.8% of inpatient claims but only 36.6% of
-- outpatient claims. Inpatient claims are worth about 35 times more on average, so about
-- 82% of the money paid to flagged providers comes from inpatient care.


/* ---------------------------------------------------------------------
   Query 5: How long do inpatient stays last, by fraud flag?
   Technique: Date arithmetic (DATEDIFF) + benchmark comparison
              (overall average from totals, not an average of averages)
   Result   : Flagged 5.74 days, not flagged 5.56 days, overall 5.67 days
   --------------------------------------------------------------------- */
WITH stay AS (
    SELECT
        pr.PotentialFraud,
        COUNT(*)                                             AS nr_claims,
        SUM(DATEDIFF(DAY, inp.AdmissionDt, inp.DischargeDt)) AS total_days
    FROM dbo.inpatient inp
    INNER JOIN dbo.provider_labels pr
        ON pr.Provider = inp.Provider
    GROUP BY pr.PotentialFraud
)
SELECT
    PotentialFraud,
    ROUND(1.0 * total_days / nr_claims, 2)                           AS avg_stay_days,
    ROUND(1.0 * SUM(total_days) OVER () / SUM(nr_claims) OVER (), 2) AS overall_avg_stay_days
FROM stay
ORDER BY PotentialFraud DESC;
GO
-- Finding: Average stay is 5.74 days for flagged providers and 5.56 for others (overall 5.67).
-- The gap is about 4 hours, which is too small to treat as a signal on its own.


/* ---------------------------------------------------------------------
   Query 6: How busy and how big are flagged providers compared with others?
   Technique: Normalisation with a two-step aggregation
              (claims to provider level, then provider level to flag level)
   Result   : Flagged: 506 providers, 420.55 claims and 584,350.04 reimbursed per provider
              Not flagged: 4,904 providers, 70.44 claims and 53,193.72 reimbursed per provider
   --------------------------------------------------------------------- */
WITH all_claims AS (
    SELECT Provider, ClaimID, InscClaimAmtReimbursed FROM dbo.inpatient
    UNION ALL
    SELECT Provider, ClaimID, InscClaimAmtReimbursed FROM dbo.outpatient
),
provider_totals AS (
    SELECT
        Provider,
        COUNT(*)                    AS nr_of_claims,
        SUM(InscClaimAmtReimbursed) AS total_reimbursed
    FROM all_claims
    GROUP BY Provider
)
SELECT
    p.PotentialFraud,
    COUNT(*)                              AS nr_of_providers,
    ROUND(AVG(1.0 * c.nr_of_claims), 2)   AS avg_nr_of_claims,
    ROUND(AVG(c.total_reimbursed), 2)     AS avg_total_reimbursed
FROM provider_totals c
INNER JOIN dbo.provider_labels p
    ON c.Provider = p.Provider
GROUP BY p.PotentialFraud
ORDER BY p.PotentialFraud DESC;
GO
-- Finding: Flagged providers have about 6 times more claims per provider (420.55 vs 70.44)
-- and receive about 11 times more money per provider (584,350 vs 53,194), so their claims
-- are also worth more on average. The money ratio matters more, because it is what the insurer pays.


/* ---------------------------------------------------------------------
   Query 7: Does annual cost per patient rise with the number of chronic
            conditions?
   Technique: Segmentation (measure each patient, then group patients
              by that measure)
   Result   : 12 groups (0 to 11 conditions) covering 138,556 patients.
              Average inpatient per patient: 272.80 (0 conditions),
              4,526.89 (5), 15,022.40 (10), 21,206.76 (11).
              Average outpatient per patient: 485.39 (0), 1,644.92 (5),
              2,595.05 (10), 2,178.59 (11).
   --------------------------------------------------------------------- */
WITH conditions AS (
    SELECT
        BeneID,
        IPAnnualReimbursementAmt,
        OPAnnualReimbursementAmt,
        CASE WHEN ChronicCond_Alzheimer           = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_HeartFailure        = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_KidneyDisease       = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_Cancer              = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_ObstrPulmonary      = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_Depression          = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_Diabetes            = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_IschemicHeart       = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_Osteoporosis        = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_RheumatoidArthritis = 'Yes' THEN 1 ELSE 0 END +
        CASE WHEN ChronicCond_Stroke              = 'Yes' THEN 1 ELSE 0 END AS nr_of_conditions
    FROM dbo.beneficiary
)
SELECT
    nr_of_conditions,
    COUNT(*)                                AS patients,
    ROUND(AVG(IPAnnualReimbursementAmt), 2) AS avg_ip_annual_reimbursement,
    ROUND(AVG(OPAnnualReimbursementAmt), 2) AS avg_op_annual_reimbursement
FROM conditions
GROUP BY nr_of_conditions
ORDER BY nr_of_conditions;
GO
-- Finding: Annual cost rises steeply with the number of chronic conditions. Inpatient cost
-- per patient grows from about 273 (no conditions) to over 15,000 (10 conditions), roughly
-- 55 times more, while outpatient cost grows only about 5 times (485 to 2,595). Inpatient care
-- is where the cost of sicker patients comes from. The 11-condition group has only 71 patients.


/* =====================================================================
   Summary of findings
   - Flagged providers are 9.4% of providers but generate 57.8% of inpatient claims.
   - All of the 10 providers with the most money are flagged; they average about 11 times
     more money per provider than other providers.
   - About 82% of the money paid to flagged providers comes from inpatient claims.
   - Length of stay is almost the same for flagged and other providers (5.74 vs 5.56 days).
   - Cost per patient rises steeply with the number of chronic conditions, mostly through
     inpatient care.
   Reminder: PotentialFraud is a provider-level label, so these are associations,
   not proof of fraud.
   ===================================================================== */
