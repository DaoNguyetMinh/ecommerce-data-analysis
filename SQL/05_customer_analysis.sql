-- --------------------------------------------------------
-- 4. Top 5 Customers by Revenue
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