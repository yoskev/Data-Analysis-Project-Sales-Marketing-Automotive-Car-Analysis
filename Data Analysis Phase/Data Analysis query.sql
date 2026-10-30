--1. Total revenue, then Yearly revenue and growth
/*SELECT 
  CONCAT('Rp.',SUM(total_amount_idr)) AS total_revenue_on_datastet
FROM `project-nusantara-car.dataset_extraction.clean_transactions`
WHERE status IN ('Completed');*/ 

-- This for revenue for each year and growth
/*SELECT
  year,
  total_revenue_per_year,
  LAG(total_revenue_per_year) OVER (ORDER BY year) AS prev_revenue,
  CONCAT(ROUND(SAFE_DIVIDE(total_revenue_per_year - LAG(total_revenue_per_year) 
  OVER (ORDER BY year),LAG(total_revenue_per_year) OVER (ORDER BY year))*100,2),'%') 
  AS revenue_growth_YOY
FROM (
  SELECT
    EXTRACT(YEAR FROM transaction_date) AS year,
    SUM(total_amount_idr) AS total_revenue_per_year
  FROM `project-nusantara-car.dataset_extraction.clean_transactions`
  WHERE status IN ('Completed') AND transaction_date < '2026-01-01'
  GROUP BY year
  ORDER BY year
);*/

--2. Failed and returned transactions
/*SELECT 
  status, 
  SUM(total_amount_idr) AS Total_Amount 
FROM `project-nusantara-car.dataset_extraction.clean_transactions`
WHERE status IN ('Cancelled', 'Returned')
GROUP BY status;*/

-- Failed and returned transactions Per Year 2021 - 2026(Last on September)
/*SELECT
  EXTRACT(YEAR FROM transaction_date) AS year,
  status, 
  SUM(total_amount_idr) AS Total_Amount 
FROM `project-nusantara-car.dataset_extraction.clean_transactions`
WHERE status IN ('Cancelled', 'Returned')
GROUP BY year, status
ORDER BY year ASC;*/

-- 3. Top Leads Channel
/*SELECT
  lead_source,
  lead_channel_count,
  CONCAT(ROUND(SAFE_DIVIDE(lead_channel_count, SUM(lead_channel_count) OVER()) * 100, 2),
  '%') AS lead_proportion
FROM (
SELECT 
  lead_source, 
  COUNT(*) AS lead_channel_count
FROM `project-nusantara-car.dataset_extraction.clean_transactions`
GROUP BY lead_source
);*/

-- To breakdown each year for leads channel
/*SELECT
  year,
  lead_source,
  lead_channel_count,
  CONCAT(ROUND(SAFE_DIVIDE(lead_channel_count, SUM(lead_channel_count) OVER()) * 100, 2),
  '%') AS lead_proportion
FROM (
SELECT
  EXTRACT(YEAR FROM transaction_date) AS year,
  lead_source, 
  COUNT(*) AS lead_channel_count
FROM `project-nusantara-car.dataset_extraction.clean_transactions`
GROUP BY year, lead_source
)
ORDER BY year ASC;*/

-- 4. Average YOY growth per month(2021 - 2025)
/*
WITH monthly_sales AS (
  SELECT
    EXTRACT(YEAR FROM transaction_date) AS year,
    EXTRACT(MONTH FROM transaction_date) AS month,
    SUM(total_amount_idr) AS total_revenue
  FROM `project-nusantara-car.dataset_extraction.clean_transactions`
  WHERE transaction_date < '2026-01-01' AND status IN ('Completed')
  GROUP BY
    EXTRACT(YEAR FROM transaction_date),
    EXTRACT(MONTH FROM transaction_date)
),
Calculate_for_difference AS (
  SELECT
    year,
    month,
    total_revenue,
    COALESCE(LAG(total_revenue, 1) OVER (PARTITION BY month ORDER BY year),0) AS previous_year_revenue_same_month,
    COALESCE(total_revenue - LAG(total_revenue, 1) OVER (PARTITION BY month ORDER BY year),0) AS different_total_amount_idr_in_month
  FROM monthly_sales
  ORDER BY
    month,
    year
),
yoy_growth_percentage_by_months AS (
SELECT
  *,
  ROUND(different_total_amount_idr_in_month * 100 / NULLIF(previous_year_revenue_same_month,0), 2) AS yoy_growth_percentage
FROM Calculate_for_difference
)
SELECT 
  month, 
  CONCAT(ROUND(AVG(yoy_growth_percentage),2),'%') AS average_yoy_growth_by_each_months
FROM yoy_growth_percentage_by_months
GROUP BY
  month;
*/

