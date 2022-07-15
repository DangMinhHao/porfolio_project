/* Here is my queries to pull data from AventureWorks2019 database to analyze the Sale Management project */

--Calendar Table
SELECT
	FullDateAlternateKey AS Date,
	EnglishDayNameOfWeek AS Day,
	EnglishMonthName AS Month,
	LEFT(EnglishMonthName, 3) AS Month_short,
	DATEPART(MONTH, FullDateAlternateKey) AS Month_num,
	CalendarQuarter AS Quarter,
	CalendarYear AS Year
FROM DimDate
WHERE CalendarYear IN (2019,2020,2021)


--Customer Table
SELECT 
	c.CustomerKey AS Customer_key,
	c.FirstName AS First_name,
	c.LastName AS Last_name,
	CASE WHEN Gender = 'M' THEN 'Male'
		 WHEN Gender = 'F' THEN 'Female'
	END AS Gender,
	CONCAT(c.FirstName, ' ', c.LastName) AS Full_name,
	g.City AS City,
	g.EnglishCountryRegionName AS Country,
	s.SalesTerritoryRegion AS Region
FROM [dbo].[DimCustomer] c
LEFT JOIN [dbo].[DimGeography] g
	ON c.GeographyKey = g.GeographyKey
LEFT JOIN [dbo].[DimSalesTerritory] s
	ON g.SalesTerritoryKey = s.SalesTerritoryKey

	
--Product Table
WITH CTE AS 
(
	SELECT 
		p.ProductKey AS Product_key,
		p.EnglishProductName AS Product,
		c.EnglishProductCategoryName AS Category,
		s.EnglishProductSubcategoryName AS Subcategory
	FROM [dbo].[DimProduct] p
	LEFT JOIN [dbo].[DimProductSubcategory] s
		ON p.ProductSubcategoryKey = s.ProductSubcategoryKey
	LEFT JOIN [dbo].[DimProductCategory] c
		ON s.ProductCategoryKey = c.ProductCategoryKey
)
SELECT 
	Product_key,
	Product,
	CASE 
		WHEN Category IS NOT NULL THEN Category ELSE 'Others' 
	END AS Category,
	CASE 
		WHEN Subcategory IS NOT NULL THEN Subcategory ELSE 'Others' 
	END AS Subcategory
FROM CTE

--Internet Sales
SELECT 
	ProductKey AS Product_key,
	OrderDate AS Order_date,
	ShipDate AS Ship_date,
	DueDate AS Due_date,
	CustomerKey AS Customer_key,
	OrderQuantity AS Order_quantity,
	UnitPrice AS Unit_price,
	SalesAmount AS Sales_amount
FROM [dbo].[FactInternetSales]
WHERE DATEPART(year, OrderDate) IN (2019, 2020, 2021)
