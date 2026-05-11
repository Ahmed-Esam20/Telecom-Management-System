WITH CTE_Customers AS (
    SELECT 
        customer_id,
        ROW_NUMBER() OVER (ORDER BY NEWID()) AS rn
    FROM Customers
),
CTE_Employees AS (
    SELECT 
        employee_id,
        ROW_NUMBER() OVER (ORDER BY employee_id) AS rn
    FROM Employee
)
INSERT INTO Complaint
(
    ComplaintDate,
    IssueType,
    Status,
    CustomerID,
    EmployeeID
)
SELECT
    -- تاريخ الشكوى
    DATEADD(day, - (ABS(CHECKSUM(NEWID())) % 60), GETDATE()) AS ComplaintDate,

    -- نوع المشكلة
    CASE 
        WHEN ABS(CHECKSUM(NEWID())) % 4 = 0 THEN 'Network Issue'
        WHEN ABS(CHECKSUM(NEWID())) % 4 = 1 THEN 'Billing Problem'
        WHEN ABS(CHECKSUM(NEWID())) % 4 = 2 THEN 'SIM Issue'
        ELSE 'Service Quality'
    END AS IssueType,

    -- حالة الشكوى
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 4 = 0 THEN 'Open'
        WHEN ABS(CHECKSUM(NEWID())) % 4 = 1 THEN 'In Progress'
        WHEN ABS(CHECKSUM(NEWID())) % 4 = 2 THEN 'Resolved'
        ELSE 'Closed'
    END AS Status,

    c.customer_id,

    e.employee_id

FROM CTE_Customers c
JOIN CTE_Employees e
    ON (c.rn % (SELECT COUNT(*) FROM Employee)) + 1 = e.rn
WHERE c.rn <= 300;





