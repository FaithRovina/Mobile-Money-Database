DROP DATABASE IF EXISTS mobile_money;
CREATE DATABASE IF NOT EXISTS mobile_money;

USE mobile_money;
-- Users Table
CREATE TABLE Users (
    UserID INT NOT NULL UNIQUE,
    Name VARCHAR(255),
    DOB DATE,
    GhanaCard VARCHAR(20),
    PhoneNumber INT UNIQUE,
    PRIMARY KEY (UserID, PhoneNumber)
);

CREATE TABLE Branches(
    BranchID INT PRIMARY KEY,
    Address VARCHAR(255),
    City VARCHAR(50),
    Region VARCHAR(50)
);

-- Add an index to the PhoneNumber column
CREATE INDEX idx_users_phone_number ON Users(PhoneNumber);

CREATE TABLE NextofKin(
    Name   VARCHAR(50),
    DOB   DATE,
    GhanaCard VARCHAR (50),
    UserID INT,
    FOREIGN KEY (UserID) REFERENCES Users(UserID)

);

CREATE TABLE Security (
    SecurityID INT PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    TwoFactorAuthenticationStatus BOOLEAN,
    SecurityQuestionsAnswers VARCHAR(255),
    FOREIGN KEY (UserID) REFERENCES Users(UserID)
);


CREATE TABLE Accounts(
    AccountNumber INT PRIMARY KEY,
    AccountType ENUM('Agent', 'Merchant', 'Personal'),
    UserID INT NOT NULL UNIQUE,
    BranchID INT NOT NULL,
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (BranchID) REFERENCES Branches(BranchID)
);


CREATE TABLE Agents(
    AgentNumber INT PRIMARY KEY,
    AccountNumber INT NOT NULL UNIQUE,
    FOREIGN KEY (AccountNumber) REFERENCES Accounts(AccountNumber)
);

CREATE TABLE  Merchants(
    MerchantNumber INT PRIMARY KEY,
    AccountNumber INT NOT NULL UNIQUE,
    FOREIGN KEY (AccountNumber) REFERENCES Accounts(AccountNumber)
);

CREATE TABLE Personal(
    PhoneNumber INT PRIMARY KEY,
    AccountNumber INT NOT NULL UNIQUE,
    FOREIGN KEY (AccountNumber) REFERENCES Accounts(AccountNumber),
    FOREIGN KEY (PhoneNumber) REFERENCES Users(PhoneNumber)
);

CREATE TABLE Wallets(
   Balance DECIMAL(10,2),
   AccountNumber INT NOT NULL UNIQUE,
   FOREIGN KEY (AccountNumber) REFERENCES Accounts(AccountNumber)

);

CREATE TABLE ServiceProviders(
    ServiceProviderID INT PRIMARY KEY,
    Name VARCHAR(255),
    ContactInfo VARCHAR(255)
);


CREATE TABLE Transactions(
    TransactionID INT PRIMARY KEY,
    Amount DECIMAL(10,2),
    TransactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    AccountNumber INT NOT NULL,
    FOREIGN KEY (AccountNumber) REFERENCES Accounts(AccountNumber)
);

CREATE TABLE Deposits(
    TransactionID INT NOT NULL UNIQUE,
    PhoneNumber INT NOT NULL,
    Amount DECIMAL(10,2),
    FOREIGN KEY (PhoneNumber) REFERENCES Users(PhoneNumber),
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);

CREATE TABLE Withdrawals(
    TransactionID INT NOT NULL UNIQUE,
    AccountNumber INT NOT NULL,
    Amount DECIMAL(10,2),
    FOREIGN KEY (AccountNumber) REFERENCES Accounts(AccountNumber),
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);


CREATE TABLE MoneyTransfers(
    TransactionID INT NOT NULL UNIQUE,
    SenderID INT NOT NULL,
    ReceiverID INT NOT NULL,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID),
    FOREIGN KEY (SenderID) REFERENCES Accounts(AccountNumber),
    FOREIGN KEY (ReceiverID) REFERENCES Accounts(AccountNumber)
);

