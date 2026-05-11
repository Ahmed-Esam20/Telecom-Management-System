--Get Service Plan Monthly Price
--Returns the monthly fee of a specific service plan based on the plan ID
create or alter function fn_GetPlanPrice(@plan_id int)
returns int
as
begin
	declare @price int;

	select @price = monthly_fee
	from ServicePlan
	where plan_id = @plan_id;
	return @price;
end

go

select dbo.fn_GetPlanPrice(6)

-----------------------------------------------------------------------------------
--Determine Subscription Status
--Determine Subscription Status (Active or Expired)
go
create or alter function fn_SubscriptionStatus(@start_date DATE,@end_date DATE)
returns varchar(20)
as
begin
	if @end_date IS NULL OR @end_date >= GETDATE()
		return 'active';
	return 'expired';
end

go

select subscription_id, dbo.fn_SubscriptionStatus(start_date, end_date) as SubStatus
from Subscription;
-----------------------------------------------------------------------------------
--Calculate Total Minutes Usage
go
create or alter function fn_TotalMinutesUsed(@subscription_id int)
returns int
AS
begin
	declare @total_minutes int;
	select @total_minutes = isnull(sum(minutes_used), 0)
	from Usage_Records
	where subscription_id = @subscription_id;
	return @total_minutes;
end
go

SELECT  dbo.fn_TotalMinutesUsed(1007) AS [Total Minutes Used]
-----------------------------------------------------------------------------------
--Calculate Total Data Usage
go
create or alter function fn_TotalDataUsed(@subscription_id int)
returns int
as
begin
	declare @total_data int;

	select @total_data = isnull(sum(data_used), 0)
	from Usage_Records
	where subscription_id = @subscription_id;
	return @total_data;
end
go

SELECT  dbo.fn_TotalDataUsed(1007) AS [Total Data Used]

go
-----------------------------------------------------------------------------------
--Calculate Total SMS Usage
create or alter function fn_TotalsmsUsed(@subscription_id int)
returns int
as
begin
	declare @total_sms int;

	select @total_sms= isnull(sum(sms_used), 0)
	from Usage_Records
	where subscription_id = @subscription_id;
	return @total_sms;
end

go


SELECT  dbo.fn_TotalsmsUsed(1007) AS [Total SMS Used]
-----------------------------------------------------------------------------------
--Calculate Total Usage
go
create or alter function fn_TotalUsed (@subscription_id int)
returns table
as
return
(
    select
        isnull(sum(minutes_used), 0) AS total_minutes,
        isnull(sum(sms_used), 0)     AS total_sms,
        isnull(sum(data_used), 0)    AS total_data
    from Usage_Records
    where subscription_id = @subscription_id
);
go

select*
from fn_TotalUsed(1008)

-----------------------------------------------------------------------------------
-- Calculate Remaining Usage
go
create or alter function fn_RemainingUsage (@subscription_id int)
returns table
as
return
(
    select
        sp.minutes_limit - isnull(sum(u.minutes_used),0) as remaining_minutes,
        sp.sms_limit     - isnull(sum(u.sms_used),0)     as remaining_sms,
        sp.data_limit    - isnull(sum(u.data_used),0)    as remaining_data
    FROM Subscription s JOIN ServicePlan sp 
			ON s.plan_id = sp.plan_id
     LEFT JOIN Usage_Records u
			ON s.subscription_id = u.subscription_id
    where s.subscription_id = @subscription_id
    group by sp.minutes_limit, sp.sms_limit, sp.data_limit
);
go

select*
from fn_RemainingUsage(1007)








