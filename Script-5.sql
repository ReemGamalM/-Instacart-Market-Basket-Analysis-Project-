-- calculate summary statistics for numerical values
-- table orders
-- statistics for days_since_prior_order
SELECT 
	AVG(days_since_prior_order) AS average_days_between_orders, 
	MIN(days_since_prior_order) AS min_days_between_orders, 
	MAX(days_since_prior_order) AS max_days_between_orders 
FROM orders o ;

-- count number of orders
SELECT COUNT(DISTINCT order_id) 
FROM orders o ;

-- number of useres made an order
SELECT COUNT(DISTINCT user_id) 
FROM orders o ;

-- get max and min number of orders
SELECT 
	MAX(order_number),
	MIN(order_number) 
FROM orders o ;

-- get number of orders in each day
SELECT 
	order_dow,
	count(order_id)
FROM orders o
GROUP BY order_dow
ORDER BY order_dow;

-- get number of orders in each hour order_hour_of_day
SELECT 
	order_hour_of_day,
	count(order_id)
FROM orders o
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;

-- Table Aisle
-- count number of aisle
SELECT COUNT(DISTINCT aisle_id) 
FROM aisles a ;

-- Table department
-- count number of department
SELECT COUNT(DISTINCT department_id) 
FROM departments a ;

-- Table Products
-- count number of products
SELECT COUNT(DISTINCT product_id) 
FROM products p ;

-- count number of product in each aisle
SELECT 
	aisle_id,
	count(product_id)
FROM products p
GROUP BY aisle_id
ORDER BY aisle_id;

-- count number of product in each department
SELECT 
	department_id,
	count(product_id)
FROM products p
GROUP BY department_id
ORDER BY department_id;

-- count number of aisle in each department
SELECT 
	department_id,
	count(aisle_id)
FROM products p
GROUP BY department_id
ORDER BY department_id;

-- Table order_product_prior
-- how many times the product is reordered
SELECT 
	opp.product_id, p.product_name, 
	SUM(opp.reordered)
FROM order_products__prior opp 
JOIN products p
on p.product_id = opp.product_id 
GROUP BY product_id, p.product_name 
ORDER BY SUM(opp.reordered) DESC;

-- Size of reordered orders
SELECT 
	order_id, 
	COUNT(product_id)
FROM order_products__prior opp  
WHERE reordered = 1
GROUP BY order_id
ORDER BY COUNT(product_id) DESC;

-- number of reordered orders
SELECT 
	COUNT(DISTINCT order_id)
FROM order_products__prior opp  
WHERE reordered = 1;

-- products added to cart first
SELECT 
	DISTINCT opp.product_id, 
	p.product_name 
FROM order_products__prior opp 
JOIN products p
on p.product_id = opp.product_id 
WHERE add_to_cart_order = 1;

-- ---------Exploratory Data Analysis----------------

-- Average number of order per user
SELECT ROUND(AVG(order_per_user),2) 
FROM
	(SELECT 
		user_id ,
		count(order_id) as order_per_user
	FROM orders o
	GROUP BY user_id) as user_order;

-- Average time between orders for each user
SELECT 
	user_id ,
	AVG(days_since_prior_order)
FROM orders o
GROUP BY user_id;

-- Categorize customer based on the total amount they've spent on the orders (orders)
-- high spend --> high number of products
-- max_number_orders = 29
-- 29/4 = 7
-- 29/2 = 14
-- (3*29)/4 = 21
SELECT MAX(count_product)
FROM 
	(SELECT 
	    o.user_id, COUNT(opp.product_id) AS count_product
	FROM orders o
	JOIN order_products__prior opp 
	ON o.order_id = opp.order_id 
	GROUP BY user_id) AS Max_num_products;

SELECT 
    user_id,
    COUNT(opp.product_id),
    CASE 
        WHEN COUNT(opp.product_id) < 7 THEN 'LOW'
        WHEN COUNT(opp.product_id) < 14 THEN 'MEDIUM'
        WHEN COUNT(opp.product_id) < 21 THEN 'HIGH'
        ELSE 'VERY HIGH'
    END AS user_categ
FROM orders o
JOIN order_products__prior opp 
ON o.order_id = opp.order_id 
GROUP BY user_id
ORDER BY COUNT(opp.product_id) DESC;

-- Customer segments based on purchase frequency
-- max_number_orders = 100
-- 100/4 = 25
-- 100/2 = 50
-- (3*100)/4 = 75
SELECT MAX(count_order)
FROM 
	(SELECT 
	    user_id, COUNT(order_id) AS count_order
	FROM orders o
	GROUP BY user_id) AS Max_num_order;

