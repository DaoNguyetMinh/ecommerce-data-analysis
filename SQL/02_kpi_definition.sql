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








