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
-- ---------------------------------------------------------------------------------------------------
-- Evaluation of Review and Delivery Performance Among Top Sellers
WITH seller_revenue AS (
	SELECT i.seller_id, s.seller_city, s.seller_state,
		   SUM(i.price + i.freight_value) AS revenue
	FROM olist_orders_dataset o
	JOIN olist_order_items_dataset i
	  ON o.order_id = i.order_id
	JOIN olist_sellers_dataset s
	  ON i.seller_id = s.seller_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY i.seller_id, s.seller_city, s.seller_state
),

top_sellers AS (
	SELECT *
	FROM seller_revenue 
	ORDER BY revenue DESC
	LIMIT 20
),

seller_quality AS (
	SELECT i.seller_id,
		   ROUND(AVG(r.review_score), 2) AS avg_review_score,
		   ROUND(AVG(CASE
		   				 WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
						 THEN 1 ELSE 0
					 END), 2) AS on_time_delivery_rate
	FROM olist_orders_dataset o
	JOIN olist_order_items_dataset i
	  ON o.order_id = i.order_id
	LEFT JOIN olist_order_reviews_dataset r
		   ON o.order_id = r.order_id
	WHERE o.order_status = 'delivered'
	GROUP BY i.seller_id
)

SELECT t.seller_id,
	   t.seller_city,
	   t.seller_state,
	   t.revenue,
	   q.avg_review_score,
	   q.on_time_delivery_rate
FROM top_sellers t
LEFT JOIN seller_quality q
	   ON t.seller_id = q.seller_id
ORDER BY t.revenue DESC;




























