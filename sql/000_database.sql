/*
    Drops and recreates HealthcareTrainingDB. Run against master.
*/
USE master;
GO

IF DB_ID(N'HealthcareTrainingDB') IS NOT NULL
BEGIN
    ALTER DATABASE HealthcareTrainingDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HealthcareTrainingDB;
END;
GO

CREATE DATABASE HealthcareTrainingDB
    COLLATE Latin1_General_CI_AS;
GO
