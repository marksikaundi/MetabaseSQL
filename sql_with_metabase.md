# SQL with Metabase: A Comprehensive Guide

## Table of Contents

1. [Introduction](#introduction)
2. [SQL Basics](#sql-basics)
   - [SELECT Statements](#select-statements)
   - [WHERE Clauses](#where-clauses)
   - [ORDER BY](#order-by)
   - [LIMIT](#limit)
3. [SQL Intermediate Concepts](#sql-intermediate-concepts)
   - [Joins](#joins)
   - [Aggregation Functions](#aggregation-functions)
   - [GROUP BY](#group-by)
   - [HAVING](#having)
4. [SQL Advanced Concepts](#sql-advanced-concepts)
   - [Subqueries](#subqueries)
   - [Common Table Expressions (CTEs)](#common-table-expressions-ctes)
   - [Window Functions](#window-functions)
   - [Multi-level Aggregation](#multi-level-aggregation)
5. [SQL Variables in Metabase](#sql-variables-in-metabase)
   - [Basic Input Variables](#basic-input-variables)
   - [Field Filters](#field-filters)
   - [Optional Filters](#optional-filters)
6. [Working with Dates in SQL](#working-with-dates-in-sql)
   - [Date Functions](#date-functions)
   - [Date Filters](#date-filters)
7. [SQL Optimization in Metabase](#sql-optimization-in-metabase)
   - [Query Performance](#query-performance)
   - [Indexing Considerations](#indexing-considerations)
8. [Advanced Metabase SQL Features](#advanced-metabase-sql-features)
   - [Nested Queries](#nested-queries)
   - [SQL Snippets](#sql-snippets)
   - [SQL Parameters in Dashboards](#sql-parameters-in-dashboards)
9. [SQL Best Practices](#sql-best-practices)
10. [Troubleshooting Common SQL Issues](#troubleshooting-common-sql-issues)
11. [Real-World SQL Examples](#real-world-sql-examples)
    - [Sales Analytics](#sales-analytics)
    - [User Engagement Analysis](#user-engagement-analysis)
    - [Cohort Analysis](#cohort-analysis)
    - [Funnel Analysis](#funnel-analysis)
12. [Practical Applications](#practical-applications)
    - [Executive Dashboards](#executive-dashboards)
    - [Operational Reporting](#operational-reporting)
    - [Ad-hoc Analysis](#ad-hoc-analysis)

## Introduction

SQL (Structured Query Language) is the standard language for interacting with relational databases. Metabase provides a powerful interface for writing SQL queries, allowing users to harness the full power of SQL while providing intuitive visualizations and dashboard capabilities.

Metabase's SQL editor (also called the Native Query editor) enables you to:
- Write and execute SQL queries directly
- Visualize results with various chart types
- Save queries as "Questions" for future use
- Create variables and filters for interactive queries
- Share results with team members
- Add questions to dashboards
- Schedule regular updates and email reports
- Create custom alerts based on query results

This guide explores how to effectively use SQL within Metabase, from basic concepts to advanced techniques, helping you unlock the full potential of your data.

## SQL Basics

### SELECT Statements

The `SELECT` statement is the foundation of SQL queries. It retrieves data from one or more tables.

```sql
SELECT column1, column2
FROM table_name;
```

To select all columns:

```sql
SELECT *
FROM table_name;
```

In Metabase's SQL editor (accessible via the "New" > "SQL query" option), you can write these queries directly and visualize the results with Metabase's visualization tools. The results appear in a tabular format by default, but you can switch to various visualizations using the "Visualization" button.

### WHERE Clauses

The `WHERE` clause filters data based on specified conditions.

```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

Example:
```sql
SELECT id, name, price
FROM products
WHERE price > 50;
```

### ORDER BY

The `ORDER BY` clause sorts results by one or more columns.

```sql
SELECT column1, column2
FROM table_name
ORDER BY column1 [ASC|DESC];
```

Example:
```sql
SELECT id, name, price
FROM products
ORDER BY price DESC;
```

### LIMIT

The `LIMIT` clause restricts the number of rows returned.

```sql
SELECT column1, column2
FROM table_name
LIMIT number;
```

Example:
```sql
SELECT id, name, price
FROM products
ORDER BY price DESC
LIMIT 10;
```

## SQL Intermediate Concepts

### Joins

Joins combine rows from two or more tables based on a related column.

#### Inner Join

Returns records with matching values in both tables.

```sql
SELECT Orders.id, Customers.name, Orders.amount
FROM Orders
INNER JOIN Customers ON Orders.customer_id = Customers.id;
```

#### Left Join

Returns all records from the left table and matching records from the right table.

```sql
SELECT Products.name, Orders.id
FROM Products
LEFT JOIN Orders ON Products.id = Orders.product_id;
```

#### Other Joins

- **Right Join**: Returns all records from the right table and matching records from the left table.
- **Full Join**: Returns all records when there's a match in either left or right table.
- **Cross Join**: Returns the Cartesian product of both tables.

Metabase makes joins easier to visualize and understand, especially when working with complex data models. While the Query Builder can automatically handle many joins based on the data model, the SQL editor gives you complete control over join operations. Metabase's data model editor also allows administrators to define relationships between tables, making joins more intuitive for all users.

### Aggregation Functions

SQL provides several functions to perform calculations on data:

- `COUNT()`: Counts rows or non-null values
- `SUM()`: Calculates the sum of numeric values
- `AVG()`: Calculates the average of numeric values
- `MIN()`: Finds the minimum value
- `MAX()`: Finds the maximum value
- `STDDEV()`: Calculates the standard deviation
- `MEDIAN()`: Finds the median value (not available in all databases)

In Metabase, these aggregations can be visualized directly as summary numbers, or as part of more complex visualizations like bar charts and line graphs. Metabase also supports custom aggregations through its "Summarize" feature in the Query Builder, which can be combined with SQL for powerful analytics.

Example:
```sql
SELECT
    category,
    COUNT(*) as total_products,
    AVG(price) as average_price,
    MIN(price) as min_price,
    MAX(price) as max_price
FROM products
GROUP BY category;
```

### GROUP BY

The `GROUP BY` clause groups rows based on one or more columns, typically used with aggregate functions.

```sql
SELECT column1, aggregate_function(column2)
FROM table_name
GROUP BY column1;
```

Example:
```sql
SELECT
    EXTRACT(YEAR FROM created_at) as year,
    EXTRACT(MONTH FROM created_at) as month,
    SUM(total) as monthly_revenue
FROM orders
GROUP BY year, month
ORDER BY year, month;
```

### HAVING

The `HAVING` clause filters groups based on aggregate values (similar to WHERE, but for groups).

```sql
SELECT column1, aggregate_function(column2)
FROM table_name
GROUP BY column1
HAVING condition;
```

Example:
```sql
SELECT
    category,
    COUNT(*) as product_count
FROM products
GROUP BY category
HAVING COUNT(*) > 5;
```

## SQL Advanced Concepts

### Subqueries

Subqueries are queries nested within another query, allowing for complex data retrieval and filtering.

```sql
SELECT column1
FROM table1
WHERE column2 IN (SELECT column2 FROM table2 WHERE condition);
```

Example:
```sql
SELECT name
FROM products
WHERE id IN (
    SELECT product_id
    FROM orders
    WHERE created_at > '2023-01-01'
);
```

### Common Table Expressions (CTEs)

CTEs provide a way to write more readable and maintainable SQL by defining temporary result sets.

```sql
WITH cte_name AS (
    SELECT column1, column2
    FROM table_name
    WHERE condition
)
SELECT *
FROM cte_name;
```

Example:
```sql
WITH monthly_sales AS (
    SELECT
        EXTRACT(YEAR FROM created_at) as year,
        EXTRACT(MONTH FROM created_at) as month,
        SUM(total) as revenue
    FROM orders
    GROUP BY year, month
)
SELECT
    year,
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY year, month) as previous_month_revenue
FROM monthly_sales
ORDER BY year, month;
```

CTEs are especially useful in Metabase when creating complex analyses that involve multiple steps.

### Window Functions

Window functions perform calculations across a set of rows related to the current row.

```sql
SELECT
    column1,
    aggregate_function() OVER (PARTITION BY column2 ORDER BY column3) as window_result
FROM table_name;
```

Example:
```sql
SELECT
    name,
    category,
    price,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) as price_rank
FROM products;
```

### Multi-level Aggregation

Multi-level aggregation involves calculating aggregates of aggregates, which can be achieved using subqueries or CTEs.

Example:
```sql
WITH weekly_sales AS (
    SELECT
        product_category,
        DATE_TRUNC('week', created_at) as week,
        COUNT(*) as weekly_count
    FROM orders
    JOIN products ON orders.product_id = products.id
    GROUP BY product_category, week
)
SELECT
    product_category,
    AVG(weekly_count) as avg_weekly_sales
FROM weekly_sales
GROUP BY product_category;
```

## SQL Variables in Metabase

Metabase allows you to create dynamic SQL queries using variables, which enable users to filter results without modifying the SQL.

### Basic Input Variables

You can add variables to your SQL by using double curly braces `{{variable_name}}`. Metabase will automatically create a filter widget for these variables.

```sql
SELECT *
FROM orders
WHERE created_at > {{start_date}};
```

To create a variable:
1. Include `{{variable_name}}` in your SQL query
2. Metabase will detect the variable and display it in the Variables sidebar
3. Set the variable type and display name
4. When the query runs, users will see a filter widget to enter values

Basic variable types include:
- Text: Simple text input (Example: `WHERE category = {{category}}`)
- Number: Numeric input (Example: `WHERE price > {{min_price}}`)
- Date: Date picker (Example: `WHERE created_at > {{start_date}}`)

### Field Filters

Field filters are special variables that connect to Metabase's metadata about your database. They create smart filter widgets that understand your data.

```sql
SELECT *
FROM orders
WHERE {{created_at}}
```

Field filters offer benefits like:
- Dropdown menus of available values
- Smart date pickers with relative date options ("Last 30 days", "This month", etc.)
- Multiple value selection
- Type-ahead search for large datasets
- Relative date filtering ("Between X and Y days ago")
- Integration with Metabase's knowledge of your data model

To create a field filter:
1. Add a variable with double curly braces: `{{variable_name}}`
2. In the Variables sidebar, select "Field Filter" as the variable type
3. Map the variable to a specific field in your database
4. Metabase will create a smart filter widget based on the field type

### Optional Filters

You can make filters optional by wrapping the entire clause in double brackets:

```sql
SELECT *
FROM products
[[WHERE category = {{category}}]]
```

If no value is provided for the variable, the entire clause is omitted from the query.

## Working with Dates in SQL

### Date Functions

Different databases have slightly different date functions, but common operations include:

```sql
-- PostgreSQL
SELECT
    created_at,
    DATE_TRUNC('month', created_at) as month,
    EXTRACT(YEAR FROM created_at) as year,
    EXTRACT(DOW FROM created_at) as day_of_week,
    created_at::DATE as date_only,
    NOW() - created_at as age
FROM orders;
```

Metabase provides standardized ways to work with dates across different database engines.

### Date Filters

Date filters in Metabase can be particularly powerful when using field filters:

```sql
SELECT *
FROM orders
WHERE {{created_at}}
```

This allows users to select relative date ranges like "Last 30 days" or "This month" without needing to hardcode date values.

## SQL Optimization in Metabase

### Query Performance

Tips for optimizing SQL query performance:
- Select only necessary columns instead of using `SELECT *`
- Use appropriate indexes
- Limit results when possible
- Avoid functions in WHERE clauses that prevent index usage
- Consider query execution plans

### Indexing Considerations

While you typically can't modify indexes directly through Metabase, understanding how they work can help in writing more efficient queries:

- Indexes speed up data retrieval but slow down data insertion/updates
- Primary keys are automatically indexed
- Foreign keys should be indexed
- Columns frequently used in WHERE, JOIN, or ORDER BY clauses are good candidates for indexing

## Advanced Metabase SQL Features

### Nested Queries

Metabase allows you to use a saved question (query) as a data source for another query:

```sql
SELECT *
FROM {{#1234}} -- This references question #1234
WHERE condition;
```

To reference a saved question:
1. Create and save your first question
2. Start a new SQL query
3. Use the `{{#question_id}}` syntax, where `question_id` is the numeric ID of your saved question
4. You can find this ID in the URL when viewing the question (e.g., `https://your-metabase.com/question/42`)

This is useful for building upon previous analyses or breaking complex queries into manageable parts. It also allows you to combine SQL questions with questions created using the visual Query Builder.

### SQL Snippets

SQL snippets let you reuse SQL fragments across multiple queries:

```sql
SELECT *
FROM orders
WHERE {{snippet: active_users}}
```

This promotes code reuse and consistency in your analyses.

### SQL Parameters in Dashboards

You can create dashboard-level filters that affect multiple SQL questions:

1. Create variables in your SQL questions (using `{{variable_name}}` syntax)
2. Add those questions to a dashboard (click "Add to dashboard" when viewing a question)
3. Create dashboard filters (click the pencil icon to edit the dashboard, then "Add a filter")
4. Map dashboard filters to the variables in your questions (connect them in the filter settings)

For example:
- Create a SQL question with `WHERE created_at > {{start_date}}`
- Create another SQL question with `WHERE date_field BETWEEN {{start_date}} AND {{end_date}}`
- Add both to a dashboard
- Add a "Date" filter to the dashboard
- Map this filter to the `start_date` variable in both questions

This creates powerful interactive dashboards where users can filter data without writing SQL. Dashboard filters affect all connected questions simultaneously, creating a cohesive analytical experience.

## SQL Best Practices

1. **Use meaningful aliases** for tables and columns (e.g., `FROM orders o JOIN products p ON o.product_id = p.id`)
2. **Format your SQL consistently** for readability, with proper indentation and line breaks for clauses
3. **Comment complex logic** to explain what queries are doing (use `--` for single-line comments or `/* */` for multi-line)
4. **Use CTEs** instead of nested subqueries for readability and maintainability
5. **Be cautious with JOINs** on large tables, as they can impact performance
6. **Test performance** of complex queries on small data samples first before running on full datasets
7. **Use parameters and variables** instead of hardcoding values to make queries reusable
8. **Consider database-specific optimizations** for your particular database engine
9. **Keep queries modular** by breaking them into smaller, reusable parts, using Metabase's "Saved Questions" feature
10. **Limit result sets** when possible to improve performance, especially for initial testing
11. **Use Metabase's visualization settings** to effectively communicate your findings
12. **Create descriptive question titles** to help others understand your SQL questions

## Troubleshooting Common SQL Issues

1. **Syntax Errors**: Check for missing semicolons, mismatched parentheses, or incorrect SQL keywords
2. **Join Issues**: Ensure you're joining on the correct columns and using appropriate join types
3. **Null Values**: Remember that NULL values require special handling (IS NULL, IS NOT NULL)
4. **Data Type Mismatches**: Ensure you're comparing compatible data types
5. **Subquery Returns Multiple Values**: Fix subqueries that return multiple values when only one is expected
6. **Performance Problems**: Analyze and optimize slow queries by examining execution plans
7. **Group By Errors**: Include all non-aggregated columns in GROUP BY clauses
8. **Case Sensitivity**: Be aware of database-specific case sensitivity rules
9. **Date Format Issues**: Use database-specific date functions correctly
10. **Permission Problems**: Ensure you have appropriate permissions to access all tables in your query

---

By mastering SQL within Metabase, you can combine the power of direct SQL queries with Metabase's intuitive visualization and dashboard capabilities, creating powerful analytics that can be shared throughout your organization.

## Additional Metabase SQL Resources

- **Metabase Documentation**: The [official documentation](https://www.metabase.com/docs/latest/questions/native-editor/writing-sql) provides comprehensive guides on using SQL in Metabase.
- **SQL Variables Guide**: Learn more about creating [dynamic SQL queries with variables](https://www.metabase.com/docs/latest/questions/native-editor/sql-parameters).
- **Field Filters**: Discover how to use [field filters](https://www.metabase.com/docs/latest/questions/native-editor/sql-parameters#the-field-filter-variable-type) to create smart filter widgets.
- **SQL Snippets**: Explore how to use [reusable SQL snippets](https://www.metabase.com/docs/latest/questions/native-editor/sql-snippets) for consistency across multiple queries.
- **
Metabase Learn**: Visit [Metabase Learn](https://www.metabase.com/learn/sql-questions) for tutorials and examples of SQL usage in Metabase.
- **Community Forum**: Connect with other Metabase users in the [community forum](https://discourse.metabase.com/) to share tips and get help with SQL questions.

Remember that Metabase aims to make data accessible to everyone in your organization, regardless of their SQL knowledge. While this guide focuses on SQL usage, Metabase's visual Query Builder provides a no-code alternative for many analytical tasks.

## Real-World SQL Examples

### Sales Analytics

Sales analytics helps businesses track performance, identify trends, and make data-driven decisions. Here's a comprehensive sales analysis example using SQL in Metabase:

```sql
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', orders.created_at) AS month,
        products.category,
        SUM(orders.quantity * products.price) AS revenue,
        COUNT(DISTINCT orders.user_id) AS unique_customers,
        COUNT(orders.id) AS order_count
    FROM orders
    JOIN products ON orders.product_id = products.id
    WHERE orders.created_at >= {{start_date}} AND orders.created_at <= {{end_date}}
    GROUP BY month, products.category
),
previous_period AS (
    SELECT
        category,
        LAG(revenue) OVER (PARTITION BY category ORDER BY month) AS prev_revenue,
        LAG(unique_customers) OVER (PARTITION BY category ORDER BY month) AS prev_customers,
        LAG(order_count) OVER (PARTITION BY category ORDER BY month) AS prev_orders,
        month
    FROM monthly_sales
)
SELECT
    ms.month,
    ms.category,
    ms.revenue,
    ms.unique_customers,
    ms.order_count,
    ROUND(((ms.revenue - pp.prev_revenue) / NULLIF(pp.prev_revenue, 0)) * 100, 2) AS revenue_growth_pct,
    ROUND(((ms.unique_customers - pp.prev_customers) / NULLIF(pp.prev_customers, 0)) * 100, 2) AS customer_growth_pct,
    ms.revenue / NULLIF(ms.unique_customers, 0) AS average_revenue_per_customer
FROM monthly_sales ms
JOIN previous_period pp ON ms.month = pp.month AND ms.category = pp.category
ORDER BY ms.month, ms.revenue DESC
```

This query provides:
- Monthly revenue by product category
- Month-over-month growth calculations
- Customer acquisition and retention metrics
- Average revenue per customer

In Metabase, you can visualize this as a line chart showing revenue trends, a bar chart comparing categories, or a combination chart displaying both metrics.

### User Engagement Analysis

Understanding user engagement is critical for product-based businesses. Here's an example query analyzing user engagement:

```sql
WITH user_activity AS (
    SELECT
        users.id AS user_id,
        users.created_at AS signup_date,
        MIN(events.created_at) AS first_activity,
        MAX(events.created_at) AS last_activity,
        COUNT(DISTINCT DATE_TRUNC('day', events.created_at)) AS active_days,
        COUNT(*) AS total_events
    FROM users
    LEFT JOIN events ON users.id = events.user_id
    WHERE users.created_at >= {{signup_start_date}}
    GROUP BY users.id, users.created_at
)
SELECT
    DATE_TRUNC('week', signup_date) AS cohort_week,
    COUNT(user_id) AS cohort_size,
    ROUND(AVG(total_events), 2) AS avg_events_per_user,
    ROUND(AVG(active_days), 2) AS avg_active_days,
    ROUND(AVG(EXTRACT(EPOCH FROM (last_activity - first_activity))/86400), 2) AS avg_retention_days,
    COUNT(CASE WHEN total_events > 10 THEN user_id END) * 100.0 / COUNT(user_id) AS pct_power_users
FROM user_activity
GROUP BY cohort_week
ORDER BY cohort_week
```

This analysis provides:
- Weekly cohort analysis of new users
- Average events per user to measure engagement intensity
- Active days metric showing how frequently users engage
- Retention metrics indicating how long users stay active
- Identification of power users (those with high engagement)

### Cohort Analysis

Cohort analysis tracks groups of users who started using your product at the same time to understand retention patterns:

```sql
WITH cohort_users AS (
    SELECT
        user_id,
        DATE_TRUNC('month', first_purchase_date) AS cohort_month,
        DATE_TRUNC('month', purchase_date) AS activity_month,
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', purchase_date), 
                              DATE_TRUNC('month', first_purchase_date))) AS month_number
    FROM (
        SELECT
            user_id,
            MIN(created_at) OVER (PARTITION BY user_id) AS first_purchase_date,
            created_at AS purchase_date
        FROM orders
        WHERE status = 'completed'
    ) purchase_history
)
SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT CASE WHEN month_number = 0 THEN user_id END) AS initial_users,
    COUNT(DISTINCT user_id) AS retained_users,
    ROUND(100.0 * COUNT(DISTINCT user_id) / 
          NULLIF(COUNT(DISTINCT CASE WHEN month_number = 0 THEN user_id END), 0), 2) AS retention_rate
FROM cohort_users
WHERE cohort_month >= {{start_date}} AND cohort_month <= {{end_date}}
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number
```

This creates a classic cohort retention table showing:
- Initial cohort size
- How many users return in subsequent months
- Percentage retention over time
- Patterns revealing product stickiness

### Funnel Analysis

Funnel analysis tracks user progression through a sequence of events, helping identify dropoff points:

```sql
WITH funnel_stages AS (
    SELECT
        user_id,
        MAX(CASE WHEN event_name = 'page_view' AND page = 'product' THEN 1 ELSE 0 END) AS viewed_product,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN event_name = 'checkout_start' THEN 1 ELSE 0 END) AS started_checkout,
        MAX(CASE WHEN event_name = 'purchase_complete' THEN 1 ELSE 0 END) AS completed_purchase
    FROM events
    WHERE created_at BETWEEN {{start_date}} AND {{end_date}}
    GROUP BY user_id
)
SELECT
    COUNT(*) AS total_users,
    SUM(viewed_product) AS product_viewers,
    SUM(added_to_cart) AS cart_adders,
    SUM(started_checkout) AS checkout_starters,
    SUM(completed_purchase) AS purchasers,
    ROUND(100.0 * SUM(added_to_cart) / NULLIF(SUM(viewed_product), 0), 2) AS view_to_cart_rate,
    ROUND(100.0 * SUM(started_checkout) / NULLIF(SUM(added_to_cart), 0), 2) AS cart_to_checkout_rate,
    ROUND(100.0 * SUM(completed_purchase) / NULLIF(SUM(started_checkout), 0), 2) AS checkout_to_purchase_rate,
    ROUND(100.0 * SUM(completed_purchase) / NULLIF(SUM(viewed_product), 0), 2) AS overall_conversion_rate
FROM funnel_stages
```

This analysis reveals:
- Conversion rates between each step in your funnel
- Where users drop off most frequently
- Overall conversion efficiency
- Opportunities for optimization

In Metabase, you can visualize this as a funnel chart to clearly see the drop-offs between stages.

## Practical Applications

### Executive Dashboards

Executives need high-level metrics and KPIs to make strategic decisions. SQL-powered executive dashboards in Metabase typically include:

1. **Revenue Overview**:
```sql
SELECT
    DATE_TRUNC('month', created_at) AS month,
    SUM(total) AS revenue,
    COUNT(DISTINCT user_id) AS customers,
    SUM(total) / COUNT(DISTINCT user_id) AS arpu
FROM orders
WHERE status = 'completed'
AND created_at BETWEEN {{start_date}} AND {{end_date}}
GROUP BY month
ORDER BY month
```

2. **Growth Metrics**:
```sql
WITH monthly_metrics AS (
    SELECT
        DATE_TRUNC('month', created_at) AS month,
        COUNT(DISTINCT user_id) AS new_users,
        SUM(total) AS revenue
    FROM orders
    WHERE status = 'completed'
    GROUP BY month
)
SELECT
    current.month,
    current.new_users,
    current.revenue,
    ROUND(100.0 * (current.new_users - previous.new_users) / NULLIF(previous.new_users, 0), 2) AS user_growth,
    ROUND(100.0 * (current.revenue - previous.revenue) / NULLIF(previous.revenue, 0), 2) AS revenue_growth
FROM monthly_metrics current
LEFT JOIN monthly_metrics previous ON current.month = previous.month + INTERVAL '1 month'
ORDER BY current.month DESC
```

Executive dashboards combine these SQL queries with other key metrics in a single view, often using variables for date ranges and filters for different business segments.

### Operational Reporting

Operational teams need detailed, actionable information for daily decision-making:

1. **Inventory Management**:
```sql
SELECT
    products.id,
    products.name,
    products.category,
    inventory.stock_level,
    inventory.reorder_point,
    CASE WHEN inventory.stock_level <= inventory.reorder_point 
         THEN 'Reorder needed' ELSE 'Sufficient stock' END AS status,
    COALESCE(monthly_sales.units_sold, 0) AS units_sold_last_30_days,
    CASE WHEN inventory.stock_level > 0 
         THEN ROUND(inventory.stock_level / NULLIF(monthly_sales.units_sold / 30, 0), 1)
         ELSE 0 END AS days_of_inventory_left
FROM products
JOIN inventory ON products.id = inventory.product_id
LEFT JOIN (
    SELECT
        product_id,
        SUM(quantity) AS units_sold
    FROM orders
    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
    AND status = 'completed'
    GROUP BY product_id
) monthly_sales ON products.id = monthly_sales.product_id
ORDER BY days_of_inventory_left ASC
```

2. **Customer Support Performance**:
```sql
SELECT
    support_agents.name AS agent,
    COUNT(tickets.id) AS tickets_handled,
    ROUND(AVG(EXTRACT(EPOCH FROM (tickets.resolved_at - tickets.created_at))/3600), 2) AS avg_resolution_hours,
    COUNT(CASE WHEN tickets.priority = 'high' THEN tickets.id END) AS high_priority_tickets,
    ROUND(AVG(ticket_ratings.rating), 2) AS avg_customer_rating
FROM support_agents
JOIN tickets ON support_agents.id = tickets.agent_id
LEFT JOIN ticket_ratings ON tickets.id = ticket_ratings.ticket_id
WHERE tickets.created_at BETWEEN {{start_date}} AND {{end_date}}
GROUP BY support_agents.name
ORDER BY tickets_handled DESC
```

### Ad-hoc Analysis

Ad-hoc analysis lets teams answer specific business questions as they arise:

1. **Product Cannibalization Analysis**:
```sql
WITH product_revenue AS (
    SELECT
        DATE_TRUNC('month', orders.created_at) AS month,
        products.id AS product_id,
        products.name AS product_name,
        products.category,
        SUM(orders.quantity * products.price) AS revenue
    FROM orders
    JOIN products ON orders.product_id = products.id
    WHERE orders.created_at >= {{new_product_launch_date}}
    GROUP BY month, products.id, products.name, products.category
),
product_share AS (
    SELECT
        month,
        product_id,
        product_name,
        category,
        revenue,
        SUM(revenue) OVER (PARTITION BY month, category) AS category_revenue,
        SUM(revenue) OVER (PARTITION BY month) AS total_revenue,
        100.0 * revenue / NULLIF(SUM(revenue) OVER (PARTITION BY month, category), 0) AS category_share_pct
    FROM product_revenue
)
SELECT
    a.month,
    a.product_name,
    a.category,
    a.revenue,
    a.category_share_pct,
    a.category_share_pct - b.category_share_pct AS share_change_from_previous
FROM product_share a
LEFT JOIN product_share b ON 
    a.product_id = b.product_id AND
    a.month = b.month + INTERVAL '1 month'
WHERE a.product_id = {{product_id}} OR a.product_id = {{comparison_product_id}}
ORDER BY a.month, a.revenue DESC
```

2. **Customer Segment Analysis**:
```sql
WITH customer_segments AS (
    SELECT
        users.id AS user_id,
        users.country,
        users.acquisition_source,
        COUNT(orders.id) AS order_count,
        SUM(orders.total) AS total_spent,
        MAX(orders.created_at) AS most_recent_order,
        MIN(orders.created_at) AS first_order,
        CASE 
            WHEN COUNT(orders.id) >= 3 AND SUM(orders.total) >= 300 THEN 'VIP'
            WHEN COUNT(orders.id) >= 2 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM users
    LEFT JOIN orders ON users.id = orders.user_id AND orders.status = 'completed'
    GROUP BY users.id, users.country, users.acquisition_source
)
SELECT
    customer_segment,
    country,
    acquisition_source,
    COUNT(user_id) AS customer_count,
    ROUND(AVG(total_spent), 2) AS avg_lifetime_value,
    ROUND(AVG(order_count), 2) AS avg_orders_per_customer,
    ROUND(100.0 * COUNT(CASE WHEN most_recent_order >= CURRENT_DATE - INTERVAL '90 days' THEN user_id END) / 
          NULLIF(COUNT(user_id), 0), 2) AS active_customer_percentage
FROM customer_segments
GROUP BY customer_segment, country, acquisition_source
ORDER BY avg_lifetime_value DESC
```

These ad-hoc analyses can be saved as Metabase questions for future reference or added to dashboards if they provide ongoing value. The SQL variables allow for quick adjustments to answer slightly different questions without rewriting the entire query.