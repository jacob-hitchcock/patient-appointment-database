--**********************************************************************************************--
-- Title: Assignment 8 - Milestone 2
-- Author: Jacob Hitchcock
-- Desc: This file designs and creates; 
--       tables, constraints, views, stored procedures, and permissions
--       for the PatientAppointment Database
-- Change Log: When,Who,What
-- 2021-02-27,JHitchcock,Created File, tables, and views
-- 2021-02-28,JHitchcock,Created Stored Procedures
-- 2021-03-01,JHitchcock,Finished Stored Prodecures, permissions and test sprocs
--***********************************************************************************************--
BEGIN TRY
	USE Master;
	IF EXISTS(SELECT Name FROM SysDatabases WHERE Name = 'PatientAppointmentsDB')
	 BEGIN 
	  ALTER DATABASE [PatientAppointmentsDB] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	  DROP DATABASE PatientAppointmentsDB;
	 END
	CREATE DATABASE PatientAppointmentsDB;
END TRY
BEGIN CATCH
	PRINT ERROR_NUMBER();
END CATCH
GO
USE PatientAppointmentsDB;

-- Create Tables -- 
CREATE TABLE Clinics (
	ClinicID INT IDENTITY (1,1)
   ,ClinicName NVARCHAR(100) NOT NULL
   ,ClinicPhoneNumber NVARCHAR(100) NOT NULL
   ,ClinicAddress NVARCHAR(100) NOT NULL
   ,ClinicCity NVARCHAR(100) NOT NULL
   ,ClinicState NVARCHAR(2) NOT NULL
   ,ClinicZipCode NVARCHAR(10) NOT NULL
);
GO

CREATE TABLE Patients (
	PatientID INT IDENTITY (1,1)
   ,PatientFirstName NVARCHAR(100) NOT NULL
   ,PatientLastName NVARCHAR(100) NOT NULL
   ,PatientPhoneNumber NVARCHAR(100) NOT NULL
   ,PatientAddress NVARCHAR(100) NOT NULL
   ,PatientCity NVARCHAR(100) NOT NULL
   ,PatientState NVARCHAR(2) NOT NULL
   ,PatientZipCode NVARCHAR(10) NOT NULL
);
GO

CREATE TABLE Doctors (
	DoctorID INT IDENTITY (1,1)
   ,DoctorFirstName NVARCHAR(100) NOT NULL
   ,DoctorLastName NVARCHAR(100) NOT NULL
   ,DoctorPhoneNumber NVARCHAR(100) NOT NULL
   ,DoctorAddress NVARCHAR(100) NOT NULL
   ,DoctorCity NVARCHAR(100) NOT NULL
   ,DoctorState NVARCHAR(2) NOT NULL
   ,DoctorZipCode NVARCHAR(10) NOT NULL
);
GO

CREATE TABLE Appointments (
	AppointmentID INT IDENTITY (1,1)
   ,AppointmentDateTime DATETIME NOT NULL
   ,AppointmentPatientID INT NOT NULL
   ,AppointmentDoctorID INT NOT NULL
   ,AppointmentClinicID INT NOT NULL
);
GO

-- Add Constraints -- 
ALTER TABLE Clinics
 ADD CONSTRAINT pkClinics
  PRIMARY KEY (ClinicID);
GO

ALTER TABLE Clinics
 ADD CONSTRAINT ukClinicName
  UNIQUE (ClinicName);
GO

