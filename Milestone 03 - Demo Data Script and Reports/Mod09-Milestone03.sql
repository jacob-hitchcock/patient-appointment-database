--**********************************************************************************************--
-- Title: Assignment 9 - Milestone 3
-- Author: Jacob Hitchcock
-- Desc: This file inserts data into the PatientAppointmentDB database and creates a new reporting
--       view
-- Change Log: When,Who,What
-- 2021-03-06,JHitchcock,Created File
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

-- Insert data
INSERT INTO Clinics (ClinicName, ClinicPhoneNumber, ClinicAddress, ClinicCity, ClinicState, ClinicZipCode) VALUES 
        ('Cole Wellness Center', '310-680-7287', '67836 Golf View Court', 'Long Beach', 'CA', '90805'),
        ('Dietrich-Schultz Health', '816-816-2773', '20508 Texas Hill', 'Kansas City', 'MO', '64101'),
        ('Mueller-Schoen Clinic', '830-449-3678', '84 Blaine Place', 'San Antonio', 'TX', '78230'),
        ('Anderson-Monahan Family Clinic', '313-870-3939', '41 Hintze Pass', 'Dearborn', 'MI', '48126'),
        ('Rohan-Gerlach 24 Hour Clinic', '404-445-7729', '88826 Mcguire Lane', 'Atlanta', 'GA', '30316');
GO

INSERT INTO Doctors (DoctorFirstName, DoctorLastName, DoctorPhoneNumber, DoctorAddress, DoctorCity, DoctorState, DoctorZipCode) VALUES
        ('Jammal', 'Zanussii', '202-516-3457', '1 Armistice Trail', 'Washington', 'DC', '20404'),
        ('Shayna', 'Domanek', '775-561-4564', '48 Eastlawn Drive', 'Sparks', 'NV', '89436'),
        ('Blondie', 'MacMichael', '718-823-8594', '2100 Welch Alley', 'Jamaica', 'NY', '11480'),
        ('Jerrome', 'MacGovern', '253-418-1007', '34676 Oneill Center', 'Tacoma', 'WA', '98481'),
        ('Roz', 'Mathieson', '317-203-9728', '02133 Garrison Lane', 'Indianapolis', 'IN', '46231'),
        ('Vick', 'Ferriday', '801-748-2427', '42 Surrey Point', 'Salt Lake City', 'UT', '84189'),
        ('Dari', 'Gameson', '915-361-1808', '577 Shopko Circle', 'El Paso', 'TX', '79940'),
        ('Lawry', 'Bonniface', '225-742-2988', '38 Sycamore Trail', 'Baton Rouge', 'LA', '70820'),
        ('Giralda', 'Ingley', '217-203-7746', '42 Graedel Point', 'Springfield', 'IL', '62718'),
        ('Carole', 'Wakerley', '859-443-1098', '3 Southridge Trail', 'Lexington', 'KY', '40546');
GO

INSERT INTO Patients (PatientFirstName, PatientLastName, PatientPhoneNumber, PatientAddress, PatientCity, PatientState, PatientZipCode) VALUES 
        ('Fulton', 'Noulton', '336-779-1006', '58135 Elgar Park', 'Winston Salem', 'NC', '27110'),
        ('Bartholomew', 'Matzke', '704-535-7045', '7544 Cascade Parkway', 'Charlotte', 'NC', '28225'),
        ('Devina', 'Grisdale', '559-668-7707', '329 Algoma Center', 'Fresno', 'CA', '93721'),
        ('Minetta', 'Thunnerclef', '415-847-7459', '4 Clarendon Park', 'San Francisco', 'CA', '94110'),
        ('Iormina', 'Baulcombe', '704-885-9435', '7 Petterle Hill', 'Charlotte', 'NC', '28242'),
        ('Penrod', 'Harden', '315-273-6487', '3 Bashford Hill', 'Rochester', 'NY', '14614'),
        ('Myrlene', 'Benninger', '407-538-4513', '8 Oak Alley', 'Orlando', 'FL', '32854'),
        ('Kele', 'Beavan', '763-376-8798', '3949 Rockefeller Trail', 'Minneapolis', 'MN', '55441'),
        ('Anna', 'Igounet', '313-591-0734', '5495 Troy Court', 'Detroit', 'MI', '48295'),
        ('Emmaline', 'Morison', '920-618-0516', '964 Crownhardt Avenue', 'Green Bay', 'WI', '54313');
GO

INSERT INTO Appointments (AppointmentDateTime, AppointmentPatientID, AppointmentDoctorID, AppointmentClinicID) VALUES 
        ('2020-05-07 09:01:00', 1, 9, 4),
        ('2020-04-23 14:37:00', 9, 1, 4),
        ('2021-02-22 15:27:00', 3, 2, 2),
        ('2021-02-07 22:35:00', 2, 3, 5),
        ('2021-02-18 04:10:00', 2, 5, 5),
        ('2020-10-12 22:30:00', 5, 6, 5),
        ('2021-03-05 06:09:00', 7, 8, 1),
        ('2020-12-10 04:28:00', 8, 7, 5),
        ('2020-09-23 18:17:00', 4, 10, 3),
        ('2021-02-08 18:50:00', 10, 2, 2);
GO

SELECT * FROM vClinics;
SELECT * FROM vDoctors;
SELECT * FROM vPatients;
SELECT * FROM vAppointments;
SELECT * FROM vAppointmentsByPatientsDoctorsAndClinics;
GO

-- New Reporting View
CREATE VIEW vNumAppointmentsUkPatientsByClinic
AS
 SELECT TOP 100000000000 
 COUNT(AppointmentID) AS NumAppointments, COUNT(DISTINCT PatientID) AS NumUniquePatients, COUNT(DISTINCT DoctorID) AS NumUniqueDoctors, 
 ClinicID, ClinicName, ClinicAddress, ClinicCity, ClinicState, ClinicZipCode
 FROM Clinics INNER JOIN Appointments
 ON Clinics.ClinicID = Appointments.AppointmentClinicID
 INNER JOIN Patients
 ON Appointments.AppointmentPatientID = Patients.PatientID
 INNER JOIN Doctors
 ON Appointments.AppointmentDoctorID = Doctors.DoctorID
 GROUP BY ClinicID, ClinicName, ClinicAddress, ClinicCity, ClinicState, ClinicZipCode
 ORDER BY NumAppointments DESC, NumUniquePatients DESC, NumUniqueDoctors DESC;
GO

CREATE VIEW vNumPatientsByDoctor
AS
 SELECT TOP 100000000
 DoctorID, DoctorFirstName, DoctorLastName, COUNT(DISTINCT PatientID) as NumUkPatients
 FROM Clinics INNER JOIN Appointments
 ON Clinics.ClinicID = Appointments.AppointmentClinicID
 INNER JOIN Patients
 ON Appointments.AppointmentPatientID = Patients.PatientID
 INNER JOIN Doctors
 ON Appointments.AppointmentDoctorID = Doctors.DoctorID
 GROUP BY DoctorID, DoctorFirstName, DoctorLastName
 ORDER BY NumUkPatients DESC;
GO

SELECT * FROM vNumAppointmentsUkPatientsByClinic;
SELECT * FROM vNumPatientsByDoctor;
GO
