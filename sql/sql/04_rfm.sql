-- Purpose: segment customers by Recency, Frequency and Monetary value (RFM)
-- Source tables: olist_orders_dataset, olist_customers_dataset, olist_order_items
-- Method: order value = price + freight per order; delivered orders only;
--         recency measured from a fixed dataset end date (not today's date);
--         R and M scored 1-5 with NTILE (5 = best)
-- Output: one row per customer_unique_id with recency_days, frequency, monetary, r_score, f_score, m_score

WITH order_revenue AS (
  SELECT order_id, SUM(price + freight_value) AS order_value
  FROM `olist-analytics-507611.olist.olist_order_items`
  GROUP BY order_id
),
customer_orders AS (
  SELECT
    c.customer_unique_id,
    DATE(o.order_purchase_timestamp) AS purchase_date,
    r.order_value
  FROM `olist-analytics-507611.olist.olist_orders_dataset` o
  JOIN `olist-analytics-507611.olist.olist_customers_dataset` c USING (customer_id)
  JOIN order_revenue r USING (order_id)
  WHERE o.order_status = 'delivered'
),
rfm_base AS (
  SELECT
    customer_unique_id,
    -- anchor recency to the dataset's end (~Oct 2018), NOT today's date,
    -- otherwise every customer looks ancient
    DATE_DIFF(DATE '2018-10-01', MAX(purchase_date), DAY) AS recency_days,
    COUNT(*)             AS frequency,
    SUM(order_value)     AS monetary
  FROM customer_orders
  GROUP BY customer_unique_id
)
SELECT
  customer_unique_id,
  recency_days,
  frequency,
  monetary,
  NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,  -- lower recency = better
  NTILE(5) OVER (ORDER BY frequency ASC)     AS f_score,
  NTILE(5) OVER (ORDER BY monetary ASC)      AS m_score
FROM rfm_base;
