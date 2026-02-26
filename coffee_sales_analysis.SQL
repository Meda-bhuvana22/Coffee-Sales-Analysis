--Monthly Total Sales------------------------------

SELECT
    YEAR(transaction_date)  AS sales_year,
    MONTH(transaction_date) AS sales_month,
    SUM(unit_price * transaction_qty) AS total_sales
FROM [dbo].[Coffee Shop Sales]
GROUP BY 
    YEAR(transaction_date),
    MONTH(transaction_date)
ORDER BY 
    sales_year,
    sales_month;

--MoM Increase/Decrease in Sales--------------------------------

WITH Monthly_Sales AS
(
    SELECT
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY 
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT
    sales_year,
    sales_month,
    total_sales,
    
    LAG(total_sales) OVER (
        ORDER BY sales_year, sales_month
    ) AS previous_month_sales,

    total_sales - 
    LAG(total_sales) OVER (
        ORDER BY sales_year, sales_month
    ) AS mom_difference

FROM Monthly_Sales
ORDER BY sales_year, sales_month;

--MoM Growth Percentage -------------------------------

WITH Monthly_Sales AS
(
    SELECT
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY 
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT
    sales_year,
    sales_month,
    total_sales,
    
    LAG(total_sales) OVER (
        ORDER BY sales_year, sales_month
    ) AS previous_month_sales,

    total_sales -
    LAG(total_sales) OVER (
        ORDER BY sales_year, sales_month
    ) AS mom_difference,

    CASE 
        WHEN LAG(total_sales) OVER (
                ORDER BY sales_year, sales_month
             ) IS NULL 
        THEN NULL
        ELSE 
            (total_sales - 
             LAG(total_sales) OVER (
                 ORDER BY sales_year, sales_month
             )
            ) * 100.0 /
            LAG(total_sales) OVER (
                ORDER BY sales_year, sales_month
            )
    END AS mom_growth_percentage

FROM Monthly_Sales
ORDER BY sales_year, sales_month;


--Monthly Total Orders------------------------------

SELECT
    YEAR(transaction_date)  AS sales_year,
    MONTH(transaction_date) AS sales_month,
    COUNT(DISTINCT transaction_id) AS total_orders
FROM [dbo].[Coffee Shop Sales]
GROUP BY 
    YEAR(transaction_date),
    MONTH(transaction_date)
ORDER BY 
    sales_year,
    sales_month;

--MoM Difference in Orders-----------------------------

WITH Monthly_Orders AS
(
    SELECT
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        COUNT(DISTINCT transaction_id) AS total_orders
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY 
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT
    sales_year,
    sales_month,
    total_orders,

    LAG(total_orders) OVER (
        ORDER BY sales_year, sales_month
    ) AS previous_month_orders,

    total_orders -
    LAG(total_orders) OVER (
        ORDER BY sales_year, sales_month
    ) AS mom_difference_orders

FROM Monthly_Orders
ORDER BY sales_year, sales_month;

--Difference in total number of orders between the selected month and the previous month.-----------
=======================

WITH Monthly_Orders AS
(
    SELECT
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        COUNT(DISTINCT transaction_id) AS total_orders
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY 
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT *
FROM
(
    SELECT
        sales_year,
        sales_month,
        total_orders -
        LAG(total_orders) OVER (
            ORDER BY sales_year, sales_month
        ) AS difference_from_previous
    FROM Monthly_Orders
) t
WHERE sales_year = 2023
AND sales_month = 5;


--Monthly Total Quantity Sold-----------------------------

SELECT
    YEAR(transaction_date)  AS sales_year,
    MONTH(transaction_date) AS sales_month,
    SUM(transaction_qty) AS total_quantity_sold
FROM [dbo].[Coffee Shop Sales]
GROUP BY 
    YEAR(transaction_date),
    MONTH(transaction_date)
ORDER BY 
    sales_year,
    sales_month;

--MoM Difference in Quantity--------------------

WITH Monthly_Quantity AS
(
    SELECT
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(transaction_qty) AS total_quantity
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY 
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT
    sales_year,
    sales_month,
    total_quantity,
    
    LAG(total_quantity) OVER (
        ORDER BY sales_year, sales_month
    ) AS previous_month_quantity,

    total_quantity -
    LAG(total_quantity) OVER (
        ORDER BY sales_year, sales_month
    ) AS mom_difference_quantity

FROM Monthly_Quantity
ORDER BY sales_year, sales_month;

--Difference in quantity sold between selected month and previous month--------------

WITH Monthly_Quantity AS
(
    SELECT
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(transaction_qty) AS total_quantity
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY 
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT *
FROM
(
    SELECT
        sales_year,
        sales_month,
        total_quantity -
        LAG(total_quantity) OVER (
            ORDER BY sales_year, sales_month
        ) AS difference_from_previous
    FROM Monthly_Quantity
) t
WHERE sales_year = 2023
AND sales_month = 5;

--Calendar Heatmap (Daily Data for Selected Month)---------------------------------

SELECT
    transaction_date,
    SUM(unit_price * transaction_qty) AS total_sales,
    COUNT(DISTINCT transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5
GROUP BY transaction_date
ORDER BY transaction_date;

--Weekday vs Weekend Sales---------------------------------

SELECT
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    SUM(unit_price * transaction_qty) AS total_sales

FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5

GROUP BY
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END;

--Weekday vs Weekend Orders---------------------------------

SELECT
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    COUNT(DISTINCT transaction_id) AS total_orders

FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5

GROUP BY
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END;

-- Weekday vs Weekend Quantity---------------------------------

SELECT
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,

    SUM(transaction_qty) AS total_quantity

FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5

GROUP BY
    CASE 
        WHEN DATENAME(WEEKDAY, transaction_date) IN ('Saturday', 'Sunday')
        THEN 'Weekend'
        ELSE 'Weekday'
    END;

--Sales by Store Location----------------------------

SELECT
    store_location,
    SUM(unit_price * transaction_qty) AS total_sales
FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY total_sales DESC;

--MoM Sales by Store--------------------------

WITH Store_Monthly_Sales AS
(
    SELECT
        store_location,
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY
        store_location,
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT *
FROM
(
    SELECT
        store_location,
        sales_year,
        sales_month,
        total_sales,
        total_sales -
        LAG(total_sales) OVER (
            PARTITION BY store_location
            ORDER BY sales_year, sales_month
        ) AS mom_difference
    FROM Store_Monthly_Sales
) t
WHERE sales_year = 2023
AND sales_month = 5
ORDER BY store_location;

--MoM percentage by Store-----------------------

WITH Store_Monthly_Sales AS
(
    SELECT
        store_location,
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY
        store_location,
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT *
FROM
(
    SELECT
        store_location,
        sales_year,
        sales_month,
        total_sales,

        ROUND(
            (
                (total_sales -
                 LAG(total_sales) OVER (
                     PARTITION BY store_location
                     ORDER BY sales_year, sales_month
                 )
                ) * 100.0
            ) /
            LAG(total_sales) OVER (
                PARTITION BY store_location
                ORDER BY sales_year, sales_month
            ),
        2) AS mom_growth_percentage

    FROM Store_Monthly_Sales
) t
WHERE sales_year = 2023
AND sales_month = 5
ORDER BY store_location;

--Sales by Product Category------------------------------------

SELECT
    product_category,
    SUM(unit_price * transaction_qty) AS total_sales
FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY total_sales DESC;

--MoM Sales by Product Category-----------------------------------

WITH Category_Monthly_Sales AS
(
    SELECT
        product_category,
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY
        product_category,
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT *
FROM
(
    SELECT
        product_category,
        sales_year,
        sales_month,
        total_sales,
        total_sales -
        LAG(total_sales) OVER (
            PARTITION BY product_category
            ORDER BY sales_year, sales_month
        ) AS mom_difference
    FROM Category_Monthly_Sales
) t
WHERE sales_year = 2023
AND sales_month = 5
ORDER BY product_category;

--MoM percentage by Product Category---------------------------------

WITH Category_Monthly_Sales AS
(
    SELECT
        product_category,
        YEAR(transaction_date)  AS sales_year,
        MONTH(transaction_date) AS sales_month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM [dbo].[Coffee Shop Sales]
    GROUP BY
        product_category,
        YEAR(transaction_date),
        MONTH(transaction_date)
)

SELECT *
FROM
(
    SELECT
        product_category,
        sales_year,
        sales_month,
        total_sales,

        ROUND(
            (
                (total_sales -
                 LAG(total_sales) OVER (
                     PARTITION BY product_category
                     ORDER BY sales_year, sales_month
                 )
                ) * 100.0
            ) /
            LAG(total_sales) OVER (
                PARTITION BY product_category
                ORDER BY sales_year, sales_month
            ),
        2) AS mom_growth_percentage

    FROM Category_Monthly_Sales
) t
WHERE sales_year = 2023
AND sales_month = 5
ORDER BY product_category;

--Daily Sales for Selected Month--------------------------------

SELECT
    transaction_date,
    SUM(unit_price * transaction_qty) AS daily_sales
FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5
GROUP BY transaction_date
ORDER BY transaction_date;

--Add Average Daily Sales Line-----------------------------------

WITH Daily_Sales AS
(
    SELECT
        transaction_date,
        SUM(unit_price * transaction_qty) AS daily_sales
    FROM [dbo].[Coffee Shop Sales]
    WHERE YEAR(transaction_date) = 2023
    AND MONTH(transaction_date) = 5
    GROUP BY transaction_date
)

SELECT
    transaction_date,
    daily_sales,
    AVG(daily_sales) OVER() AS average_daily_sales
FROM Daily_Sales
ORDER BY transaction_date;

------Highlight Above/Below Average Days----------------------

WITH Daily_Sales AS
(
    SELECT
        transaction_date,
        SUM(unit_price * transaction_qty) AS daily_sales
    FROM [dbo].[Coffee Shop Sales]
    WHERE YEAR(transaction_date) = 2023
    AND MONTH(transaction_date) = 5
    GROUP BY transaction_date
)

SELECT
    transaction_date,
    daily_sales,
    AVG(daily_sales) OVER() AS average_daily_sales,
    CASE 
        WHEN daily_sales > AVG(daily_sales) OVER()
        THEN 'Above Average'
        ELSE 'Below Average'
    END AS performance_flag
FROM Daily_Sales
ORDER BY transaction_date;

------------Top 10 Products by Sales-------------------

SELECT TOP 10
    product_detail,
    SUM(unit_price * transaction_qty) AS total_sales
FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5
GROUP BY product_detail
ORDER BY total_sales DESC;

---------------Sales by Day and Hour-------

SELECT
    DATENAME(WEEKDAY, transaction_date) AS day_name,
    DATEPART(HOUR, transaction_time) AS hour_of_day,
    SUM(unit_price * transaction_qty) AS total_sales
FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5
GROUP BY
    DATENAME(WEEKDAY, transaction_date),
    DATEPART(HOUR, transaction_time)
ORDER BY
    day_name,
    hour_of_day;

------Add Tooltip Metrics (Sales, Orders, Quantity)--------------------

SELECT
    DATENAME(WEEKDAY, transaction_date) AS day_name,
    DATEPART(HOUR, transaction_time) AS hour_of_day,
    SUM(unit_price * transaction_qty) AS total_sales,
    COUNT(DISTINCT transaction_id) AS total_orders,
    SUM(transaction_qty) AS total_quantity
FROM [dbo].[Coffee Shop Sales]
WHERE YEAR(transaction_date) = 2023
AND MONTH(transaction_date) = 5
GROUP BY
    DATENAME(WEEKDAY, transaction_date),
    DATEPART(HOUR, transaction_time)
ORDER BY
    day_name,
    hour_of_day;