CREATE TABLE AirtimePurchases(
    TransactionID INT NOT NULL  UNIQUE,
    PurchaseType ENUM('airtime', 'databundle'),
    PhoneNumber INT,
    ServiceProviderID INT NOT NULL,
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID),
    FOREIGN KEY (PhoneNumber) REFERENCES Users(PhoneNumber),
    FOREIGN KEY (ServiceProviderID) REFERENCES ServiceProviders(ServiceProviderID)

);

CREATE TABLE BillPayments(
    TransactionID INT NOT NULL UNIQUE,
    BillType ENUM('electricity', 'water', 'tv-decoder'),
    FOREIGN KEY (TransactionID) REFERENCES Transactions(TransactionID)
);

CREATE VIEW UserAccountsView AS
SELECT Users.Name, Accounts.AccountNumber, Accounts.AccountType
FROM Users
INNER JOIN Accounts ON Users.UserID = Accounts.UserID;

CREATE VIEW BranchAccountsView AS
SELECT Branches.Address, Accounts.AccountNumber
FROM Branches
INNER JOIN Accounts ON Branches.BranchID = Accounts.BranchID;

CREATE VIEW ServiceProviderPurchasesView AS
SELECT ServiceProviders.Name, SUM(Transactions.Amount) AS TotalPurchases
FROM AirtimePurchases
INNER JOIN Transactions ON AirtimePurchases.TransactionID = Transactions.TransactionID
INNER JOIN ServiceProviders ON AirtimePurchases.ServiceProviderID = ServiceProviders.ServiceProviderID
GROUP BY ServiceProviders.Name;

CREATE VIEW UserNextofKinView AS
SELECT Users.Name AS UserName, NextofKin.Name AS NextofKinName
FROM Users
INNER JOIN NextofKin ON Users.UserID = NextofKin.UserID;




-- Create triggers

CREATE TRIGGER after_deposit_insert
AFTER INSERT ON Deposits
FOR EACH ROW
BEGIN
   UPDATE Wallets
   SET Balance = Balance + NEW.Amount
   WHERE AccountNumber = (SELECT AccountNumber FROM Transactions WHERE TransactionID = NEW.TransactionID);
END;



CREATE TRIGGER after_withdraw_insert
AFTER INSERT ON Withdrawals
FOR EACH ROW
BEGIN
   UPDATE Wallets
   SET Balance = Balance - NEW.Amount
   WHERE AccountNumber = (SELECT AccountNumber FROM Transactions WHERE TransactionID = NEW.TransactionID);
END;



CREATE VIEW UsersView AS SELECT * FROM Users;




# Data Insertion into the tables
#Users:
INSERT INTO Users (UserID, Name, DOB, GhanaCard, PhoneNumber)
VALUES
    (001, 'Faith Ngala', '1990-05-15', 'AB123456', 0549669809),
    (002, 'Kwame Amoako', '1987-09-23', 'CD789012', 0241234567),
    (003, 'Akua Mensah', '1995-02-10', 'EF345678', 0559876543),
    (004, 'Yaw Owusu', '1980-11-30', 'GH567890', 0258765432),
    (005, 'Abena Asante', '1993-08-17', 'IJ123456', 0542345678),
    (006, 'Kofi Anane', '1984-04-03', 'KL789012', 0247654321),
    (007, 'Adwoa Adu', '1998-12-05', 'MN345678', 0551122334),
    (008, 'Kwesi Boateng', '1982-06-20', 'OP567890', 0534455667),
    (009, 'Ama Mensah', '1991-03-12', 'QR123456', 0259988776),
    (010, 'Yaw Ansah', '1975-07-28', 'ST789012', 0556655443),
    (011, 'Esi Acheampong', '1989-10-02', 'UV345678', 0249876543),
    (012, 'Kwabena Osei', '1997-01-18', 'WX123456', 0543322110),
    (013, 'Akosua Yeboah', '1986-04-22', 'YZ789012', 0558765432),
    (014, 'Kwaku Mensah', '1994-09-09', 'AB234567', 0251234567),
    (015, 'Afia Boakye', '1983-12-14', 'CD678901', 0544443333),
    (016, 'Yaw Ansah', '1980-05-01', 'EF123456', 0591111222),
    (017, 'Ama Kumi', '1996-08-27', 'GH789012', 0548888999),
    (018, 'Kwesi Asante', '1987-02-08', 'IJ234567', 0257777666),
    (019, 'Akua Ofori', '1990-11-19', 'KL789012', 0536666555),
    (020, 'Kofi Anokye', '1985-06-07', 'MN123456', 0594444333);