SELECT 
    user_id,
    COUNT(order_id),
    CASE 
        WHEN COUNT(order_id) < 25 THEN 'LOW'
        WHEN COUNT(order_id) < 50 THEN 'MEDIUM'
        WHEN COUNT(order_id) < 75 THEN 'HIGH'
        ELSE 'VERY HIGH'
    END AS user_categ
FROM orders o
GROUP BY user_id
ORDER BY COUNT(order_id) DESC;

-- Product Analysis
-- Identify most popular product by frequency
SELECT opp.product_id, p.product_name ,COUNT(opp.product_id) 
FROM order_products__prior opp 
JOIN products p 
ON opp.product_id = p.product_id 
GROUP BY opp.product_id, p.product_name 
ORDER BY COUNT(opp.product_id) DESC;

-- Determine average order size(number of items per order)
SELECT ROUND(AVG(count_product),2)
FROM 
	(SELECT 
	    order_id, COUNT(product_id) AS count_product
	FROM order_products__prior opp 
	GROUP BY order_id) AS Max_num_product;

-- Temporal Patterns
-- Analyze orders by day of week and hour of day
-- Day of week
SELECT 
	order_dow,
	count(order_id)
FROM orders o
GROUP BY order_dow
ORDER BY order_dow;
-- hour of day
SELECT 
	order_hour_of_day,
	count(order_id)
FROM orders o
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;

-- Basket Analysis
-- identify most frequently co-purchased items
SELECT 
	opp.product_id AS product1, 
	opp2.product_id AS product2,
	COUNT(*) 
FROM order_products__prior opp 
JOIN order_products__prior opp2 
ON opp.order_id = opp2.order_id AND opp.product_id != opp2.product_id
GROUP BY opp.product_id, opp2.product_id
ORDER BY COUNT(*) DESC;

-- products often bought together on weekends vs. weekdays
-- weekends
SELECT 
	opp.product_id AS product1, 
	opp2.product_id AS product2,
	COUNT(*) 
FROM order_products__prior opp 
JOIN order_products__prior opp2 
ON opp.order_id = opp2.order_id AND opp.product_id != opp2.product_id
WHERE opp.order_id IN (
		SELECT order_id
		FROM orders o 
		WHERE order_dow in (0,6)
)
GROUP BY opp.product_id, opp2.product_id
ORDER BY COUNT(*) DESC;

-- weekdays
SELECT 
	opp.product_id AS product1, 
	opp2.product_id AS product2,
	COUNT(*) 
FROM order_products__prior opp 
JOIN order_products__prior opp2 
ON opp.order_id = opp2.order_id AND opp.product_id != opp2.product_id
WHERE opp.order_id IN (
		SELECT order_id
		FROM orders o 
		WHERE order_dow NOT IN (0,6)
)
GROUP BY opp.product_id, opp2.product_id
ORDER BY COUNT(*) DESC;

-- Buisness Questions and Analysis
-- Popular products
-- Analyze sales distribution of top-selling products
SELECT 
	opp.product_id, p.product_name, 
	COUNT(opp.product_id)
FROM order_products__prior opp 
JOIN products p
on p.product_id = opp.product_id 
GROUP BY product_id, p.product_name 
ORDER BY COUNT(opp.product_id) DESC;


-- Identify top 5 products commonly added to the cart first
SELECT 
	opp.product_id, p.product_name, 
	COUNT(opp.product_id)
FROM order_products__prior opp 
JOIN products p
on p.product_id = opp.product_id 
WHERE opp.add_to_cart_order = 1
GROUP BY product_id, p.product_name 
ORDER BY COUNT(opp.product_id) DESC
LIMIT 5;

-- How many unique products are typically included in a single order
SELECT 
    AVG(unique_product_count) AS avg_unique_products_per_order
FROM (
    SELECT 
        order_id, 
        COUNT(DISTINCT product_id) AS unique_product_count
    FROM order_products__prior opp 
    GROUP BY order_id
) AS product_counts_per_order;

-- Reorder Behavior
-- products reordered the most
SELECT
	opp.product_id,
	p.product_name,
	COUNT(opp.product_id) 
FROM order_products__prior opp 
JOIN products p
on p.product_id = opp.product_id 
WHERE reordered = 1
GROUP BY product_id, p.product_name 
ORDER BY COUNT(opp.product_id) DESC;

-- Reorder behavior based on day of the week and days since prior order
-- Day of week
WITH avg_product_per_dow AS (
    SELECT 
        order_dow,
        COUNT(product_id) AS count_product_weed
    FROM order_products__prior opp 
    JOIN orders o 
    ON opp.order_id = o.order_id 
    WHERE reordered = 1
    GROUP BY order_dow
)
SELECT 
	order_dow,
	count_product_weed / SUM(count_product_weed) OVER () AS total
FROM avg_product_per_dow;

