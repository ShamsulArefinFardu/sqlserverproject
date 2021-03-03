Use BusTransportDSDB
Go

Select * From Client;
Select * From BusCatagory;
Select * From Bus;
Select * From Route;
Select * From Schedule;
Select * From Journey;
Select * From Employee;
Select * From Counter;
Select * From Seats;
Select * From PurchasedSeat;
Select * From Ticket;
Go

Insert into BusCatagory values('Ac'),('Non Ac');

Insert into Bus values('Green Line', 101, 1),('Green Line', 201, 1),('Green Line', 301, 2),('Green Line', 401, 1),('Green Line', 501, 2);

Insert into Route values('Chittagong','Dakha'),('Dakha','Chittagong'),('Chittagong','Dinajpur'),('Dinajpur','Chittagong'),('Chittagong','Sylet');

Insert into Schedule values(1,1,'07:00AM'),(2,2,'12:00pm'),(3,3,'05:00pm'),(4,4,'08:00pm'),(5,5,'11:00pm');

Insert into Journey values(1,'02-02-2020',30,30,1200),(3,'02-05-2020',40,40,1200),(5,'02-06-2020',40,40,600),(4,'02-07-2020',35,35,1200),(2,'02-08-2020',40,40,600);

Insert into Client values('Arif Reza',22,'01733 123 234','Male','12345'),('Sweety', 19,'01746 098 765','Female','23456'),('Jitu',18,'01456 345 678','Male','34567'),('Rassel',19,'01756 234 678','Male','45678'),('Noyan',17,'01765 556 788','Male','56789');

Insert into Employee values('Sayed','Manager'),('Alip','Senior Executive'),('Shubo','Junior Executive'),('Iqbal','Retailer'),('Mizan','Retailer');

Insert into Counter values('Dampara',034567,'Dampara Mosjid Goli',1),('New Market',039875,'Station Road',2),('BRTC',038458,'Oxizen',3),('Olonkar',031594,'Police Box',4),('Bataiary',032981,'Chatter Road',5);

-----------------Inserting Seats
Declare @cnt INT = 0;
While @cnt < 30
Begin
	Insert Into Seats Values(CONCAT(char(65+(@cnt/3)), @cnt%3), 1);
	Set @cnt = @cnt + 1;
End

Set @cnt = 0;
While @cnt < 40
Begin
	Insert Into Seats Values(CONCAT(char(65+(@cnt/3)), @cnt%3), 2);
	Set @cnt = @cnt + 1;
End


Set @cnt = 0;
While @cnt < 40
Begin
	Insert Into Seats Values(CONCAT(char(65+(@cnt/3)), @cnt%3), 3);
	Set @cnt = @cnt + 1;
End

Set @cnt = 0;
While @cnt < 35
Begin
	Insert Into Seats Values(CONCAT(char(65+(@cnt/3)), @cnt%3), 4);
	Set @cnt = @cnt + 1;
End


Set @cnt = 0;
While @cnt < 40
Begin
	Insert Into Seats Values(CONCAT(char(65+(@cnt/3)), @cnt%3), 5);
	Set @cnt = @cnt + 1;
End
Go
-------------------Inserting ticket and purchased seat table
Declare @ticket_id int;
Begin Transaction;
	Insert Into Ticket Values(1, 1, 1, 0, 2400, null, null);
	Update Journey set NumberOfAvailableSeat = NumberOfAvailableSeat - 1 where JourneyID = 1;
	Set @ticket_id = (select SCOPE_IDENTITY());
	
	Declare @rows int = 0;
	Declare @seat_id int;
	While @rows < 1
	Begin
		Set @seat_id = (select top 1 Seats.SeatID from Seats left join PurchasedSeat on (Seats.SeatID = PurchasedSeat.SeatID and PurchasedSeat.IsBooked = NULL) where JourneyID = 1 order by Seats.SeatID);
		Insert Into PurchasedSeat Values (@seat_id, 0, @ticket_id, 1);
		Set @rows = @rows + 1;
	End
Commit Transaction;

----------------Cube, Rollup, Grouping Set
Select ScheduleID,BusID,Sum(RouteID) as Schedules
From Schedule
Group By ScheduleID,BusID With Cube
Go

Select ScheduleID,BusID,Sum(RouteID) as Schedules
From Schedule
Group By ScheduleID,BusID With ROLLUP
Go

