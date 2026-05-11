INSERT INTO Subscription (SIM_ID, start_date, end_date, status, plan_id)
SELECT
    s.SIM_ID,
    sd.start_date,
    DATEADD(day, 30, sd.start_date) AS end_date,
    CASE
        WHEN ABS(CHECKSUM(NEWID())) % 10 = 0 THEN 'suspended'
        WHEN DATEADD(day, 30, sd.start_date) < GETDATE() THEN 'Cancelled'
        ELSE 'active'
    END AS status,
    ((ABS(CHECKSUM(NEWID())) % 8) + 1) AS plan_id
FROM SIM_Card s
CROSS APPLY (
    SELECT DATEADD(day, - (ABS(CHECKSUM(NEWID())) % 90), GETDATE()) AS start_date
) sd;




