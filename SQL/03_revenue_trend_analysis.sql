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
-- Revenue by Customer Segment
WITH payment_agg AS (
	SELECT order_id,
		   SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
),

customer_orders AS (
	SELECT c.customer_unique_id,
		   COUNT(DISTINCT o.order_id) AS order_count,
		   SUM(p.total_payment) AS customer_revenue
	FROM olist_orders_dataset o
	JOIN payment_agg p
	  ON o.order_id = p.order_id
	JOIN olist_customers_dataset c
	  ON o.customer_id = c.customer_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY c.customer_unique_id
),

customer_segment AS (
	SELECT customer_unique_id,
		   customer_revenue,
		   CASE
		   	   WHEN order_count = 1 THEN 'One-time'
			   WHEN order_count BETWEEN 2 AND 3 THEN 'Repeat'
			   ELSE 'High-value'
		   END AS segment
	FROM customer_orders
)

SELECT segment,
	   COUNT(*) AS customer_count,
	   SUM(customer_revenue) AS total_revenue,
	   ROUND(SUM(customer_revenue)*100.0
	   	   / SUM(SUM(customer_revenue)) OVER (), 2) AS revenue_percent
FROM customer_segment
GROUP BY segment
ORDER BY total_revenue DESC;
-- -------------------------------------------------------------------------------------
-- Revenue per state
WITH seller_perf AS (
    SELECT 
        s.seller_state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(i.price + i.freight_value) AS total_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_items_dataset i
        ON o.order_id = i.order_id
    JOIN olist_sellers_dataset s
        ON i.seller_id = s.seller_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY s.seller_state
)

SELECT 
    seller_state,
    total_orders,
    total_revenue,
    ROUND(total_revenue / total_orders, 2) AS avg_order_value,
    ROUND(total_revenue * 100.0 
        / SUM(total_revenue) OVER (), 2) AS revenue_percent
FROM seller_perf
ORDER BY total_revenue DESC;
-- --------------------------------------------------------------------------------------------
-- AOV overall approximate 160
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
)

SELECT ROUND(SUM(p.total_payment)/COUNT(DISTINCT o.order_id), 2) AS AOV
FROM olist_orders_dataset o
JOIN payment_agg p
	ON o.order_id = p.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
-- -----------------------------------------------------------------------------------
-- 3. AOV by Month
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
),

monthly_metrics AS (
	SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
		   SUM(p.total_payment) AS revenue,
		   COUNT(DISTINCT o.order_id) AS orders,
		   ROUND(SUM(p.total_payment) / COUNT(DISTINCT o.order_id), 2) AS AOV
	FROM olist_orders_dataset o
	JOIN payment_agg p
	  ON o.order_id = p.order_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY 1
	ORDER BY 1
)

SELECT month,
	   revenue,
	   orders,
	   AOV,
	   ROUND((AOV - LAG(AOV) OVER (ORDER BY month)) / LAG(AOV) OVER (ORDER BY month)*100, 2) AS AOV_growth
FROM monthly_metrics
-- ----------------------------------------------------------------------------------------
-- AOV by Customer Segment
WITH payment_agg AS (
	SELECT order_id,
		   SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
),

customer_orders AS (
	SELECT c.customer_unique_id,
		   p.total_payment,
		   o.order_id
	FROM olist_orders_dataset o
	JOIN payment_agg p
	  ON o.order_id = p.order_id
	JOIN olist_customers_dataset c
	  ON o.customer_id = c.customer_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
),

customer_segment AS (
	SELECT customer_unique_id,
		   COUNT(order_id) AS total_orders,
		   CASE 
		   	   WHEN COUNT(order_id) = 1 THEN 'One-time'
			   WHEN COUNT(order_id) BETWEEN 2 AND 5 THEN 'Repeat'
			   ELSE 'High-value'
		   END AS segment
	FROM customer_orders
	GROUP BY customer_unique_id
)

SELECT s.segment,
	   COUNT(DISTINCT co.order_id) AS orders,
	   SUM(co.total_payment) AS revenue,
	   ROUND(SUM(co.total_payment)/COUNT(DISTINCT co.order_id), 2) AS AOV
FROM customer_orders co
JOIN customer_segment s
  ON co.customer_unique_id = s.customer_unique_id
GROUP BY s.segment
ORDER BY AOV DESC;

