--Data Cleansing
--Dataset customers
/*CREATE OR REPLACE VIEW `project-nusantara-car.dataset_extraction.clean_customers` AS

WITH dataset_source_customers AS (
  SELECT
    customer_id,
    full_name,
    gender,
    birth_date,
    email,
    CAST(phone AS STRING) AS phone_text,
    city,
    province,
    occupation,
    monthly_income_idr,
    customer_segment,
    registration_date,
    marketing_opt_in
  FROM `project-nusantara-car.dataset_extraction.customers`
),

standardized_first_approach AS (
  SELECT
    customer_id,
    CASE WHEN customer_segment = 'Retail' THEN INITCAP(TRIM(full_name))
         ELSE TRIM(full_name) END AS full_name,
    gender,
    birth_date,
    LOWER(TRIM(email)) AS email,
    CASE WHEN phone_text LIKE '8%' THEN CONCAT('62', phone_text)
         ELSE phone_text END AS phone,
    INITCAP(TRIM(city)) AS city,
    province,
    occupation,
    monthly_income_idr,
    customer_segment,
    registration_date,
    CASE marketing_opt_in WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE 'Unknown' END AS marketing_opt_in
  FROM dataset_source_customers
),

handling_duplicate_customer AS (
  SELECT
  customer_id,
  full_name,
  gender,
  birth_date,
  email,
  phone,
  city,
  province,
  occupation,
  monthly_income_idr,
  customer_segment,
  registration_date,
  marketing_opt_in,
  CASE WHEN customer_segment = 'Retail' AND phone IS NOT NULL THEN
        FIRST_VALUE(customer_id) OVER (
          PARTITION BY full_name, phone
          ORDER BY (email IS NOT NULL) DESC, registration_date, customer_id)
       ELSE customer_id END AS master_customer_id
  FROM standardized_first_approach
)

SELECT
  customer_id,
  master_customer_id,
  full_name,
  gender,
  birth_date,
  email,
  phone,
  city,
  province,
  occupation,
  monthly_income_idr,
  customer_segment,
  registration_date,
  marketing_opt_in
FROM handling_duplicate_customer;*/

--Dataset dealers
/*CREATE OR REPLACE VIEW `project-nusantara-car.dataset_extraction.clean_dealers` AS

WITH dataset_source_dealers AS (
  SELECT
    dealer_id,
    dealer_name,
    dealer_type,
    city,
    province,
    region,
    address,
    CAST(phone AS STRING) AS phone,
    manager_name,
    opened_date,
    closed_date,
    is_active,
    monthly_sales_target_units,
    showroom_area_sqm
  FROM `project-nusantara-car.dataset_extraction.dealers`
),

standarized_dealers_first_approach AS (
  SELECT
    dealer_id,
    dealer_name,
    dealer_type,
    city,
    province,
    region,
    address,
    CASE
      WHEN phone NOT LIKE '62%' THEN CONCAT('62', phone) 
        ELSE phone 
      END AS phone,
    manager_name,
    opened_date,
    closed_date,
    CASE is_active WHEN 1 THEN 'Active' WHEN 0 THEN 'Non Active' 
      ELSE 'Unknown' 
    END AS is_active,
    monthly_sales_target_units,
    showroom_area_sqm
  FROM `dataset_source_dealers`
)

SELECT
  dealer_id,
  dealer_name,
  dealer_type,
  city,
  province,
  region,
  address,
  phone,
  manager_name,
  opened_date,
  closed_date,
  is_active,
  monthly_sales_target_units,
  showroom_area_sqm
FROM standarized_dealers_first_approach;*/

--Data vehicles
/*CREATE OR REPLACE VIEW `project-nusantara-car.dataset_extraction.clean_vehicles` AS

WITH data_source_vehicle AS (
  SELECT
    vehicle_id,
    brand,
    model,
    variant,
    body_type,
    fuel_type,
    transmission,
    engine_cc,
    seating_capacity,
    assembly_origin,
    model_year,
    list_price_idr,
    cost_idr,
    launch_date,
    discontinued_date,
    is_active
  FROM `project-nusantara-car.dataset_extraction.vehicles`
),

standarized_vehicles_first_approach AS (
  SELECT
    vehicle_id,
    brand,
    model,
    variant,
    body_type,
    fuel_type,
    transmission,
    engine_cc,
    seating_capacity,
    assembly_origin,
    model_year,
    list_price_idr,
    cost_idr,
    launch_date,
    discontinued_date,
    CASE WHEN is_active = 1 THEN 'Active' WHEN is_active = 0 THEN 'Inactive' 
          ELSE 'Unknown' 
    END AS is_active
  FROM data_source_vehicle
)

SELECT * FROM standarized_vehicles_first_approach;*/

--data transactions
/*CREATE OR REPLACE VIEW `project-nusantara-car.dataset_extraction.clean_transactions` AS

WITH data_source_transactions AS (
  SELECT
    transaction_id,
    transaction_date,
    customer_id,
    vehicle_id,
    dealer_id,
    salesperson_name,
    quantity,
    unit_price_idr,
    discount_idr,
    total_amount_idr,
    payment_method,
    financing_partner,
    down_payment_pct,
    tenor_months,
    lead_source,
    is_trade_in,
    insurance_included,
    status,
    delivery_date,
    csat_score
  FROM `project-nusantara-car.dataset_extraction.transactions`
),

standardized_first_approach_transactions AS (
  SELECT
    transaction_id,
    transaction_date,
    customer_id,
    vehicle_id,
    dealer_id,
    COALESCE(salesperson_name,'Unknown') AS salesperson_name,
    quantity,
    unit_price_idr,
    discount_idr,
    total_amount_idr,
    payment_method,
    COALESCE(financing_partner,'Not Used') AS financing_partner,
    down_payment_pct,
    tenor_months,
    COALESCE(lead_source,'Unknown') AS lead_source,
    CASE is_trade_in WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' 
        ELSE 'Unknown' 
      END AS is_trade_in,
    CASE insurance_included WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' 
        ELSE 'Unknown' 
      END AS insurance_included,
    status,
    delivery_date,
    csat_score
  FROM data_source_transactions
),

categorized_second_approach_for_csat_score AS (
  SELECT
    *,
    CASE WHEN csat_score >= 4 THEN 'Satisfied'
         WHEN csat_score = 3 THEN 'Netral'
         WHEN csat_score <= 2 THEN 'Dissatisfied'
         WHEN status IN ('Pending', 'Cancelled') THEN 'N/A'
         ELSE 'No Response' END AS csat_category
  FROM standardized_first_approach_transactions
)

SELECT * FROM categorized_second_approach_for_csat_score;*/