-- 5. Segment Contribution(Sum total amount and count transactions)
/*
SELECT 
  c.customer_segment,
  SUM(t.total_amount_idr) AS revenue_per_segment,
  COUNT(t.transaction_id) AS count_transaction_per_segment
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.status IN ('Completed')
GROUP BY c.customer_segment;
*/

-- 6. Top 1 - 5 Customers for each customer_segment
/*
WITH customer_revenue_by_segment AS (
SELECT
  c.customer_segment,
  c.master_customer_id,
  c.full_name,
  SUM(t.total_amount_idr) AS revenue_each_by_customer
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.status IN ('Completed')
GROUP BY
  c.customer_segment,
  c.master_customer_id,
  c.full_name
),
ranked_customer_segment AS(
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY customer_segment ORDER BY revenue_each_by_customer DESC) AS rank_in_segment
FROM customer_revenue_by_segment
)
SELECT
  *
FROM ranked_customer_segment
WHERE rank_in_segment <= 5
ORDER BY customer_segment, rank_in_segment;
*/

-- 7. Top 3 and Bottom 3 Cities for Revenue Contribution
/*
WITH revenue_city AS (
SELECT
  c.city,
  SUM(t.total_amount_idr) AS total_revenue_by_city
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.status = 'Completed'
GROUP BY
  c.city
)
SELECT
  *,
  ROW_NUMBER() OVER (ORDER BY total_revenue_by_city DESC) AS rank_city
FROM revenue_city;
*/

-- 8. Customer growth by registration year from 2021 - 2025
/*
WITH first_registration_data AS (
SELECT
  master_customer_id,
  MIN(registration_date) AS real_registration_date
FROM
  `project-nusantara-car.dataset_extraction.clean_customers`
WHERE registration_date < '2026-01-01'
GROUP BY
  master_customer_id
),
count_customer_id_registration AS (
SELECT
  EXTRACT(YEAR FROM real_registration_date) AS year_registration,
  COUNT(master_customer_id) AS count_customer
FROM
  first_registration_data
GROUP BY
  year_registration
)
SELECT
  year_registration,
  count_customer,
  CONCAT(ROUND(SAFE_DIVIDE(count_customer - LAG(count_customer) 
  OVER (ORDER BY year_registration),LAG(count_customer) OVER (ORDER BY year_registration))*100,1),'%')
FROM
  count_customer_id_registration
ORDER BY
  year_registration;
*/

-- 9. part 1 Repeat purchase from customers by each segment
/*
WITH customer_count_transaction_by_segment AS (
SELECT
  c.customer_segment,
  c.master_customer_id,
  c.full_name,
  COUNT(t.transaction_id) AS count_transaction_by_customer,
  SUM(t.total_amount_idr) AS revenue_by_customer
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.status IN ('Completed')
GROUP BY
  c.customer_segment,
  c.master_customer_id,
  c.full_name
),
filter_rank_customer AS(
SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY customer_segment ORDER BY count_transaction_by_customer DESC, revenue_by_customer DESC) AS rank_in_segment
FROM customer_count_transaction_by_segment
WHERE count_transaction_by_customer > 1
)
SELECT
  *
FROM
  filter_rank_customer
WHERE
  rank_in_segment <= 5
ORDER BY
  customer_segment ASC,
  rank_in_segment ASC;
*/

-- 9. part 2 how many customers do repeat purchases for each segment
/*
WITH count_customer_data_that_do_repeat AS (
SELECT
  c.customer_segment,
  c.master_customer_id,
  c.full_name,
  COUNT(t.transaction_id) AS count_transaction_by_customer
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE 
  t.status IN ('Completed')
GROUP BY
  c.customer_segment,
  c.master_customer_id,
  c.full_name
)
SELECT
  customer_segment,
  COUNT(master_customer_id) AS count_of_customer,
  COUNTIF(count_transaction_by_customer > 1) AS repeat_customer,
  CONCAT(ROUND(SAFE_DIVIDE(COUNTIF(count_transaction_by_customer > 1),COUNT(master_customer_id))*100,2),'%') AS percentage_repeat_customers
FROM
  count_customer_data_that_do_repeat
GROUP BY
  customer_segment;
*/

