# Customer Cohort and Retention Analysis (Olist E-commerce)

## Business question
How well does the store keep customers after their first order, and which regions and customer segments drive revenue and order value?

## Dataset
- Olist Brazilian E-Commerce Public Dataset (Kaggle): [add link]
- Period: [add start and end dates]
- Only delivered orders are analyzed. Customers are identified by `customer_unique_id` (`customer_id` changes with every order in this dataset).
- Source and license: please check the license on the Kaggle dataset page and credit Olist.

## Approach
Tools: BigQuery (SQL), Tableau Public.

| File | What it does |
|---|---|
| `sql/01_sanity_check.sql` | Counts customers, orders and orders per customer before the analysis |
| `sql/02_retention_table.sql` | Monthly cohort retention (share of each cohort ordering again in later months) |
| `sql/03_ltv.sql` | Customer lifetime value (delivered-order revenue per customer) |
| `sql/04_rfm.sql` | Recency, Frequency and Monetary scores per customer |

SQL techniques: CTEs, window functions (`FIRST_VALUE`, `NTILE`), date functions, and aggregating order items per order before joining to avoid inflating revenue. Recency is measured from a fixed dataset end date, not today's date.

## Key findings
1. **Mostly one-time buyers.** 93,358 customers placed 96,478 delivered orders, which is 1.03 orders per customer.
2. **Very low repeat ordering.** In cohorts with at least 500 customers, only about 0.2% to 0.7% of a cohort orders again in the month after the first order. Later months are mostly lower.
3. **Order value is higher in smaller states.** Among states with at least 500 customers, SP (the largest state) has the lowest average order value (about 143 BRL), while states such as PB and PA are the highest (above 200 BRL). Order value includes freight, so shipping cost is a possible explanation. This has not been tested yet.
4. **Revenue is concentrated in a few states.** SP generates the most revenue by a wide margin, followed by RJ and MG [confirm exact figures from the dashboard].
5. **RFM scores computed.** Customers are scored 1 to 5 on recency, frequency and monetary value. By design each recency score has roughly the same number of customers (about 18,700).

## Recommendations
These are hypotheses to test, not proven conclusions.
1. Because repeat ordering is the main weakness, test a re-engagement message or offer in the weeks after a first purchase, and measure it with an A/B test.
2. Compare freight cost per order by state to see whether shipping explains the higher order values outside SP.
3. Focus retention and marketing effort first on the states that generate most of the revenue (SP, RJ, MG).

## Limitations
- Retention here means "placed a delivered order in that month". It does not capture customers who return after a longer gap.
- Cohorts with fewer than 500 customers and states with fewer than 500 customers are excluded from the charts to avoid noisy results.
- Individual heatmap cells are small, so the overall pattern is more reliable than any single cell.
- The dataset covers a limited period, so later cohorts have fewer months to observe.

## Dashboard
Live dashboard: https://public.tableau.com/app/profile/sreeya.manne/viz/E-CommerceCustomerInsightsDashboard/Dashboard1

<img width="1280" height="832" alt="image" src="https://github.com/user-attachments/assets/f62333e0-3dde-4705-bcdf-d1835854bf9e" />
<img width="2688" height="980" alt="image" src="https://github.com/user-attachments/assets/f9b5fa98-7d90-461a-aa22-700753fbff9a" />


## How to reproduce
1. Load the Olist tables into BigQuery.
2. Run the SQL files in `sql/` in numerical order.
3. The result tables are exported to `data/` (`retention_by_cohort.csv`, `ltv_by_customer.csv`, `rfm_scores.csv`) and are the data source for the Tableau dashboard.
