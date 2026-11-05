/*
Project: EmporiUm Sales Analysis
Analyst: Alizon Martinez
Assigned territory: Maryland
Assigned region: Northeast

This script analyzes in-store and online sales for Maryland.
It provides total revenue, date coverage, the monthly and yearly sales, regional comparisons 
transaction statistics, category peformance and a recommendation for the next quarterly 
review.
*/

USE sample_sales;

SELECT
    StoreId,
    StoreLocation,
    State
FROM Store_Locations
WHERE State = 'Maryland'
ORDER BY StoreLocation;

SELECT
	COUNT(*) AS MarylandOnlineTransactions
FROM Online_Sales
WHERE ShiptoState = 'Maryland';

-- Question 1:
-- Total Maryland revenue. In-store sales,
-- With first and last transaction dates.

SELECT
	MIN(MarylandSales.SaleDate) AS StartDate,
    MAX(MarylandSales.SaleDate) AS EndDate,
    ROUND(SUM(MarylandSales.Revenue), 2) AS TotalMarylandRevenue
FROM
(
	-- Maryland in-store sales
    SELECT
		ss.Transaction_Date AS SaleDate,
        ss.Sale_Amount AS Revenue
	FROM Store_Sales AS ss
    INNER JOIN Store_Locations AS sl
		ON ss.Store_ID = sl.StoreId
	WHERE sl.State = 'Maryland'
) AS MarylandSales;

-- Question 2:
-- Maryland revenue by year and month.

SELECT
    YEAR(MarylandSales.SaleDate) AS SaleYear,
    MONTH(MarylandSales.SaleDate) AS SaleMonthNumber,
    MONTHNAME(MarylandSales.SaleDate) AS SaleMonth,
    ROUND(SUM(MarylandSales.Revenue), 2) AS TotalRevenue
FROM
(
    SELECT
        ss.Transaction_Date AS SaleDate,
        ss.Sale_Amount AS Revenue
    FROM Store_Sales AS ss
    INNER JOIN Store_Locations AS sl
        ON ss.Store_ID = sl.StoreId
    WHERE sl.State = 'Maryland'
) AS MarylandSales
GROUP BY
    YEAR(MarylandSales.SaleDate),
    MONTH(MarylandSales.SaleDate),
    MONTHNAME(MarylandSales.SaleDate)
ORDER BY
    SaleYear,
    SaleMonthNumber;
    
-- Maryland yearly revenue by sales channel.

SELECT
    YEAR(ChannelSales.SaleDate) AS SaleYear,
    ChannelSales.SalesChannel,
    ROUND(SUM(ChannelSales.Revenue), 2) AS TotalRevenue
FROM
(
    SELECT
        ss.Transaction_Date AS SaleDate,
        'In-store' AS SalesChannel,
        ss.Sale_Amount AS Revenue
    FROM Store_Sales AS ss
    INNER JOIN Store_Locations AS sl
        ON ss.Store_ID = sl.StoreId
    WHERE sl.State = 'Maryland'
) AS ChannelSales
GROUP BY
    YEAR(ChannelSales.SaleDate),
    ChannelSales.SalesChannel
ORDER BY
    SaleYear,
    SalesChannel;
    
-- Question 3:
-- Compare total Maryland revenue with total Northeast regional revenue.

SELECT 
	Comparison.Area,
    ROUND(SUM(Comparison.Revenue), 2) AS TotalRevenue
FROM
(
	-- Maryland in-store
    SELECT
		'Maryland' AS Area,
        ss.Sale_Amount AS Revenue
	FROM Store_Sales AS ss
    INNER JOIN Store_Locations AS sl
		ON  ss.Store_ID = sl.StoreId
	WHERE sl.State = 'Maryland'
    
    UNION ALL 
    -- Northeast in-store
    SELECT
		'Northeast Region',
        ss.Sale_Amount
	FROM Store_Sales AS ss
    INNER JOIN Store_Locations AS sl
		ON ss.Store_ID = sl.StoreId
	INNER JOIN Management AS m
		ON sl.State = m.State
	WHERE m.Region = 'Northeast'    
) AS Comparison
GROUP BY Comparison.Area
ORDER BY TotalRevenue DESC;

