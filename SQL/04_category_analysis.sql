-- CATERORY
-- --------------------------------------------------------
-- Top 10 Products by Revenue
WITH product_revenue AS (
	SELECT i.product_id,
		   SUM(i.price + i.freight_value) AS revenue
	FROM olist_orders_dataset o
	JOIN olist_order_items_dataset i
		ON o.order_id = i.order_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY i.product_id
)

SELECT 
	product_id,
	revenue,
	ROUND(revenue * 100.0 / (SELECT SUM(revenue) FROM product_revenue), 2) AS revenue_percent
FROM product_revenue
ORDER BY revenue DESC
LIMIT 10;