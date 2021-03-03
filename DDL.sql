Use master
Drop Database If Exists BusTransportDSDB
Go
Create Database BusTransportDSDB
On Primary
(
Name='BusTransportDSDB_Data', FileName='C:\Users\idb_c#\BusTransportDSDB_Data.Mdf', Size=10MB, MaxSize=100MB, FileGrowth=5%
)
Log On
(
Name='BusTransportDSDB_Log', FileName='C:\Users\idb_c#\BusTransportDSDB_Data.ldf', Size=2MB, MaxSize=50MB, FileGrowth=1%
);
Go

Use BusTransportDSDB
Create Table Client
(
ClientID int Primary Key Identity,
ClientName Varchar(20) Sparse null,
Age int,
Phone char(30) not null CHECK ((Phone Like '[0][1][0-9][0-9][0-9] [0-9][0-9][0-9] [0-9][0-9][0-9]')),
Gender varchar(6),
NIDNO varchar(15) not null
);

Create Table Route
(
RouteID int Primary Key Identity,
AddressFrom varchar(15),
AddressTo varchar(15)
);

Create Table BusCatagory
(
CatagoryID int Primary Key Identity,
CatagoryName varchar(20)
);

Create Table Bus
(
BusID int Primary Key Identity,
BusName varchar(20),
BusNumber varchar(10),
CatagoryID int References BusCatagory(CatagoryID)
);

Create Table Schedule
(
ScheduleID int Primary Key Identity,
BusID int References Bus(BusID), 
RouteID int References Route(RouteID),
Time time
);

Create Table Journey
(
JourneyID int Primary Key Identity,
ScheduleID int References Schedule(ScheduleID),
Date date,
NumberOfSeat int,
NumberOfAvailableSeat int
);
Alter Table Journey
Add Fair int;
Go

Create Table Employee
(
EmployeeID int Primary Key Identity,
EmployeeName Varchar(20),
Designation varchar(20)
);

Create Table Counter
(
CounterID int Primary Key Identity,
CounterName varchar(20),
ContactInfo varchar(20),
ContactAddress varchar(20),
BusID int References Bus(BusID) ON UPDATE CASCADE
);

Create Table Ticket
(
TicketID int Primary Key Identity,
ClientID int References Client(ClientID),
JourneyID int References Journey(JourneyID),
NumberPurchaseOfSeat int,
Discount int,
PerSeatFare int,
TotalFare int,
EmployeeID int References Employee(EmployeeID),
CounterID int References Counter(CounterID)
);
Alter Table Ticket
Drop column PerSeatFare;


Create Table Seats
(
SeatID int Primary Key Identity,
SeatName varchar(2),
JourneyID int References Journey(JourneyID) ON DELETE CASCADE
);


Create Table PurchasedSeat
(
PurchasedSeatID int Primary Key Identity,
SeatID int References Seats(SeatID),
IsBooked bit default 0,
TicketID int References Ticket(TicketID),
ClientID int References Client(ClientID),
);
Go

Create Table Visitor
(
VisitorID int Identity,
VisitorName varchar(20)
);
Go



-------------Create Clustered and NonClustered
Create Clustered Index CI_Visit on Visitor(VisitorID)
Go
Create NonClustered Index NCI_EmpName on Employee(EmployeeName)
Go

--------------------Views

Create View vw_ClientInfo
With Encryption
AS 
Select ClientID,ClientName,Phone
From Client
Go

-------------Create Tabular Function
Create Function fn_Tabular(@busname varchar(20))
Returns Table
AS
Return
(
Select Schedule.BusID,RouteID,BusName,BusNumber
From Bus
Join Schedule
On Bus.BusID= Schedule.BusID
Where BusName = @busname
)
GO

-------------------OutPut
Select * from dbo.fn_Tabular('Green Line')
GO

-------------Create Scalar Function
Create Function fn_Scalar(@totalfare int)
Returns int
AS
Begin
	Return
	(
	Select sum(TotalFare)
	From Ticket
	)
