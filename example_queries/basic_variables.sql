-- Basic SQL Variables Example
-- This example demonstrates how to use basic variables in Metabase SQL queries

-- Example 1: Text variable
-- Creates a filter widget where users can input text
SELECT *
FROM products
WHERE category = {{category}}
LIMIT 10;

-- Example 2: Number variable
-- Creates a filter widget where users can input a numeric value
SELECT *
FROM products
WHERE price < {{max_price}}
ORDER BY price DESC
LIMIT 10;

-- Example 3: Date variable
-- Creates a date picker filter widget
SELECT 
    order_date,
    product_id,
    quantity,
    total_amount
FROM orders
WHERE order_date >= {{start_date}}
AND order_date <= {{end_date}}
ORDER BY order_date DESC;

-- Example 4: Optional variable
-- The entire WHERE clause becomes optional if no value is provided
SELECT *
FROM products
[[WHERE category = {{category}}]]
ORDER BY price DESC
LIMIT 10;

-- Example 5: Multiple variables
-- Combines several variables in one query
SELECT
    p.product_name,
    p.category,
    p.price,
    o.order_date,
    o.quantity
FROM products p
JOIN orders o ON p.product_id = o.product_id
WHERE p.category = {{category}}
AND p.price <= {{max_price}}
AND o.order_date BETWEEN {{start_date}} AND {{end_date}}
ORDER BY o.order_date DESC;