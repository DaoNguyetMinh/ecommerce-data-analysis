-- --------------------------------------------------------
-- Top 5 Customers by Revenue
WITH payment_agg AS (
	SELECT order_id,
		SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
)

SELECT o.customer_id,
	   c.customer_city,
	   c.customer_state,
	   SUM(p.total_payment) AS total_revenue
FROM olist_orders_dataset o
JOIN payment_agg p
	ON o.order_id = p.order_id
JOIN olist_customers_dataset c
	ON o.customer_id = c.customer_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY c.customer_city, c.customer_state, o.customer_id
ORDER BY total_revenue DESC
LIMIT 5;
-- ---------------------------------------------------------------------------------------------------------
-- Customer order frequency buckets
WITH payment_agg AS (
	SELECT order_id,
		   SUM(payment_value) AS total_payment
	FROM olist_order_payments_dataset
	GROUP BY order_id
),

customer_orders AS (
	SELECT c.customer_unique_id,
		   o.order_id,
		   p.total_payment
	FROM olist_orders_dataset o
	JOIN payment_agg p
	  ON o.order_id = p.order_id
	JOIN olist_customers_dataset c
	  ON o.customer_id = c.customer_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
),

customer_frequency AS (
	SELECT customer_unique_id,
		   COUNT(order_id) AS total_orders,
		   SUM(total_payment) AS total_revenue
	FROM customer_orders
	GROUP BY customer_unique_id
),

buckets AS (
	SELECT *,
		   CASE
		   	   WHEN total_orders = 1 THEN '1 order'
			   WHEN total_orders = 2 THEN '2 orders'
			   WHEN total_orders BETWEEN 3 AND 5 THEN '3-5 orders'
			   WHEN total_orders BETWEEN 6 AND 10 THEN '6-10 orders'
			   ELSE '+10 orders'
		   END AS frequency_bucket
	FROM customer_frequency
)

SELECT frequency_bucket,
	   COUNT(*) AS customers,
	   SUM(total_orders) AS orders,
	   SUM(total_revenue) AS revenue,
	   ROUND(SUM(total_revenue)*100.0 / SUM(SUM(total_revenue)) OVER (), 2) AS revenue_percent
FROM buckets
GROUP BY frequency_bucket
ORDER BY customers DESC;



































