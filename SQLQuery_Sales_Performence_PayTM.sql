
--TIME SERIES ANALYSIS
--1. Total revenue of all successful transactions from 2019 to 2020

SELECT
    YEAR(transaction_time) AS year
    ,MONTH(transaction_time) AS month
    ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
    ,SUM(1.0*charged_amount) AS total_revenue
FROM fact_transaction_2019 
WHERE status_id = 1
GROUP BY YEAR(transaction_time), MONTH(transaction_time)
UNION
SELECT
    YEAR(transaction_time) AS year
    ,MONTH(transaction_time) AS month
    ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
    ,SUM(1.0*charged_amount) AS total_revenue
FROM fact_transaction_2020
WHERE status_id = 1
GROUP BY YEAR(transaction_time), MONTH(transaction_time)


-- WITH CTE AS
-- (
--     SELECT  
--         YEAR(transaction_time) AS year 
--         ,MONTH(transaction_time) AS month 
--         ,original_price 
--         ,discount_value
--     FROM fact_transaction_2019
--     WHERE MONTH(transaction_time) IN (9,10,11,12) AND status_id = 1
--     UNION
--     SELECT  
--         YEAR(transaction_time) AS year 
--         ,MONTH(transaction_time) AS month 
--         ,original_price 
--         ,discount_value
--     FROM fact_transaction_2020
--     WHERE MONTH(transaction_time) IN (1,2,3,4,5,6,7) AND status_id = 1
-- )
-- SELECT *
-- FROM CTE
-- ORDER BY year, month 


--2. The revenue of each category of successful transactions from 2019 to 2020