-- days since prior order
WITH avg_product_per_dsp AS (
    SELECT 
        days_since_prior_order,
        COUNT(product_id) AS count_product_dsp
    FROM order_products__prior opp 
    JOIN orders o 
    ON opp.order_id = o.order_id 
    WHERE reordered = 1
    GROUP BY days_since_prior_order
)
SELECT 
	days_since_prior_order,
	count_product_dsp / SUM(count_product_dsp) OVER () AS total
FROM avg_product_per_dsp;

-- How the number of items in the cart impact the likelihood of reordering
WITH avg_product_likelihood AS (
    SELECT 
		order_id,
		reordered ,
		COUNT(product_id) AS count_product
	FROM order_products__prior opp
	GROUP BY order_id, reordered
)
SELECT
	order_id,
	count_product / SUM(count_product) OVER (PARTITION BY order_id) AS total
FROM avg_product_likelihood;

-- Department and Aisle Analysis
-- Best-selling department and aisle breakdown
WITH dep_aisle_product AS (
    SELECT
		department_id,
		aisle_id,
		COUNT(opp.product_id) AS count_product
	FROM products p
	JOIN order_products__prior opp 
	ON p.product_id = opp.product_id 
	GROUP BY department_id, aisle_id
	ORDER BY count_product DESC
)
SELECT
	department,
	aisle
FROM dep_aisle_product dap
JOIN departments d
ON d.department_id = dap.department_id
JOIN aisles a
ON a.aisle_id = dap.aisle_id
ORDER BY department;

-- what is the "produce" department? break it down by aisle
SELECT department,aisle
FROM products p 
JOIN aisles a 
ON p.aisle_id = a.aisle_id 
JOIN departments d 
ON p.department_id = d.department_id 
where department = 'produce'
GROUP BY department,aisle;

-- Difference in purchasing behavior based on different deparment or aisle
SELECT 
	department,
	aisle,
	COUNT(opp.product_id) 
FROM products p 
JOIN aisles a 
ON p.aisle_id = a.aisle_id 
JOIN departments d 
ON p.department_id = d.department_id
JOIN order_products__prior opp 
ON opp.product_id = p.product_id 
GROUP BY department,aisle;


-- *************Time Based Analysis***************
-- Adding column date and assume start date
ALTER TABLE orders
DROP COLUMN order_date;

ALTER TABLE orders
ADD COLUMN order_date DATE DEFAULT('2023-01-01');

UPDATE orders o
JOIN (
    SELECT 
        order_id,
        order_number,
        SUM(days_since_prior_order) OVER (PARTITION BY user_id ORDER BY order_number) AS cumulative_days
    FROM orders
) CO ON o.order_id = CO.order_id
SET o.order_date = (CASE
    WHEN CO.order_number = 1 THEN '2023-01-01'
    ELSE DATE_ADD('2023-01-01', INTERVAL CO.cumulative_days DAY)
    END);

-- OR
WITH CumulativeOrders AS (
    SELECT 
        order_id,
        order_number,
        SUM(days_since_prior_order) OVER (PARTITION BY user_id ORDER BY order_number) AS cumulative_days
    FROM orders
)
UPDATE orders o
JOIN CumulativeOrders CO ON o.order_id = CO.order_id
SET o.order_date = (CASE
    WHEN CO.order_number = 1 THEN '2023-01-01'
    ELSE DATE_ADD('2023-01-01', INTERVAL CO.cumulative_days DAY)
	END);


-- identify customers who haven't placed an order in the last 30 days
SELECT DATE_ADD(CURRENT_TIMESTAMP, INTERVAL -30 DAY) AS "CURRENTTIMESTAMP"; 
SELECT DATE_ADD(MAX(order_date), INTERVAL -30 DAY)  FROM orders;

SELECT 
	user_id 
FROM orders o 
WHERE user_id NOT IN(
	SELECT user_id
	FROM orders o2 
	WHERE order_date >= (
		SELECT DATE_ADD(MAX(order_date), INTERVAL -30 DAY)  
		FROM orders
	)
)
-- percentage of customers churned in the past quarter
SELECT DATE_ADD(CURRENT_TIMESTAMP, INTERVAL -3 MONTH) AS "CURRENTTIMESTAMP"; 
SELECT DATE_ADD(MAX(order_date), INTERVAL -3 MONTH)  FROM orders;

SELECT 
	COUNT(DISTINCT user_id) * 100 / (SELECT COUNT(DISTINCT user_id) FROM orders o ) AS per_user
FROM orders o 
WHERE user_id NOT IN(
	SELECT user_id
	FROM orders o2 
	WHERE order_date >= (
		SELECT DATE_ADD(MAX(order_date), INTERVAL -3 MONTH)  
		FROM orders
	)
)

























	





