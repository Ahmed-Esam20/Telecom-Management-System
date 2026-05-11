INSERT INTO ServicePlan (plan_name, monthly_fee, minutes_limit, data_limit, sms_limit)
VALUES
-- Basic Plans
('Basic Mini', 80,   300,  2048,  100),
('Basic Plus', 120,  600,  4096,  250),

-- Standard Plans
('Standard Mini', 160, 1000,  8192,  500),
('Standard Plus', 220, 1500, 12288,  750),

-- Premium Plans
('Premium Mini', 300, 2500, 20480, 1000),
('Premium Plus', 400, 4000, 30720, 1500),

-- Unlimited / Business-like
('Ultra', 550, 8000, 51200, 3000),
('VIP',   750, 15000, 102400, 5000);