End
GO
Select *from Ticket

---------------OutPut
Print dbo.fn_Scalar(10)
GO

-------------------Stored Procedure
Go
Create proc sp_employee
@employeeid int,
@employeename Varchar(20),
@designation varchar(20),
@operationname varchar(30),
@tablename varchar(30)
As
Begin
IF @tablename= 'Employee' and @operationname='Insert'
	Begin
		Insert Into Employee Values(@employeename,@designation,@operationname)
	End
IF @tablename='Employee' and @operationname='Update'
	Begin
		Update Employee set EmployeeName=@employeename Where EmployeeID=@employeeid
	End
IF @tablename='Employee' and @operationname='Delete'
	Begin
		Delete Employee Where EmployeeID=@employeeid
	End
IF @tablename='Employee' and @operationname='Select'
	Begin
		Select * From Employee
	End

End
Go

------------Transaction(Commit, Rollback)
Create proc sp_Counter
@counterid int ,
@countername varchar,
@contactinfo varchar,
@contactaddress varchar,
@busid int,
@message varchar(30) output	 -- For Message Passing
As
Begin
	set nocount on
	Begin Try
		Begin Transaction
			Insert Into Counter(CounterID,CounterName,ContactInfo,ContactAddress,BusID)
			values (@counterid,@countername,@contactinfo,@contactaddress,@busid)
			set @message='Data Inserted Successfully'
			print @message
		Commit Transaction	-- Permanently Store the table data
	End Try
	Begin Catch
		Rollback transaction	-- Rollback data from the table
		Print 'Something goes wrong !!!!!'
	End Catch
End
Go

Exec sp_Counter 1,'Gec','Gec Mor','Dampara',401,'Data Inserted Successfully'
Go

Create Trigger trg_forupdatedelete on Schedule
Instead of Update, Delete
AS
Declare @rowcount int
Set @rowcount=@@ROWCOUNT
IF(@rowcount>1)
				BEGIN
				Raiserror('You cannot Update or Delete more than 1 Record',16,1)
				END
Else 
	Print 'Update or Delete Successful'
GO


Create Table Counter_Table_History
(
CounterID int,
CounterName varchar(20),
ContactInfo varchar(20),
ContactAddress varchar(20),
BusID int,
AudtiAction varchar(30),
AuditTimeStamp datetime
);
Go

Create Trigger tr_After_Insert_Counter on dbo.Counter
For Insert
As
Declare @counterid int,@countername varchar(20),@contactinfo varchar(20),@contactaddress varchar(20),@busid int,@audtiaction varchar(30)
Select @counterid=i.CounterID from inserted as i;
Select @countername=i.CounterName from inserted as i;
Select @contactinfo=i.ContactInfo from inserted as i;
Select @contactaddress=i.ContactAddress from inserted as i;
Select @busid=i.BusID from Inserted as i;
Set @audtiaction ='Row has been Inserted in Counter Table';
Insert Into Counter_Table_History(CounterID,CounterName,ContactInfo,ContactAddress,BusID,AudtiAction,AuditTimeStamp)
Values(@counterid,@countername,@contactinfo,@contactaddress,@busid,@audtiaction,getdate());
Print 'After Trigger Fired For Insert'
Go


Create View vw_AdmissionPayment
With Schemabinding
AS
Select Route.RouteID,AddressFrom,AddressTo,BusID,Time
from dbo.Route join dbo.Schedule
on Route.RouteID=Schedule.RouteID
Go

--------------Create Temporary and Global Table
Create Table #Schedule
(
ScheduleID int Primary Key Identity,
BusID int References Bus(BusID), 
RouteID int References Route(RouteID),
Time time
);
Go

Create Table ##Seats
(
SeatID int Primary Key Identity,
SeatName varchar(2),
JourneyID int References Journey(JourneyID),
);
Go
Drop Table ##Seats

------------Truncate
Truncate Table #Schedule
Go
