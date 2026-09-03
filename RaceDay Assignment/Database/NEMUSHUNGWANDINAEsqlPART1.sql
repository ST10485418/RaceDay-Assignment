/* ============================================================
   RACEDAY DATABASE - PART 1
   SQL SERVER DATABASE SCRIPT
   ============================================================ */


/* ============================================================
   1. CREATE DATABASE
   ============================================================ */

IF DB_ID('RaceDay') IS NULL
BEGIN
    CREATE DATABASE RaceDay;
END
GO

USE RaceDay;
GO


/* ============================================================
   2. DROP EXISTING TABLES
   Child tables must be dropped before parent tables.
   ============================================================ */

IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL
    DROP TABLE dbo.Results;
GO

IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL
    DROP TABLE dbo.Enrolments;
GO

IF OBJECT_ID('dbo.EventCategories', 'U') IS NOT NULL
    DROP TABLE dbo.EventCategories;
GO

IF OBJECT_ID('dbo.Routes', 'U') IS NOT NULL
    DROP TABLE dbo.Routes;
GO

IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL
    DROP TABLE dbo.Categories;
GO

IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL
    DROP TABLE dbo.Events;
GO

IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL
    DROP TABLE dbo.Users;
GO


/* ============================================================
   3. USERS TABLE
   Stores Organisers and Participants.
   ============================================================ */

CREATE TABLE dbo.Users
(
    UserID INT IDENTITY(1,1) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(20) NULL,
    Role NVARCHAR(20) NOT NULL,
    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Users_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Users PRIMARY KEY (UserID),

    CONSTRAINT UQ_Users_Email UNIQUE (Email),

    CONSTRAINT CK_Users_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);
GO


/* ============================================================
   4. EVENTS TABLE
   Each event belongs to an Organiser.
   ============================================================ */

CREATE TABLE dbo.Events
(
    EventID INT IDENTITY(1,1) NOT NULL,
    OrganiserID INT NOT NULL,
    EventName NVARCHAR(150) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    EventDate DATE NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    DistanceKm DECIMAL(6,2) NOT NULL,
    EventType NVARCHAR(20) NOT NULL,
    IsActive BIT NOT NULL
        CONSTRAINT DF_Events_IsActive DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Events_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Events PRIMARY KEY (EventID),

    CONSTRAINT FK_Events_Users
        FOREIGN KEY (OrganiserID)
        REFERENCES dbo.Users(UserID),

    CONSTRAINT CK_Events_Distance
        CHECK (DistanceKm > 0),

    CONSTRAINT CK_Events_Type
        CHECK (EventType IN ('Run', 'Walk', 'Cycle'))
);
GO


/* ============================================================
   5. CATEGORIES TABLE
   Stores the categories available in RaceDay.
   ============================================================ */

CREATE TABLE dbo.Categories
(
    CategoryID INT IDENTITY(1,1) NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    CategoryType NVARCHAR(50) NOT NULL,
    Description NVARCHAR(300) NULL,

    CONSTRAINT PK_Categories
        PRIMARY KEY (CategoryID),

    CONSTRAINT UQ_Categories_Name_Type
        UNIQUE (CategoryName, CategoryType)
);
GO


/* ============================================================
   6. EVENT CATEGORIES TABLE
   Junction table connecting Events and Categories.
   ============================================================ */

CREATE TABLE dbo.EventCategories
(
    EventCategoryID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL,
    MaxEntries INT NOT NULL,
    StartTime TIME NOT NULL,
    IsActive BIT NOT NULL
        CONSTRAINT DF_EventCategories_IsActive DEFAULT 1,

    CONSTRAINT PK_EventCategories
        PRIMARY KEY (EventCategoryID),

    CONSTRAINT FK_EventCategories_Events
        FOREIGN KEY (EventID)
        REFERENCES dbo.Events(EventID),

    CONSTRAINT FK_EventCategories_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID),

    CONSTRAINT UQ_EventCategories_Event_Category
        UNIQUE (EventID, CategoryID),

    CONSTRAINT CK_EventCategories_EntryFee
        CHECK (EntryFee >= 0),

    CONSTRAINT CK_EventCategories_MaxEntries
        CHECK (MaxEntries > 0)
);
GO


/* ============================================================
   7. ENROLMENTS TABLE
   Records participants entering event categories.
   ============================================================ */

