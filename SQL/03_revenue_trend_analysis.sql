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
-- --------------------------------------------------------
-- 2. Revenue by Month
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
),
monthly_revenue AS (
	SELECT
		COUNT(o.order_id) AS quatily_order,
		DATE_TRUNC('month', order_purchase_timestamp) AS month,
		SUM(p.total_payment) AS revenue
	FROM olist_orders_dataset o
	JOIN payment_agg p
		ON o.order_id = p.order_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY month
)

SELECT month,
	   revenue,
	   quatily_order,
	   ROUND((revenue - LAG(revenue) OVER (ORDER BY month))
	   /
	   LAG(revenue) OVER (ORDER BY month) * 100, 2) AS MoM
FROM monthly_revenue;

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