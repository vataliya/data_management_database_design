--PART A

--STEP 1

CREATE DATABASE vataliya_harshish_test;

--STEP2
USE vataliya_harshish_test

CREATE TABLE Users
(
uid varchar(5),
name varchar(40) not null
);

CREATE TABLE Classes
(
cID int NOT NULL PRIMARY KEY,
uID varchar(5) NOT NULL,
class_Date datetime DEFAULT Current_Timestamp
);

CREATE TABLE Products
(
pID int NOT NULL PRIMARY KEY,
name varchar(40) NOT NULL,
unitPrice int
);

CREATE TABLE ClassItems
(
classID int NOT NULL
REFERENCES Classes(cID),
productID int NOT NULL
REFERENCES Products(pID),
UnitPrice int,
Quantity int,
CONSTRAINT PKClassItem PRIMARY KEY CLUSTERED
(classID, productID)
);


ALTER TABLE Users ALTER COLUMN uid varchar(5) NOT NULL;
ALTER TABLE Products ALTER COLUMN UnitPrice int NOT NULL;
ALTER TABLE ClassItems ALTER COLUMN UnitPrice int NOT NULL;
ALTER TABLE ClassItems ALTER COLUMN Quantity int NOT NULL;

Alter table Users Add  primary key (uid);

ALTER TABLE Classes ADD CONSTRAINT ClassesFK FOREIGN KEY (uid) REFERENCES Users(uid);


ALTER TABLE Users add email varchar(100) not null;
INSERT INTO USERS values(1,'Harshish','harshish@gmail.com');
INSERT INTO USERS values(2,'Sarthak','sarthak@gmail.com');
INSERT INTO USERS values(3,'Harish','harish@gmail.com');

SELECT * FROM USERS

INSERT INTO PRODUCTS values(1,'Laptop', 200);
INSERT INTO PRODUCTS values(2,'Bag', 200);
INSERT INTO PRODUCTS values(3,'Book', 200);

select * from Products;

INSERT INTO Classes(cID, uID) values(1,1);
INSERT INTO Classes(cID, uID) values(2,2);
INSERT INTO Classes(cID, uID) values(3,2);

select * from Classes;

select * from ClassItems;

INSERT INTO ClassItems values(1,2,55,70);

drop table Products;
drop table Users;
drop table ClassItems;
drop table Classes;

--STEP 3

CREATE TABLE TARGETCUSTOMERS 
(
TargetID  INT Primary key NOT NULL,
FirstName Varchar(30) NOT NULL,
LastName Varchar(20) NOT NULL,
Address Varchar(30) NOT NULL,
City Varchar(30) NOT NULL,
State Varchar(30) NOT NULL,
ZipCode int NOT NULL
);
 
CREATE TABLE MAILINGLISTS
(
MailingListID INT Primary Key,
MailingList Varchar(30) NOT NULL
);
 
Create TABLE TARGETMAILINGLISTS
( 
TargetID  int ,
MailingListID int,
foreign key (TargetID) references TargetCustomers(TargetID),
foreign key (MailingListID) references MailingLists(MailingListID),
primary key (TargetID,MailingListID)
);


-- PART B

USE AdventureWorks2008R2

SELECT DISTINCT OH.CustomerID,
isnull(STUFF(
(
SELECT DISTINCT ', '+RTRIM(CAST(SalesPersonID as char ))   
		FROM Sales.SalesOrderHeader OH
		WHERE CustomerID = C.CustomerID 
		FOR XML PATH('')
)
, 1, 2, '') ,'') AS SalesPerson
FROM 
Sales.SalesOrderHeader OH
JOIN Sales.Customer C
On OH.CustomerID = C.CustomerID
JOIN Person.Person P
on C.PersonID = P.BusinessEntityID
ORDER BY OH.CustomerID DESC;

-- Part C

WITH Parts(AssemblyID, ComponentID, PerAssemblyQty, EndDate, ComponentLevel)
AS 
(
 SELECT BOM.ProductAssemblyID, BOM.ComponentID, BOM.PerAssemblyQty,
 BOM.EndDate, 0 AS ComponentLevel
 FROM Production.BillOfMaterials AS BOM
 WHERE BOM.ProductAssemblyID = 992 AND BOM.EndDate IS NULL
 UNION ALL
 SELECT bm.ProductAssemblyID, bm.ComponentID, p.PerAssemblyQty,
 bm.EndDate, ComponentLevel + 1
 FROM Production.BillOfMaterials AS bm
 INNER JOIN Parts AS p
 ON bm.ProductAssemblyID = p.ComponentID AND bm.EndDate IS NULL
)

SELECT AssemblyID, ComponentID, ListPrice, PerAssemblyQty, ComponentLevel
INTO #TempTable 
FROM Parts AS P
    INNER JOIN Production.Product AS PR
    ON P.ComponentID = PR.ProductID
ORDER BY ComponentLevel, AssemblyID, ComponentID;

SELECT CAST(
(
(SELECT SUM(ListPrice)
FROM #TempTable
WHERE ComponentLevel = 0  AND  ComponentID = 815
)
-
(
SELECT SUM(ListPrice)
FROM #TempTable
WHERE ComponentLevel = 1 and AssemblyID = 815 )
) AS DECIMAL(8,4)
) 
AS TotalCost;

IF EXISTS (SELECT * from #TempTable)
DROP TABLE #TempTable;