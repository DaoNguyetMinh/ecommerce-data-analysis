-- ========================================================
-- OLIST ECOMMERCE ANALYSIS
-- Author: Dao Nguyet Minh
-- Date: 03/03/2026
-- 2. REVENUE ANALYSIS
-- ========================================================
-- Test connect
SELECT
	(SELECT COUNT(*) FROM olist_orders_dataset) AS total_orders,
	(SELECT COUNT(*) FROM olist_order_items_dataset) AS total_items,
	(SELECT COUNT(*) FROM olist_order_payments_dataset) AS total_payments;

-- 1. Total Revenue
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
)

SELECT SUM(total_payment) AS total_revenue
FROM olist_orders_dataset o
JOIN payment_agg p
	ON o.order_id = p.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');
-- total_revenue = 15739137.01
-- --------------------------------------------------------
-- 2. Revenue by Year
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
)

SELECT
	EXTRACT (YEAR FROM o.order_purchase_timestamp) AS order_purchase_year,
	SUM(p.total_payment) AS total_revenue
FROM olist_orders_dataset o
JOIN payment_agg p
	ON o.order_id = p.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY EXTRACT (YEAR FROM o.order_purchase_timestamp)
ORDER BY order_purchase_year;
-- Insight: Revenue increased by 16,488.06% from 2016 to 2018.
-- --------------------------------------------------------
-- 3. Average Order Value (AOV)
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
)

SELECT SUM(p.total_payment)/COUNT(DISTINCT o.order_id) AS AOV
FROM olist_orders_dataset o
JOIN payment_agg p
	ON o.order_id = p.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');
-- --------------------------------------------------------
-- 4. Top 5 Customers by Revenue
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
)

SELECT o.customer_id, 
	SUM(p.total_payment) AS total_revenue
FROM olist_orders_dataset o
JOIN payment_agg p
	ON o.order_id = p.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY o.customer_id
ORDER BY total_revenue DESC
LIMIT 5;
-- --------------------------------------------------------
-- Top 10 Products by Revenue
WITH product_revenue AS (
	SELECT product_id,
		SUM(price + freight_value) AS revenue
	FROM olist_order_items_dataset
	GROUP BY product_id
),

top_products AS (
	SELECT *
	FROM product_revenue
	ORDER BY revenue DESC
	LIMIT 10
)

SELECT SUM(revenue) * 100.0 / (SELECT SUM(revenue) FROM product_revenue) AS top_10_revenue_percentage
FROM top_products;
-- --------------------------------------------------------------------------------
-- Top 10 Sellers by Revenue





