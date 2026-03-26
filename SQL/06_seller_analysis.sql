-- --------------------------------------------------------------------------------
-- Top 10 Sellers by Revenue
SELECT i.seller_id,
	   s.seller_city,
	   s.seller_state,
	   SUM(i.price + i.freight_value) AS seller_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset i
	ON o.order_id = i.order_id
JOIN olist_sellers_dataset s
	ON i.seller_id = s.seller_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY s.seller_city, s.seller_state, i.seller_id
ORDER BY seller_revenue DESC
LIMIT 5;