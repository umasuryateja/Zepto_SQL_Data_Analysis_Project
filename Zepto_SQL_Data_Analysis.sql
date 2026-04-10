drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);


---DATA EXPLORATION

--- COUNT OF ROWS
SELECT COUNT(*) FROM zepto;

---SAMPLE DATA
SELECT * FROM zepto
limit 10;

---NULL VALUES 
SELECT * FROM zepto 
WHERE name IS NULL 
OR 
category IS NULL 
OR 
mrp IS NULL 
OR 
discountpercent IS NULL 
OR 
availablequantity IS NULL 
OR
discountedsellingprice IS NULL 
OR 
weightingms IS NULL 
OR 
outofstock IS NULL 
OR 
quantity IS NULL; 


---DIFFRENT PRODUCT CATEGORIES
SELECT distinct category
from zepto
order by category;


--- PRODUCTS IN STOCK VS OUT OF STOCK
SELECT outofstock, count(sku_id)
from zepto
GROUP BY outofstock;


---PRODUCT NAMES PRESENT MUTIPLE TIMES 
SELECT name,count(sku_id) as "NUmber Of SKUs"
from zepto
group by name
having count(sku_id) > 1
order by count(sku_id) desc;

---DATA CLEANING

---PRODUCTS WITH PRICE = 0
SELECT * FROM zepto
where mrp = 0 or discountedsellingprice = 0;

DELETE FROM zepto
WHERE mrp = 0;


--- convert paise to rupees
update zepto
set mrp = mrp/100.0,
discountedSellingPrice=discountedSellingPrice/100.0; 

SELECT mrp,discountedsellingprice FROM zepto


---BUSINESS INSIGHT QUERIES

---FIND THE TOP 10 BEST-VALUE PRODUCTS BASED ON THE DISCOUNT PERCENTAGE.
SELECT DISTINCT name,mrp,discountpercent FROM zepto
ORDER BY discountpercent desc
LIMIT 10;

--- WHAT ARE THE PRODUCTS WITH HIGH MRP BUT OUT OF STOCK
SELECT DISTINCT name,mrp FROM zepto
WHERE outofstock = TRUE and mrp > 300
ORDER BY mrp DESC;

---CALCULATE ESTIMATED REVENUE FOR EACH CATEGORY
SELECT category,
SUM(discountedsellingprice * availablequantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

--- FIND ALL PRODUCTS WHERE MRP IS GREATER THAN RS 500 AND DISCOUNT IS LESS THAN 10%
SELECT DISTINCT name,mrp,discountpercent
FROM zepto
WHERE mrp > 500 and discountpercent < 10
ORDER BY mrp DESC, discountpercent DESC;

--- IDENTIFY THE TOP 5 CATEGORIES OFFERING THE HIGHEST AVERAGE DISCOUNT PERCENTAGE.
SELECT category,
ROUND(AVG(discountpercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY  avg_discount DESC
LIMIT 5;

--- FIND THE PRICE PER GRAM FOR PRODUCTS ABOVE 100G AND SORT BY BEST VALUE
SELECT DISTINCT name,weightingms,discountedsellingprice,
ROUND(discountedsellingprice/weightingms,2) AS price_per_gram
FROM zepto
WHERE weightingms >=100
ORDER BY price_per_gram;

--- GROUP THE PRODUCTS INTO CATEGORY LIKE LOW, MEDIUM, BULK.
SELECT DISTINCT name, weightingms,
CASE WHEN weightingms < 1000 THEN 'Low'
     WHEN weightingms < 5000 THEN 'Medium'
	 ELSE 'Bulk'
	 END AS weight_category
FROM zepto;

--- WHAT IS THE TOTAL INVENTORY WEIGHT PER CATEGORY
SELECT category,
SUM(weightingms *  availablequantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;


