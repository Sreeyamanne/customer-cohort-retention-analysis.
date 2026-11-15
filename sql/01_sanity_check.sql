-- Purpose: sanity check on delivered orders before the retention, LTV and RFM analyses
--          (how many customers and orders, and how many orders per customer)
-- Source tables: olist_orders_dataset, olist_customers_dataset
-- Method: delivered orders only; customers identified by customer_unique_id
--         (customer_id changes with every order in Olist)
-- Output: one row with total_customers, total_orders, orders_per_customer
-- Note: orders_per_customer close to 1 means most customers order only once,
--       which explains the low repeat rates in the retention and RFM results

SELECT
  COUNT(DISTINCT c.customer_unique_id) AS total_customers,
  COUNT(DISTINCT o.order_id)           AS total_orders,
  ROUND(COUNT(DISTINCT o.order_id) / COUNT(DISTINCT c.customer_unique_id), 3)
    AS orders_per_customer
FROM `olist-analytics-507611.olist.olist_orders_dataset` o
JOIN `olist-analytics-507611.olist.olist_customers_dataset` c USING (customer_id)
WHERE o.order_status = 'delivered';
