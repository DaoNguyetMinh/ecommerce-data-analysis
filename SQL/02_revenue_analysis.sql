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
),
yearly_revenue AS (
	SELECT 
		EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,
		SUM(p.total_payment) AS revenue
	FROM olist_orders_dataset o
	JOIN payment_agg p
		ON o.order_id = p.order_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY year
)

SELECT year,
	   revenue,
	   ROUND((revenue - LAG(revenue) OVER (ORDER BY year))
	   /
	   LAG(revenue) OVER (ORDER BY year) * 100, 2) AS growth_percent
FROM yearly_revenue;
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
SELECT i.product_id,
	SUM(i.price + i.freight_value) AS product_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
	ON o.order_id = i.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY i.product_id
ORDER BY product_revenue DESC
LIMIT 10;
-- --------------------------------------------------------------------------------
-- Top 10 Sellers by Revenue
SELECT i.seller_id,
	SUM(i.price + i.freight_value) AS seller_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
	ON o.order_id = i.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY i.seller_id
ORDER BY seller_revenue DESC
LIMIT 10;