INSERT INTO Branches (BranchID, Address, City, Region)
VALUES 
(1, 'Sir. Arku Korsah Rd Airport West', 'Accra', 'Greater Accra'),
(2, 'Post Office Box 608 E/R', 'Tamale', 'Northern'),
(3, '9 Nii Noi Kwame Street', 'Accra', 'Greater Accra'),
(4, 'A54 Sorodae, koforidua Market Avenue', 'Koforidua', 'Eastern'),
(5, 'GA-557-9869 Tantra Hill Sowutuom District', 'Accra', 'Greater Accra'),
(6, 'Adj. Procredit, St. Johns', 'Accra', 'Greater Accra'),
(7, 'Virtual online business', 'Accra', 'Greater Accra');

# User Next of Kin
-- Insert data into the NextofKin table with Ghanaian names
INSERT INTO NextofKin (Name, DOB, GhanaCard, UserID)
VALUES
    ('Kwame Mensah', '1978-05-10', 'KM987654', 002),
    ('Akua Adu', '1985-09-15', 'AA123456', 003),
    ('Yaw Boateng', '1972-06-20', 'YB567890', 004),
    ('Abena Ansah', '1979-12-25', 'AA112233', 005),
    ('Kofi Asante', '1986-08-30', 'KA445566', 006),
    ('Ama Osei', '1975-04-15', 'AO789012', 007),
    ('Kwesi Adu', '1990-11-08', 'KA334455', 008),
    ('Akosua Yeboah', '1968-03-25', 'AY998877', 009),
    ('Kofi Amoako', '1983-07-01', 'KA667788', 010),
    ('Yaw Mensah', '1977-02-14', 'YM112233', 011),
    ('Afia Boateng', '1991-01-18', 'AB445566', 012),
    ('Kwabena Osei', '1973-06-22', 'KO789012', 013),
    ('Adwoa Ansah', '1988-09-09', 'AA334455', 014),
    ('Kwaku Asante', '1993-12-14', 'KA998877', 015),
    ('Akua Adu', '1971-05-01', 'AA667788', 016),
    ('Kwesi Amoah', '1987-08-27', 'KA112233', 017),
    ('Ama Yeboah', '1980-02-08', 'AY445566', 018),
    ('Yaw Asante', '1992-11-19', 'YA789012', 019),
    ('Esi Anokye', '1986-06-07', 'EA334455', 020);


    # Security table:
INSERT INTO Security (SecurityID, UserID, TwoFactorAuthenticationStatus, SecurityQuestionsAnswers)
VALUES
    (987654321, '001', false, 'Q1: Kelewele, Q2: Highlife Music'),
    (876543210, '002', true, 'Q1: Fufu, Q2: Azonto Dance'),
    (765432109, '003', false, 'Q1: W.E.B. Du Bois, Q2: Cape Coast Castle'),
    (654321098, '004', true, 'Q1: Adinkra Symbols, Q2: Kente Cloth'),
    (543210987, '005', false, 'Q1: Kwame Nkrumah, Q2: Independence Arch'),
    (432109876, '006', true, 'Q1: Asaana Dance, Q2: Adowa Dance'),
    (321098765, '007', false, 'Q1: Lake Volta, Q2: Akosombo Dam'),
    (210987654, '008', true, 'Q1: Mole National Park, Q2: Tamale'),
    (109876543, '009', false, 'Q1: Cocoa Farming, Q2: Kumasi'),
    (123456789, '010', true, 'Q1: Osu Castle, Q2: Jamestown Lighthouse'),
    (234567890, '011', false, 'Q1: Wulomei, Q2: Palm Wine Music'),
    (345678901, '012', true, 'Q1: Makola Market, Q2: Accra'),
    (456789012, '013', false, 'Q1: Kwahu Paragliding, Q2: Nkawkaw'),
    (567890123, '014', true, 'Q1: Mfantsipim School, Q2: Cape Coast'),
    (678901234, '015', false, 'Q1: Shai Hills Reserve, Q2: Dodowa Forest'),
    (789012345, '016', true, 'Q1: Fante Language, Q2: Elmina Castle'),
    (890123456, '017', false, 'Q1: Wli Waterfalls, Q2: Hohoe'),
    (901234567, '018', true, 'Q1: Wa Naa''s Palace, Q2: Upper West Region'),
    (987012345, '019', false, 'Q1: Aburi Botanical Gardens, Q2: Eastern Region'),
    (876543219, '020', true, 'Q1: Osu Beach, Q2: Chale Wote Festival');