Select ScheduleID,BusID,Sum(RouteID) as Schedules
From Schedule
Group By Grouping Sets(
(ScheduleID,BusID,RouteID),
(ScheduleID)
)
Go
------------------6 Basic Clause (Select,From, Where, Having, Group By, Order By
Select Schedule.BusID,BusName,AddressFrom,AddressTo,CatagoryID,Count(*)
From Schedule
Join Bus
ON Bus.BusID=Schedule.BusID
Join Route
On Route.RouteID=Schedule.RouteID
Where ScheduleID is not null
Group By Schedule.BusID,Bus.BusName,AddressFrom,AddressTo,CatagoryID,Time
Having Count(*)>0
Order By BusName
Go

--Inner Join
Select Client.ClientID,ClientName,Ticket.TicketID,PurchasedSeatID,IsBooked,NumberPurchaseOfSeat,TotalFare
From Client 
Join PurchasedSeat
On PurchasedSeat.ClientID=Client.ClientID
Join Ticket
On Ticket.TicketID=PurchasedSeat.TicketID
Go

--Left Outer Join
Select ScheduleID,Route.RouteID,BusID,AddressFrom,AddressTo,Time
From Schedule
Left Join Route
On Schedule.RouteID=Route.RouteID
Go

--Right Outer Join
Select CounterID,CounterName,Counter.BusID,BusName,BusNumber,CatagoryID
From Counter
Right Join Bus
On Counter.BusID=Bus.BusID
Go

--Full Outer Join
Select ScheduleID,Route.RouteID,BusID,AddressFrom,AddressTo
From Route
Full Outer Join Schedule
On Schedule.RouteID=Route.RouteID
Go

---------------Cross Join
Select Ticket.TicketID,PurchasedSeatID,NumberPurchaseOfSeat,TotalFare,Discount,IsBooked
From Ticket
Cross Join PurchasedSeat
Go

-------------Self Join
Select E.EmployeeID,C.EmployeeID,E.Designation
From Employee as C,Employee as E
Where C.EmployeeID<>E.EmployeeID
Go

select * from PurchasedSeat left join Seats on Seats.SeatID = PurchasedSeat.SeatID;

-------------------How many tickets has been sold for particular journey
-- method 1
select NumberOfSeat - NumberOfAvailableSeat as Tickets_Sold from Journey where JourneyID = 1;

-----------------method 2
select count(*) as Tickets_Sold from PurchasedSeat left join Seats on Seats.SeatID = PurchasedSeat.SeatID where JourneyID = 1

--------------Union
Select ScheduleID as Sch From Schedule
Union 
Select EmployeeID as Emp From Employee
Go

-----------------Union All
Select EmployeeID From Employee
Union All
Select ScheduleID From Schedule
Go

-------------Operator
Select 10+2 as [Sum]
Go
Select 10-2 as [Substraction]
Go
Select 10*3 as [Multiplication]
Go
Select 10/2 as [Divide]
Go
Select 10%3 as [Remainder]
Go
----- Sequence for Table
Use BusTransportDSDB
Create Sequence sq_Contacts
	As Bigint
	Start With 1
	Increment By 1
	Minvalue 1
	Maxvalue 99999
	No Cycle
	Cache 20;
	GO

Select Next value for sq_Contacts;
GO
----------------With Loop, If, Else and While

Declare @i int=0;
While @i <10
Begin
	If @i%2=0
		Begin
			Print @i
		End
	Else
		Begin
			Print Cast(@i as varchar) + 'Skip'
		End
	Set @i=@i+1-1*2/2
End
GO

------------Floor Round DatedIF Function

Declare @p money =10.49;
Select FLOOR(@p) As FloorRuselt, ROUND(@p,0) as RoundRuselt

Select DATEDIFF(yy,CAST('10/12/1990' as datetime), GETDATE ()) As Years,
	   DATEDIFF(MM,CAST('10/12/1990' as datetime), GETDATE ())%12 As Months,
	   DATEDIFF(DD,CAST('10/12/1990' as datetime), GETDATE ())%30 As Days
GO

Select Getdate() AS Arefin

Declare @value decimal(10,2)=10.05
Select ROUND(@value,1)
Select Ceiling(@value)
Select Floor(@value)
GO

-------------Cast, Convert, Concatenation
SELECT 'Today : ' + CAST(GETDATE() as varchar)
Go

SELECT 'Today : ' + CONVERT(varchar,GETDATE(),1)
Go

--------------Distinct
Select Distinct EmployeeName, Designation
From Employee
Go


-------------WildCard
Select * From Employee
Where EmployeeName Like 'Sh%'
Go

------------Select Into. Copy Data From Another Table
Select * 
Into #SeatName
From Seats
Go

Select * From Seats
Go

-------------Drop Table
Drop Table #SeatName
Go

----------Case
Select BusID, CatagoryID,
	Case CatagoryID
	When 1 then 'AC'
	When 2 then 'NonAC'
		Else 'Not In Catagory'
End	 
From Bus
Go
