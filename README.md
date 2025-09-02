# PetPals: T-SQL Mini Project

Welcome to **PetPals**, a SQL-based mini project that simulates (tries to simulate) a pet adoption platform. This project models the essential entities and operations involved in managing pets, shelters, donations, adoption events, and participants.

##  Overview

PetPals is built using **T-SQL** and includes:

- Relational database schema design
- Table creation with constraints and relationships
- Stored procedures and functions
- Views and complex queries for data analysis

## Database Schema

The project includes the following core tables:

- `Pets`: Stores pet details including breed, age, type, and adoption status
- `Shelters`: Contains shelter names and locations
- `Donations`: Tracks monetary and item-based donations
- `AdoptionEvents`: Details of events organized for pet adoption
- `Participants`: Individuals or shelters participating in events

### Relationships
<img width="1152" height="857" alt="PetPals-Schema-FK" src="https://github.com/user-attachments/assets/e8b7ac1a-b2a5-4cca-90e1-61ae042b82b3" />



## Features
- Everything was done within a 9 hour window (Worked on a cloud instance to run SSMS, it was not ideal, 1/10 would NOT recommend)
- AI-Assisted content (ONLY for inputing Dummy values, and writing the README ^_^)

## Sample Queries

```sql
-- Available pets
SELECT PName, Age, Breed, PType
FROM Pets
WHERE AvailableForAdoption = 1;

-- Total donations by shelter
SELECT s.SName AS ShelterName, ISNULL(SUM(d.DonationAmount), 0) AS TotalDonation
FROM Donations d
JOIN Shelters s ON s.ShelterID = d.ShelterID
GROUP BY s.SName;

-- Update shelter info
EXEC updateShelterInfo @ShelterID = 6, @newName = 'Owlery', @newLocation = 'Mumbai';
```

## Getting Started

To run this project:

1. Open SQL Server Management Studio (SSMS) (Preferably NOT on a Cloud instance)
2. Execute the provided script to initialize the database 
3. Run individual queries or procedures to explore functionality


##  Learnings

- Designing normalized relational schemas, tried to do so at least
- Enforcing data integrity with constraints, did try, didn't work as I intended :)
- Writing reusable procedures and functions
- Aggregating and filtering data with SQL
- How NOT to use SSMS, I've a feeling the runtime-compiler did not like me...

## License

DO what you want, no need for referencing this work 

---

Happy querying! (Co-pilot at it's peak)

P.S. Everything in () is done by a human, the rest is debatable.
