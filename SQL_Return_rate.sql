/*
Return rate for each product in each territory
Skills used: Union, Joins, CTE's, Aggregate Functions
*/
WITH Sales AS --merge 3 sale tables from 2015-2017
( 
	SELECT *
	FROM AdventureWorks_Sales_2015$
	UNION
	SELECT *
	FROM AdventureWorks_Sales_2016$
	UNION
	SELECT *
	FROM AdventureWorks_Sales_2017$
), 
	Total_quantity AS --calculate total order quantity in Sales table
(	
	SELECT ProductKey, TerritoryKey, SUM(OrderQuantity) AS TotalQuantity
	FROM Sales
	GROUP BY ProductKey,TerritoryKey
),
	Total_return AS --calculate total return quantity in Returns table
(
	SELECT ProductKey, TerritoryKey, SUM(ReturnQuantity) TotalReturn
	FROM AdventureWorks_Returns$
	GROUP BY ProductKey, TerritoryKey
), 
	product_sales AS --join Total_quantity and Total_return and Products table to have a table with full information about products
(
	SELECT q.ProductKey, q.TerritoryKey, p.ProductName, p.ModelName, q.TotalQuantity, 
			CASE WHEN r.TotalReturn IS NOT NULL THEN r.TotalReturn ELSE 0 END AS TotalReturn
	FROM Total_quantity q
	LEFT JOIN Total_return r
	ON q.ProductKey = r.ProductKey AND q.TerritoryKey = r.TerritoryKey
	JOIN AdventureWorks_Products$ p
	ON q.ProductKey = p.ProductKey
), 
	Retention_rate AS --calculate retention rate 
(
	SELECT ProductKey, TerritoryKey, ProductName, ModelName, TotalQuantity, TotalReturn , 
			ROUND((TotalReturn/TotalQuantity)*100, 2) AS RetentionRate
	FROM product_sales
)
SELECT *
FROM Retention_rate
ORDER BY ProductKey