-- 10. Payment method percentage per segment
/*
SELECT
  c.customer_segment,
  t.payment_method,
  COUNT(t.payment_method) AS count_payment_method,
  CONCAT(ROUND(COUNT(t.payment_method)*100/SUM(COUNT(t.payment_method)) OVER (PARTITION BY c.customer_segment),1),'%') AS payment_method_percentage
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.payment_method IS NOT NULL AND t.status IN ('Completed')
GROUP BY
  c.customer_segment,
  t.payment_method
ORDER BY
  c.customer_segment ASC;
*/

-- 11. New vs repeat revenue: where does growth come from? (my idea)
-- 11. Part 1 New Revenue(First Purchase)
/*
WITH source_transaction_data AS (
SELECT
  c.master_customer_id,
  t.transaction_id,
  t.transaction_date,
  t.total_amount_idr,
  ROW_NUMBER() OVER (
    PARTITION BY c.master_customer_id ORDER BY transaction_date ASC, t.transaction_id ASC
  ) AS rn
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.status IN ('Completed') AND t.transaction_date < '2026-01-01'
),
transaction_data AS (
  SELECT
    master_customer_id,
    transaction_id AS first_transaction,
    transaction_date AS first_transaction_date,
    total_amount_idr AS first_transaction_amount
  FROM source_transaction_data
  WHERE rn = 1
),
year_define_first_purchase AS (
SELECT
 EXTRACT(YEAR FROM first_transaction_date) AS year,
 *
FROM transaction_data
),
figure_first_purchase AS (
SELECT
  year,
  COUNT(first_transaction) AS count_first_transaction,
  SUM(first_transaction_amount) AS revenue_from_first_transaction
FROM
  year_define_first_purchase
GROUP BY
  year
ORDER BY
  year ASC
)
SELECT
  year,
  count_first_transaction,
  CONCAT(ROUND(SAFE_DIVIDE(count_first_transaction - LAG(count_first_transaction) 
  OVER (ORDER BY year),LAG(count_first_transaction) OVER (ORDER BY year))*100,1),'%') AS yoy_growth_count_transaction,
  revenue_from_first_transaction,
  CONCAT(ROUND(SAFE_DIVIDE(revenue_from_first_transaction - LAG(revenue_from_first_transaction) 
  OVER (ORDER BY year),LAG(revenue_from_first_transaction) OVER (ORDER BY year))*100,1),'%') AS yoy_growth_revenue_first_transaction
FROM figure_first_purchase
*/
-- 11. Part 2 Repeat Revenue
/*
WITH source_transaction_data AS (
SELECT
  c.master_customer_id,
  t.transaction_id,
  t.transaction_date,
  t.total_amount_idr,
  ROW_NUMBER() OVER (
    PARTITION BY c.master_customer_id ORDER BY transaction_date ASC, t.transaction_id ASC
  ) AS rn
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.status IN ('Completed') AND t.transaction_date < '2026-01-01'
),
transaction_data AS (
  SELECT
    master_customer_id,
    transaction_id AS repeat_transaction,
    transaction_date AS repeat_transaction_date,
    total_amount_idr AS repeat_transaction_amount
  FROM source_transaction_data
  WHERE rn > 1
),
year_define_repeat_purchase AS (
SELECT
 EXTRACT(YEAR FROM repeat_transaction_date) AS year,
 *
FROM transaction_data
),
figure_repeat_purchase AS (
SELECT
  year,
  COUNT(repeat_transaction) AS count_repeat_transaction,
  COUNT(DISTINCT master_customer_id) AS count_repeat_customer,
  SUM(repeat_transaction_amount) AS revenue_from_repeat_transaction
FROM
  year_define_repeat_purchase
GROUP BY
  year
ORDER BY
  year ASC
)
SELECT
  year,
  count_repeat_customer,
  count_repeat_transaction,
  CONCAT(ROUND(SAFE_DIVIDE(count_repeat_transaction - LAG(count_repeat_transaction) 
  OVER (ORDER BY year),LAG(count_repeat_transaction) OVER (ORDER BY year))*100,1),'%') AS yoy_growth_count_transaction,
  revenue_from_repeat_transaction,
  CONCAT(ROUND(SAFE_DIVIDE(revenue_from_repeat_transaction - LAG(revenue_from_repeat_transaction) 
  OVER (ORDER BY year),LAG(revenue_from_repeat_transaction) OVER (ORDER BY year))*100,1),'%') AS yoy_growth_revenue_repeat_transaction
FROM figure_repeat_purchase
*/

