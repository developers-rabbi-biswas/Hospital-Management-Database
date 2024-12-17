CREATE DATABASE Hospital_Managment
ON
(
NAME = 'Hospital_Managment_DATA_1',
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Hospital_Managment_DATA_1',
SIZE = 50MB,
MAXSIZE = 100MB,
FILEGROWTH = 5%
)

LOG ON
(
NAME = 'Hospital_Managment_LOG_1',
FILENAME ='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Hospital_Managment_LOG_1',
SIZE = 25MB,
MAXSIZE = 50MB,
FILEGROWTH =  4%
)

USE Hospital_Managment
GO
---PATIENT TABLE
CREATE TABLE Patient(
Patient_ID INT PRIMARY KEY NOT NULL,
Patient_FName VARCHAR(40) NOT NULL,
Patient_LName VARCHAR(40) NOT NULL,
Phone VARCHAR(40) NOT NULL,
Blood_Type VARCHAR(10) NOT NULL,
Gender VARCHAR(10) NOT NULL,
Condition VARCHAR(40) NOT NULL,
Admission_Date DATE,
Discharge_Date DATE
);
GO
---DEPARTMENT TABLE
CREATE TABLE Department(
Dept_ID INT PRIMARY KEY NOT NULL,
Dept_Head VARCHAR(40) NOT NULL,
Dept_Name VARCHAR(40) NOT NULL,
Emp_Count INT 
);
GO
---STAFF TABLE
CREATE TABLE Staff(
Emp_ID INT PRIMARY KEY NOT NULL,
Emp_FName VARCHAR(40) NOT NULL,
Emp_LName VARCHAR(40) NOT NULL,
Date_Joining DATETIME,
Date_Seperation DATETIME,
Emp_Type VARCHAR(40) NOT NULL,
Email VARCHAR(40) NOT NULL,
Addresss VARCHAR(40) NOT NULL,
Dept_ID INT NOT NULL,
SSN  INT NOT NULL,
FOREIGN KEY(Dept_ID) REFERENCES Department(Dept_ID)
);
GO
---DOCTOR TABLE
CREATE TABLE Doctor(
Doctor_ID INT PRIMARY KEY NOT NULL,
Qualification VARCHAR(40) NOT NULL,
Emp_ID INT NOT NULL,
Specialization VARCHAR(40) NOT NULL,
Dept_ID INT NOT NULL,
FOREIGN KEY (Emp_ID) REFERENCES Staff (Emp_ID),
FOREIGN KEY (Dept_ID) REFERENCES Department (Dept_ID)
)
GO
---NURSE TABLE
CREATE TABLE Nurse(
Nurse_ID INT PRIMARY KEY NOT NULL,
Patient_ID INT NOT NULL,
Emp_ID INT NOT NULL,
Dept_ID INT NOT NULL,
FOREIGN KEY (Patient_ID)  REFERENCES Patient(Patient_ID),
FOREIGN KEY (Emp_ID)  REFERENCES Staff (Emp_ID),
FOREIGN KEY (Dept_ID) REFERENCES Department (Dept_ID)
)
GO
---EMERGENCEY COBTACT TABLE
CREATE TABLE Emergencey_Contact(
Contact_ID INT PRIMARY KEY NOT NULL,
Contact_Name VARCHAR(40) NOT NULL,
Phone VARCHAR(15) NOT NULL,
Relation VARCHAR(40),
Patient_ID INT NOT NULL
FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
)
GO
---PAYROLL TABLE
CREATE TABLE Payroll(
Account_No VARCHAR (40) NOT NULL,
Salary DECIMAL(10,2) NOT NULL,
Bonus  DECIMAL(10,2),
Emp_ID INT NOT NULL,
IBAN VARCHAR(40),
FOREIGN KEY (Emp_ID) REFERENCES Staff(Emp_ID)
)
GO
---LAB SCREENING TABLE
CREATE TABLE Lab_Screening(
Lab_ID INT PRIMARY KEY NOT NULL,
Patient_ID INT NOT NULL,
Technican_ID INT NOT NULL,
Doctor_ID INT NULL,
Test_Cost DECIMAL(10,2),
Date DATE NOT NULL,
FOREIGN KEY (Patient_ID)  REFERENCES Patient(Patient_ID),
FOREIGN KEY (Doctor_ID) REFERENCES Doctor(Doctor_ID)
)
GO
---MEDICINE TABLE
CREATE TABLE Medicine(
Medicne_ID INT PRIMARY KEY NOT NULL,
M_Name VARCHAR(40) NOT NULL,
M_Quantity INT NOT NULL,
M_Cost DECIMAL(10,2)
)
GO
---PRESCRIPTION TABLE
CREATE TABLE Prescription(
Prescription_ID INT PRIMARY KEY NOT NULL,
Patient_ID INT NOT NULL,
Medicne_ID INT NOT NULL,
Date DATE,
Dosage INT,
Doctor_ID INT NOT NULL,
FOREIGN KEY (Patient_ID)  REFERENCES Patient(Patient_ID),
FOREIGN KEY (Doctor_ID)   REFERENCES Doctor (Doctor_ID),
FOREIGN KEY (Medicne_ID) REFERENCES Medicine(Medicne_ID)
)
GO
---MEDICAL HISTORY TABLE
CREATE TABLE Mediacl_History(
Record_ID INT PRIMARY KEY NOT NULL,
Patient_ID INT NOT NULL,
Allargies VARCHAR(50),
Pre_Condition VARCHAR(50),
FOREIGN KEY(Patient_ID) REFERENCES Patient(Patient_ID)
)
GO
---APPOINTMENT TABLE
CREATE TABLE Appointment(
Appt_ID INT PRIMARY KEY NOT NULL,
Scheduled_On DATETIME NOT NULL,
Date DATE,
Doctor_ID INT NOT NULL,
Patient_ID INT NOT NULL,
FOREIGN KEY(Doctor_ID) REFERENCES Doctor(Doctor_ID),
FOREIGN KEY (Patient_ID)REFERENCES Patient(Patient_ID)
)
GO
---ROOM TABLE
CREATE TABLE Room(
Room_ID INT PRIMARY KEY NOT NULL,
Room_Type VARCHAR(50) NOT NULL,
Patient_ID INT NOT NULL,
Room_Cost DECIMAL(10,2),
FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
)
GO
---BILL TABLE
CREATE TABLE Bill(
Bill_ID INT PRIMARY KEY NOT NULL,
Date DATE,
Room_Cost DECIMAL(10,2),
Test_Cost DECIMAL(10,2),
Other_Charge DECIMAL(10,2),
M_Cost DECIMAL(10,2),
Total DECIMAL(10,2),
Patient_ID INT NOT NULL,
Remaining_Balance DECIMAL(10,2),
FOREIGN KEY (Patient_ID) REFERENCES Patient (Patient_ID)
)
GO
------------TRIGGER------------

