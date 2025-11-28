show databases;
create database miniproj;
use miniproj;

CREATE TABLE Customer (
    CustomerId INT PRIMARY KEY,          -- Unique identifier
    Name VARCHAR(100) NOT NULL,          -- Cannot be NULL
    Address VARCHAR(255) NOT NULL,       -- Cannot be NULL
    PhoneNumber VARCHAR(15) NOT NULL,    -- Cannot be NULL
    Email VARCHAR(100) UNIQUE            -- Must be unique
);

INSERT INTO Customer (CustomerId, Name, Address, PhoneNumber, Email)
VALUES
(1, 'Arun Kumar', '123 MG Road, Chennai', '9876543210', 'arun.kumar@example.com'),
(2, 'Priya Sharma', '45 Anna Nagar, Chennai', '9123456780', 'priya.sharma@example.com'),
(3, 'Rahul Mehta', '78 Park Street, Kolkata', '9988776655', 'rahul.mehta@example.com'),
(4, 'Sneha Reddy', '12 Jubilee Hills, Hyderabad', '9001122334', 'sneha.reddy@example.com'),
(5, 'Vikram Singh', '56 Connaught Place, Delhi', '9112233445', 'vikram.singh@example.com');

CREATE TABLE Meter (
    MeterId INT PRIMARY KEY,                  -- Unique identifier for each meter
    CustomerId INT,                           -- Foreign key referencing Customer
    InstallationDate DATE NOT NULL,           -- Must be a valid date, not null
    LastReadingDate DATE NOT NULL,            -- Must be a valid date, not null
    CONSTRAINT fk_customer
        FOREIGN KEY (CustomerId) 
        REFERENCES Customer(CustomerId)
        ON DELETE CASCADE
);

INSERT INTO Meter (MeterId, CustomerId, InstallationDate, LastReadingDate)
VALUES
(101, 1, '2022-01-15', '2022-11-20'),
(102, 2, '2022-03-10', '2022-11-18'),
(103, 3, '2022-05-05', '2022-11-19'),
(104, 4, '2022-07-22', '2022-11-21'),
(105, 5, '2022-09-01', '2022-11-22');

CREATE TABLE ElectricityUsage (
    UsageId INT PRIMARY KEY,                     -- Unique identifier
    MeterId INT,                                 -- Foreign key referencing Meter
    ReadingDate DATE NOT NULL,                   -- Must be a valid date
    UsageUnits DECIMAL(10,2) CHECK (UsageUnits >= 0),  -- Prevent negative values
    CONSTRAINT fk_meter
        FOREIGN KEY (MeterId) 
        REFERENCES Meter(MeterId)
        ON DELETE CASCADE
);

INSERT INTO ElectricityUsage (UsageId, MeterId, ReadingDate, UsageUnits)
VALUES
(1001, 101, '2022-11-01', 120.50),
(1002, 101, '2022-11-15', 135.75),
(1003, 102, '2022-11-05', 98.00),
(1004, 103, '2022-11-10', 150.25),
(1005, 104, '2022-11-12', 110.00),
(1006, 105, '2022-11-20', 200.00);

CREATE TABLE Bill (
    BillId INT PRIMARY KEY,                         -- Unique identifier
    MeterId INT,                                    -- Foreign key referencing Meter
    BillDate DATE NOT NULL,                         -- Must be a valid date
    AmountDue DECIMAL(10,2) CHECK (AmountDue >= 0), -- Prevent negative values
    DueDate DATE NOT NULL,                          -- Must be a valid date
    Paid BIT NOT NULL DEFAULT 0,                    -- 0 = false, 1 = true
    CONSTRAINT fk_meter_bill
        FOREIGN KEY (MeterId) 
        REFERENCES Meter(MeterId)
        ON DELETE CASCADE
);

INSERT INTO Bill (BillId, MeterId, BillDate, AmountDue, DueDate, Paid)
VALUES
(5001, 101, '2022-11-25', 1200.50, '2022-12-10', 0),
(5002, 102, '2022-11-26', 950.00, '2022-12-11', 1),
(5003, 103, '2022-11-27', 1500.75, '2022-12-12', 0),
(5004, 104, '2022-11-28', 1100.00, '2022-12-13', 1),
(5005, 105, '2022-11-29', 2000.00, '2022-12-14', 0);

CREATE TABLE Payment (
    PaymentId INT PRIMARY KEY,                        -- Unique identifier
    BillId INT,                                       -- Foreign key referencing Bill
    PaymentDate DATE NOT NULL,                        -- Must be a valid date
    AmountPaid DECIMAL(10,2) CHECK (AmountPaid >= 0), -- Prevent negative values
    CONSTRAINT fk_bill_payment
        FOREIGN KEY (BillId) 
        REFERENCES Bill(BillId)
        ON DELETE CASCADE
);

INSERT INTO Payment (PaymentId, BillId, PaymentDate, AmountPaid)
VALUES
(7001, 5001, '2022-12-05', 1200.50),
(7002, 5002, '2022-12-06', 950.00),
(7003, 5003, '2022-12-07', 1500.75),
(7004, 5004, '2022-12-08', 1100.00),
(7005, 5005, '2022-12-09', 2000.00);

SELECT * FROM Customer;
SELECT * FROM Meter;
SELECT * FROM ElectricityUsage;
SELECT * FROM Bill;
SELECT * FROM Payment;

SELECT 
    MeterId,
    SUM(UsageUnits) AS TotalUsage
FROM ElectricityUsage
GROUP BY MeterId
HAVING SUM(UsageUnits) > 200;

SELECT 
    c.CustomerId,
    c.Name,
    SUM(b.AmountDue) AS TotalUnpaidAmount
FROM Customer c
JOIN Meter m ON c.CustomerId = m.CustomerId
JOIN Bill b ON m.MeterId = b.MeterId
WHERE b.Paid = 0   -- Only unpaid bills
GROUP BY c.CustomerId, c.Name
ORDER BY TotalUnpaidAmount DESC;

SELECT 
    b.BillId,
    b.MeterId,
    b.BillDate,
    b.AmountDue,
    b.DueDate,
    CASE 
        WHEN p.PaymentId IS NOT NULL THEN 'Paid'
        ELSE 'Unpaid'
    END AS PaymentStatus
FROM Bill b
LEFT JOIN Payment p ON b.BillId = p.BillId
ORDER BY b.BillDate ASC;

SELECT DISTINCT 
    c.CustomerId,
    c.Name,
    c.Address,
    c.PhoneNumber,
    c.Email
FROM Customer c
JOIN Meter m ON c.CustomerId = m.CustomerId
WHERE m.InstallationDate > '2023-12-31';

SELECT 
    m.MeterId,
    m.LastReadingDate,
    SUM(eu.UsageUnits) AS TotalUsage
FROM Meter m
JOIN ElectricityUsage eu ON m.MeterId = eu.MeterId
GROUP BY m.MeterId, m.LastReadingDate
ORDER BY TotalUsage DESC;


