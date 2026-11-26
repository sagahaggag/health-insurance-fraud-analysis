/* =====================================================================
   04_analysis_queries.sql
   Project : Healthcare Provider Fraud Detection Analysis
   Database: FraudAnalysis (SQL Server / T-SQL)
   Purpose : Analysis queries on the cleaned claims data.
   Tables  : dbo.provider_labels, dbo.beneficiary, dbo.inpatient, dbo.outpatient
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

/* ---------------------------------------------------------------------
   Query 2: How many inpatient claims and how much money come from
            flagged providers?
   Technique: Aggregation + part-to-whole (window function over grouped rows)
   Result   : Flagged providers: 23,402 claims (57.8%) and 241,288,510
              reimbursed (59.1%); not flagged: 17,072 claims (42.2%) and
              167,008,510 reimbursed (40.9%)
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
    ROUND(avg_reimbursed_per_claim, 2)                               AS avg_reimbursed_per_claim,
    ROUND(100.0 * nr_of_claims     / SUM(nr_of_claims)     OVER (), 1) AS pct_of_claims,
    ROUND(100.0 * total_reimbursed / SUM(total_reimbursed) OVER (), 1) AS pct_of_money
FROM flag_summary
ORDER BY PotentialFraud DESC;
GO

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