-- 12. Top and least dealers by revenue
/*
WITH data_dealers_rank AS (
SELECT
  d.dealer_name,
  d.opened_date,
  SUM(t.total_amount_idr) AS total_revenue_by_dealers,
FROM `project-nusantara-car.dataset_extraction.clean_dealers` d
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON d.dealer_id = t.dealer_id
WHERE
  t.status IN ('Completed') AND d.is_active = 'Active'
GROUP BY
  d.dealer_name,
  d.opened_date
ORDER BY total_revenue_by_dealers DESC
),
dealer_ranking AS(
SELECT
  *,
  RANK() OVER(ORDER BY total_revenue_by_dealers DESC) AS dealer_ranks
FROM data_dealers_rank
)
SELECT
  *
FROM dealer_ranking
WHERE CAST(dealer_ranks AS STRING) IN ('1','2','3','26','27','28','29','30','31');
*/

-- 13. Dealer city demand by look from customer city for puchase
/*
WITH customer_city_match_dealer AS(
SELECT 
  c.city, 
  COUNT(t.transaction_id) AS count_transactions, 
  SUM(t.total_amount_idr) AS revenue_from_city
FROM `project-nusantara-car.dataset_extraction.clean_customers` c
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON c.customer_id = t.customer_id
WHERE t.status IN ('Completed') AND c.city IN (
SELECT DISTINCT city FROM  `project-nusantara-car.dataset_extraction.clean_customers`
EXCEPT DISTINCT
SELECT DISTINCT city FROM `project-nusantara-car.dataset_extraction.clean_dealers`
)
GROUP BY
  c.city
)
SELECT
  *
FROM
  customer_city_match_dealer
ORDER BY
  count_transactions DESC,
  revenue_from_city DESC;
*/

-- 14. Dealers reaching monthly unit targets
/*
WITH dealer_transaction_gather_source AS (
SELECT
  d.dealer_name,
  EXTRACT(YEAR FROM transaction_date) AS year,
  EXTRACT(MONTH FROM transaction_date) AS month,
  t.quantity,
  d.monthly_sales_target_units
FROM `project-nusantara-car.dataset_extraction.clean_dealers` d
LEFT JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
ON d.dealer_id = t.dealer_id
WHERE
  t.status IN ('Completed') AND t.transaction_date > '2025-08-31' AND t.transaction_date < '2026-09-01'
),
calculate_quantity_units_for_each_dealers AS(
SELECT
  year,
  month,
  dealer_name,
  monthly_sales_target_units,
  SUM(quantity) AS sales_quantity_per_dealers,
  COUNT(*)
FROM dealer_transaction_gather_source
GROUP BY
  year,
  month,
  dealer_name,
  monthly_sales_target_units
ORDER BY
  dealer_name ASC,
  year ASC,
  month ASC
),
comparison_target_vs_actual AS (
SELECT
  *
FROM calculate_quantity_units_for_each_dealers
WHERE monthly_sales_target_units > sales_quantity_per_dealers
)
SELECT
  dealer_name,
  monthly_sales_target_units AS monthly_target_units,
  COUNT(dealer_name) AS how_many_months_dealer_not_achieve_target,
  MAX(sales_quantity_per_dealers) AS highest_monthly_sales_units_in_non_achive_months
FROM
  comparison_target_vs_actual
GROUP BY
  dealer_name,
  monthly_target_units
ORDER BY
  how_many_months_dealer_not_achieve_target DESC;
*/
-- 15. Region: transactions vs number of dealers
/*
SELECT
  d.region,
  COUNT(DISTINCT d.dealer_id) AS count_dealers,
  COUNT(t.transaction_id) AS count_transactions,
  ROUND(SUM(t.total_amount_idr) / 1e9, 0) AS revenue_in_billion,
  ROUND(SUM(t.total_amount_idr) / 1e9 / COUNT(DISTINCT d.dealer_id), 0) AS revenue_in_billion_per_dealer
FROM `project-nusantara-car.dataset_extraction.clean_dealers` d
JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
  ON d.dealer_id = t.dealer_id
WHERE t.status = 'Completed'
GROUP BY d.region
ORDER BY revenue_in_billion_per_dealer DESC;
*/

