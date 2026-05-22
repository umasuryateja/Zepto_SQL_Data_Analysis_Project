# Zepto_SQL_Data_Analysis_Project

> End-to-end SQL data analysis project on a real-world e-commerce inventory dataset from Zepto — India's leading quick-commerce platform.

---

## Overview

This project simulates the workflow of a data analyst working on an e-commerce inventory system. Using a dataset scraped from Zepto's product listings, it covers the complete pipeline from raw data exploration and cleaning to writing business-driven SQL queries that generate actionable insights around pricing, inventory, stock availability, and revenue.

---

## Problem Statement

E-commerce companies like Zepto manage thousands of SKUs across multiple product categories. Inventory data is often messy — inconsistent pricing, missing values, and duplicate entries. The goal of this project is to:

- Clean and standardize the raw inventory data
- Explore the dataset to understand its structure and quality
- Answer real business questions using SQL to support decision-making around pricing strategy, stock management, and revenue estimation

---

## Objectives

- Set up a structured PostgreSQL database from raw CSV data
- Perform exploratory data analysis (EDA) to understand the dataset
- Clean invalid, null, and inconsistent records
- Write business-focused SQL queries to extract insights on pricing, discounts, inventory weight, and stock availability

---

## Dataset Overview

The dataset was sourced from Kaggle and originally scraped from Zepto's live product listings. Each row represents a unique **SKU (Stock Keeping Unit)**. The same product may appear multiple times under different package sizes, weights, or discount tiers — which is typical of real catalog data.

| Column | Type | Description |
|---|---|---|
| `sku_id` | SERIAL | Unique identifier for each SKU (Primary Key) |
| `name` | VARCHAR(150) | Product name as listed on the app |
| `category` | VARCHAR(120) | Product category (Fruits, Snacks, Beverages, etc.) |
| `mrp` | NUMERIC(8,2) | Maximum Retail Price (converted from paise to ₹) |
| `discountPercent` | NUMERIC(5,2) | Discount percentage applied on MRP |
| `discountedSellingPrice` | NUMERIC(8,2) | Final selling price after discount (converted to ₹) |
| `availableQuantity` | INTEGER | Units currently available in inventory |
| `weightInGms` | INTEGER | Product weight in grams |
| `outOfStock` | BOOLEAN | True if the product is currently out of stock |
| `quantity` | INTEGER | Units per package |

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| PostgreSQL | Primary database engine |
| pgAdmin | GUI client for database management and CSV import |
| SQL | Data exploration, cleaning, and business analysis |

---

## Project Workflow

### Step 1 — Table Creation

```sql
DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id                 SERIAL PRIMARY KEY,
    category               VARCHAR(120),
    name                   VARCHAR(150) NOT NULL,
    mrp                    NUMERIC(8,2),
    discountPercent        NUMERIC(5,2),
    availableQuantity      INTEGER,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms            INTEGER,
    outOfStock             BOOLEAN,
    quantity               INTEGER
);
```

---

### Step 2 — Data Import

Import the dataset using pgAdmin's import/export tool, or run:

```sql
\copy zepto(category, name, mrp, discountPercent, availableQuantity,
            discountedSellingPrice, weightInGms, outOfStock, quantity)
FROM 'data/zepto_v2.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ENCODING 'UTF8');
```

> **Note:** If you encounter a UTF-8 encoding error, re-save the CSV file as **CSV UTF-8** format before importing.

---

### Step 3 — Data Exploration

```sql
-- Total number of records
SELECT COUNT(*) FROM zepto;

-- Preview sample data
SELECT * FROM zepto LIMIT 10;

-- Check for NULL values across all columns
SELECT * FROM zepto
WHERE name IS NULL OR category IS NULL OR mrp IS NULL
   OR discountPercent IS NULL OR availableQuantity IS NULL
   OR discountedSellingPrice IS NULL OR weightInGms IS NULL
   OR outOfStock IS NULL OR quantity IS NULL;

-- All distinct product categories
SELECT DISTINCT category FROM zepto ORDER BY category;

-- In-stock vs out-of-stock count
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

-- Products appearing under multiple SKUs
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;
```

---

### Step 4 — Data Cleaning

```sql
-- Identify zero-price records
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- Remove rows with invalid zero MRP
DELETE FROM zepto WHERE mrp = 0;

-- Convert prices from paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;
```

---

### Step 5 — Business Insight Queries

```sql
-- Top 10 best-value products by discount percentage
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- High-MRP products that are currently out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE AND mrp > 300
ORDER BY mrp DESC;

-- Estimated revenue per category
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Premium products (MRP > ₹500) with low discount (< 10%)
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Top 5 categories by average discount percentage
SELECT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Price per gram for products above 100g (best value ranking)
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Classify products by weight into Low, Medium, and Bulk
SELECT DISTINCT name, weightInGms,
       CASE
           WHEN weightInGms < 1000 THEN 'Low'
           WHEN weightInGms < 5000 THEN 'Medium'
           ELSE 'Bulk'
       END AS weight_category
FROM zepto;

-- Total inventory weight per category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;
```

---

## Key Insights

| Business Question | Query Outcome |
|---|---|
| Which products offer the best discounts? | Top 10 SKUs ranked by discount percentage |
| Which premium products need restocking? | High-MRP items (> ₹300) flagged as out of stock |
| Which categories generate the most revenue? | Categories ranked by estimated inventory revenue |
| Which premium products have minimal discounts? | Items priced > ₹500 with less than 10% off |
| Which categories discount the most? | Top 5 categories by average discount |
| Which products offer the best price per gram? | Value-ranked products filtered above 100g |
| How is inventory weight distributed? | Total stock weight per category for logistics planning |

---

## How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/umasuryateja/Zepto_SQL_Data_Analysis_Project.git
   cd Zepto_SQL_Data_Analysis_Project
   ```

2. **Set up PostgreSQL**
   - Open pgAdmin or any PostgreSQL client
   - Create a new database (e.g., `zepto_db`)

3. **Run the SQL script**
   - Open `Zepto_SQL_Data_Analysis_Project.sql`
   - Execute the full script — table creation, data cleaning, and all analysis queries are included

4. **Import the dataset**
   - Use pgAdmin's import tool to load `zepto_v2.csv` into the `zepto` table
   - Or use the `\copy` command from Step 2
   - Ensure the file is saved in **UTF-8** encoding before import

5. **Explore and modify**
   - Run each section independently to follow the analysis step by step
   - Adjust filters and thresholds to explore your own business questions

---

## Future Scope

- Connect the cleaned dataset to Power BI for interactive dashboards
- Use **window functions** to build category-level pricing and ranking reports
- Extend with **time-series analysis** if historical pricing snapshots become available
- Build a **discount effectiveness analysis** to measure impact on estimated revenue
- Integrate with Python (Pandas + Matplotlib) for visual EDA alongside SQL

---

## Conclusion

This project demonstrates a complete, real-world data analyst workflow — from raw messy inventory data to clean, insight-ready SQL outputs. It reflects the day-to-day responsibilities of a data analyst in a retail or e-commerce environment, covering data cleaning, exploratory analysis, and business reporting entirely within SQL

---