CREATE TABLE dbo.Enrolments
(
    EnrolmentID INT IDENTITY(1,1) NOT NULL,
    UserID INT NOT NULL,
    EventCategoryID INT NOT NULL,

    EnrolmentDate DATETIME2 NOT NULL
        CONSTRAINT DF_Enrolments_Date DEFAULT SYSDATETIME(),

    Status NVARCHAR(30) NOT NULL
        CONSTRAINT DF_Enrolments_Status DEFAULT 'Pending',

    CONSTRAINT PK_Enrolments
        PRIMARY KEY (EnrolmentID),

    CONSTRAINT FK_Enrolments_Users
        FOREIGN KEY (UserID)
        REFERENCES dbo.Users(UserID),

    CONSTRAINT FK_Enrolments_EventCategories
        FOREIGN KEY (EventCategoryID)
        REFERENCES dbo.EventCategories(EventCategoryID),

    CONSTRAINT UQ_Enrolments_User_EventCategory
        UNIQUE (UserID, EventCategoryID),

    CONSTRAINT CK_Enrolments_Status
        CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled'))
);
GO


/* ============================================================
   8. RESULTS TABLE
   Stores participant race results.
   ============================================================ */

CREATE TABLE dbo.Results
(
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrolmentID INT NOT NULL,

    ChipTime TIME NULL,
    GunTime TIME NULL,

    PositionOverall INT NULL,
    PositionCategory INT NULL,

    IsCompleted BIT NOT NULL
        CONSTRAINT DF_Results_IsCompleted DEFAULT 1,

    Notes NVARCHAR(500) NULL,

    RecordedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Results_RecordedAt DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Results
        PRIMARY KEY (ResultID),

    CONSTRAINT UQ_Results_EnrolmentID
        UNIQUE (EnrolmentID),

    CONSTRAINT FK_Results_Enrolments
        FOREIGN KEY (EnrolmentID)
        REFERENCES dbo.Enrolments(EnrolmentID),

    CONSTRAINT CK_Results_PositionOverall
        CHECK (PositionOverall IS NULL OR PositionOverall > 0),

    CONSTRAINT CK_Results_PositionCategory
        CHECK (PositionCategory IS NULL OR PositionCategory > 0)
);
GO


/* ============================================================
   9. ROUTES TABLE
   Stores route information for each event.
   ============================================================ */

CREATE TABLE dbo.Routes
(
    RouteID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    RouteName NVARCHAR(150) NOT NULL,
    DistanceKm DECIMAL(6,2) NOT NULL,
    ElevationGain DECIMAL(8,2) NULL,
    RouteDescription NVARCHAR(1000) NULL,
    MapUrl NVARCHAR(500) NULL,

    CONSTRAINT PK_Routes
        PRIMARY KEY (RouteID),

    CONSTRAINT UQ_Routes_EventID
        UNIQUE (EventID),

    CONSTRAINT FK_Routes_Events
        FOREIGN KEY (EventID)
        REFERENCES dbo.Events(EventID),

    CONSTRAINT CK_Routes_Distance
        CHECK (DistanceKm > 0),

    CONSTRAINT CK_Routes_Elevation
        CHECK (ElevationGain IS NULL OR ElevationGain >= 0)
);
GO


/* ============================================================
   10. INSERT USERS
   2 Organisers and 2 Participants.
   ============================================================ */

INSERT INTO dbo.Users
(
    FirstName,
    LastName,
    Email,
    PasswordHash,
    Phone,
    Role
)
VALUES
(
    'Thabo',
    'Mokoena',
    'thabo@raceday.co.za',
    'PasswordHash_Thabo_123',
    '0711111111',
    'Organiser'
),
(
    'Lerato',
    'Dlamini',
    'lerato@raceday.co.za',
    'PasswordHash_Lerato_123',
    '0733333333',
    'Organiser'
),
(
    'Karabo',
    'Baloi',
    'karabo@example.com',
    'PasswordHash_Karabo_123',
    '0755555555',
    'Participant'
),
(
    'Sipho',
    'Nkosi',
    'sipho@example.com',
    'PasswordHash_Sipho_123',
    '0777777777',
    'Participant'
);
GO


/* ============================================================
   11. INSERT EVENTS
   At least 3 events.
   ============================================================ */