-- Data Insertion into the Account table with updated AccountType

# Account table
INSERT INTO Accounts (AccountNumber, AccountType, UserID, BranchID)
VALUES
    (1001, 'Personal', 001, 1),
    (1002, 'Agent', 002, 2),
    (1003, 'Merchant', 003, 3),
    (1004, 'Agent', 004, 4),
    (1005, 'Personal', 005, 5),
    (1006, 'Merchant', 006, 6),
    (1007, 'Agent', 007, 1),
    (1008, 'Personal', 008, 2),
    (1009, 'Agent', 009, 3),
    (1010, 'Merchant', 010, 4),
    (1011, 'Personal', 011, 5),
    (1012, 'Agent', 012, 6),
    (1013, 'Merchant', 013, 1),
    (1014, 'Personal', 014, 2),
    (1015, 'Agent', 015, 3),
    (1016, 'Merchant', 016, 4),
    (1017, 'Personal', 017, 5),
    (1018, 'Agent', 018, 6),
    (1019, 'Merchant', 019, 1),
    (1020, 'Personal', 020, 2);


INSERT INTO Agents (AgentNumber, AccountNumber)
VALUES
    (3001, 1002),
    (3002, 1004),
    (3004, 1007),
    (3005, 1009),
    (3006, 1012),
    (3007, 1015),
    (3008, 1018);

-- Verify the data
SELECT * FROM Agents;


-- Populate the Merchants table
INSERT INTO Merchants (MerchantNumber, AccountNumber)
VALUES
    (2001, 1003),
    (2002, 1006),
    (2003, 1010),
    (2004, 1013),
    (2005, 1016),
    (2006, 1019);

-- Verify the data
SELECT * FROM Merchants;



INSERT INTO Personal (PhoneNumber, AccountNumber)
VALUES
    (0549669809, 1001),
    (0542345678, 1005),
    (0534455667, 1008),
    (0249876543, 1011),
    (0251234567, 1014),
    (0548888999, 1017),
    (0594444333, 1020);

-- Populate the Wallet table
INSERT INTO Wallets (Balance, AccountNumber)
VALUES
    (500.00, 1001),
    (1000.00, 1002),
    (750.50, 1003),
    (1200.00, 1004),
    (300.75, 1005),
    (900.25, 1006),
    (600.50, 1007),
    (1500.00, 1008),
    (800.00, 1009),
    (950.75, 1010),
    (400.25, 1011),
    (1100.00, 1012),
    (700.50, 1013),
    (200.75, 1014),
    (1300.00, 1015),
    (450.25, 1016),
    (1000.50, 1017),
    (1800.00, 1018),
    (650.00, 1019),
    (850.75, 1020);

INSERT INTO ServiceProviders (ServiceProviderID, Name, ContactInfo)
VALUES 
(1, 'MTN Ghana', 'Contact Info Here'),
(2, 'Vodafone Ghana', 'Contact Info Here'),
(3, 'AirtelTigo Ghana', 'Contact Info Here'),
(4, 'Glo Mobile Ghana', 'Contact Info Here'),
(5, 'Expresso', 'Contact Info Here'),
(6, 'Telesol 4G', 'Contact Info Here'),
(7, 'Busy Ghana', 'Contact Info Here'),
(8, 'Surfline Ghana', 'Contact Info Here');


