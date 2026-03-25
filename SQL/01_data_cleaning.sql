-- ========================================================
-- OLIST ECOMMERCE ANALYSIS
-- Author: Dao Nguyet Minh
-- Date: 07/03/2026
-- 1. DATA QUALITY CHECK
-- ========================================================
-- CHECK NULL VALUES
SELECT COUNT(*)
FROM olist_orders_dataset
WHERE order_id IS NULL 
   OR order_purchase_timestamp IS NULL 
   OR order_status IS NULL;

SELECT COUNT(*)
FROM olist_order_payments_dataset
WHERE payment_value IS NULL;

SELECT COUNT(*)
FROM olist_order_items_dataset
WHERE price IS NULL 
   OR freight_value IS NULL;

SELECT COUNT(*)
FROM olist_products_dataset
WHERE product_category_name IS NULL;

-- CHECK DUPLICATE ORDERS
SELECT order_id, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- CHECK ORDER STATUS DISTRIBUTION
SELECT order_status, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_status;

-- CHECK CANCELED/UNAVAILABLE SHARE
SELECT
	order_status,
	COUNT(*) AS order_count,
	ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_orders_dataset)
	, 2) AS status_percent
FROM olist_orders_dataset
WHERE order_status IN ('canceled', 'unavailable')
GROUP BY order_status;

-- CHECK GRAIN
-- 1 row = 1 order
SELECT order_id, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_id;

-- olist_order_items_dataset is at item-line level, where each row is uniquely identified by (order_id, order_item_id)
SELECT order_id,
	   order_item_id,
	   COUNT(*) AS cnt
FROM olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- One order have multiple payment records
SELECT order_id, COUNT(*)
FROM olist_order_payments_dataset
GROUP BY order_id
ORDER BY COUNT(*) DESC;

-- CHECK TIME RANGE
-- The data start in 04/09/2016 - end in 17/10/2018
SELECT 
	MIN(order_purchase_timestamp) AS min_purchase_date,
	MAX(order_purchase_timestamp) AS max_purchase_date
FROM olist_orders_dataset;

SELECT 
	EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
	EXTRACT(MONTH FROM order_purchase_timestamp) AS month,
	COUNT(*) AS order_count
FROM olist_orders_dataset
GROUP BY year, month
ORDER BY year, month;

-- CHECK PAYMENT ANOMALIES
-- Order have payment but canceled
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
)

SELECT o.order_id,
	   o.order_status,
	   p.total_payment
FROM olist_orders_dataset o
JOIN payment_agg p
	ON o.order_id = p.order_id
WHERE o.order_status = 'canceled'
ORDER BY p.total_payment DESC;

-- Order have payment_value = 0
SELECT order_id, COUNT(*)
FROM olist_order_payments_dataset
WHERE payment_value = 0
GROUP BY order_id;

--Order without payment
SELECT COUNT(*) AS order_without_payment
FROM olist_orders_dataset o
LEFT JOIN olist_order_payments_dataset p
	   ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

-- ----------------------------------------------





