-- Purpose: monthly cohort retention (what share of each month's new customers
--          place another delivered order in the months that follow)
-- Source tables: olist_orders_dataset, olist_customers_dataset
-- Method: delivered orders only; customers identified by customer_unique_id;
--         cohort = month of a customer's first delivered order;
--         month_offset = months between that cohort month and each later order month;
--         retention_pct = active customers in a month / cohort size (month_offset 0) * 100
-- Output: one row per cohort_month and month_offset with active_customers,
--         cohort_size and retention_pct (month_offset 0 is always 100%)
-- Note: retention here means "ordered in that month". A customer who skips a month
--       and returns later is counted only in the months they actually ordered.

WITH orders_with_customer AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS purchase_month
  FROM `olist-analytics-507611.olist.olist_orders_dataset` o
  JOIN `olist-analytics-507611.olist.olist_customers_dataset` c USING (customer_id)
  WHERE o.order_status = 'delivered'
),

cohort AS (                          -- each customer's first-purchase month
  SELECT
    customer_unique_id,
    MIN(purchase_month) AS cohort_month
  FROM orders_with_customer
  GROUP BY customer_unique_id
),

activity AS (                        -- months since the customer joined
  SELECT
    owc.customer_unique_id,
    ch.cohort_month,
    DATE_DIFF(owc.purchase_month, ch.cohort_month, MONTH) AS month_offset
  FROM orders_with_customer owc
  JOIN cohort ch USING (customer_unique_id)
),

retention AS (
  SELECT
    cohort_month,
    month_offset,
    COUNT(DISTINCT customer_unique_id) AS active_customers
  FROM activity
  GROUP BY cohort_month, month_offset
)

SELECT
  cohort_month,
  month_offset,
  active_customers,
  FIRST_VALUE(active_customers) OVER (
    PARTITION BY cohort_month ORDER BY month_offset
  ) AS cohort_size,
  ROUND(
    active_customers / FIRST_VALUE(active_customers) OVER (
      PARTITION BY cohort_month ORDER BY month_offset
    ) * 100, 2
  ) AS retention_pct
FROM retention
ORDER BY cohort_month, month_offset;