-- Maryland revenue as a percentage of Northeast regional revenue.

SELECT
    ROUND(
        Maryland.TotalRevenue /
        NULLIF(Northeast.TotalRevenue, 0) * 100,
        2
    ) AS MarylandPercentOfNortheast
FROM
(
    SELECT SUM(Revenue) AS TotalRevenue
    FROM
    (
        SELECT ss.Sale_Amount AS Revenue
        FROM Store_Sales AS ss
        INNER JOIN Store_Locations AS sl
            ON ss.Store_ID = sl.StoreId
        WHERE sl.State = 'Maryland'
    ) AS MarylandRevenue
) AS Maryland
CROSS JOIN
(
    SELECT SUM(Revenue) AS TotalRevenue
    FROM
    (
        SELECT ss.Sale_Amount AS Revenue
        FROM Store_Sales AS ss
        INNER JOIN Store_Locations AS sl
            ON ss.Store_ID = sl.StoreId
        INNER JOIN Management AS m
            ON sl.State = m.State
        WHERE m.Region = 'Northeast'
    ) AS NortheastRevenue
) AS Northeast;

    -- Question 4:
-- Monthly transaction count and average transaction amount
-- by product category for Maryland.

SELECT
    ic.Category,
    COUNT(*) AS TransactionCount,
    ROUND(SUM(MarylandSales.Revenue), 2) AS TotalRevenue,
    ROUND(AVG(MarylandSales.Revenue), 2) AS AverageTransactionAmount
FROM
(
    SELECT
        ss.Prod_Num AS ProductNumber,
        ss.Sale_Amount AS Revenue
    FROM Store_Sales AS ss
    INNER JOIN Store_Locations AS sl
        ON ss.Store_ID = sl.StoreId
    WHERE sl.State = 'Maryland'
) AS MarylandSales
INNER JOIN Products AS p
    ON MarylandSales.ProductNumber = p.ProdNum
INNER JOIN Inventory_Categories AS ic
    ON p.Categoryid = ic.Categoryid
GROUP BY
    ic.Categoryid,
    ic.Category
ORDER BY TotalRevenue DESC;

-- Question 5:
-- Rank Maryland stores by total in-store revenue.

SELECT
    RANK() OVER (
        ORDER BY SUM(ss.Sale_Amount) DESC
    ) AS RevenueRank,
    sl.StoreId,
    sl.StoreLocation,
    COUNT(*) AS TransactionCount,
    ROUND(SUM(ss.Sale_Amount), 2) AS TotalRevenue,
    ROUND(AVG(ss.Sale_Amount), 2) AS AverageTransactionAmount
FROM Store_Sales AS ss
INNER JOIN Store_Locations AS sl
    ON ss.Store_ID = sl.StoreId
WHERE sl.State = 'Maryland'
GROUP BY
    sl.StoreId,
    sl.StoreLocation
ORDER BY
    TotalRevenue DESC;
    
-- Question 6:
-- Quarterly Maryland performance for the latest year. 

SELECT
	QUARTER(MarylandSales.SaleDate) AS SaleQuarter,
    MarylandSales.SalesChannel,
    COUNT(*) AS SaleQuater,
    ROUND(SUM(MarylandSales.Revenue), 2) AS TotalRevenue,
    ROUND(AVG(MarylandSales.Revenue), 2) AS AverageTransactionAmount
FROM
(
	SELECT
		ss.Transaction_Date AS SaleDate,
        'In-store' AS SalesChannel,
        ss.Sale_Amount AS Revenue
	FROM Store_Sales AS ss
    INNER JOIN Store_Locations AS sl
		ON ss.Store_ID = sl.StoreId
	WHERE sl.State = 'Maryland'
		AND YEAR(ss.Transaction_Date) = 2025
) AS Marylandsales
GROUP BY
	QUARTER(MarylandSales.SaleDate),
    MarylandSales.SalesChannel
ORDER BY
	SaleQuarter,
    SalesChannel;
	
    
    
    
    



    
    
    









    



    
    


