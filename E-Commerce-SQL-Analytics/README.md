# 🛒 E-Commerce SQL Analytics — PostgreSQL

> A hands-on PostgreSQL analytics project containing 40 progressively challenging SQL problems designed around a realistic e-commerce dataset.

This project focuses on solving business and analytical problems using SQL — starting from basic filtering and aggregation and progressing to **subqueries, correlated subqueries, nested queries, self-joins, and window functions**.

---

## 📌 Project Overview

The goal of this project was to analyze an e-commerce order dataset and answer practical business questions using PostgreSQL.

Instead of only practicing SQL syntax, the project focuses on:

- Customer behavior
- Product performance
- Revenue & profit analysis
- Returns & cart abandonment
- Discounts & promotions
- Payment methods
- Supplier performance
- Regional analysis
- Product recommendations
- Ranking and cumulative analysis

### Dataset

| Property | Details |
|---|---|
| Database | PostgreSQL |
| Records | 10,000 orders |
| Columns | 29 |
| Domain | E-Commerce |
| Query Exercises | 40 |
| SQL Dialect | PostgreSQL |

---

# 🧠 SQL Skills Demonstrated

## 1. Basic SQL

- `SELECT`
- `WHERE`
- `DISTINCT`
- `ORDER BY`
- `LIMIT`
- `IN`
- `AND / OR`
- Comparison operators

Example:

```sql
select product_name, product_id
from orders
where discount > 0.15
  and quantity > 3;

Advanced SQL Concepts
3. Subqueries

Used subqueries to compare individual records against calculated values.

Examples include:

Products above category average discount
Orders above customer average sales
Products that were never returned
Customers with no recent purchases
Revenue comparisons

Window Functions

One of the most important sections of the project.

Functions used include:

RANK()
ROW_NUMBER()
DENSE_RANK()
LAG()
SUM() OVER()
COUNT() OVER()

Product Analytics

Product-level analysis included:

Top products by sales
Top products by profit margin
Products with high discounts
Products with high return frequency
Products never returned
Top products per region
Products above category average discount
Product pairs purchased together

Author

Koti Tarun

B.E. — Artificial Intelligence & Data Science

Interested in:

Data Analytics
SQL
Python
Power BI
Full-Stack Development
AI & Data Science
