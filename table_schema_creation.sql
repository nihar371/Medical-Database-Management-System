-- =========================
-- Table: Admin
-- =========================
DROP TABLE IF EXISTS Admin;

CREATE TABLE Admin (
    Admin_ID INT PRIMARY KEY,
    Admin_Name VARCHAR(30),
    Admin_Mobile VARCHAR(10) CHECK (LENGTH(Admin_Mobile) = 10),
    Admin_Password VARCHAR(20) CHECK (LENGTH(Admin_Password) > 7)
);

-- =========================
-- Table: Company
-- =========================
DROP TABLE IF EXISTS Company;

CREATE TABLE Company (
    Company_Name VARCHAR(50) PRIMARY KEY,
    Company_Address VARCHAR(50),
    Company_ContactPerson VARCHAR(30),
    Company_Mobile VARCHAR(10) CHECK (LENGTH(Company_Mobile) = 10)
);

-- =========================
-- Table: Medicine
-- =========================
DROP TABLE IF EXISTS Medicine;

CREATE TABLE Medicine (
    Medicine_SlotID INT PRIMARY KEY,
    Medicine_Name VARCHAR(30),
    Medicine_Detail TEXT,
    Medicine_Price FLOAT,
    Company_Name VARCHAR(50),
    Medicine_ExpiryDate DATE,
    FOREIGN KEY (Company_Name) REFERENCES Company(Company_Name)
);

-- =========================
-- Table: Employee
-- =========================
DROP TABLE IF EXISTS Employee;

CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(30),
    Employee_Mobile VARCHAR(10) CHECK (LENGTH(Employee_Mobile) = 10),
    Employee_Salary INT
);

-- =========================
-- Table: Purchase (Bill)
-- =========================
DROP TABLE IF EXISTS Purchase;

CREATE TABLE Purchase (
    Bill_BillNo VARCHAR(10) PRIMARY KEY,
    Medicine_Price FLOAT,
    Medicine_Quantity INT,
    Medicine_Total FLOAT GENERATED ALWAYS AS (Medicine_Price * Medicine_Quantity) STORED,
    Bill_Total FLOAT,
    Medicine_Name VARCHAR(30),
    Company_Name VARCHAR(50),
    FOREIGN KEY (Company_Name) REFERENCES Company(Company_Name)
);

-- =========================
-- Table: Customer (linked to Purchase)
-- =========================
DROP TABLE IF EXISTS Customer;

CREATE TABLE Customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(30),
    Customer_Mobile VARCHAR(10) CHECK (LENGTH(Customer_Mobile) = 10),
    Bill_BillNo VARCHAR(10),
    FOREIGN KEY (Bill_BillNo) REFERENCES Purchase(Bill_BillNo)
);

-- =========================
-- Remaining Tables: Pharmacy System
-- =========================

-- Pharmacy
CREATE TABLE Pharmacy (
    PhID INT PRIMARY KEY,
    Name VARCHAR(20),
    City VARCHAR(20),
    Fax VARCHAR(20),
    Phone VARCHAR(10)
);

-- Doctor
CREATE TABLE Doctor (
    DID INT PRIMARY KEY,
    DName VARCHAR(20),
    Speciality VARCHAR(20),
    Age INT NOT NULL,
    Mobile VARCHAR(10),
    Gender VARCHAR(6)
);

-- Customer (pharmacy context)
CREATE TABLE Customer_P (
    PID INT PRIMARY KEY,
    Name VARCHAR(20),
    Sex VARCHAR(6),
    City VARCHAR(20),
    Phone VARCHAR(10),
    Age INT,
    DID INT,
    FOREIGN KEY (DID) REFERENCES Doctor(DID) ON DELETE SET NULL
);

-- Manufacturer
CREATE TABLE Manufacturer (
    CID INT PRIMARY KEY,
    Name VARCHAR(20),
    Email VARCHAR(20),
    Mobile VARCHAR(10),
    City VARCHAR(20),
    PharID INT,
    FOREIGN KEY (PharID) REFERENCES Pharmacy(PhID) ON DELETE SET NULL
);

-- MediEquipment
CREATE TABLE MediEquipment (
    Code INT PRIMARY KEY,
    Trade_Name VARCHAR(20),
    Product_Type VARCHAR(20),
    Mfg_Date DATE,
    Exp_Date DATE,
    Price DECIMAL(10,2),
    CID INT,
    FOREIGN KEY (CID) REFERENCES Manufacturer(CID) ON DELETE SET NULL
);

-- Supplier
CREATE TABLE Supplier (
    Name VARCHAR(20),
    City VARCHAR(20),
    Mobile INT PRIMARY KEY,
    Email VARCHAR(20),
    CID INT,
    PharID INT,
    FOREIGN KEY (CID) REFERENCES Manufacturer(CID) ON DELETE SET NULL,
    FOREIGN KEY (PharID) REFERENCES Pharmacy(PhID) ON DELETE SET NULL
);

-- Employee (pharmacy)
CREATE TABLE Employee_P (
    Name VARCHAR(20),
    City VARCHAR(20),
    DOJ DATE,
    Mobile INT PRIMARY KEY,
    Salary DECIMAL(10),
    Age INT,
    Sex VARCHAR(1),
    PharID INT,
    FOREIGN KEY (PharID) REFERENCES Pharmacy(PhID) ON DELETE SET NULL
);

-- Hospital
CREATE TABLE Hospital (
    HID INT PRIMARY KEY,
    Name VARCHAR(20),
    Email VARCHAR(40),
    Phone VARCHAR(10),
    City VARCHAR(20),
    PharID INT,
    FOREIGN KEY (PharID) REFERENCES Pharmacy(PhID) ON DELETE SET NULL
);

-- Bill
CREATE TABLE Bill (
    BID INT PRIMARY KEY,
    DOB DATE,
    Age INT,
    PName VARCHAR(20),
    Mobile INT,
    City VARCHAR(20),
    Product VARCHAR(20),
    Amount DECIMAL(10,2),
    PharID INT,
    FOREIGN KEY (PharID) REFERENCES Pharmacy(PhID) ON DELETE SET NULL
);

-- Works
CREATE TABLE Works (
    PharID INT PRIMARY KEY,
    Start_Date DATE,
    End_Date DATE,
    FOREIGN KEY (PharID) REFERENCES Pharmacy(PhID) ON DELETE CASCADE
);

-- Contract
CREATE TABLE Contract (
    PharID INT,
    CID INT,
    Start_Date DATE,
    End_Date DATE,
    PRIMARY KEY (PharID, CID),
    FOREIGN KEY (PharID) REFERENCES Pharmacy(PhID) ON DELETE CASCADE,
    FOREIGN KEY (CID) REFERENCES Manufacturer(CID) ON DELETE CASCADE
);

-- Prescribe
CREATE TABLE Prescribe (
    DOP DATE,
    Medicine VARCHAR(20),
    DID INT,
    PID INT,
    PRIMARY KEY (PID, DID),
    FOREIGN KEY (DID) REFERENCES Doctor(DID) ON DELETE CASCADE,
    FOREIGN KEY (PID) REFERENCES Customer_P(PID) ON DELETE CASCADE
);