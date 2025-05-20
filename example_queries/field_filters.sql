-- Field Filters Example
-- This example demonstrates how to use Field Filters in Metabase SQL queries

-- Example 1: Basic Field Filter
-- Maps the 'category' variable to the Products.category field
-- Creates a dropdown filter with available category values
SELECT *
FROM products
WHERE category = {{category}}
LIMIT 10;

-- Example 2: Field Filter with multiple selections
-- Allow users to select multiple categories
-- Note how the variable is used directly in the WHERE clause
SELECT *
FROM products
WHERE {{category}}
ORDER BY price DESC
LIMIT 10;

-- Example 3: Date Field Filter
-- Create a smart date picker with relative date options
SELECT 
    order_date,
    product_id,
    quantity,
    total_amount
FROM orders
WHERE {{order_date}}
ORDER BY order_date DESC;

-- Example 4: Combined Field Filters
-- Using multiple field filters in one query
SELECT
    p.product_name,
    p.category,
    p.price,
    o.order_date,
    o.quantity
FROM products p
JOIN orders o ON p.product_id = o.product_id
WHERE {{category}}
AND {{price}}
AND {{order_date}}
ORDER BY o.order_date DESC;

-- Example 5: Field Filter with a JOIN
-- When using Field Filters with JOINs, make sure to specify the full table name
SELECT
    c.name AS customer_name,
    o.order_date,
    p.product_name,
    p.category,
    o.quantity
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN products p ON o.product_id = p.product_id
WHERE {{products.category}}
ORDER BY o.order_date DESC;

-- Example 6: Optional Field Filter
-- Making a field filter optional
SELECT *
FROM products
[[WHERE {{category}}]]
ORDER BY price DESC
LIMIT 10;