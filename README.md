https://youtu.be/_mu5KVerjHU?si=9ukcyIouGXhvctVx
 RaceDay Database System

Project Overview

RaceDay is a relational database system designed to manage events, users, categories, enrolments, routes, and race results.

The database was designed using the provided business requirements and Entity Relationship Diagram (ERD). The project demonstrates the use of relational database concepts, SQL Server, primary keys, foreign keys, relationships, constraints, and an API Endpoint Plan.

 Project Objectives

The main objectives of the RaceDay database are to:

- Store and manage user information.
- Store and manage race events.
- Manage event categories.
- Record user enrolments for events.
- Store race routes.
- Record race results.
- Maintain relationships between the different entities.
- Provide a structured database that can support a RaceDay application and API.

 Database Entities

The RaceDay database contains the following entities:

1. Users
   - Stores information about users participating in RaceDay events.

2. Events
   - Stores information about the different race events.

3. Categories
   - Stores the categories available for events.

4. EventCategories
   - Links events with their applicable categories.

5. Elments
   - Records users who enrol for events.

6. Results
   - Stores the results of participants after completing an event.

7. Routes
   - Stores route information associated with race events.

 Relationships

The database uses primary keys and foreign keys to maintain relationships between the entities.

The main relationships include:

- A user can have multiple enrolments.
- An event can have multiple enrolments.
- An event can have multiple categories.
- A category can be associated with multiple events.
- An event can have race routes.
- Enrolments are connected to race results.
- Results are associated with participants and events.

These relationships help maintain data integrity and reduce unnecessary duplication of data.

 Technologies Used

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL
- Entity Relationship Diagram (ERD)
- REST API Endpoint Planning
- GitHub

Project Structure

   text
RaceDay/
│
├── Database/
│   └── RaceDay.sql
│
├── Docs/
│   ├── RaceDay_ERD.pdf
│   └── RaceDay_API_Endpoint_Plan.pdf
│
├── README.md
│
└── Video/
    └── RaceDay_Presentation.mp4
