-- Purpose: customer lifetime value (total delivered-order revenue per customer)
-- Source tables: olist_orders_dataset, olist_customers_dataset, olist_order_items
-- Output: one row per customer_unique_id

WITH order_revenue AS (
  SELECT order_id, SUM(price + freight_value) AS order_value
  FROM `olist-analytics-507611.olist.olist_order_items`
  GROUP BY order_id
)
SELECT
  c.customer_unique_id,
  c.customer_state,
  COUNT(DISTINCT o.order_id)                       AS num_orders,
  ROUND(SUM(r.order_value), 2)                     AS lifetime_value,
  ROUND(SUM(r.order_value) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM `olist-analytics-507611.olist.olist_orders_dataset` o
JOIN `olist-analytics-507611.olist.olist_customers_dataset` c USING (customer_id)
JOIN order_revenue r USING (order_id)
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id, c.customer_state
ORDER BY lifetime_value DESC;