-- 16. Top 3 and least 3 vehicles (includes V2)
/*
WITH sales_revenue_and_quantity_from_vehicles AS (
SELECT
  v.brand,
  v.model,
  SUM(t.total_amount_idr) AS revenue_vehicles,
  SUM(t.quantity) AS total_quantity_sales
FROM
  `project-nusantara-car.dataset_extraction.clean_vehicles` v
JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
  ON v.vehicle_id = t.vehicle_id
WHERE t.status = 'Completed'
GROUP BY
  v.brand,
  v.model
),
ranking_vehicles AS (
SELECT
  *,
  RANK() OVER(ORDER BY revenue_vehicles DESC, total_quantity_sales DESC) AS rank_sales_vehicles
FROM 
  sales_revenue_and_quantity_from_vehicles
ORDER BY
  rank_sales_vehicles ASC
)
SELECT
  *
FROM
  ranking_vehicles
WHERE 
  rank_sales_vehicles <= 3
  OR rank_sales_vehicles >= (SELECT MAX(rank_sales_vehicles) FROM ranking_vehicles) - 2
*/

-- 17.  Top brands and sales dependency
/*
WITH vehicles_sales_revenue AS (
SELECT
  v.brand AS brand,
  SUM(t.total_amount_idr) AS revenue,
FROM
  `project-nusantara-car.dataset_extraction.clean_vehicles` v
JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
  ON v.vehicle_id = t.vehicle_id
WHERE t.status = 'Completed'
GROUP BY
 brand
ORDER BY
  revenue DESC
)
SELECT
  brand,
  revenue,
   ROUND(revenue * 100 / SUM(revenue) OVER (), 1) AS pct_of_revenue
FROM vehicles_sales_revenue
*/

-- 18.  Product mix: seats, body, transmission, fuel
/*
WITH vehicle_data_specification AS (
SELECT
  EXTRACT(YEAR FROM t.transaction_date) AS year,
  seating_capacity,
  body_type,
  transmission,
  fuel_type,
  SUM(t.total_amount_idr) AS revenue_for_vehicle_specification
FROM
  `project-nusantara-car.dataset_extraction.clean_vehicles` v
JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
  ON v.vehicle_id = t.vehicle_id
WHERE t.status = 'Completed'
GROUP BY
  year,
  seating_capacity,
  body_type,
  transmission,
  fuel_type
),
ranking_specification_yearly AS (
SELECT
  *,
  RANK() OVER(PARTITION BY year ORDER BY revenue_for_vehicle_specification DESC) AS ranking_specification_per_year,
  ROUND(revenue_for_vehicle_specification * 100 / SUM(revenue_for_vehicle_specification) OVER(PARTITION BY year), 1) AS pct_revenue_per_year
FROM 
  vehicle_data_specification
)
SELECT
  *
FROM
  ranking_specification_yearly
WHERE
  ranking_specification_per_year <= 5
ORDER BY
  year ASC,
  ranking_specification_per_year ASC;
*/

