-- View 1: Customer purchase details
CREATE VIEW CustomerPurchaseView AS
SELECT 
    c.Customer_ID,
    c.Customer_Name,
    c.Customer_Mobile,
    p.Bill_BillNo,
    p.Medicine_Name,
    p.Medicine_Quantity,
    p.Medicine_Price,
    p.Medicine_Total,
    p.Bill_Total,
    p.Company_Name
FROM Customer c
JOIN Purchase p ON c.Bill_BillNo = p.Bill_BillNo;

-- View 2: Doctor assigned to patient
CREATE VIEW DoctorPatientView AS
SELECT 
    cp.PID,
    cp.Name AS Patient_Name,
    cp.City AS Patient_City,
    d.DName AS Doctor_Name,
    d.Speciality
FROM Customer_P cp
LEFT JOIN Doctor d ON cp.DID = d.DID;

-- View 3: Medicine and manufacturer details
CREATE VIEW MedicineInventoryView AS
SELECT 
    m.Medicine_SlotID,
    m.Medicine_Name,
    m.Medicine_Detail,
    m.Medicine_Price,
    m.Medicine_ExpiryDate,
    m.Company_Name,
    c.Company_Address,
    c.Company_ContactPerson,
    c.Company_Mobile
FROM Medicine m
JOIN Company c ON m.Company_Name = c.Company_Name;

-- View 4: Manufacturer contracts with pharmacies
CREATE VIEW PharmacyManufacturerView AS
SELECT 
    p.Name AS Pharmacy_Name,
    m.Name AS Manufacturer_Name,
    c.Start_Date,
    c.End_Date
FROM Contract c
JOIN Pharmacy p ON c.PharID = p.PHID
JOIN Manufacturer m ON c.CID = m.CID;

-- View 5: Prescription records linking doctor and patient
CREATE VIEW PrescriptionView AS
SELECT 
    pr.DOP,
    pr.Medicine,
    d.DName AS Doctor_Name,
    cp.Name AS Patient_Name,
    cp.City
FROM Prescribe pr
JOIN Doctor d ON pr.DID = d.DID
JOIN Customer_P cp ON pr.PID = cp.PID;

-- View 6: Basic customer info (no billing details)
CREATE VIEW BasicCustomerInfoView AS
SELECT 
    Customer_ID, 
    Customer_Name, 
    Customer_Mobile 
FROM Customer;

-- View 7: List of active (non-expired) medicines
CREATE VIEW ActiveMedicinesView AS
SELECT *
FROM Medicine
WHERE Medicine_ExpiryDate > CURRENT_DATE;

-- View 8: Summarize total and average salary of employees per pharmacy
CREATE VIEW TopSellingMedicines AS
SELECT
    m.Medicine_SlotID,
    m.Medicine_Name,
    m.Company_Name,
    c.Company_Address,
    SUM(p.Medicine_Quantity) AS Total_Quantity_Sold,
    SUM(p.Medicine_Price * p.Medicine_Quantity) AS Total_Revenue
FROM Medicine m
JOIN Purchase p ON m.Medicine_Name = p.Medicine_Name
JOIN Company c ON m.Company_Name = c.Company_Name
GROUP BY m.Medicine_SlotID, m.Medicine_Name, m.Company_Name, c.Company_Address
ORDER BY Total_Quantity_Sold DESC;

-- View 9: Shows unique patients, prescribed medicines, total prescriptions, and last prescription date, for each doctor
CREATE VIEW DoctorPrescriptionStats AS
SELECT
    d.DID,
    d.DName,
    d.Speciality,
    COUNT(DISTINCT pr.PID) AS Unique_Patients,
    COUNT(*) AS Total_Prescriptions,
    MAX(pr.DOP) AS Last_Prescription_Date
FROM Doctor d
LEFT JOIN Prescribe pr ON d.DID = pr.DID
GROUP BY d.DID, d.DName, d.Speciality;

-- View 10: Show purchases in the last 30 days with running total per customer ordered by date
CREATE VIEW RecentPurchasesWithRunningTotal AS
SELECT
    c.Customer_ID,
    c.Customer_Name,
    p.Bill_BillNo,
    p.Medicine_Name,
    p.Medicine_Quantity,
    p.Medicine_Price,
    p.Bill_Total,
    p.Order_Date,
    SUM(p.Bill_Total) OVER (PARTITION BY c.Customer_ID ORDER BY p.Order_Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Running_Total
FROM Customer c
JOIN Purchase p ON c.Bill_BillNo = p.Bill_BillNo
WHERE p.Order_Date >= CURRENT_DATE - INTERVAL '30' DAY
ORDER BY c.Customer_ID, p.Order_Date;