INSERT INTO Transactions (TransactionID, Amount, AccountNumber)
VALUES
    (1, 500.00, 1001), -- Faith Ngala made a transaction
    (2, 200.00, 1002), -- Kwame Amoako made a transaction
    (3, 300.00, 1003), -- Akua Mensah made a transaction
    (4, 400.00, 1004), -- Yaw Owusu made a transaction
    (5, 250.00, 1005), -- Abena Asante made a transaction
    (6, 350.00, 1006), -- Kofi Anane made a transaction
    (7, 450.00, 1007), -- Adwoa Adu made a transaction
    (8, 550.00, 1008), -- Kwesi Boateng made a transaction
    (9, 650.00, 1009), -- Ama Mensah made a transaction
    (10, 750.00, 1010), -- Yaw Ansah made a transaction
    (11, 850.00, 1011), -- Esi Acheampong made a transaction
    (12, 950.00, 1012), -- Kwabena Osei made a transaction
    (13, 1050.00, 1013), -- Akosua Yeboah made a transaction
    (14, 1150.00, 1014), -- Kwaku Mensah made a transaction
    (15, 1250.00, 1015), -- Afia Boakye made a transaction
    (16, 1300.00, 1001), -- Faith Ngala made a transaction
    (17, 1400.00, 1002), -- Kwame Amoako made a transaction
    (18, 1500.00, 1003), -- Akua Mensah made a transaction
    (19, 1600.00, 1004), -- Yaw Owusu made a transaction
    (20, 1700.00, 1005), -- Abena Asante made a transaction
    (21, 1800.00, 1006), -- Kofi Anane made a transaction
    (22, 1900.00, 1007), -- Adwoa Adu made a transaction
    (23, 2000.00, 1008), -- Kwesi Boateng made a transaction
    (24, 2100.00, 1009), -- Ama Mensah made a transaction
    (25, 2200.00, 1010), -- Yaw Ansah made a transaction
    (26, 2300.00, 1011), -- Esi Acheampong made a transaction
    (27, 2400.00, 1012), -- Kwabena Osei made a transaction
    (28, 2500.00, 1013), -- Akosua Yeboah made a transaction
    (29, 2600.00, 1014), -- Kwaku Mensah made a transaction
    (30, 2700.00, 1015); -- Afia Boakye made a transaction

-- Deposit
INSERT INTO Deposits (TransactionID, PhoneNumber, Amount)
VALUES
    (1, 0549669809, 500.00), -- Faith Ngala made a deposit
    (2, 0241234567, 200.00), -- Kwame Amoako made a deposit
    (3, 0559876543, 300.00), -- Akua Mensah made a deposit
    (4, 0258765432, 400.00), -- Yaw Owusu made a deposit
    (5, 0542345678, 250.00), -- Abena Asante made a deposit
    (16, 0549669809, 1300.00), -- Faith Ngala made a deposit
    (17, 0241234567, 1400.00), -- Kwame Amoako made a deposit
    (18, 0559876543, 1500.00), -- Akua Mensah made a deposit
    (19, 0258765432, 1600.00), -- Yaw Owusu made a deposit
    (20, 0542345678, 1700.00); -- Abena Asante made a deposit

-- Withdraw
INSERT INTO Withdrawals (TransactionID, AccountNumber, Amount)
VALUES
    (6, 1006, 350.00), -- Kofi Anane made a withdrawal
    (7, 1007, 450.00), -- Adwoa Adu made a withdrawal
    (8, 1008, 550.00), -- Kwesi Boateng made a withdrawal
    (9, 1009, 650.00), -- Ama Mensah made a withdrawal
    (10, 1010, 750.00), -- Yaw Ansah made a withdrawal
    (21, 1006, 1800.00), -- Kofi Anane made a withdrawal
    (22, 1007, 1900.00), -- Adwoa Adu made a withdrawal
    (23, 1008, 2000.00), -- Kwesi Boateng made a withdrawal
    (24, 1009, 2100.00), -- Ama Mensah made a withdrawal
    (25, 1010, 2200.00); -- Yaw Ansah made a withdrawal

-- MoneyTransfer
INSERT INTO MoneyTransfers (TransactionID, SenderID, ReceiverID)
VALUES
    (11, 1011, 1001), -- Esi Acheampong transferred money to Faith Ngala
    (12, 1012, 1002), -- Kwabena Osei transferred money to Kwame Amoako
    (13, 1013, 1003), -- Akosua Yeboah transferred money to Akua Mensah
    (14, 1014, 1004), -- Kwaku Mensah transferred money to Yaw Owusu
    (15, 1015, 1005), -- Afia Boakye transferred money to Abena Asante
    (26, 1011, 1001), -- Esi Acheampong transferred money to Faith Ngala
    (27, 1012, 1002), -- Kwabena Osei transferred money to Kwame Amoako
    (28, 1013, 1003), -- Akosua Yeboah transferred money to Akua Mensah
    (29, 1014, 1004), -- Kwaku Mensah transferred money to Yaw Owusu
    (30, 1015, 1005); -- Afia Boakye transferred money to Abena Asante

