INSERT INTO Usage_Records
(subscription_id, usage_date, minutes_used, data_used, sms_used)
SELECT
    s.subscription_id,

    -- تاريخ استخدام داخل فترة الاشتراك
    DATEADD(day, ABS(CHECKSUM(NEWID())) % 25, s.start_date) AS usage_date,

    -- دقائق
    CASE 
        WHEN s.status = 'active' THEN ABS(CHECKSUM(NEWID())) % 60 + 1
        ELSE 0
    END AS minutes_used,

    -- داتا (MB)
    CASE 
        WHEN s.status = 'active' THEN ABS(CHECKSUM(NEWID())) % 500 + 50
        ELSE 0
    END AS data_used,

    -- SMS
    CASE 
        WHEN s.status = 'active' THEN ABS(CHECKSUM(NEWID())) % 10
        ELSE 0
    END AS sms_used

FROM Subscription s
CROSS APPLY (
    SELECT TOP (ABS(CHECKSUM(NEWID())) % 8 + 3) 1 AS n
    FROM sys.objects
) t;







