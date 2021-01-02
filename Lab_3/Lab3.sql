USE AdventureWorks2008R2

--Lab 3-1
SELECT c.CustomerID, c.TerritoryID, 
COUNT(oh.SalesOrderid) as [Total Orders],
CASE 
	WHEN COUNT( oh.SalesOrderID) = 0
	THEN 'No Orders'
	WHEN COUNT( oh.SalesOrderID) = 1
	THEN 'One-Time'
	WHEN COUNT( oh.SalesOrderID) > 12
	THEN 'Very Often'
	WHEN COUNT( oh.SalesOrderID) between 2 and 5
	THEN 'Regular'
	Else 'Often'
End as Frequency
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader oh
ON c.CustomerID = oh.CustomerID
WHERE DATEPART(YEAR, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;


--Lab 3-2
SELECT c.CustomerID, c.TerritoryID,
COUNT(o.SalesOrderid) [Total Orders],
DENSE_RANK() OVER (PARTITION BY c.TerritoryID ORDER BY COUNT(o.SalesOrderid) DESC) as [RANK]
FROM Sales.Customer c
LEFT OUTER JOIN Sales.SalesOrderHeader o
ON c.CustomerID = o.CustomerID
WHERE DATEPART(year, OrderDate) = 2007
GROUP BY c.TerritoryID, c.CustomerID;

--Lab 3-3
SELECT pn.FirstName, pn.LastName, e.Gender, st.Name as [Country], sp.bonus as [Highest Bonus]
FROM sales.SalesPerson sp
LEFT OUTER JOIN sales.SalesTerritory st
ON sp.TerritoryID = st.TerritoryID
LEFT OUTER JOIN person.Person pn
ON sp.BusinessEntityID = pn.BusinessEntityID
LEFT OUTER JOIN HumanResources.Employee e
ON pn.BusinessEntityID = e.BusinessEntityID
WHERE sp.Bonus IN
		(SELECT MAX (Bonus) 
		FROM sales.salesperson
		WHERE TerritoryID = 6)
AND e.Gender = 'M';

--Lab 3-4
SELECT main.month, main.color, max(main.Quantity) as [Total Quantity]
FROM ( SELECT P.Color AS COLOR, SUM(OD.OrderQty) AS Quantity, DATEPART(Month,OH.OrderDate) AS [Month],
		DENSE_RANK() OVER (PARTITION BY DATEPART(MONTH, OH.orderdate) ORDER BY sum(OD.orderqty) DESC ) position
		FROM Production.Product P
		INNER JOIN SALES.SalesOrderDetail OD ON P.ProductID = OD.ProductID
		INNER JOIN SALES.SalesOrderHeader OH ON OD.SalesOrderID = OH.SalesOrderID
		WHERE P.Color IS NOT NULL 
		AND DATEPART(YEAR, OH.OrderDate) = '2007'
		GROUP BY P.Color, DATEPART(Month,OH.OrderDate)) main
where main.position = 1
group by main.Month, main.COLOR
order by main.Month;

--Lab 3-5
SELECT 	DISTINCT (oh.CustomerId) as [Customer ID], c.AccountNumber as [Account Number]
FROM	sales.SalesOrderHeader oh
LEFT JOIN sales.SalesOrderDetail od  
ON oh.SalesOrderId = od.salesOrderId
LEFT JOIN sales.Customer c 
ON oh.CustomerId = c.CustomerId
WHERE	od.ProductId NOT IN (708)
ORDER BY oh.CustomerId
