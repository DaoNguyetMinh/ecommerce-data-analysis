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
-- Revenue by Category
SELECT COALESCE(p.product_category_name, 'Unknown') AS category,
	   SUM(i.price + i.freight_value) AS revenue_item,
	   ROUND(SUM(i.price + i.freight_value)*100 
	   	   / SUM(SUM(i.price + i.freight_value)) OVER (), 2) AS revenue_percent
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
  ON o.order_id = i.order_id
LEFT JOIN olist_products_dataset p
	   ON i.product_id = p.product_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY category
ORDER BY revenue_item DESC;
-- ------------------------------------------------------------------------------------
-- Revenue by Customer
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