-- 19. Top 10 Most profitable vehicles and Correlation between profit margin and volume sales units
-- 19. Part 1 Top 10 Most profitable car vehicle models
/*
WITH gather_aggregate_revenue_profit_per_model AS (
SELECT
  v.brand,
  v.model,
  SUM(t.quantity) AS total_quantity_units,
  SUM(t.total_amount_idr) AS revenue_per_vehicle_model,
  SUM(t.total_amount_idr - v.cost_idr * t.quantity) AS gross_profit_for_vehicle_model
FROM
  `project-nusantara-car.dataset_extraction.clean_vehicles` v
JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
  ON v.vehicle_id = t.vehicle_id
WHERE t.status = 'Completed'
GROUP BY
  v.brand,
  v.model
)
SELECT
  brand,
  model,
  total_quantity_units,
  gross_profit_for_vehicle_model,
  ROUND(gross_profit_for_vehicle_model * 100 / revenue_per_vehicle_model, 1) AS gross_profit_margin_pct,
  ROUND(gross_profit_for_vehicle_model / total_quantity_units / 10E9, 1) AS profit_per_unit_of_vehicle_model,
  RANK() OVER (ORDER BY gross_profit_for_vehicle_model DESC) AS rank_from_gross_profit,
  RANK() OVER (ORDER BY total_quantity_units DESC) AS rank_profit_per_unit_of_vehicle_model
FROM 
gather_aggregate_revenue_profit_per_model
ORDER BY
  rank_from_gross_profit ASC;
*/

-- 19. Part 2 Correlation between profit margin and volume sales units
/*
SELECT
  COUNT(*) AS count_vehicle_models,
  ROUND(CORR(gross_profit_margin_pct, total_units), 2) AS correlation_margin_against_units
FROM
(SELECT
  SUM(t.quantity) AS total_units,
  SUM(t.total_amount_idr - (v.cost_idr * t.quantity)) * 100 / SUM(t.total_amount_idr) AS gross_profit_margin_pct
FROM
  `project-nusantara-car.dataset_extraction.clean_vehicles` v
JOIN `project-nusantara-car.dataset_extraction.clean_transactions` t
  ON v.vehicle_id = t.vehicle_id
WHERE t.status = 'Completed'
GROUP BY
  v.brand,
  v.model)
*/

-- 20. Discount threshold recommendation
-- 20. Part 1 margin per discount group
/*
WITH sales_margin AS (
SELECT
  t.discount_idr * 100 / t.unit_price_idr AS discount_pct,
  (t.total_amount_idr - v.cost_idr * t.quantity) * 100 / t.total_amount_idr AS net_margin_pct
FROM `project-nusantara-car.dataset_extraction.clean_transactions` t
JOIN `project-nusantara-car.dataset_extraction.clean_vehicles` v
  ON t.vehicle_id = v.vehicle_id
WHERE t.status = 'Completed'
)
SELECT
  CASE
    WHEN discount_pct < 2 THEN '0-2% Group'
    WHEN discount_pct < 4 THEN '2-4% Group'
    WHEN discount_pct < 6 THEN '4-6% Group'
    WHEN discount_pct < 8 THEN '6-8% Group'
    ELSE '8% and above Group'
  END AS discount_group,
  COUNT(*) AS count_sales,
  ROUND(COUNT(*) * 100 / SUM(COUNT(*)) OVER (), 1) AS pct_of_sales,
  ROUND(AVG(net_margin_pct), 1) AS avg_net_margin_pct,
  ROUND(MIN(net_margin_pct), 1) AS min_net_margin_pct,
  COUNTIF(net_margin_pct < 0) AS sales_below_cost
FROM sales_margin
GROUP BY discount_group
ORDER BY discount_group;
*/
-- 20. part 2 per segmen pelanggan
/*
SELECT
  c.customer_segment,
  COUNT(*) AS count_sales_transcation,
  ROUND(AVG(t.discount_idr * 100 / t.unit_price_idr),1) AS average_discount,
  ROUND(MAX(t.discount_idr * 100 / t.unit_price_idr),1) AS max_discount,
  ROUND(AVG((t.total_amount_idr - v.cost_idr * t.quantity) * 100 / t.total_amount_idr),1) AS net_margin_pct
FROM `project-nusantara-car.dataset_extraction.clean_transactions` t
JOIN `project-nusantara-car.dataset_extraction.clean_vehicles` v
  ON t.vehicle_id = v.vehicle_id
JOIN `project-nusantara-car.dataset_extraction.clean_customers` c
  ON t.customer_id = c.customer_id
WHERE t.status = 'Completed'
GROUP BY c.customer_segment
ORDER BY average_discount DESC;
*/