ALTER TABLE Clinics
 ADD CONSTRAINT ckClinicPhonePattern
  CHECK (ClinicPhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Clinics
 ADD CONSTRAINT ckClinicZipPattern
  CHECK (ClinicZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR ClinicZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Patients
 ADD CONSTRAINT pkPatients
  PRIMARY KEY (PatientID);
GO

ALTER TABLE Patients
 ADD CONSTRAINT ckPatientPhonePattern
  CHECK (PatientPhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Patients
 ADD CONSTRAINT ckPatientZipPattern
  CHECK (PatientZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR PatientZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Doctors
 ADD CONSTRAINT pkDoctors
  PRIMARY KEY (DoctorID);
GO

ALTER TABLE Doctors
 ADD CONSTRAINT ckDoctorPhonePattern
  CHECK (DoctorPhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Doctors
 ADD CONSTRAINT ckDoctorZipPattern
  CHECK (DoctorZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]' OR DoctorZipCode LIKE '[0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]');
GO

ALTER TABLE Appointments
 ADD CONSTRAINT pkAppointments
  PRIMARY KEY (AppointmentID);
GO

ALTER TABLE Appointments
 ADD CONSTRAINT fkAppointmentsToPatients
  FOREIGN KEY (AppointmentPatientID) REFERENCES Patients(PatientID);
GO

ALTER TABLE Appointments
 ADD CONSTRAINT fkAppointmentsToDoctors
  FOREIGN KEY (AppointmentDoctorID) REFERENCES Doctors(DoctorID);
GO

ALTER TABLE Appointments
 ADD CONSTRAINT fkAppointmentsToClinics
  FOREIGN KEY (AppointmentClinicID) REFERENCES Clinics(ClinicID);
GO

-- Add Views --
-- Base Views --
CREATE VIEW vClinics
AS
 SELECT ClinicID, ClinicName, ClinicPhoneNumber, ClinicAddress, ClinicCity, ClinicState, ClinicZipCode
 FROM Clinics;
GO

CREATE VIEW vPatients
AS
 SELECT PatientID, PatientFirstName, PatientLastName, PatientPhoneNumber, PatientAddress, PatientCity, PatientState, PatientZipCode
 FROM Patients;
GO

CREATE VIEW vDoctors
AS
 SELECT DoctorID, DoctorFirstName, DoctorLastName, DoctorPhoneNumber, DoctorAddress, DoctorCity, DoctorState, DoctorZipCode
 FROM Doctors;
GO

CREATE VIEW vAppointments
AS
 SELECT AppointmentID, AppointmentDateTime, AppointmentPatientID, AppointmentDoctorID, AppointmentClinicID
 FROM Appointments;
GO

-- Final Reporting View --
CREATE VIEW vAppointmentsByPatientsDoctorsAndClinics
AS
 SELECT AppointmentID, FORMAT(AppointmentDateTime, 'MM/dd/yyyy', 'en-us') AS AppointmentDate, FORMAT(AppointmentDateTime, 'HH:mm') AS AppointmentTime, PatientID,
        CONCAT(PatientFirstName, ' ', PatientLastName) AS PatientName, PatientPhoneNumber, PatientAddress, PatientCity, PatientState, PatientZipCode, DoctorID,
        CONCAT(DoctorFirstName, ' ', DoctorLastName) AS DoctorName, DoctorPhoneNumber, DoctorAddress, DoctorCity, DoctorState, DoctorZipCode, ClinicID, ClinicName,
        ClinicPhoneNumber, ClinicAddress, ClinicCity, ClinicState, ClinicZipCode
 FROM Clinics INNER JOIN Appointments
 ON Clinics.ClinicID = Appointments.AppointmentClinicID
 INNER JOIN Patients
 ON Appointments.AppointmentPatientID = Patients.PatientID
 INNER JOIN Doctors
 ON Appointments.AppointmentDoctorID = Doctors.DoctorID;
GO

-- Add Stored Procedures --
-- Inserts --
CREATE PROCEDURE pInsClinics
(@ClinicName NVARCHAR(100)
,@ClinicPhoneNumber NVARCHAR(100)
,@ClinicAddress NVARCHAR(100)
,@ClinicCity NVARCHAR(100)
,@ClinicState NVARCHAR(2)
,@ClinicZipCode NVARCHAR(10))
/* Author: JHitchcock
** Desc: Processes inserts into Clinics table
** Change Log: When,Who,What
** 2021-02-28,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    INSERT INTO Clinics(ClinicName, ClinicPhoneNumber, ClinicAddress, ClinicCity, ClinicState, ClinicZipCode)
    VALUES (@ClinicName, @ClinicPhoneNumber, @ClinicAddress, @ClinicCity, @ClinicState, @ClinicZipCode);
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pInsPatients
(@PatientFirstName NVARCHAR(100)
,@PatientLastName NVARCHAR(100)
,@PatientPhoneNumber NVARCHAR(100)
,@PatientAddress NVARCHAR(100)
,@PatientCity NVARCHAR(100)
,@PatientState NVARCHAR(2)
,@PatientZipCode NVARCHAR(10))
/* Author: JHitchcock
** Desc: Processes inserts into Patients table
** Change Log: When,Who,What
** 2021-02-28,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    INSERT INTO Patients(PatientFirstName, PatientLastName, PatientPhoneNumber, PatientAddress, PatientCity, PatientState, PatientZipCode)
    VALUES (@PatientFirstName, @PatientLastName, @PatientPhoneNumber, @PatientAddress, @PatientCity, @PatientState, @PatientZipCode);
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pInsDoctors
(@DoctorFirstName NVARCHAR(100)
,@DoctorLastName NVARCHAR(100)
,@DoctorPhoneNumber NVARCHAR(100)
,@DoctorAddress NVARCHAR(100)
,@DoctorCity NVARCHAR(100)
,@DoctorState NVARCHAR(2)
,@DoctorZipCode NVARCHAR(10))
/* Author: JHitchcock
** Desc: Processes inserts into Doctors table
** Change Log: When,Who,What
** 2021-02-28,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    INSERT INTO Doctors(DoctorFirstName, DoctorLastName, DoctorPhoneNumber, DoctorAddress, DoctorCity, DoctorState, DoctorZipCode)
    VALUES (@DoctorFirstName, @DoctorLastName, @DoctorPhoneNumber, @DoctorAddress, @DoctorCity, @DoctorState, @DoctorZipCode);
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pInsAppointments
(@AppointmentDateTime DATETIME
,@AppointmentPatientID INT
,@AppointmentDoctorID INT
,@AppointmentClinicID INT)
/* Author: JHitchcock
** Desc: Processes inserts into Appointments table
** Change Log: When,Who,What
** 2021-02-28,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    INSERT INTO Appointments(AppointmentDateTime, AppointmentPatientID, AppointmentDoctorID, AppointmentClinicID)
    VALUES (@AppointmentDateTime, @AppointmentPatientID, @AppointmentDoctorID, @AppointmentClinicID);
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

-- Updates
CREATE PROCEDURE pUpdClinics
(@ClinicID INT
,@ClinicName NVARCHAR(100)
,@ClinicPhoneNumber NVARCHAR(100)
,@ClinicAddress NVARCHAR(100)
,@ClinicCity NVARCHAR(100)
,@ClinicState NVARCHAR(2)
,@ClinicZipCode NVARCHAR(10))
/* Author: JHitchcock
** Desc: Processes updates in Clinics table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    UPDATE Clinics
    SET ClinicName = @ClinicName,
        ClinicPhoneNumber = @ClinicPhoneNumber,
        ClinicAddress = @ClinicAddress,
		ClinicCity = @ClinicCity,
        ClinicState = @ClinicState,
        ClinicZipCode = @ClinicZipCode
    WHERE ClinicID = @ClinicID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pUpdPatients
(@PatientID INT
,@PatientFirstName NVARCHAR(100)
,@PatientLastName NVARCHAR(100)
,@PatientPhoneNumber NVARCHAR(100)
,@PatientAddress NVARCHAR(100)
,@PatientCity NVARCHAR(100)
,@PatientState NVARCHAR(2)
,@PatientZipCode NVARCHAR(10))
/* Author: JHitchcock
** Desc: Processes updates in Patients table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    UPDATE Patients
    SET PatientFirstName = @PatientFirstName,
        PatientLastName = @PatientLastName,
        PatientPhoneNumber = @PatientPhoneNumber,
		PatientAddress = @PatientAddress,
        PatientCity = @PatientCity,
        PatientState = @PatientState,
        PatientZipCode = @PatientZipCode
    WHERE PatientID = @PatientID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pUpdDoctors
(@DoctorID INT
,@DoctorFirstName NVARCHAR(100)
,@DoctorLastName NVARCHAR(100)
,@DoctorPhoneNumber NVARCHAR(100)
,@DoctorAddress NVARCHAR(100)
,@DoctorCity NVARCHAR(100)
,@DoctorState NVARCHAR(2)
,@DoctorZipCode NVARCHAR(10))
/* Author: JHitchcock
** Desc: Processes updates in Doctors table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    UPDATE Doctors
    SET DoctorFirstName = @DoctorFirstName,
        DoctorLastName = @DoctorLastName,
        DoctorPhoneNumber = @DoctorPhoneNumber,
		DoctorAddress = @DoctorAddress,
        DoctorCity = @DoctorCity,
        DoctorState = @DoctorState,
        DoctorZipCode = @DoctorZipCode
    WHERE DoctorID = @DoctorID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pUpdAppointments
(@AppointmentID INT
,@AppointmentDateTime DATETIME
,@AppointmentPatientID INT
,@AppointmentDoctorID INT
,@AppointmentClinicID INT)
/* Author: JHitchcock
** Desc: Processes updates in Appointments table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    UPDATE Appointments
    SET AppointmentDateTime = @AppointmentDateTime,
        AppointmentPatientID = @AppointmentPatientID,
        AppointmentDoctorID = @AppointmentDoctorID,
		AppointmentClinicID = @AppointmentClinicID
    WHERE AppointmentID = @AppointmentID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

-- Deletes
CREATE PROCEDURE pDelClinics
(@ClinicID INT)
/* Author: JHitchcock
** Desc: Processes deletes from Clinics table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    DELETE 
      FROM Clinics 
      WHERE ClinicID = @ClinicID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pDelPatients
(@PatientID INT)
/* Author: JHitchcock
** Desc: Processes deletes from Patients table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    DELETE 
      FROM Patients
      WHERE PatientID = @PatientID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pDelDoctors
(@DoctorID INT)
/* Author: JHitchcock
** Desc: Processes deletes from Doctors table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    DELETE 
      FROM Doctors
      WHERE DoctorID = @DoctorID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

CREATE PROCEDURE pDelAppointments
(@AppointmentID INT)
/* Author: JHitchcock
** Desc: Processes deletes from Appointments table
** Change Log: When,Who,What
** 2021-03-01,JHitchcock,Created stored procedure.
*/
AS
 BEGIN
  DECLARE @RC INT = 0;
  BEGIN TRY
   BEGIN TRANSACTION 
    DELETE 
      FROM Appointments
      WHERE AppointmentID = @AppointmentID;
   COMMIT TRANSACTION;
   SET @RC = +1
  END TRY
  BEGIN CATCH
   IF(@@TRANCOUNT > 0) ROLLBACK TRANSACTION
   PRINT ERROR_MESSAGE()
   SET @RC = -1
  END CATCH
  RETURN @RC;
 END;
GO

-- Set Permissions --
-- Permissions for source tables --
DENY SELECT, INSERT, UPDATE, DELETE ON Clinics TO Public; 
DENY SELECT, INSERT, UPDATE, DELETE ON Patients TO Public; 
DENY SELECT, INSERT, UPDATE, DELETE ON Doctors TO Public; 
DENY SELECT, INSERT, UPDATE, DELETE ON Appointments TO Public; 
GO

-- Permissions for table views
GRANT SELECT ON vClinics TO Public;
GRANT SELECT ON vPatients TO Public;
GRANT SELECT ON vDoctors TO Public;
GRANT SELECT ON vAppointments TO Public;
GRANT SELECT ON vAppointmentsByPatientsDoctorsAndClinics TO Public;
GO

-- Permissions for stored procedures
GRANT EXECUTE ON pInsClinics TO Public;
GRANT EXECUTE ON pUpdClinics TO Public;
GRANT EXECUTE ON pDelClinics TO Public;
GO

GRANT EXECUTE ON pInsPatients TO Public;
GRANT EXECUTE ON pUpdPatients TO Public;
GRANT EXECUTE ON pDelPatients TO Public;
GO

GRANT EXECUTE ON pInsDoctors TO Public;
GRANT EXECUTE ON pUpdDoctors TO Public;
GRANT EXECUTE ON pDelDoctors TO Public;
GO

GRANT EXECUTE ON pInsAppointments TO Public;
GRANT EXECUTE ON pUpdAppointments TO Public;
GRANT EXECUTE ON pDelAppointments TO Public;
GO

-- Test Sprocs
DECLARE @Status INT;
EXEC @Status = pInsClinics
	    @ClinicName = 'Seattle Clinic',
        @ClinicPhoneNumber = '123-456-7890',
        @ClinicAddress = '123 Main St',
		@ClinicCity = 'Seattle',
        @ClinicState = 'WA',
        @ClinicZipCode = '12345'
SELECT CASE @Status
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert failed! Common Issues: Duplicate Data'
  END AS [Status];
  SELECT [The New ID is:] = @@IDENTITY
SELECT * FROM vClinics WHERE ClinicID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pInsPatients
	    @PatientFirstName = 'Gloria',
        @PatientLastName = 'Smith',
        @PatientPhoneNumber = '246-810-1214',
		@PatientAddress = '246 Other St',
        @PatientCity = 'Edmonds',
        @PatientState = 'WA',
        @PatientZipCode = '24680'
SELECT CASE @Status
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert failed! Common Issues: Duplicate Data'
  END AS [Status];
  SELECT [The New ID is:] = @@IDENTITY
SELECT * FROM vPatients WHERE PatientID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pInsDoctors
	    @DoctorFirstName = 'Brenda',
        @DoctorLastName = 'Silver',
        @DoctorPhoneNumber = '135-791-1131',
		@DoctorAddress = '135 Odd Rd',
        @DoctorCity = 'Bellingham',
        @DoctorState = 'WA',
        @DoctorZipCode = '13579'
SELECT CASE @Status
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert failed! Common Issues: Duplicate Data'
  END AS [Status];
  SELECT [The New ID is:] = @@IDENTITY
SELECT * FROM vDoctors WHERE DoctorID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pInsAppointments
	    @AppointmentDateTime = '20210401 15:30:00',
        @AppointmentPatientID = 1,
        @AppointmentDoctorID = 1,
		@AppointmentClinicID = 1
SELECT CASE @Status
  WHEN +1 THEN 'Insert was successful!'
  WHEN -1 THEN 'Insert failed! Common Issues: Duplicate Data'
  END AS [Status];
  SELECT [The New ID is:] = @@IDENTITY
SELECT * FROM vAppointments WHERE AppointmentID = @@IDENTITY;
GO

SELECT * FROM vAppointmentsByPatientsDoctorsAndClinics WHERE AppointmentID = 1;
GO

DECLARE @Status INT;
EXEC @Status = pUpdClinics 
		@ClinicID = @@IDENTITY,
	    @ClinicName = 'Bothell Clinic',
        @ClinicPhoneNumber = '123-456-7890',
        @ClinicAddress = '123 Normal St',
		@ClinicCity = 'Bothell',
        @ClinicState = 'WA',
        @ClinicZipCode = '12345'
SELECT CASE @Status
  WHEN +1 THEN 'Update was successful!'
  WHEN -1 THEN 'Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  END AS [Status];
  SELECT [The Updated ID Was:] = @@IDENTITY
SELECT * FROM vClinics WHERE ClinicID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pUpdPatients 
		@PatientID = @@IDENTITY,
	    @PatientFirstName = 'Gloria',
        @PatientLastName = 'Smithsonian',
        @PatientPhoneNumber = '246-810-1214',
		@PatientAddress = '246 Even Ave',
        @PatientCity = 'Edmonds',
        @PatientState = 'WA',
        @PatientZipCode = '24680'
SELECT CASE @Status
  WHEN +1 THEN 'Update was successful!'
  WHEN -1 THEN 'Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  END AS [Status];
  SELECT [The Updated ID Was:] = @@IDENTITY
SELECT * FROM vPatients WHERE PatientID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pUpdDoctors
		@DoctorID = @@IDENTITY,
	    @DoctorFirstName = 'Brenda',
        @DoctorLastName = 'Gold',
        @DoctorPhoneNumber = '135-791-1131',
		@DoctorAddress = '135 Odd Rd',
        @DoctorCity = 'Tacoma',
        @DoctorState = 'WA',
        @DoctorZipCode = '13579'
SELECT CASE @Status
  WHEN +1 THEN 'Update was successful!'
  WHEN -1 THEN 'Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  END AS [Status];
  SELECT [The Updated ID Was:] = @@IDENTITY
SELECT * FROM vDoctors WHERE DoctorID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pUpdAppointments
		@AppointmentID = @@IDENTITY,
	    @AppointmentDateTime = '20210301 11:30:00',
        @AppointmentPatientID = 1,
        @AppointmentDoctorID = 1,
		@AppointmentClinicID = 1
SELECT CASE @Status
  WHEN +1 THEN 'Update was successful!'
  WHEN -1 THEN 'Update failed! Common Issues: Duplicate Data or Foreign Key Violation'
  END AS [Status];
  SELECT [The Updated ID Was:] = @@IDENTITY
SELECT * FROM vAppointments WHERE AppointmentID = @@IDENTITY;
GO

SELECT * FROM vAppointmentsByPatientsDoctorsAndClinics WHERE AppointmentID = 1;
GO

DECLARE @Status INT;
EXEC @Status = pDelAppointments
    @AppointmentID = @@IDENTITY
SELECT CASE @Status
  WHEN +1 THEN 'Delete was successful!'
  WHEN -1 THEN 'Delete failed! Common Issues: Foreign Key Violation'
  END AS [Status];
  SELECT [The Deleted ID Was:] = @@IDENTITY
SELECT * FROM vAppointments WHERE AppointmentID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pDelClinics
    @ClinicID = @@IDENTITY
SELECT CASE @Status
  WHEN +1 THEN 'Delete was successful!'
  WHEN -1 THEN 'Delete failed! Common Issues: Foreign Key Violation'
  END AS [Status];
  SELECT [The Deleted ID Was:] = @@IDENTITY
SELECT * FROM vClinics WHERE ClinicID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pDelPatients
    @PatientID = @@IDENTITY
SELECT CASE @Status
  WHEN +1 THEN 'Delete was successful!'
  WHEN -1 THEN 'Delete failed! Common Issues: Foreign Key Violation'
  END AS [Status];
  SELECT [The Deleted ID Was:] = @@IDENTITY
SELECT * FROM vPatients WHERE PatientID = @@IDENTITY;
GO

DECLARE @Status INT;
EXEC @Status = pDelDoctors
    @DoctorID = @@IDENTITY
SELECT CASE @Status
  WHEN +1 THEN 'Delete was successful!'
  WHEN -1 THEN 'Delete failed! Common Issues: Foreign Key Violation'
  END AS [Status];
  SELECT [The Deleted ID Was:] = @@IDENTITY
SELECT * FROM vDoctors WHERE DoctorID = @@IDENTITY;
GO

SELECT * FROM vAppointmentsByPatientsDoctorsAndClinics;
GO