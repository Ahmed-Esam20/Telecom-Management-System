
---------------------------------------Rules = Triggers-----------------------------------------------
use [Telecom  System]
---------------------------------------SIM Lifecycle Automation------------------------------------------------------
--(1) Rule: When the first Subscription is activated → the SIM becomes Active
CREATE or Alter TRIGGER trg_SIM_Activate_OnFirstActiveSub
ON Subscription
AFTER INSERT
AS
BEGIN
    UPDATE sim
    SET 
        sim.Status = 'Active',
        sim.ActivationDate = GETDATE()
    FROM SIM_Card sim
    JOIN inserted i 
        ON sim.SIM_ID = i.SIM_ID
    WHERE i.status = 'active'
      AND sim.Status <> 'Active';
END




--(2) If there is no active subscription on the SIM → it will Suspend
CREATE or Alter TRIGGER trg_SIM_Suspend_WhenNoActiveSub
ON Subscription
AFTER UPDATE
AS
BEGIN
    UPDATE sim
    SET sim.Status = 'Suspended'
    FROM SIM_Card sim
    JOIN inserted i 
        ON sim.SIM_ID = i.SIM_ID
    WHERE NOT EXISTS (
        SELECT 1
        FROM Subscription s
        WHERE s.SIM_ID = sim.SIM_ID
          AND s.status = 'active'
    )
END

---------------------------------------Subscription Integrity Rules------------------------------------------------------
--(1) Prevent having more than one active subscription for the same SIM on the same time
CREATE or Alter TRIGGER trg_Prevent_Overlapping_Subscriptions
ON Subscription
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Subscription s
        JOIN inserted i
            ON s.SIM_ID = i.SIM_ID
        WHERE 
            s.start_date <= ISNULL(i.end_date, '9999-12-31')
            AND ISNULL(s.end_date, '9999-12-31') >= i.start_date
    )
    BEGIN
        RAISERROR('Subscription period overlaps with an existing subscription for this SIM.',16,1);
        RETURN
    END

    INSERT INTO Subscription (SIM_ID, plan_id, start_date, end_date, status)
    SELECT SIM_ID, plan_id, start_date, end_date, status
    FROM inserted;
END


---------------------------------------Complaint Workflow Automation------------------------------------------------------
--(1) Rule: If the complaint is registered without a status → it will be Open
CREATE or ALTER TRIGGER trg_Complaint_DefaultStatus
ON Complaint
AFTER INSERT
AS
BEGIN
    UPDATE c
    SET c.Status = 'Open'
    FROM Complaint c
    JOIN inserted i
        ON c.Complaint_ID = i.Complaint_ID
    WHERE c.Status IS NULL
END

--(2) Rule: If the complaint is resolved → record the closing date
CREATE or ALTER TRIGGER trg_Set_Complaint_ClosedDate
ON Complaint
AFTER UPDATE
AS
BEGIN
    UPDATE c
    SET ComplaintDate = GETDATE()
    FROM Complaint c
    JOIN inserted i ON c.Complaint_ID = i.Complaint_ID
    JOIN deleted d ON d.Complaint_ID = i.Complaint_ID
    WHERE i.Status = 'Closed'
      AND d.Status <> 'Closed'
END

---------------------------------------Audit Logging on Subscription------------------------------------------------------
CREATE TABLE Subscription_Audit (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    subscription_id INT,
    old_status VARCHAR(30),
    new_status VARCHAR(30),
    changed_at DATETIME DEFAULT GETDATE()
)

CREATE or ALTER TRIGGER trg_Audit_Subscription_Status
ON Subscription
AFTER UPDATE
AS
BEGIN
    INSERT INTO Subscription_Audit (subscription_id, old_status, new_status)
    SELECT 
        i.subscription_id,
        d.status,
        i.status
    FROM inserted i
    JOIN deleted d
        ON i.subscription_id = d.subscription_id
    WHERE i.status <> d.status
END