CREATE TABLE Dept_Record
(
LogID INT PRIMARY KEY,
DeptID INT,
Dept_Head VARCHAR(50),
Dept_Name VARCHAR (50)
)

GO
CREATE TRIGGER Tr_Dept
ON Department
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @DeptID INT
	DECLARE @Dept_Head VARCHAR(50)
	DECLARE @Dept_Name VARCHAR(50)
SELECT @DeptID = DELETED.Dept_ID,
	   @Dept_Head = DELETED.Dept_Head,
	   @Dept_Name = DELETED.Dept_Name
FROM DELETED
IF @DeptID = 1
BEGIN
RAISERROR('You can not this Deleted',16,1)
ROLLBACK
INSERT INTO  Dept_Record
VALUES (@DeptID,@Dept_Head,@Dept_Head, 'INVALID')
END
ELSE
	BEGIN
	DELETE Department
	WHERE Dept_ID = @DeptID
	INSERT INTO Dept_Record
	VALUES(@DeptID, @Dept_Head,@Dept_Name, 'DELETED')
	END
END
GO

------------STORE PROCEDURE---------
CREATE PROCEDURE SP_Department
(
@DeptID INT,
@Dept_head VARCHAR(50),
@Dept_Name VARCHAR(50),
@StatementType VARCHAR(50) = '',
@Emp_Count INT,
@Status VARCHAR(20) OUTPUT
)
AS
BEGIN
	IF @StatementType ='SELECT'
	BEGIN
	SET @Status = 'SELECTED';
	SELECT * FROM Department
	RETURN;
	END

	IF @StatementType = 'INSERT'
	BEGIN
	INSERT INTO Department
	VALUES(@DeptID,@Dept_head,@Dept_Name,@Emp_Count)
	SET @Status = 'INSERTED'
	END

	IF @StatementType = 'UPDATE'
	BEGIN
	UPDATE Department
	SET Dept_head = @Dept_head,
		Dept_Name = @Dept_Name,
		Emp_Count = @Emp_Count
	WHERE Dept_ID = @DeptID
	SET @Status = 'UPDATED'
	END

	IF @StatementType = 'DELETE'
	BEGIN
	DELETE Department
	WHERE Dept_ID = @DeptID
	SET @Status = 'DELETED'
	END
END
GO

-------------FUNCTION-----------
CREATE FUNCTION dbo.CalculateTotalCompensation (@Emp_ID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalCompensation DECIMAL(10, 2);
    
    SELECT @TotalCompensation = Salary + ISNULL(Bonus, 0)
    FROM Payroll
    WHERE Emp_ID = @Emp_ID;
    
    RETURN @TotalCompensation;
END;

------------COMMON TABLE EXPRESSION---------
WITH EmployeeCompensationCTE AS (
    SELECT 
        p.Emp_ID,
        p.Account_No,
        p.Salary,
        p.Bonus,
        dbo.CalculateTotalCompensation(p.Emp_ID) AS TotalCompensation
    FROM Payroll p
)
SELECT *
FROM EmployeeCompensationCTE;
GO


