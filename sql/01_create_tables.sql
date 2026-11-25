/* =====================================================================
   01_create_tables.sql
   Project : Healthcare Provider Fraud Detection Analysis
   Purpose : Create the database and the four empty tables that will
             receive the cleaned Excel data (imported from CSV files).
   Run     : In SSMS, open this file and press F5.
   Note    : Column names must match the headers in your CSV files.
             SQL Server ignores capital letters, so Stroke = stroke,
             but spelling must match. Edit a name below if yours differs.
   ===================================================================== */

IF DB_ID('FraudAnalysis') IS NULL
    CREATE DATABASE FraudAnalysis;
GO

USE FraudAnalysis;
GO

/* ---------- 1. Provider labels (one row per provider) ---------- */
CREATE TABLE dbo.provider_labels (
    Provider        VARCHAR(20) NOT NULL PRIMARY KEY,
    PotentialFraud  VARCHAR(3)  NOT NULL        -- Yes / No
);
GO

/* ---------- 2. Beneficiary (one row per patient) ---------- */
CREATE TABLE dbo.beneficiary (
    BeneID                           VARCHAR(20) NOT NULL PRIMARY KEY,
    DOB                              DATE        NULL,
    DOD                              DATE        NULL,      -- NULL = alive
    Gender                           VARCHAR(10) NULL,      -- Male / Female
    Race                             VARCHAR(20) NULL,
    RenalDiseaseIndicator            VARCHAR(3)  NULL,      -- Yes / No
    State                            INT         NULL,      -- code, not decoded
    County                           INT         NULL,      -- code, not decoded
    NoOfMonths_PartACov              TINYINT     NULL,
    NoOfMonths_PartBCov              TINYINT     NULL,
    ChronicCond_Alzheimer            VARCHAR(3)  NULL,      -- Yes / No
    ChronicCond_Heartfailure         VARCHAR(3)  NULL,
    ChronicCond_KidneyDisease        VARCHAR(3)  NULL,
    ChronicCond_Cancer               VARCHAR(3)  NULL,
    ChronicCond_ObstrPulmonary       VARCHAR(3)  NULL,
    ChronicCond_Depression           VARCHAR(3)  NULL,
    ChronicCond_Diabetes             VARCHAR(3)  NULL,
    ChronicCond_IschemicHeart        VARCHAR(3)  NULL,
    ChronicCond_Osteoporosis         VARCHAR(3)  NULL,
    ChronicCond_rheumatoidarthritis  VARCHAR(3)  NULL,
    ChronicCond_stroke               VARCHAR(3)  NULL,
    IPAnnualReimbursementAmt         DECIMAL(12,2) NULL,
    IPAnnualDeductibleAmt            DECIMAL(12,2) NULL,
    OPAnnualReimbursementAmt         DECIMAL(12,2) NULL,
    OPAnnualDeductibleAmt            DECIMAL(12,2) NULL,
    NegativeIPFlag                   VARCHAR(3)  NULL,      -- Yes / No
    NegativeOPFlag                   VARCHAR(3)  NULL,
    ZeroPartAFlag                    VARCHAR(3)  NULL,
    ZeroPartBFlag                    VARCHAR(3)  NULL
);
GO

/* ---------- 3. Inpatient claims (one row per claim) ---------- */
CREATE TABLE dbo.inpatient (
    BeneID                  VARCHAR(20) NOT NULL,
    ClaimID                 VARCHAR(20) NOT NULL PRIMARY KEY,
    ClaimStartDt            DATE        NULL,
    ClaimEndDt              DATE        NULL,
    Provider                VARCHAR(20) NOT NULL,
    InscClaimAmtReimbursed  DECIMAL(12,2) NULL,
    AttendingPhysician      VARCHAR(20) NULL,
    OperatingPhysician      VARCHAR(20) NULL,
    OtherPhysician          VARCHAR(20) NULL,
    AdmissionDt             DATE        NULL,
    ClmAdmitDiagnosisCode   VARCHAR(20) NULL,
    DeductibleAmtPaid       DECIMAL(12,2) NULL,
    DischargeDt             DATE        NULL,
    DiagnosisGroupCode      VARCHAR(20) NULL,
    ClmDiagnosisCode_1      VARCHAR(20) NULL,
    ClmDiagnosisCode_2      VARCHAR(20) NULL,
    ClmDiagnosisCode_3      VARCHAR(20) NULL,
    ClmDiagnosisCode_4      VARCHAR(20) NULL,
    ClmDiagnosisCode_5      VARCHAR(20) NULL,
    ClmDiagnosisCode_6      VARCHAR(20) NULL,
    ClmDiagnosisCode_7      VARCHAR(20) NULL,
    ClmDiagnosisCode_8      VARCHAR(20) NULL,
    ClmDiagnosisCode_9      VARCHAR(20) NULL,
    ClmDiagnosisCode_10     VARCHAR(20) NULL,
    ClmProcedureCode_1      VARCHAR(20) NULL,
    ClmProcedureCode_2      VARCHAR(20) NULL,
    ClmProcedureCode_3      VARCHAR(20) NULL,
    ClmProcedureCode_4      VARCHAR(20) NULL,
    ClmProcedureCode_5      VARCHAR(20) NULL
);
GO

/* ---------- 4. Outpatient claims (one row per claim) ---------- */
CREATE TABLE dbo.outpatient (
    BeneID                  VARCHAR(20) NOT NULL,
    ClaimID                 VARCHAR(20) NOT NULL PRIMARY KEY,
    ClaimStartDt            DATE        NULL,
    ClaimEndDt              DATE        NULL,
    Provider                VARCHAR(20) NOT NULL,
    InscClaimAmtReimbursed  DECIMAL(12,2) NULL,
    AttendingPhysician      VARCHAR(20) NULL,
    OperatingPhysician      VARCHAR(20) NULL,
    OtherPhysician          VARCHAR(20) NULL,
    ClmDiagnosisCode_1      VARCHAR(20) NULL,
    ClmDiagnosisCode_2      VARCHAR(20) NULL,
    ClmDiagnosisCode_3      VARCHAR(20) NULL,
    ClmDiagnosisCode_4      VARCHAR(20) NULL,
    ClmDiagnosisCode_5      VARCHAR(20) NULL,
    ClmDiagnosisCode_6      VARCHAR(20) NULL,
    ClmDiagnosisCode_7      VARCHAR(20) NULL,
    ClmDiagnosisCode_8      VARCHAR(20) NULL,
    ClmDiagnosisCode_9      VARCHAR(20) NULL,
    ClmDiagnosisCode_10     VARCHAR(20) NULL,
    ClmProcedureCode_1      VARCHAR(20) NULL,
    ClmProcedureCode_2      VARCHAR(20) NULL,
    ClmProcedureCode_3      VARCHAR(20) NULL,
    ClmProcedureCode_4      VARCHAR(20) NULL,
    DeductibleAmtPaid       DECIMAL(12,2) NULL,
    ClmAdmitDiagnosisCode   VARCHAR(20) NULL
);
GO

