-- LAB 5

/*LAB 5-1
Create a function in your own database that takes two
parameters:
1) A year parameter
2) A month parameter
The function then calculates and returns the total sale
for the requested year and month. If there was no sale
for the requested period, returns 0.
Hints: a) Use the TotalDue column of the
Sales.SalesOrderHeader table in an
AdventureWorks database for
calculating the total sale.
b) The year and month parameters should use
the INT data type.
c) Make sure the function returns 0 if there
was no sale in the database for the requested
period. */

USE vataliya_harshish_test;

SELECT TotalDue
FROM AdventureWorks2008R2.Sales.SalesOrderHeader;
 
CREATE FUNCTION TotalSale (@month int, @year int)
RETURNS FLOAT AS
BEGIN
DECLARE @TotalReturn FLOAT;
SELECT @TotalReturn = ( SELECT COALESCE(SUM(oh.TotalDue),0) 
						FROM AdventureWorks2008R2.Sales.SalesOrderHeader oh
						WHERE MONTH(OrderDate) = @month 
						and YEAR(OrderDate) = @year )
RETURN @TotalReturn;
END;
GO
SELECT dbo.TotalSale(7,2005);
 
 create function ufSalesByMonthYear
(@month int, @year int)
returns money
As
Begin 
	Declare @sale money;
	select @sale = isnull( sum(TotalDue) , 0)
	   from AdventureWorks2008R2.Sales.SalesOrderHeader
	   where month(orderDate) = @month AND year(OrderDate) = @year
	return @sale;
End
	
-- Test run
select dbo.ufSalesByMonthYear(5, 2007);

-- House keeping
drop function dbo.ufSalesByMonthYear;

/*Lab 5-2
Create a table in your own database using the following statement.
CREATE TABLE DateRange
(DateID INT IDENTITY,
DateValue DATE,
Month INT,
DayOfWeek INT);
Write a stored procedure that accepts two parameters:
1) A starting date
2) The number of the consecutive dates beginning with the starting
date
The stored procedure then populates all columns of the
DateRange table according to the two provided parameters.*/


USE vataliya_harshish_test

CREATE TABLE DateRange
(
DateID INT IDENTITY,
DateValue DATE,
Month INT,
DayOfWeek INT
);


ALTER PROCEDURE dbo.GetDateRange
(@StartDate date, @NumberOfDays int)
AS 
BEGIN
	DECLARE @i int = 0;
	DECLARE @currentdate DATE = NULL;
	DECLARE @currentmonth int;
	DECLARE @currentweekday int;

WHILE (@i < @NumberOfDays)
	BEGIN
	SET @currentdate = DATEADD(day, @i,@StartDate);
	SET @currentmonth = Month(@currentdate);
	SET @currentweekday = datepart(weekday, @currentdate);
	INSERT INTO dbo.DateRange (DateValue,Month,DayOfWeek)
	VALUES(@currentdate, @currentmonth , @currentweekday);
	SET @i += 1;
	END
END
GO

EXEC dbo.GetDateRange @StartDate='2008-10-01', @NumberOfDays=14;
SELECT * FROM DateRange;



/*Lab 5-3
With three tables as defined below: 
Write a trigger to update the CustomerStatus column of Customer
based on the total of OrderAmountBeforeTax for all orders
placed by the customer. If the total exceeds 5,000, put Preferred
in the CustomerStatus column. */

USE vataliya_harshish_test
CREATE TABLE Customer
(CustomerID VARCHAR(20) PRIMARY KEY,
CustomerLName VARCHAR(30),
CustomerFName VARCHAR(30),
CustomerStatus VARCHAR(10));

CREATE TABLE SalesOrder
(OrderID INT IDENTITY PRIMARY KEY,
CustomerID VARCHAR(20) REFERENCES Customer(CustomerID),
OrderDate DATE,
OrderAmountBeforeTax INT);

CREATE TABLE SalesOrderDetail
(OrderID INT REFERENCES SalesOrder(OrderID),
ProductID INT,
Quantity INT,
UnitPrice INT,
PRIMARY KEY (OrderID, ProductID));

CREATE TRIGGER UpdateCustomerStatus ON dbo.SalesOrder
FOR INSERT, UPDATE
AS
BEGIN 

DECLARE @CustomerID INT;
DECLARE @TotalAmountBeforeTax FLOAT;
Select @CustomerID = CustomerID from inserted;

SET @TotalAmountBeforeTax = (Select Sum(OrderAmountBeforeTax) from SalesOrder 
Where CustomerID = @CustomerID); 

IF @TotalAmountBeforeTax >= 5000 
BEGIN
UPDATE Customer set CustomerStatus = 'Preferred' WHERE CustomerID = @CustomerID; 
END; 
END

--DROP TRIGGER UpdateCustomerStatus

/*Lab 5-4
Use the content of an AdventureWorks database. Write a query
that returns the following columns.
1) Customer ID
2) Customer’s first name
3) Customer’s last name
4) Total of orders made by each customer
5) Total of unique products ever purchased by each customer
Sort the returned data by the customer ID. */

USE AdventureWorks2008R2
SELECT c.CustomerID, p.FirstName, p.LastName, 
	count(DISTINCT oh.SalesOrderID) AS Orders, 
	count(DISTINCT od.ProductID) as ProductIDs
FROM Sales.Customer c 
	join sales.SalesOrderHeader OH on c.CustomerID = oh.CustomerID
	join sales.SalesOrderDetail OD ON od.SalesOrderID = oh.SalesOrderID
	join person.person p ON p.BusinessEntityID = c.PersonID
GROUP BY c.CustomerID, p.FirstName, p.LastName
order by c.customerID;
