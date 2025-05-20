-- Advanced SQL Examples for Metabase
-- This file contains advanced SQL techniques that can be used in Metabase

-- Example 1: Common Table Expressions (CTEs)
-- CTEs help break down complex queries into more manageable parts
WITH monthly_revenue AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE order_date BETWEEN {{start_date}} AND {{end_date}}
    GROUP BY month
),
monthly_growth AS (
    SELECT
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
    FROM monthly_revenue
)
SELECT
    month,
    revenue,
    previous_month_revenue,
    CASE 
        WHEN previous_month_revenue IS NULL THEN NULL
        ELSE (revenue - previous_month_revenue) / previous_month_revenue * 100 
    END AS growth_percentage
FROM monthly_growth
ORDER BY month;

-- Example 2: Window Functions
-- Window functions perform calculations across a set of table rows
SELECT
    product_id,
    product_name,
    category,
    price,
    AVG(price) OVER (PARTITION BY category) AS category_avg_price,
    price - AVG(price) OVER (PARTITION BY category) AS difference_from_avg,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) AS price_rank_in_category
FROM products
WHERE {{category}};

-- Example 3: Pivoting Data
-- Converts row data into column format for easier analysis
SELECT
    DATE_TRUNC('month', order_date) AS month,
    SUM(CASE WHEN category = 'Electronics' THEN total_amount ELSE 0 END) AS electronics_revenue,
    SUM(CASE WHEN category = 'Clothing' THEN total_amount ELSE 0 END) AS clothing_revenue,
    SUM(CASE WHEN category = 'Books' THEN total_amount ELSE 0 END) AS books_revenue,
    SUM(CASE WHEN category = 'Home & Kitchen' THEN total_amount ELSE 0 END) AS home_kitchen_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
WHERE order_date BETWEEN {{start_date}} AND {{end_date}}
GROUP BY month
ORDER BY month;

-- Example 4: Recursive Queries
-- Useful for hierarchical data like organization charts or product categories
WITH RECURSIVE category_hierarchy AS (
    -- Base case: top-level categories (no parent)
    SELECT 
        id, 
        name, 
        parent_id, 
        0 AS level, 
        name AS path
    FROM categories
    WHERE parent_id IS NULL
    
    UNION ALL
    
    -- Recursive case: categories with parents
    SELECT 
        c.id, 
        c.name, 
        c.parent_id, 
        ch.level + 1, 
        ch.path || ' > ' || c.name
    FROM categories c
    JOIN category_hierarchy ch ON c.parent_id = ch.id
)
SELECT 
    id,
    name,
    level,
    path
FROM category_hierarchy
ORDER BY path;

-- Example 5: Advanced Aggregations with Filters
-- Combining multiple aggregates with different filtering conditions
SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    COUNT(DISTINCT CASE WHEN o.is_first_purchase THEN o.customer_id END) AS new_customers,
    SUM(o.total_amount) AS total_revenue,
    SUM(o.total_amount) / COUNT(DISTINCT o.order_id) AS average_order_value,
    SUM(CASE WHEN o.order_status = 'returned' THEN o.total_amount ELSE 0 END) AS returned_amount,
    COUNT(CASE WHEN o.order_status = 'returned' THEN 1 END) AS returned_orders
FROM orders o
WHERE o.order_date BETWEEN {{start_date}} AND {{end_date}}
GROUP BY month
ORDER BY month;

-- Example 6: Cohort Analysis
-- Track user behavior over time from their first interaction
WITH first_purchases AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    GROUP BY customer_id
),
customer_activity AS (
    SELECT
        fp.customer_id,
        fp.cohort_month,
        DATE_TRUNC('month', o.order_date) AS activity_month,
        EXTRACT(MONTH FROM DATE_TRUNC('month', o.order_date) - fp.cohort_month) AS months_since_first_purchase
    FROM first_purchases fp
    JOIN orders o ON fp.customer_id = o.customer_id
)
SELECT
    cohort_month,
    months_since_first_purchase,
    COUNT(DISTINCT customer_id) AS active_customers
FROM customer_activity
WHERE cohort_month BETWEEN {{start_date}} AND {{end_date}}
GROUP BY cohort_month, months_since_first_purchase
ORDER BY cohort_month, months_since_first_purchase;

-- Example 7: Moving Averages
-- Calculate rolling metrics for trend analysis
SELECT
    order_date,
    total_daily_revenue,
    AVG(total_daily_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_day_moving_avg
FROM (
    SELECT
        DATE_TRUNC('day', order_date) AS order_date,
        SUM(total_amount) AS total_daily_revenue
    FROM orders
    WHERE order_date BETWEEN {{start_date}} AND {{end_date}}
    GROUP BY DATE_TRUNC('day', order_date)
) daily_revenue
ORDER BY order_date;

-- Example 8: String Manipulation and Regular Expressions
-- Advanced text processing
SELECT
    product_id,
    product_name,
    REGEXP_REPLACE(product_name, '[^a-zA-Z0-9 ]', '', 'g') AS cleaned_name,
    LOWER(SUBSTRING(product_name, 1, 10)) AS short_name,
    LENGTH(product_name) AS name_length,
    CASE 
        WHEN product_name ~* 'premium|deluxe|professional' THEN 'Premium'
        WHEN product_name ~* 'basic|standard|regular' THEN 'Standard'
        ELSE 'Other'
    END AS product_tier
FROM products
WHERE {{category}}
LIMIT 100;