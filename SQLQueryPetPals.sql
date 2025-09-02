--Task 1
USE master;

GO
DROP DATABASE IF EXISTS PetPals;
GO --Batch END indicator/ Execute the Prev queries

CREATE DATABASE PetPals; 
GO
USE PetPals;

--Task 4 (Handling preixisting UserDefined Tables)
GO
/*
Dosen't handle Foreign constraints
Make sure to drop the Child Table first
This Proc is susceptible to SQL Injection
*/
DROP PROC IF EXISTS DropTableIfExists; 
GO
CREATE PROCEDURE DropTableIfExists @TableName varchar(50)
AS
BEGIN
	EXEC('DROP TABLE '+'IF EXISTS ' + @TableName); --DDL cannot take a var
END;
GO

EXEC DropTableIfExists 'Shelters';
EXEC DropTableIfExists 'Participants';
EXEC DropTableIfExists 'Pets';
EXEC DropTableIfExists 'AdoptionEvents';
EXEC DropTableIfExists 'Donations';

GO

--Task 2
CREATE TABLE Pets(
	PetID INT IDENTITY(1,1) PRIMARY KEY,
	PName varchar(50),
	Age INT CHECK(Age>=0),
	Breed varchar(50),
	PType varchar(50),
	AvaialableForAdoption BIT DEFAULT 0
);

CREATE TABLE Shelters(
	ShelterID INT IDENTITY(1,1) PRIMARY KEY,
	SName varchar(50),
	SLocation varchar(50) NOT NULL 
);

