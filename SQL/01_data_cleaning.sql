-- ========================================================
-- OLIST ECOMMERCE ANALYSIS
-- Author: Dao Nguyet Minh
-- Date: 07/03/2026
-- 1. DATA QUALITY CHECK
-- ========================================================
-- Check NULL values
SELECT COUNT(*)
FROM olist_orders_dataset
WHERE order_id IS NULL;

-- Check duplicate orders
SELECT order_id, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Check order status distribution
SELECT order_status, COUNT(*)
FROM olist_orders_dataset
GROUP BY order_status;

-- Check payment records per order
SELECT order_id, COUNT(*)
FROM olist_order_payments_dataset
GROUP BY order_id
ORDER BY COUNT(*) DESC;