WITH CTE AS
(
    SELECT
        YEAR(transaction_time) AS year
        ,MONTH(transaction_time) AS month
        ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
        ,sce.category 
        ,SUM(1.0*charged_amount) AS total_revenue
    FROM fact_transaction_2019 AS tran19
    LEFT JOIN dim_scenario AS sce
        ON tran19.scenario_id = sce.scenario_id 
    WHERE status_id = 1
    GROUP BY YEAR(transaction_time), MONTH(transaction_time), sce.category 
), CTE2 AS
(
    SELECT 
        year 
        ,month 
        ,date 
        ,SUM(CASE WHEN category = 'Billing' THEN total_revenue ELSE 0 END) AS Billing
        ,SUM(CASE WHEN category = 'Delivery' THEN total_revenue ELSE 0 END) AS Delivery
        ,SUM(CASE WHEN category = 'Entertainment' THEN total_revenue ELSE 0 END) AS Entertainment
        ,SUM(CASE WHEN category = 'FnB' THEN total_revenue ELSE 0 END) AS FnB
        ,SUM(CASE WHEN category = 'Game' THEN total_revenue ELSE 0 END) AS Game
        ,SUM(CASE WHEN category = 'Marketplace' THEN total_revenue ELSE 0 END) AS Marketplace
        ,SUM(CASE WHEN category = 'Movies' THEN total_revenue ELSE 0 END) AS Movies
        ,SUM(CASE WHEN category = 'Not Payment' THEN total_revenue ELSE 0 END) AS [Not_Payment]
        ,SUM(CASE WHEN category = 'Other Services' THEN total_revenue ELSE 0 END) AS [Other_Services]
        ,SUM(CASE WHEN category = 'Shopping' THEN total_revenue ELSE 0 END) AS Shopping
        ,SUM(CASE WHEN category = 'Telco' THEN total_revenue ELSE 0 END) AS Telco
        ,SUM(CASE WHEN category = 'Transportation' THEN total_revenue ELSE 0 END) AS Transportation
        ,SUM(CASE WHEN category = 'Traveling' THEN total_revenue ELSE 0 END) AS Traveling
        ,SUM(CASE WHEN category IS NULL THEN total_revenue ELSE 0 END) AS Unknown 
    FROM CTE 
    GROUP BY year, month, date 
), CTE3 AS
(
    SELECT
        YEAR(transaction_time) AS year
        ,MONTH(transaction_time) AS month
        ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
        ,sce.category 
        ,SUM(1.0*charged_amount) AS total_revenue
    FROM fact_transaction_2020 AS tran20
    LEFT JOIN dim_scenario AS sce
        ON tran20.scenario_id = sce.scenario_id 
    WHERE status_id = 1
    GROUP BY YEAR(transaction_time), MONTH(transaction_time), sce.category 
), CTE4 AS
(
    SELECT 
        year 
        ,month 
        ,date 
        ,SUM(CASE WHEN category = 'Billing' THEN total_revenue ELSE 0 END) AS Billing
        ,SUM(CASE WHEN category = 'Delivery' THEN total_revenue ELSE 0 END) AS Delivery
        ,SUM(CASE WHEN category = 'Entertainment' THEN total_revenue ELSE 0 END) AS Entertainment
        ,SUM(CASE WHEN category = 'FnB' THEN total_revenue ELSE 0 END) AS FnB
        ,SUM(CASE WHEN category = 'Game' THEN total_revenue ELSE 0 END) AS Game
        ,SUM(CASE WHEN category = 'Marketplace' THEN total_revenue ELSE 0 END) AS Marketplace
        ,SUM(CASE WHEN category = 'Movies' THEN total_revenue ELSE 0 END) AS Movies
        ,SUM(CASE WHEN category = 'Not Payment' THEN total_revenue ELSE 0 END) AS [Not_Payment]
        ,SUM(CASE WHEN category = 'Other Services' THEN total_revenue ELSE 0 END) AS [Other_Services]
        ,SUM(CASE WHEN category = 'Shopping' THEN total_revenue ELSE 0 END) AS Shopping
        ,SUM(CASE WHEN category = 'Telco' THEN total_revenue ELSE 0 END) AS Telco
        ,SUM(CASE WHEN category = 'Transportation' THEN total_revenue ELSE 0 END) AS Transportation
        ,SUM(CASE WHEN category = 'Traveling' THEN total_revenue ELSE 0 END) AS Traveling
        ,SUM(CASE WHEN category IS NULL THEN total_revenue ELSE 0 END) AS Unknown 
    FROM CTE3 
    GROUP BY year, month, date 
), CTE5 AS
(
    SELECT *
    FROM CTE2
    UNION
    SELECT *
    FROM CTE4
)
SELECT
    CTE5.year 
    ,CTE5.month 
    ,CTE5.date 
    ,FORMAT(Billing / total_revenue, 'p') AS Billing_pct
    ,FORMAT(Delivery / total_revenue, 'p') AS Delivery_pct
    ,FORMAT(Entertainment / total_revenue, 'p') AS Entertainment_pct
    ,FORMAT(FnB / total_revenue, 'p') AS FnB_pct
    ,FORMAT(Game / total_revenue, 'p') AS Game_pct
    ,FORMAT(Marketplace / total_revenue, 'p') AS Marketplace_pct
    ,FORMAT(Movies / total_revenue, 'p') AS Movies_pct
    ,FORMAT(Not_Payment / total_revenue, 'p') AS Not_Payment_pct
    ,FORMAT(Other_Services / total_revenue, 'p') AS Other_Services_pct
    ,FORMAT(Shopping / total_revenue, 'p') AS Shopping_pct
    ,FORMAT(Telco / total_revenue, 'p') AS Telco_pct
    ,FORMAT(Transportation / total_revenue, 'p') AS Transportation_pct
    ,FORMAT(Traveling / total_revenue, 'p') AS Traveling_pct
    ,FORMAT(Unknown / total_revenue, 'p') AS Unknown_pct
    ,Total.total_revenue 
FROM CTE5
JOIN (
        SELECT
            YEAR(transaction_time) AS year
            ,MONTH(transaction_time) AS month
            ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
            ,SUM(1.0*charged_amount) AS total_revenue
        FROM fact_transaction_2019 
        WHERE status_id = 1
        GROUP BY YEAR(transaction_time), MONTH(transaction_time)
        UNION
        SELECT
            YEAR(transaction_time) AS year
            ,MONTH(transaction_time) AS month
            ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
            ,SUM(1.0*charged_amount) AS total_revenue
        FROM fact_transaction_2020
        WHERE status_id = 1
        GROUP BY YEAR(transaction_time), MONTH(transaction_time)
     ) AS Total 
ON CTE5.date = Total.date


