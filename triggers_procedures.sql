--============================
--TRIGGER
--============================

-- Trigger 1: BEFORE INSERT on Employee_P
-- Ensures the employee's salary is within a realistic range (e.g., 30000 to 200000)
CREATE TRIGGER trg_check_salary BEFORE INSERT ON Employee_P
FOR EACH ROW
BEGIN
  IF NEW.Salary < 30000 OR NEW.Salary > 200000 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary out of allowed range!';
  END IF;
END;

-- Trigger 2: AFTER INSERT on Purchase
-- Automatically updates the Bill_Total in the Purchase table after new purchase entry
CREATE TRIGGER trg_update_bill_total AFTER INSERT ON Purchase
FOR EACH ROW
BEGIN
  UPDATE Purchase
  SET Bill_Total = Medicine_Price * Medicine_Quantity
  WHERE Bill_BillNo = NEW.Bill_BillNo;
END;

-- Trigger 3: BEFORE DELETE on Company
-- Prevents deletion of company if there are medicines linked to it
CREATE TRIGGER trg_prevent_company_delete BEFORE DELETE ON Company
FOR EACH ROW
BEGIN
  DECLARE medicine_count INT;
  SELECT COUNT(*) INTO medicine_count FROM Medicine WHERE Company_Name = OLD.Company_Name;
  IF medicine_count > 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete company with medicines linked!';
  END IF;
END;

-- Trigger 4: AFTER UPDATE on Medicine
-- Logs the update of Medicine_Price into a separate table (MedicinePriceHistory)
CREATE TABLE IF NOT EXISTS MedicinePriceHistory (
  History_ID INT AUTO_INCREMENT PRIMARY KEY,
  Medicine_SlotID INT,
  Old_Price FLOAT,
  New_Price FLOAT,
  Change_Date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TRIGGER trg_log_price_update AFTER UPDATE ON Medicine
FOR EACH ROW
BEGIN
  IF OLD.Medicine_Price <> NEW.Medicine_Price THEN
    INSERT INTO MedicinePriceHistory (Medicine_SlotID, Old_Price, New_Price)
    VALUES (OLD.Medicine_SlotID, OLD.Medicine_Price, NEW.Medicine_Price);
  END IF;
END;

-- Trigger 5: BEFORE INSERT on Customer
-- Checks if mobile number is exactly 10 digits (basic validation)
CREATE TRIGGER trg_check_customer_mobile BEFORE INSERT ON Customer
FOR EACH ROW
BEGIN
  IF LENGTH(CAST(NEW.Customer_Mobile AS CHAR)) <> 10 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer mobile number must be exactly 10 digits.';
  END IF;
END;



--============================
--PROCEDURE
--============================

-- Procedure 1: Get Monthly Sales Report per Pharmacy
CREATE PROCEDURE GetMonthlySalesReport(IN report_month INT, IN report_year INT)
BEGIN
    SELECT p.PharID, phar.PharName, SUM(p.Bill_Total) AS TotalSales
    FROM Purchase p
    JOIN Pharmacy phar ON p.PharID = phar.PharID
    WHERE MONTH(p.Purchase_Date) = report_month AND YEAR(p.Purchase_Date) = report_year
    GROUP BY p.PharID;
END;

-- Procedure 2: Increase Employee Salary by Percentage if Sales Target Met
CREATE PROCEDURE UpdateSalaryBasedOnPerformance(IN phar_id INT, IN sales_target FLOAT, IN percent_increase FLOAT)
BEGIN
    DECLARE total_sales FLOAT;

    SELECT SUM(Bill_Total) INTO total_sales
    FROM Purchase
    WHERE PharID = phar_id;

    IF total_sales >= sales_target THEN
        UPDATE Employee_P
        SET Salary = Salary + (Salary * percent_increase / 100)
        WHERE PharID = phar_id;
    END IF;
END;

-- Procedure 3: Find Top Selling Medicines and Their Company
CREATE PROCEDURE GetTopSellingMedicines(IN top_n INT)
BEGIN
    SELECT m.Medicine_Name, c.Company_Name, SUM(p.Medicine_Quantity) AS TotalSold
    FROM Purchase p
    JOIN Medicine m ON p.Medicine_SlotID = m.Medicine_SlotID
    JOIN Company c ON m.Company_Name = c.Company_Name
    GROUP BY m.Medicine_Name, c.Company_Name
    ORDER BY TotalSold DESC
    LIMIT top_n;
END;

-- Procedure 4: Archive Old Employee Records to History Table
CREATE PROCEDURE ArchiveOldEmployees(IN cutoff_year INT)
BEGIN
    -- Create history table if not exists
    CREATE TABLE IF NOT EXISTS Employee_History AS SELECT * FROM Employee_P WHERE 1=0;

    INSERT INTO Employee_History
    SELECT * FROM Employee_P
    WHERE YEAR(DOJ) <= cutoff_year;

    DELETE FROM Employee_P
    WHERE YEAR(DOJ) <= cutoff_year;
END;

-- Procedure 5: Generate Complete Customer Purchase Summary
CREATE PROCEDURE GetCustomerPurchaseSummary(IN cust_id INT)
BEGIN
    SELECT 
        c.Customer_Name,
        c.Customer_Mobile,
        p.Purchase_Date,
        m.Medicine_Name,
        p.Medicine_Quantity,
        p.Medicine_Price,
        p.Medicine_Quantity * p.Medicine_Price AS Total
    FROM Customer c
    JOIN Purchase p ON c.Customer_ID = p.Customer_ID
    JOIN Medicine m ON p.Medicine_SlotID = m.Medicine_SlotID
    WHERE c.Customer_ID = cust_id
    ORDER BY p.Purchase_Date DESC;
END;