CREATE TABLE Donations(
	DonationID INT IDENTITY(1,1) PRIMARY KEY,
	DonorName varchar(50),
	DonationType varchar(50),
	DonationAmount DECIMAL(10,2),
	DonationItem varchar(50),
	DonationDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE AdoptionEvents(
	EventID INT IDENTITY(1,1) PRIMARY KEY,
	EventName varchar(50),
	EventDate DATETIME DEFAULT GETDATE(),
	ELocation varchar(50) NOT NULL 
);

CREATE TABLE Participants(
	ParticipantID INT IDENTITY(1,1) PRIMARY KEY,
	ParticipantName varchar(50),
	ParticipantType varchar(50) CHECK(ParticipantType IN( 'Adopter','Shelter')),
	EventID INT,
	FOREIGN KEY(EventID) REFERENCES AdoptionEvents(EventID) ON DELETE SET NULL ON UPDATE CASCADE 
);

--Task 3 (Adding Appropriate Unique Constraints)
--Adding FK to Pets Table
ALTER TABLE Pets ADD ShelterID INT NULL;
GO
ALTER TABLE Pets ADD FOREIGN KEY(ShelterID) REFERENCES Shelters(ShelterID) ON DELETE SET NULL ON UPDATE CASCADE;
GO
ALTER TABLE Pets ADD OwnerID INT NULL;
GO
ALTER TABLE Pets ADD FOREIGN KEY(OwnerID) REFERENCES Participants(ParticipantID) ON DELETE SET NULL ON UPDATE CASCADE;
GO

--Adding FK to AdoptionEvents Table
ALTER TABLE AdoptionEvents ADD ShelterID INT NULL;
GO
ALTER TABLE AdoptionEvents ADD FOREIGN KEY(ShelterID) REFERENCES Shelters(ShelterID) ON DELETE NO ACTION;
GO

--Adding FK to Donations Table
ALTER TABLE Donations ADD ShelterID INT NULL;
GO
ALTER TABLE Donations ADD FOREIGN KEY(ShelterID) REFERENCES Shelters(ShelterID) ON DELETE SET NULL ON UPDATE CASCADE;
GO
--Adding UQ to Donations Table
ALTER TABLE Donations
ADD CONSTRAINT CK_DonationType_Data CHECK(
	(DonationType = 'Amount' AND DonationAmount IS NOT NULL AND DonationItem IS NULL) OR
	(DonationType = 'Item' AND DonationAmount IS NULL AND DonationItem IS NOT NULL)
);
GO

--Inserting Values
/*
SELECT * FROM Donations
SELECT * FROM Shelters
SELECT * FROM AdoptionEvents
SELECT * FROM Participants
SELECT * FROM Pets
*/

INSERT INTO Shelters (SName, SLocation) VALUES
('Friends of Furballs', 'Mumbai'),
('Paws & Co.', 'Bangalore'),
('Street Dog Welfare', 'New Delhi'),
('Care for Critters', 'Kolkata'),
('Animal Sanctuary', 'Chennai');

INSERT INTO Donations (DonorName, DonationType, DonationAmount, DonationItem, ShelterID) VALUES
('Navneet Pujari', 'Item', NULL, 'Golden Apple',5),
('Ujjwal Zambad', 'Item', NULL, 'Dog Chew Toy',2),
('Sahil Khune', 'Amount', 9000.00, NULL,1),
('Sonia Desai', 'Item', NULL, 'Pet Blankets',3),
('Rajesh Kumar', 'Amount', 1500.00, NULL,1),
('Priya Sharma', 'Item', NULL, 'Dog Food Bags',2),
('Amit Singh', 'Amount', 5000.00, NULL,4),
('Sonia Desai', 'Item', NULL, 'Pet Blankets',3),
('Vikram Joshi', 'Amount', 1000.00, NULL,4);

INSERT INTO AdoptionEvents (EventName, EventDate, ELocation, ShelterID) VALUES
('Pet Adoption Drive', '2025-09-15', 'Mumbai',1),
('Rescue Dog Meetup', '2025-10-05', 'Bangalore',2),
('Kitten and Puppies Fair', '2025-11-20', 'New Delhi',3),
('Pet Adoption Drive', '2020-09-15', 'Kolkata',4),
('Rescue Dog Meetup', '2023-10-05', 'Chennai',5),
('Kitten and Puppies Fair', '2015-11-20', 'New Delhi',3);

INSERT INTO Participants (ParticipantName, ParticipantType, EventID) VALUES
('Meera', 'Adopter', 1),
('Aditya', 'Adopter', 1),
('Ritu', 'Shelter', 2),
('Bob', 'Shelter', 3),
('Bobby', 'Adopter', 4),
('Friends of Furballs', 'Adopter', 1),
('Paws & Co.', 'Adopter', 2),
('Street Dog Welfare', 'Shelter', 3),
('Care for Critters', 'Shelter',4),
('Animal Sanctuary', 'Shelter',5);

INSERT INTO Pets (PName, Age, Breed, PType, AvaialableForAdoption, ShelterID, OwnerID) VALUES
('Kallu', 2, 'Indian Pariah', 'Dog', 1, 5,NULL),
('Brownie', 1, 'Pug', 'Dog', 1, 5,NULL),
('Billu', 3, 'Bengal Cat', 'Cat', 1,5,NULL),
('Kallu', 2, 'Indian Pariah', 'Dog', 1, 1,1),
('Brownie', 1, 'Pug', 'Dog', 1, 2,2),
('Billu', 3, 'Bengal Cat', 'Cat', 1,3,3),
('Lucky', 5, 'Golden Retriever', 'Dog', 0, 3,4),
('MeowMeow', 4, 'Persian', 'Cat', 1, 4,5),
('Rocky', 1, 'Labrador', 'Dog', 1, 5,1);

--Task 5
SELECT PName,Age,Breed,PType FROM Pets
WHERE AvaialableForAdoption = 1;

--Task 6
--iTVF
GO
CREATE FUNCTION dbo.getParticipantsByEvent(@EventID INT) --Created a Function since, @EventID was required as Para.
RETURNS TABLE 
AS
RETURN(
	SELECT ParticipantID,ParticipantName,ParticipantType,EventID FROM Participants
	WHERE EventID = @EventID
);
GO

DECLARE 
@EventID INT
SET @EventID = 2
SELECT e.EventName, p.ParticipantName, p.ParticipantType FROM AdoptionEvents e
JOIN dbo.getParticipantsByEvent(@EventID) as p
ON p.EventID=e.EventID

--Task 7
GO
CREATE PROC updateShelterInfo
@ShelterID INT,
@newName varchar(50),
@newLocation varchar(50)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM Shelters WHERE ShelterID=@ShelterID)
		UPDATE Shelters
		SET SName = @newName, SLocation=@newLocation
		WHERE ShelterID=@ShelterID;
	ELSE
		PRINT concat('Invalid Shelter ID:',@ShelterID);
