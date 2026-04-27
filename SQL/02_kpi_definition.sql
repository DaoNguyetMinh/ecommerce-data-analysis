-- ==============================================================
-- Product and seller contribution analysis uses item-level revenue approximated 
-- by 'price + freight_value'.
-- Overall revenue is measured using 'payment_value' aggregated at the order level.
-- ==============================================================

SELECT
	(SELECT COUNT(*) FROM olist_orders_dataset) AS total_orders,
	(SELECT COUNT(*) FROM olist_order_items_dataset) AS total_items,
	(SELECT COUNT(*) FROM olist_order_payments_dataset) AS total_payments,
	(SELECT COUNT(*) FROM olist_products_dataset) AS total_products,
	(SELECT COUNT(*) FROM olist_customers_dataset) AS total_customers,
	(SELECT COUNT(*) FROM olist_sellers_dataset) AS total_sellers;

-- ---------------------------------------------------------

CREATE TABLE final_ecommerce_dataset AS 
WITH payment_summary AS (
	SELECT order_id,
		   SUM(payment_value) AS total_payment_value,
		   MAX(payment_type) AS payment_type,
		   MAX(payment_installments) AS payment_installments
	FROM olist_order_payments_dataset
	GROUP BY order_id
),

review_summary AS (
	SELECT order_id,
		   ROUND(AVG(review_score), 2) AS avg_review_score
	FROM olist_order_reviews_dataset
	GROUP BY order_id
)

SELECT
	  -- ORDER INFO
	  o.order_id,
	  o.order_status,
	  o.order_purchase_timestamp,
	  o.order_delivered_customer_date,
	  o.order_estimated_delivery_date,
	  
	  -- CUSTOMER INFO
	  c.customer_id,
	  c.customer_unique_id,
	  c.customer_city,
	  c.customer_state,

	  -- ITEM INFO
	  i.order_item_id,
	  i.product_id,
	  i.seller_id,
	  i.price,
	  i.freight_value,

	  -- PRODUCT INFO
	  p.product_category_name,
	  p.product_weight_g,
	  p.product_length_cm,
	  p.product_height_cm,
	  p.product_width_cm,

	  -- PAYMENT INFO (aggregated)
	  ps.total_payment_value,
	  ps.payment_type,
	  ps.payment_installments,

	  -- REVIEW INFO (aggregated)
	  rs.avg_review_score,

	  -- CALCULATED METRICS
	  (i.price + i.freight_value) AS revenue,

	  DATE_PART('day', o.order_delivered_customer_date - o.order_purchase_timestamp) AS delivery_days,

	  CASE
	  	  WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
		  ELSE 0
	  END AS late_delivery_flag

FROM olist_orders_dataset o

JOIN olist_order_items_dataset i
  ON o.order_id = i.order_id

LEFT JOIN olist_products_dataset p
	   ON i.product_id = p.product_id

LEFT JOIN olist_customers_dataset c
	   ON o.customer_id = c.customer_id

LEFT JOIN payment_summary ps
	   ON o.order_id = ps.order_id

LEFT JOIN review_summary rs
	   ON o.order_id = rs.order_id

WHERE o.order_status NOT IN ('canceled', 'unavailable');

-- --------------------------------------------------------------
SELECT *
FROM final_ecommerce_dataset;





























