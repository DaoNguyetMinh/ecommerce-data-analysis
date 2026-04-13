-- --------------------------------------------------------------------------------
-- Top seller revenue share
WITH seller_revenue AS (
	SELECT i.seller_id,
		   SUM(i.price + i.freight_value) AS revenue
	FROM olist_orders_dataset o
	JOIN olist_order_items_dataset i
	  ON o.order_id = i.order_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY i.seller_id
)

SELECT sr.seller_id, sr.revenue, s.seller_city, s.seller_state,
	   ROUND(sr.revenue*100.0
	   	 	/(SELECT SUM(revenue) FROM seller_revenue), 2) AS revenue_percent
FROM seller_revenue sr
JOIN olist_sellers_dataset s
  ON sr.seller_id = s.seller_id
ORDER BY revenue DESC 
LIMIT 10;
-- -----------------------------------------------------------------------------------
-- Distribution of sellers across states
SELECT seller_state,
	   COUNT(DISTINCT seller_id) AS total_sellers,
	   ROUND(COUNT(DISTINCT seller_id)*100.0
	   	    /SUM(COUNT(DISTINCT seller_id)) OVER (), 2) AS seller_percent
FROM olist_sellers_dataset
GROUP BY seller_state
ORDER BY total_sellers DESC;
-- -------------------------------------------------------------------------------------
-- revenue per state
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





