INSERT INTO dbo.Events
(
    OrganiserID,
    EventName,
    Description,
    EventDate,
    Location,
    DistanceKm,
    EventType,
    IsActive
)
VALUES
(
    1,
    'Johannesburg City Run',
    'A road running event through Johannesburg.',
    '2026-10-10',
    'Johannesburg',
    10.00,
    'Run',
    1
),
(
    2,
    'Cape Town Charity Walk',
    'A community charity walk along the Cape Town coastline.',
    '2026-11-14',
    'Cape Town',
    5.00,
    'Walk',
    1
),
(
    1,
    'Pretoria Cycle Challenge',
    'A cycling challenge through Pretoria.',
    '2026-12-05',
    'Pretoria',
    25.00,
    'Cycle',
    1
);
GO


/* ============================================================
   12. INSERT CATEGORIES
   ============================================================ */

INSERT INTO dbo.Categories
(
    CategoryName,
    CategoryType,
    Description
)
VALUES
(
    'Open',
    'Run',
    'Open category for running participants.'
),
(
    'Junior',
    'Run',
    'Junior category for younger running participants.'
),
(
    'Family',
    'Walk',
    'Family category for walking participants.'
),
(
    'Open',
    'Walk',
    'Open category for walking participants.'
),
(
    'Open',
    'Cycle',
    'Open category for cycling participants.'
),
(
    'Junior',
    'Cycle',
    'Junior category for younger cycling participants.'
);
GO


/* ============================================================
   13. INSERT EVENT CATEGORIES
   Connect categories to events.
   ============================================================ */

INSERT INTO dbo.EventCategories
(
    EventID,
    CategoryID,
    EntryFee,
    MaxEntries,
    StartTime,
    IsActive
)
VALUES
(
    1,
    1,
    150.00,
    500,
    '07:00',
    1
),
(
    1,
    2,
    100.00,
    200,
    '07:15',
    1
),
(
    2,
    3,
    80.00,
    300,
    '08:00',
    1
),
(
    2,
    4,
    100.00,
    400,
    '08:15',
    1
),
(
    3,
    5,
    250.00,
    250,
    '06:30',
    1
),
(
    3,
    6,
    150.00,
    100,
    '06:45',
    1
);
GO


/* ============================================================
   14. INSERT ENROLMENTS
   Sample participant enrolments.
   ============================================================ */

INSERT INTO dbo.Enrolments
(
    UserID,
    EventCategoryID,
    Status
)
VALUES
(
    3,
    1,
    'Confirmed'
),
(
    4,
    1,
    'Confirmed'
),
(
    3,
    3,
    'Confirmed'
),
(
    4,
    4,
    'Confirmed'
),
(
    3,
    5,
    'Confirmed'
);
GO


/* ============================================================
   15. INSERT RESULTS
   Sample race results.
   ============================================================ */

INSERT INTO dbo.Results
(
    EnrolmentID,
    ChipTime,
    GunTime,
    PositionOverall,
    PositionCategory,
    IsCompleted,
    Notes
)
VALUES
(
    1,
    '00:52:35',
    '00:53:10',
    1,
    1,
    1,
    'Completed successfully.'
),
(
    2,
    '00:58:20',
    '00:58:55',
    2,
    2,
    1,
    'Completed successfully.'
),
(
    3,
    '01:31:45',
    '01:32:10',
    1,
    1,
    1,
    'Completed successfully.'
);
GO


/* ============================================================
   16. INSERT ROUTES
   One route for each event.
   ============================================================ */

INSERT INTO dbo.Routes
(
    EventID,
    RouteName,
    DistanceKm,
    ElevationGain,
    RouteDescription,
    MapUrl
)
VALUES
(
    1,
    'Johannesburg City 10KM Route',
    10.00,
    120.00,
    'Road route through central Johannesburg and surrounding areas.',
    'https://example.com/johannesburg-10km-route'
),
(
    2,
    'Cape Town 5KM Coastal Walk',
    5.00,
    45.00,
    'Scenic walking route along the Cape Town coastline.',
    'https://example.com/cape-town-5km-route'
),
(
    3,
    'Pretoria 25KM Cycle Route',
    25.00,
    280.00,
    'Cycling route through selected roads around Pretoria.',
    'https://example.com/pretoria-25km-route'
);
GO


/* ============================================================
   17. VERIFY ALL DATA
   ============================================================ */

SELECT * FROM dbo.Users;
SELECT * FROM dbo.Events;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.EventCategories;
SELECT * FROM dbo.Enrolments;
SELECT * FROM dbo.Results;
SELECT * FROM dbo.Routes;
GO


/* ============================================================
   18. VERIFY NUMBER OF TABLES
   ============================================================ */

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
GO