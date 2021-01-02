/*2-1 Select product id, name and selling start date for all products
that started selling after 01/01/2007 and had a black color.
Use the CAST function to display the date only. Sort the returned
data by the selling start date.
Hint: a: You need to work with the Production.Product table.
b: The syntax for CAST is CAST(expression AS data_type),
where expression is the column name we want to format and
we can use DATE as data_type for this question to display
just the date. */

Use AdventureWorks2008R2;
select p.ProductID, p.Name, p.Color, cast(p.SellStartDate as date) as SellStartDate
from Production.Product p
where p.SellStartDate > '2007-01-01' and p.Color = 'Black'
order by p.SellStartDate

/*2-2 Retrieve the customer ID, account number, oldest order date
and total number of orders for each customer.
Use column aliases to make the report more presentable.
Sort the returned data by the total number of orders in
the descending order.
Hint: You need to work with the Sales.SalesOrderHeader table.*/

select oh.CustomerID, oh.AccountNumber,
cast (min (oh.OrderDate) as date) as 'Oldest Order Date', count (oh.CustomerID) as 'Number of orders' 
From sales.SalesOrderHeader oh
group by oh.CustomerID, oh.AccountNumber
order by 'Number of orders' desc;


SELECT CustomerID, AccountNumber, COUNT(SalesOrderID) AS TotalOrders, CAST(MIN(OrderDate) AS DATE) AS OrderDate
FROM Sales.SalesOrderHeader
GROUP BY CustomerID, AccountNumber
ORDER BY TotalOrders DESC;

/*2-3 Write a query to select the product id, name, and list price
for the product(s) that have the highest list price.
Hint: You’ll need to use a simple subquery to get the highest
list price and use it in a WHERE clause. 
*/
 select p.ProductID, p.Name, p.ListPrice
 from Production.Product p
 where p.ListPrice = (select max(pd.ListPrice) from Production.product pd);

 
SELECT ProductID, Name, ListPrice
FROM Production.Product
WHERE ListPrice = 
(
	SELECT MAX(ListPrice) 
	FROM Production.Product
);



 /* 2-4 Write a query to retrieve the total quantity sold for each product. 
 Include only products that have a total quantity sold greater than 3000. 
 Sort the results by the total quantity sold in the descending order. 
 Include the product ID, product name, and total quantity sold columns in the report.
 Hint: Use the Sales.SalesOrderDetail and Production.Product tables. */

select p.ProductID, p.Name, sum(od.OrderQty) as "Total Quantity"
from production.product p  inner join sales.SalesOrderDetail od
on p.ProductID = od.ProductID
group by p.ProductID, p.Name
having sum(od.OrderQty) > 3000
order by "Total Quantity" desc;

/* 2-5 Write a SQL query to generate a list of customer ID's and
account numbers that have never placed an order before.
Sort the list by CustomerID in the ascending order. */

select c.CustomerID, c.AccountNumber 
from sales.Customer c 
where c.CustomerID not in 
		( select distinct oh.CustomerID
		from sales.SalesOrderHeader oh) 
order by c.CustomerID desc;

 /* 2-6 Write a query to create a report containing customer id, first name,
 last name and email address for all customers. Sort the returned data by CustomerID. */

 select c.CustomerID , pn.FirstName , pn.LastName ,pe.EmailAddress
 from Sales.Customer c JOIN Person.person pn
 on c.PersonID = pn.BusinessEntityID LEFT JOIN Person.EmailAddress pe
 on c.PersonID = pe.BusinessEntityID
 order by c.CustomerID;
