INSERT INTO Payment (subscription_id, payment_amount, payment_date, payment_method)
SELECT
    s.subscription_id,

    -- مبلغ قريب من سعر الباقة
    sp.monthly_fee 
      - (ABS(CHECKSUM(NEWID())) % 20) AS payment_amount,

    -- تاريخ دفع داخل فترة الاشتراك
    DATEADD(day, ABS(CHECKSUM(NEWID())) % 20, s.start_date) AS payment_date,

    -- طريقة دفع عشوائية
    CASE 
        WHEN ABS(CHECKSUM(NEWID())) % 3 = 0 THEN 'Cash'
        WHEN ABS(CHECKSUM(NEWID())) % 3 = 1 THEN 'Credit Card'
        ELSE 'Wallet'
    END AS payment_method

FROM Subscription s
JOIN ServicePlan sp
    ON s.plan_id = sp.plan_id
WHERE s.status IN ('active', 'suspended');




