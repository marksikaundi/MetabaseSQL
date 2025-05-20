-- Common Use Cases for SQL in Metabase
-- This file contains examples of common SQL queries for various business scenarios

-- Example 1: Sales Dashboard Metrics
-- Key metrics for a sales dashboard
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(total_amount) AS revenue,
    SUM(total_amount) / COUNT(DISTINCT order_id) AS average_order_value,
    SUM(total_amount) / COUNT(DISTINCT customer_id) AS revenue_per_customer
FROM orders
WHERE order_date BETWEEN {{start_date}} AND {{end_date}}
GROUP BY month
ORDER BY month;

-- Example 2: Product Performance Analysis
-- Analyze product performance by category
SELECT 
    p.category,
    p.product_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.quantity) AS units_sold,
    SUM(o.total_amount) AS revenue,
    SUM(o.total_amount) / SUM(o.quantity) AS average_unit_price,
    SUM(o.total_amount) * 100.0 / (SELECT SUM(total_amount) FROM orders WHERE {{order_date}}) AS revenue_percentage
FROM products p
JOIN orders o ON p.product_id = o.product_id
WHERE {{order_date}}
AND {{category}}
GROUP BY p.category, p.product_name
ORDER BY revenue DESC;

-- Example 3: Customer Segmentation
-- Segment customers by purchase frequency and total spend
SELECT 
    CASE 
        WHEN purchase_count >= 10 THEN 'High Frequency'
        WHEN purchase_count >= 5 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_segment,
    CASE 
        WHEN total_spend >= 1000 THEN 'High Spend'
        WHEN total_spend >= 500 THEN 'Medium Spend'
        ELSE 'Low Spend'
    END AS spend_segment,
    COUNT(DISTINCT customer_id) AS customer_count,
    AVG(total_spend) AS average_customer_spend,
    AVG(purchase_count) AS average_purchase_count
FROM (
    SELECT 
        customer_id,
        COUNT(DISTINCT order_id) AS purchase_count,
        SUM(total_amount) AS total_spend
    FROM orders
    WHERE {{order_date}}
    GROUP BY customer_id
) customer_metrics
GROUP BY frequency_segment, spend_segment
ORDER BY frequency_segment, spend_segment;

-- Example 4: Conversion Funnel Analysis
-- Track user progression through a conversion funnel
WITH funnel_stages AS (
    SELECT 
        user_id,
        MIN(CASE WHEN event_name = 'page_view' THEN event_timestamp END) AS page_view_time,
        MIN(CASE WHEN event_name = 'add_to_cart' THEN event_timestamp END) AS add_to_cart_time,
        MIN(CASE WHEN event_name = 'checkout_start' THEN event_timestamp END) AS checkout_start_time,
        MIN(CASE WHEN event_name = 'purchase_complete' THEN event_timestamp END) AS purchase_complete_time
    FROM user_events
    WHERE event_timestamp BETWEEN {{start_date}} AND {{end_date}}
    GROUP BY user_id
)
SELECT 
    COUNT(DISTINCT user_id) AS total_users,
    COUNT(DISTINCT CASE WHEN page_view_time IS NOT NULL THEN user_id END) AS page_view_count,
    COUNT(DISTINCT CASE WHEN add_to_cart_time IS NOT NULL THEN user_id END) AS add_to_cart_count,
    COUNT(DISTINCT CASE WHEN checkout_start_time IS NOT NULL THEN user_id END) AS checkout_start_count,
    COUNT(DISTINCT CASE WHEN purchase_complete_time IS NOT NULL THEN user_id END) AS purchase_complete_count,
    COUNT(DISTINCT CASE WHEN add_to_cart_time IS NOT NULL THEN user_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN page_view_time IS NOT NULL THEN user_id END), 0) AS view_to_cart_rate,
    COUNT(DISTINCT CASE WHEN purchase_complete_time IS NOT NULL THEN user_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN add_to_cart_time IS NOT NULL THEN user_id END), 0) AS cart_to_purchase_rate
FROM funnel_stages;

-- Example 5: Trend Analysis with Year-over-Year Comparison
-- Compare current year metrics with previous year
WITH yearly_data AS (
    SELECT 
        DATE_TRUNC('month', order_date) AS month,
        EXTRACT(YEAR FROM order_date) AS year,
        SUM(total_amount) AS revenue,
        COUNT(DISTINCT order_id) AS order_count
    FROM orders
    WHERE order_date >= DATE_TRUNC('year', {{reference_date}}) - INTERVAL '1 year'
    AND order_date < DATE_TRUNC('year', {{reference_date}}) + INTERVAL '1 year'
    GROUP BY DATE_TRUNC('month', order_date), EXTRACT(YEAR FROM order_date)
)
SELECT 
    TO_CHAR(month, 'Month') AS month_name,
    current_year.revenue AS current_revenue,
    previous_year.revenue AS previous_revenue,
    (current_year.revenue - previous_year.revenue) * 100.0 / NULLIF(previous_year.revenue, 0) AS revenue_growth,
    current_year.order_count AS current_orders,
    previous_year.order_count AS previous_orders,
    (current_year.order_count - previous_year.order_count) * 100.0 / NULLIF(previous_year.order_count, 0) AS order_growth
FROM (
    SELECT month, revenue, order_count
    FROM yearly_data
    WHERE year = EXTRACT(YEAR FROM {{reference_date}})
) current_year
LEFT JOIN (
    SELECT 
        month + INTERVAL '1 year' AS month, 
        revenue, 
        order_count
    FROM yearly_data
    WHERE year = EXTRACT(YEAR FROM {{reference_date}}) - 1
) previous_year ON current_year.month = previous_year.month
ORDER BY current_year.month;