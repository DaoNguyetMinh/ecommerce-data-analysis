-- CATERORY
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
-- AOV by Category
WITH order_category AS (
	SELECT o.order_id,
		   COALESCE(p.product_category_name, 'Unknown') AS category,
		   SUM(i.price + i.freight_value) AS order_category_revenue
	FROM olist_orders_dataset o
	JOIN olist_order_items_dataset i
	  ON o.order_id = i.order_id
	LEFT JOIN olist_products_dataset p
	       ON i.product_id = p.product_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY o.order_id, category
)

SELECT category,
	   SUM(order_category_revenue) AS revenue,
	   COUNT(DISTINCT order_id) AS orders,
	   ROUND(SUM(order_category_revenue)/COUNT(DISTINCT order_id), 2) AS AOV
FROM order_category
GROUP BY category
ORDER BY AOV DESC;
-- -------------------------------------------------------------------------------------
-- Top categories by repeat purchase overview score
WITH customer_category_orders AS (
	SELECT c.customer_unique_id,
		   p.product_category_name AS category,
		   COUNT(DISTINCT o.order_id) AS order_count,
		   SUM(i.price + i.freight_value) AS revenue
	FROM olist_orders_dataset o
	JOIN olist_order_items_dataset i
	  ON o.order_id = i.order_id
	JOIN olist_products_dataset p
	  ON i.product_id = p.product_id
	JOIN olist_customers_dataset c 
	  ON o.customer_id = c.customer_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY c.customer_unique_id, category
),

customer_type AS (
	SELECT *,
		   CASE
		   	   WHEN order_count = 1 THEN 'One-time'
			   ELSE 'Repeat'
		   END AS customer_segment
	FROM customer_category_orders
)

SELECT category,
	   COUNT(DISTINCT customer_unique_id) AS total_customers,
	   COUNT(DISTINCT CASE
	   					  WHEN customer_segment = 'Repeat'
						  THEN customer_unique_id END) AS repeat_customers,
	   ROUND(
	   		 COUNT(DISTINCT CASE
							    WHEN customer_segment = 'Repeat'
								THEN customer_unique_id END)*1.0
		    /COUNT(DISTINCT customer_unique_id), 4) AS repeat_rate,
	   SUM(order_count) AS total_orders,
	   SUM(revenue) AS total_revenue,
	   ROUND(SUM(revenue)*1.0 / SUM(SUM(revenue)) OVER (), 4) AS revenue_percent,
	   ROUND(SUM(order_count)*1.0
	   		/COUNT(DISTINCT customer_unique_id), 2) AS avg_orders_per_customer
FROM customer_type
GROUP BY category
ORDER BY repeat_rate DESC;
-- ---------------------------------------------------------------------------------------
-- Category growth over time
WITH monthly_category_revenue AS (
	SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
		   COALESCE(p.product_category_name, 'Unknown') AS category,
		   SUM(i.price + i.freight_value) AS revenue
	FROM olist_orders_dataset o
	JOIN olist_order_items_dataset i
	  ON o.order_id = i.order_id
	LEFT JOIN olist_products_dataset p
	       ON i.product_id = p.product_id
	WHERE o.order_status NOT IN ('canceled', 'unavailable')
	GROUP BY month, category
)

SELECT month, category, revenue
FROM monthly_category_revenue
ORDER BY month, category;
-- ------------------------------------------------------------------------------------------------------------------
-- Freight cost as % of Product Revenue by Category (RANK)
WITH cat_freight AS (
	SELECT COALESCE(pt.product_category_name_english, p.product_category_name) AS category,
		   COUNT(i.order_item_id) AS items_sold,
		   ROUND(SUM(i.price), 2) AS total_revenue,
		   ROUND(SUM(i.freight_value), 2) AS total_freight
	FROM olist_order_items_dataset i
	JOIN olist_products_dataset p ON i.product_id = p.product_id
	LEFT JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
	GROUP BY COALESCE(pt.product_category_name_english, p.product_category_name)
	HAVING COUNT(i.order_item_id) > 30
)

SELECT *,
	   ROUND(100.0*total_freight / NULLIF(total_revenue, 0), 2) AS freight_pct,
	   RANK() OVER (ORDER BY total_freight / NULLIF(total_revenue, 0) DESC) AS freight_burden_rank
FROM cat_freight
ORDER BY freight_pct DESC
LIMIT 15;







