--3. The changes of total revenue comparing to the January, 2019
WITH CTE AS
(
    SELECT
        YEAR(transaction_time) AS year
        ,MONTH(transaction_time) AS month
        ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
        ,SUM(1.0*charged_amount) AS total_revenue
    FROM fact_transaction_2019 
    WHERE status_id = 1
    GROUP BY YEAR(transaction_time), MONTH(transaction_time)
    UNION
    SELECT
        YEAR(transaction_time) AS year
        ,MONTH(transaction_time) AS month
        ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date 
        ,SUM(1.0*charged_amount) AS total_revenue
    FROM fact_transaction_2020
    WHERE status_id = 1
    GROUP BY YEAR(transaction_time), MONTH(transaction_time)
)
SELECT
    year 
    ,month 
    ,date 
    ,total_revenue
    ,FIRST_VALUE(total_revenue) OVER(ORDER BY year, month) AS starting_revenue
    ,FORMAT(total_revenue / FIRST_VALUE(total_revenue) OVER(ORDER BY year, month) -1, 'p') AS changes_comparing_2019
FROM CTE 

--4. Comparing revenue of same month versus last year
WITH CTE AS 
(
    SELECT 
        CAST(transaction_time AS DATE) AS transaction_time  
        ,SUM(1.0*charged_amount) AS charge_amount  
    FROM fact_transaction_2019 
    GROUP BY CAST(transaction_time AS DATE)  
    UNION
    SELECT 
        CAST(transaction_time AS DATE) AS transaction_time  
        ,SUM(1.0*charged_amount) AS charge_amount  
    FROM fact_transaction_2020
    GROUP BY CAST(transaction_time AS DATE)
), CTE2 AS 
(
    SELECT 
        YEAR(transaction_time) AS year 
        ,MONTH(transaction_time) AS month
        ,CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time)) AS date
        ,SUM(charge_amount) AS charge_amount 
        ,LAG(CONCAT(YEAR(transaction_time), '-', MONTH(transaction_time))) OVER(PARTITION BY MONTH(transaction_time) ORDER BY MONTH(transaction_time)) AS month_preyear
        ,LAG(SUM(charge_amount)) OVER(PARTITION BY MONTH(transaction_time) ORDER BY MONTH(transaction_time)) AS amount_month_preyear
    FROM CTE 
    GROUP BY YEAR(transaction_time), MONTH(transaction_time)
)
SELECT 
    date 
    ,month 
    ,charge_amount
    ,month_preyear 
    ,amount_month_preyear
    ,FORMAT(charge_amount / amount_month_preyear - 1, 'p') AS pct_diff
FROM CTE2
WHERE amount_month_preyear IS NOT NULL

--COHORT ANALYSIS - RETENTION ANALYSIS
--1. The retention rate of the company in each month in 2020

