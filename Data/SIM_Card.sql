INSERT INTO SIM_Card (SIM_Number, Status, ActivationDate, CustomerID)
SELECT
    CONCAT('010', RIGHT('00000000' + CAST(customer_id AS VARCHAR), 8)) AS SIM_Number,
    'Active' AS Status,
    DATEADD(day, ABS(CHECKSUM(NEWID())) % 365, '2023-01-01') AS ActivationDate,
    customer_id
FROM Customers;