END
GO

EXEC updateShelterInfo 6,'Owlery','Mumbai';

--Task 8
SELECT s.SName AS ShelterName, ISNULL(SUM(d.DonationAmount),0) AS TotalDonation FROM Donations d
JOIN Shelters s
ON s.ShelterID=d.ShelterID
GROUP BY s.SName

--Task 9
SELECT p.PName, p.Age,p.Breed,PType FROM Pets p
LEFT JOIN Participants pa
ON pa.ParticipantID = p.OwnerID
WHERE p.OwnerID IS NULL;

--Task 10
SELECT concat(MONTH(DonationDate),' ',YEAR(DonationDate)) AS MonthYear,
ISNULL(SUM(DonationAmount),0) AS TotalDonationAmount FROM Donations
GROUP BY YEAR(DonationDate),MONTH(DonationDate);

--Task 11
SELECT DISTINCT Breed, Age FROM Pets
WHERE (Age BETWEEN 1 AND 3) OR (Age>5);

--Task 12
SELECT p.PetID,p.PName AS PetsAvilableForAdoption,s.SName AS ShelterName FROM Pets p
JOIN Shelters s
ON p.ShelterID=s.ShelterID
WHERE p.AvaialableForAdoption = 1;

--Task 13
DECLARE @city varchar(50)
SET @city = 'Mumbai'

SELECT COUNT(*) AS TotalParticipants,e.ELocation FROM Participants p
JOIN AdoptionEvents e
	ON e.EventID=p.EventID
JOIN Shelters s 
	ON s.ShelterID=e.ShelterID
GROUP BY e.ELocation
HAVING e.ELocation=@city

--Task 14
GO
CREATE VIEW displayBreed AS
SELECT DISTINCT Breed, Age FROM Pets
WHERE (Age BETWEEN 1 AND 5) ;
GO
SELECT * from displayBreed;


--Task 15
SELECT * FROM Pets
WHERE AvaialableForAdoption = 1 AND
OwnerID IS NULL;

--Task 16
SELECT p.PName AS PetName, pr.ParticipantName FROM Pets p
JOIN Participants pr
ON p.OwnerID = pr.ParticipantID
WHERE pr.ParticipantType = 'Adopter';

--Task 17
SELECT s.SName AS ShelterName, COUNT(p.PetID) AS AvailablePets FROM Shelters s
JOIN Pets p
ON p.ShelterID=s.ShelterID
WHERE p.AvaialableForAdoption=1
GROUP BY s.SName;

--Task 18
/*
INSERT INTO Pets(PName,Age,Breed,PType,ShelterID) VALUES
('Tom',9,'Bengal Cat','Cat',5),
('Meowwwth',1,'Bengal Cat','Cat',5),
('Bitti',5,'Bengal Cat','Cat',5);
*/
SELECT p1.PName AS Pet1Name,p2.PName AS Pet2Name, s.SName AS ShelterName,p1.Breed FROM Pets p1
JOIN Pets p2
ON 
	p1.ShelterID = p2.ShelterID AND
	p1.Breed = p2.Breed AND
	p1.PetID < p2.PetID
JOIN Shelters s 
ON p1.ShelterID = s.ShelterID;


--Task 19
SELECT s.ShelterID,s.SName AS ShelterName,e.EventID,e.EventName,e.EventDate FROM Shelters s 
CROSS JOIN AdoptionEvents e
ORDER BY s.ShelterID,e.EventDate;

--Task 20
SELECT TOP 1 s.SName , COUNT(p.PetID) AS NumberOfPets FROM Shelters s
JOIN Pets p
ON 
	p.ShelterID=s.ShelterID
	AND p.AvaialableForAdoption=0
GROUP BY s.ShelterID,s.SName
ORDER BY NumberOfPets DESC;