-- AirtimePurchase
INSERT INTO AirtimePurchases (TransactionID, PurchaseType, PhoneNumber, ServiceProviderID)
VALUES
    (1, 'airtime', 0549669809, 1), -- Faith Ngala purchased airtime from MTN Ghana
    (3, 'airtime', 0559876543, 2), -- Akua Mensah purchased airtime from Vodafone Ghana
    (5, 'airtime', 0542345678, 3), -- Abena Asante purchased airtime from AirtelTigo Ghana
    (16, 'airtime', 0549669809, 4), -- Faith Ngala purchased airtime from Glo Mobile Ghana
    (18, 'airtime', 0559876543, 5), -- Akua Mensah purchased airtime from Expresso
    (20, 'airtime', 0542345678, 6); -- Abena Asante purchased airtime from Telesol 4G

    

-- BillPayment
INSERT INTO BillPayments (TransactionID, BillType)
VALUES
    (2, 'electricity'), -- Kwame Amoako paid an electricity bill
    (4, 'water'), -- Yaw Owusu paid a water bill
    (6, 'tv-decoder'), -- Kofi Anane paid a tv-decoder bill
    (17, 'electricity'), -- Kwame Amoako paid an electricity bill
    (19, 'water'), -- Yaw Owusu paid a water bill
    (21, 'tv-decoder'); -- Kofi Anane paid a tv-decoder bill


#Uses an inner join and the SUM aggregate function to calculate the total amount of deposits for each user
SELECT Users.Name, SUM(Deposits.Amount) AS TotalDeposits
FROM Users
INNER JOIN Deposits ON Users.PhoneNumber = Deposits.PhoneNumber
GROUP BY Users.Name;


#Uses an inner join and the COUNT aggregate function to count the number of transactions for each user.
SELECT Users.Name, COUNT(Transactions.TransactionID) AS TransactionCount
FROM Users
INNER JOIN Accounts ON Users.UserID = Accounts.UserID
INNER JOIN Transactions ON Accounts.AccountNumber = Transactions.AccountNumber
GROUP BY Users.Name;



#Uses multiple joins, subqueries aggregate functions and HAVING clause to find the users who have made above average transactions more than any set number.
SELECT Users.Name, COUNT(Transactions.TransactionID) AS TransactionCount, SUM(Transactions.Amount) AS TotalAmount
FROM Users
INNER JOIN Accounts ON Users.UserID = Accounts.UserID
INNER JOIN Transactions ON Accounts.AccountNumber = Transactions.AccountNumber
WHERE Transactions.Amount > (
    SELECT AVG(Transactions.Amount)
    FROM Transactions
)
GROUP BY Users.Name
HAVING COUNT(Transactions.TransactionID) > 0;

#Uses ORDER BY and IN to retrieve tansactions that are either deposits or withdrawals and sorts them by amount
SELECT *
FROM Transactions
WHERE TransactionID IN (SELECT TransactionID FROM Deposits UNION SELECT TransactionID FROM Withdrawals)
ORDER BY Amount;

#Uses LIKE and IN to retrieve users whose name start with F who have made a transaction
SELECT *
FROM Users
WHERE Name LIKE 'F%' AND UserID IN (SELECT UserID FROM Accounts WHERE AccountNumber IN (SELECT AccountNumber FROM Transactions));

#Uses LEFT OUTER JOIN and ORDER BY to retrieve users and their account numbers and sorts them by name
SELECT Users.Name, Accounts.AccountNumber
FROM Users
LEFT OUTER JOIN Accounts ON Users.UserID = Accounts.UserID
ORDER BY Users.Name;

#Uses COUNT and a mathematical condition to count the number of transactions greater than 1000
SELECT COUNT(TransactionID) AS NumberOfLargeTransactions
FROM Transactions
WHERE Amount > 1000;




SELECT * from Wallets;

SELECT * FROM UserAccountsView;
SELECT * FROM BranchAccountsView;
SELECT * FROM ServiceProviderPurchasesView;
SELECT * FROM UserNextofKinView;





