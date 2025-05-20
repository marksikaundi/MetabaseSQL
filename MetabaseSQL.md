# Comprehensive Guide to SQL in Metabase

## Table of Contents

1. [Introduction to SQL in Metabase](#introduction-to-sql-in-metabase)
2. [Basic SQL Concepts](#basic-sql-concepts)
3. [SQL Editor in Metabase](#sql-editor-in-metabase)
4. [SQL Variables and Parameters](#sql-variables-and-parameters)
5. [Field Filters](#field-filters)
6. [Advanced SQL Techniques](#advanced-sql-techniques)
7. [SQL Best Practices in Metabase](#sql-best-practices-in-metabase)
8. [Debugging SQL in Metabase](#debugging-sql-in-metabase)
9. [SQL Optimization](#sql-optimization)
10. [SQL Security Considerations](#sql-security-considerations)
11. [Common Use Cases](#common-use-cases)
12. [Troubleshooting](#troubleshooting)
13. [Resources](#resources)

## Introduction to SQL in Metabase

Metabase is an open-source business intelligence tool that allows users to ask questions about their data and display answers in formats that make sense, whether that's a bar chart or a detailed table. While Metabase is designed to be accessible to non-technical users through its intuitive Query Builder, it also provides a native SQL editor for more advanced users who want to write their own SQL queries.

SQL (Structured Query Language) is a standard language for interacting with relational databases. In Metabase, SQL allows you to:

- Create complex queries that may not be possible with the point-and-click interface
- Perform advanced data analysis
- Build custom visualizations and dashboards
- Create dynamic, parameterized reports using variables

This guide provides a comprehensive overview of using SQL in Metabase, from basic concepts to advanced techniques.

## Basic SQL Concepts

### SQL Query Structure

A typical SQL query follows this structure:

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition
GROUP BY column1, column2, ...
HAVING condition
ORDER BY column1, column2, ... [ASC|DESC]
LIMIT number;
```

### Essential SQL Commands

1. **SELECT**: Retrieves data from a database
2. **FROM**: Specifies the table to query
3. **WHERE**: Filters records based on conditions
4. **GROUP BY**: Groups records with identical values
5. **HAVING**: Filters groups based on conditions
6. **ORDER BY**: Sorts the result set
7. **LIMIT**: Restricts the number of rows returned

### SQL Data Types

Common SQL data types include:

- **Numeric**: INTEGER, DECIMAL, FLOAT
- **String**: VARCHAR, CHAR, TEXT
- **Date/Time**: DATE, TIME, TIMESTAMP
- **Boolean**: BOOLEAN

### SQL Joins

Joins combine rows from two or more tables based on a related column:

- **INNER JOIN**: Returns records with matching values in both tables
- **LEFT JOIN**: Returns all records from the left table and matching records from the right table
- **RIGHT JOIN**: Returns all records from the right table and matching records from the left table
- **FULL JOIN**: Returns all records from both tables

## SQL Editor in Metabase

### Accessing the SQL Editor

In Metabase, you can access the SQL editor by:

1. Clicking on the "New" button
2. Selecting "SQL Query"
3. Choosing the database you want to query

### SQL Editor Features

- Syntax highlighting
- Auto-completion for table and column names
- Query formatting
- Variables and parameters support
- Data visualization options
- Query saving and version history

### Running SQL Queries

To run a SQL query in Metabase:

1. Write your SQL query in the editor
2. Click "Run" or press Ctrl+Enter (Cmd+Enter on Mac)
3. View the results in the data table below
4. Choose a visualization type from the visualization options

## SQL Variables and Parameters

### Basic Input Variables

Metabase allows you to create variables in your SQL queries that generate filter widgets:

```sql
SELECT *
FROM products
WHERE category = {{category}}
```

When you run this query, Metabase will prompt you for a value for the `category` variable.

### Variable Types

Metabase supports several variable types:

1. **Text**: A plain input box for text values
2. **Number**: A plain input box for numeric values
3. **Date**: A date picker
4. **Field Filter**: Smart filter widgets based on field types

### Optional Variables

To make a variable optional:

```sql
SELECT *
FROM products
[[WHERE category = {{category}}]]
```

When enclosed in double brackets, the entire clause becomes optional. If no value is provided, the clause is omitted.

### Multiple Variables

You can include multiple variables in your query:

```sql
SELECT *
FROM products
WHERE category = {{category}}
AND price < {{max_price}}
```

### URL Parameters

You can pre-fill variables by adding parameters to the URL:

```
https://metabase.example.com/question/42?category=Gadget&max_price=100
```

## Field Filters

### What Are Field Filters?

Field Filters are a special type of variable in Metabase that map to a specific field in your database. They provide smart filter widgets based on the field type.

### Creating Field Filters

To create a Field Filter:

```sql
SELECT *
FROM orders
WHERE products.category = {{category}}
```

In the Variables sidebar, set the variable type to "Field Filter" and map it to the appropriate field.

### Advantages of Field Filters

- Dropdown menus for field values
- Advanced date filter options
- Support for multiple value selection
- Better user experience for filter widgets

### Field Filter Gotchas

- Field Filters don't work with table aliases
- The field must exist in your database schema
- Certain field types may not be compatible

## Advanced SQL Techniques

### Common Table Expressions (CTEs)

CTEs help structure complex queries by breaking them into simpler, named subqueries:

```sql
WITH revenue_by_month AS (
    SELECT date_trunc('month', created_at) AS month,
           SUM(subtotal) AS revenue
    FROM orders
    GROUP BY month
)
SELECT month, revenue,
       LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue
FROM revenue_by_month
ORDER BY month;
```

### Window Functions

Window functions perform calculations across a set of table rows:

```sql
SELECT product_id, category, price,
       AVG(price) OVER (PARTITION BY category) AS category_avg_price,
       price - AVG(price) OVER (PARTITION BY category) AS price_diff_from_avg
FROM products;
```

### Subqueries

Subqueries are queries nested inside another query:

```sql
SELECT product_id, product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products);
```

### Recursive Queries

Recursive queries process hierarchical data:

```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Base case: employees without managers
    SELECT id, name, manager_id, 0 AS level
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive case: employees with managers
    SELECT e.id, e.name, e.manager_id, eh.level + 1
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.id
)
SELECT * FROM employee_hierarchy
ORDER BY level, name;
```

### Pivoting Data

Transforming rows into columns:

```sql
SELECT category,
       SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed,
       SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
       SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM orders
GROUP BY category;
```

## SQL Best Practices in Metabase

### Query Performance

- Use appropriate indexes
- Limit result sets
- Avoid `SELECT *`
- Use JOINs instead of subqueries when possible
- Filter data early in the query

### Query Structure

- Use consistent indentation
- Include comments for complex logic
- Use descriptive aliases
- Break complex queries into CTEs
- Format queries for readability

### Variables and Parameters

- Use meaningful variable names
- Provide default values where appropriate
- Make variables optional when possible
- Use Field Filters for better user experience

### Security

- Avoid SQL injection vulnerabilities
- Use parameterized queries
- Limit database permissions
- Don't expose sensitive data

## Debugging SQL in Metabase

### Common SQL Errors

- Syntax errors
- Column or table not found
- Data type mismatches
- Invalid operations
- Permissions issues

### Error Messages

Metabase displays SQL error messages from the database. Common error patterns include:

- `ERROR: syntax error at or near "..."`
- `ERROR: column "..." does not exist`
- `ERROR: relation "..." does not exist`

### Troubleshooting Steps

1. Check syntax and punctuation
2. Verify table and column names
3. Test simpler versions of the query
4. Use CTEs to isolate problematic parts
5. Check data types in operations and comparisons

### SQL Syntax Variations

Different databases have slightly different SQL dialects. Common differences include:

- Date/time functions
- String manipulation
- Window functions
- Aggregate functions
- Recursive queries

## SQL Optimization

### Query Execution Plans

Many databases allow you to view query execution plans:

```sql
EXPLAIN ANALYZE SELECT * FROM large_table WHERE complex_condition;
```

### Indexing

Proper indexes can drastically improve query performance:

```sql
CREATE INDEX idx_customer_email ON customers(email);
```

### Materialized Views

For frequently run complex queries, consider materialized views:

```sql
CREATE MATERIALIZED VIEW sales_summary AS
SELECT date_trunc('month', order_date) AS month,
       product_id,
       SUM(quantity) AS total_quantity,
       SUM(price * quantity) AS total_sales
FROM orders
GROUP BY month, product_id;
```

### Query Refactoring

- Replace subqueries with JOINs when possible
- Use CTEs to improve readability and potentially performance
- Filter early to reduce the working data set
- Use appropriate aggregate functions

## SQL Security Considerations

### SQL Injection

Metabase protects against SQL injection by using parameterized queries when handling variables.

### Data Access Control

- Limit database user permissions
- Use row-level security when available
- Create database views to restrict access to certain columns

### Sensitive Data

- Avoid querying sensitive data unnecessarily
- Consider data masking for sensitive fields
- Be careful with logging and error messages

## Common Use Cases

### Sales Analysis

```sql
SELECT 
    date_trunc('month', order_date) AS month,
    product_category,
    COUNT(*) AS order_count,
    SUM(order_total) AS total_revenue,
    AVG(order_total) AS average_order_value
FROM orders
JOIN products ON orders.product_id = products.id
WHERE order_date BETWEEN {{start_date}} AND {{end_date}}
GROUP BY month, product_category
ORDER BY month, total_revenue DESC;
```

### User Cohort Analysis

```sql
WITH cohort_users AS (
    SELECT 
        user_id,
        date_trunc('month', first_purchase_date) AS cohort_month,
        date_trunc('month', purchase_date) AS activity_month,
        EXTRACT(MONTH FROM purchase_date - first_purchase_date) AS months_since_first_purchase
    FROM (
        SELECT 
            user_id,
            MIN(purchase_date) OVER (PARTITION BY user_id) AS first_purchase_date,
            purchase_date
        FROM purchases
    ) user_purchases
)
SELECT 
    cohort_month,
    months_since_first_purchase,
    COUNT(DISTINCT user_id) AS active_users
FROM cohort_users
GROUP BY cohort_month, months_since_first_purchase
ORDER BY cohort_month, months_since_first_purchase;
```

### Customer Segmentation

```sql
SELECT 
    CASE 
        WHEN lifetime_value > 1000 THEN 'High Value'
        WHEN lifetime_value > 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    AVG(lifetime_value) AS average_lifetime_value,
    MAX(last_order_date) AS most_recent_order
FROM customers
GROUP BY customer_segment
ORDER BY average_lifetime_value DESC;
```

## Troubleshooting

### Query Performance Issues

- Check for missing indexes
- Review execution plans
- Look for large table scans
- Consider query complexity
- Check server resources

### Field Filter Problems

- Ensure field is properly mapped in Metabase
- Check for table aliases (not supported)
- Verify field type is compatible
- Check syntax for the specific database

### Visualization Issues

- Check data types for chart axes
- Limit the number of series for clarity
- Consider using custom formatting
- Try different visualization types

## Resources

### SQL Reference Guides

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)
- [Oracle Documentation](https://docs.oracle.com/en/database/)

### Metabase Documentation

- [Metabase Documentation](https://www.metabase.com/docs/latest/)
- [Metabase SQL Tutorial](https://www.metabase.com/learn/sql-questions)
- [Metabase Field Filters Guide](https://www.metabase.com/learn/sql-questions/field-filters)

### Learning Resources

- [Metabase Learn](https://www.metabase.com/learn)
- [SQL Tutorial](https://www.w3schools.com/sql/)
- [Mode SQL Tutorial](https://mode.com/sql-tutorial/)
- [SQL for Data Analysis](https://www.udacity.com/course/sql-for-data-analysis--ud198)