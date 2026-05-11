create table Customers(
	customer_id int  primary key identity (1,1),
	f_name  varchar (50),
	L_name varchar(50),
	gender varchar(2) check (gender in ('M','F')),
	national_id varchar(20) not null unique,
	email varchar(50) unique,
	city varchar(50),
	street varchar(50),
	Registration_Date date , 
	Card_num varchar(20),
);

CREATE TABLE SIM_Card (
    SIM_ID INT IDENTITY(1,1) PRIMARY KEY,
    SIM_Number VARCHAR(20) NOT NULL,
    Status VARCHAR(20) NOT NULL,
    ActivationDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    CONSTRAINT FK_SIM_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(customer_id)
);



create table Department (
    department_id int primary key identity(1,1),
    department_name varchar(50) not null unique,
	manager_id int,
);


create table Employee(
	employee_id int primary key identity (1,1),
	department_id int,
	f_name varchar(50),
	L_name varchar(50),
	salary float,
	constraint FK_Employee_Department foreign key (department_id) references Department(department_id)
);

alter table Department
add constraint FK_Department_Manager foreign key (Manager_ID) references Employee(employee_id)


create table Complaint (
    Complaint_ID int primary key identity (1,5),
    ComplaintDate date,
    IssueType varchar(100),
    Status varchar(30),
    CustomerID int,
    EmployeeID int,
    constraint FK_Complaint_Customer foreign key (CustomerID)references Customers(customer_id),
    constraint FK_Complaint_Employee foreign key (EmployeeID)references Employee(employee_id)
);


create table ServicePlan(
	plan_id int primary key identity (1,1),
	plan_name varchar(50),
	monthly_fee float,
	minutes_limit int,
	data_limit 	int,
	sms_limit int,
);


create table Subscription(
	subscription_id int primary key identity  (1,1),
	SIM_ID int not null,
	start_date date,
	end_date date,
	status varchar(30) check (status IN ('active', 'suspended', 'Cancelled')),
	plan_id int not null,
	constraint FK_Subscription_SIM_Card foreign key(SIM_ID)  references SIM_Card(SIM_ID),
	constraint FK_Subscription_Plan foreign key(Plan_id) references ServicePlan(plan_id)
);


CREATE TABLE Usage_Records(
	usage_id int primary key identity (1,1),
	subscription_id int,
	usage_date date,
	minutes_used int,
	data_used int,
	sms_used int,
	constraint FK_Usage_Subscription foreign key(subscription_id) references Subscription(subscription_id)
);





CREATE TABLE Payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,

    subscription_id INT NOT NULL,

    payment_amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Payment_Subscription
        FOREIGN KEY (subscription_id)
        REFERENCES Subscription(subscription_id)
);