WITH CTE AS 
(
    SELECT
        customer_id  
        ,MIN(MONTH(transaction_time)) AS first_month_tran 
    FROM fact_transaction_2020 
    WHERE status_id = 1
    GROUP BY customer_id 
), CTE2 AS 
(
    SELECT 
        first_month_tran 
        ,COUNT(DISTINCT customer_id) AS new_customers
    FROM CTE 
    GROUP BY first_month_tran
), CTE3 AS 
(
    SELECT 
        customer_id 
        ,MONTH(transaction_time) AS subsequent_month
    FROM fact_transaction_2020 AS tran20
    WHERE status_id = 1
    GROUP BY customer_id, MONTH(transaction_time)
), CTE4 AS 
(
    SELECT 
        first_month_tran 
        ,subsequent_month 
        ,COUNT(CTE.customer_id) AS retained_customers
        ,FIRST_VALUE(COUNT(DISTINCT CTE.customer_id)) OVER(PARTITION BY first_month_tran ORDER BY first_month_tran, subsequent_month) AS original_customers
    FROM CTE3 
    JOIN CTE 
        ON CTE3.customer_id = CTE.customer_id 
    GROUP BY first_month_tran, subsequent_month
), CTE5 AS 
(
    SELECT 
        first_month_tran AS acquisition_month
        ,subsequent_month - first_month_tran AS subsequent_month
        ,retained_customers
        ,original_customers
        ,FORMAT(1.0*retained_customers / original_customers, 'p') AS retention_rate
    FROM CTE4 
)
SELECT
    acquisition_month
    ,original_customers
    ,FORMAT(SUM(CASE WHEN subsequent_month = 0 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [0]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 1 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [1]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 2 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [2]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 3 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [3]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 4 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [4]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 5 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [5]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 6 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [6]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 7 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [7]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 8 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [8]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 9 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [9]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 10 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [10]
    ,FORMAT(1.0*SUM(CASE WHEN subsequent_month = 11 THEN retained_customers ELSE 0 END) / original_customers, 'p') AS [11]
FROM CTE5
GROUP BY acquisition_month, original_customers
ORDER BY acquisition_month

--USER SEGMENTATION
WITH CTE AS
(
    SELECT 
        tran19.customer_id 
        ,DATEDIFF(day, MAX(tran19.transaction_time), '2020-12-31') AS Recency
        ,COUNT(DISTINCT(CAST(tran19.transaction_time AS Date))) AS Frequency
        ,SUM(1.0*tran19.charged_amount) AS Monetary
    FROM dbo.fact_transaction_2019 AS tran19
    WHERE status_id = 1 
    GROUP BY tran19.customer_id 
    UNION 
    SELECT 
        tran20.customer_id 
        ,DATEDIFF(day, MAX(tran20.transaction_time), '2020-12-31') AS Recency
        ,COUNT(DISTINCT(CAST(tran20.transaction_time AS Date))) AS Frequency
        ,SUM(1.0*tran20.charged_amount) AS Monetary
    FROM dbo.fact_transaction_2020 AS tran20
    WHERE status_id = 1
    GROUP BY tran20.customer_id 
), CTE2 AS
(
    SELECT 
        customer_id 
        ,Recency
        ,Frequency
        ,Monetary
        ,CASE WHEN PERCENT_RANK() OVER(ORDER BY Recency DESC) > 0.75 THEN 1
            WHEN PERCENT_RANK() OVER(ORDER BY Recency DESC) > 0.5 THEN 2
            WHEN PERCENT_RANK() OVER(ORDER BY Recency DESC) > 0.25 THEN 3
        ELSE 4 END AS Recency_tier
        ,CASE WHEN PERCENT_RANK() OVER(ORDER BY Frequency) > 0.75 THEN 1
            WHEN PERCENT_RANK() OVER(ORDER BY Frequency) > 0.5 THEN 2
            WHEN PERCENT_RANK() OVER(ORDER BY Frequency) > 0.25 THEN 3
        ELSE 4 END AS Frequency_tier
        ,CASE WHEN PERCENT_RANK() OVER(ORDER BY Monetary) > 0.75 THEN 1
            WHEN PERCENT_RANK() OVER(ORDER BY Monetary) > 0.5 THEN 2
            WHEN PERCENT_RANK() OVER(ORDER BY Monetary) > 0.25 THEN 3
        ELSE 4 END AS Monetary_tier
    FROM CTE
), CTE3 AS
(
    SELECT 
        customer_id
        ,Recency_tier
        ,Frequency_tier
        ,Monetary_tier
        ,CONCAT(Recency_tier, Frequency_tier, Monetary_tier) AS rfm_score
    FROM CTE2 
), CTE4 AS
(
    SELECT 
    customer_id
            ,Recency_tier
            ,Frequency_tier
            ,Monetary_tier
            ,CASE WHEN rfm_score = '111' THEN 'Best customers' 
                WHEN rfm_score LIKE '[3,4][3,4][1-4]' THEN 'Lost Bad customers'
                WHEN rfm_score LIKE '[3,4]2[1-4]' THEN 'Lost customers' 
                WHEN rfm_score LIKE '21[1-4]' THEN 'Almost lost'
                WHEN rfm_score LIKE '11[2-4]' THEN 'Loyal customers'
                WHEN rfm_score LIKE '[1,2][1-3]1' THEN 'Big Spender'
                WHEN rfm_score LIKE '[1,2]4[1-4]' THEN 'New customers'
                WHEN rfm_score LIKE '[3,4]1[1-4]' THEN 'Hibernating'
                WHEN rfm_score LIKE '[1,2][2,3][2-4]' THEN 'Potential Loyalist'
            ELSE 'unknown' END AS Segment 
    FROM CTE3 
)
SELECT 
    Segment
    ,COUNT(customer_id) AS number_users 
    ,SUM(COUNT(customer_id)) OVER() AS total_users
    ,FORMAT( 1.0*COUNT( customer_id) / SUM( COUNT( customer_id)) OVER(), 'p') AS pct
FROM CTE4
GROUP BY Segment


