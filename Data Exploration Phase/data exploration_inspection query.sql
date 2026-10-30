--data exploration

--CUSTOMER DATA :
--SELECT * FROM `project-nusantara-car.dataset_extraction.customers` LIMIT 1000

/*SELECT city,TRIM(INITCAP(city)) AS try_clean_city FROM `project-nusantara-car.dataset_extraction.customers` 
WHERE city <> TRIM(INITCAP(city))
LIMIT 1000*/

/*SELECT
  COUNTIF(customer_id IS NULL) AS customer_id,
  COUNTIF(full_name IS NULL) AS full_name,
  COUNTIF(gender IS NULL) AS gender,
  COUNTIF(birth_date IS NULL) AS birth_date,
  COUNTIF(email IS NULL) AS email,
  COUNTIF(phone IS NULL) AS phone,
  COUNTIF(city IS NULL) AS city,
  COUNTIF(province IS NULL) AS province,
  COUNTIF(occupation  IS NULL) AS occupation,
  COUNTIF(monthly_income_idr IS NULL) AS monthly_income,
  COUNTIF(customer_segment IS NULL) AS customer_segment,
  COUNTIF(registration_date IS NULL) AS registration_date,
  COUNTIF(marketing_opt_in IS NULL) AS marketing_opt_in,
FROM `project-nusantara-car.dataset_extraction.customers`*/


/*select distinct email, count(*) FROM `project-nusantara-car.dataset_extraction.customers` 
GROUP BY email
HAVING COUNT(*) > 1;*/

/*SELECT
    LOWER(TRIM(full_name)) AS name_key,
    LOWER(TRIM(email)) AS email_key,
    CASE
        WHEN CAST(phone AS STRING) LIKE '62%' THEN SUBSTR(CAST(phone AS STRING), 3)
        ELSE CAST(phone AS STRING)
    END AS phone_key,
    COUNT(*) AS jumlah
FROM `project-nusantara-car.dataset_extraction.customers`
GROUP BY name_key, email_key, phone_key
HAVING COUNT(*) > 1
ORDER BY jumlah DESC;*/

/*SELECT
  LOWER(TRIM(full_name)) AS customer_name, 
  LOWER(TRIM(email)) AS customer_email,
  CASE
    WHEN CAST(phone AS STRING) LIKE '62%' 
    THEN SUBSTR(CAST(phone AS STRING), 3)
    ELSE CAST(phone AS STRING) 
  END AS customer_phone, 
  COUNT(*) AS jumlah_customers
FROM `project-nusantara-car.dataset_extraction.customers`
GROUP BY customer_name, customer_email, customer_phone
HAVING COUNT(*) > 1;*/


/*SELECT DISTINCT gender, COUNT(*) AS count_distinct
FROM `project-nusantara-car.dataset_extraction.customers`
GROUP BY gender
HAVING COUNT(*) > 1;*/  -- terdapat data gender yang kosong karena data data tersebut adalah data perusahaan

/*SELECT DISTINCT TRIM(INITCAP(city)), COUNT(*) AS count_distinct
FROM `project-nusantara-car.dataset_extraction.customers`
GROUP BY TRIM(INITCAP(city))
HAVING COUNT(*) > 1;*/ -- data city butuh di trim, initcap

/*SELECT DISTINCT occupation, COUNT(*) AS count_distinct
FROM `project-nusantara-car.dataset_extraction.customers`
GROUP BY occupation
HAVING COUNT(*) > 0;*/ --ada beberapa value yang punya arti sama tapi dinamakan beda contoh pengusaha dengan wiraswasta dan guru/dosen dengan profesional

/*SELECT DISTINCT transaction_id, COUNT(*) AS count_distinct
FROM `project-nusantara-car.dataset_extraction.transactions`
GROUP BY transaction_id
HAVING COUNT(*) > 1;*/

--SELECT * FROM `project-nusantara-car.dataset_extraction.transactions` LIMIT 1000

--SELECT * FROM `project-nusantara-car.dataset_extraction.transactions` WHERE salesperson_name IS NULL(Banyak salesperson null, nanti salesperson diisi unknown) dan juga lead_source. Lalu untuk csat_score di klasifikasi atau dikategori dengan case when dan yang tidak mengisi dipisahkan. berguna untuk analisa
/*CASE
    WHEN csat_score >= 4 THEN 'Puas (4-5)'
    WHEN csat_score = 3  THEN 'Netral (3)'
    WHEN csat_score <= 2 THEN 'Tidak puas (1-2)'
    ELSE 'Tidak mengisi'
END AS csat_kategori*/


/*SELECT
  COUNTIF(quantity IS NULL) AS null_quantity,
  COUNTIF(unit_price_idr IS NULL) AS null_unit_price_idr,
  COUNTIF(discount_idr IS NULL) AS null_discount_idr,
  COUNTIF(total_amount_idr IS NULL) AS null_total_amount,
  COUNTIF(payment_method IS NULL) AS null_payment_method,
  COUNTIF(financing_partner IS NULL) AS null_financing_patner,
  COUNTIF(down_payment_pct IS NULL) AS null_down_payment,
  COUNTIF(tenor_months IS NULL) AS null_tenor_months,
  COUNTIF(lead_source  IS NULL) AS null_lead_source,
  COUNTIF(is_trade_in IS NULL) AS null_trade_in,
  COUNTIF(insurance_included IS NULL) AS null_insurance_included,
  COUNTIF(status IS NULL) AS null_status,
  COUNTIF(delivery_date IS NULL) AS null_delivery_date,
  COUNTIF(csat_score IS NULL) AS null_csat_score
FROM `project-nusantara-car.dataset_extraction.transactions`*/

/*SELECT MIN(down_payment_pct), MAX(down_payment_pct) FROM `project-nusantara-car.dataset_extraction.transactions`*/

/*SELECT
    customer_id,
    CAST(phone AS STRING) AS phone_asli,
    CASE
        WHEN CAST(phone AS STRING) LIKE '8%' THEN CONCAT('62', CAST(phone AS STRING))
        ELSE CAST(phone AS STRING)
    END AS phone_standardized
FROM `project-nusantara-car.dataset_extraction.customers`;*/

/*SELECT customer_id, lead_source, COUNT(*) FROM `project-nusantara-car.dataset_extraction.transactions`
GROUP BY customer_id, lead_source
HAVING COUNT(*) > 1
ORDER BY customer_id ASC;*/

/*SELECT * FROM `project-nusantara-car.dataset_extraction.transactions` WHERE delivery_date < transaction_date;*/

/*SELECT transaction_id, total_amount_idr, (quantity * (unit_price_idr - discount_idr)) AS comparison_total_amount_idr
FROM `project-nusantara-car.dataset_extraction.transactions` 
WHERE total_amount_idr > (quantity * (unit_price_idr - discount_idr))
LIMIT 10;*/

/*WITH k AS (
  SELECT customer_id, email, birth_date, city, registration_date,
         LOWER(TRIM(full_name)) AS name_key,
         CASE WHEN CAST(phone AS STRING) LIKE '62%' THEN SUBSTR(CAST(phone AS STRING), 3)
              ELSE CAST(phone AS STRING) END AS phone_key
  FROM `project-nusantara-car.dataset_extraction.customers`
  WHERE customer_segment = 'Retail' AND phone IS NOT NULL
)
SELECT name_key, phone_key,
       COUNT(*)                          AS n_customer_id,
       COUNT(DISTINCT birth_date)        AS n_birth_date_berbeda,
       COUNT(DISTINCT LOWER(TRIM(city))) AS n_city_berbeda,
       COUNT(DISTINCT LOWER(email))      AS n_email_berbeda,
       COUNTIF(email IS NULL)            AS n_email_kosong,
       STRING_AGG(customer_id, ', ' ORDER BY registration_date) AS daftar_id
FROM k
GROUP BY name_key, phone_key
HAVING COUNT(*) > 1
ORDER BY n_customer_id DESC, name_key;*/


/*SELECT 
  LOWER(TRIM(full_name)) AS name_key,
  CASE WHEN CAST(phone AS STRING) LIKE '62%' THEN SUBSTR(CAST(phone AS STRING), 3) ELSE CAST(phone AS STRING) END AS phone_key,
  COUNT(*)
from `project-nusantara-car.dataset_extraction.customers`
GROUP BY name_key, phone_key
HAVING COUNT(*) > 1;*/

/*WITH boundary AS (  
    SELECT 
        APPROX_QUANTILES(total_amount_idr, 100)[OFFSET(25)] AS q1,         
        APPROX_QUANTILES(total_amount_idr, 100)[OFFSET(75)] AS q3    
    FROM `project-nusantara-car.dataset_extraction.transactions` 
) 
SELECT 
    COUNT(t.total_amount_idr) AS total_count,       
    COUNTIF(t.total_amount_idr < b.q1 - 1.5 * (b.q3 - b.q1)) AS lower_outliers,       
    COUNTIF(t.total_amount_idr > b.q3 + 1.5 * (b.q3 - b.q1)) AS upper_outliers,       
    MAX(b.q3 + 1.5 * (b.q3 - b.q1)) AS upper_bound 
FROM `project-nusantara-car.dataset_extraction.transactions` t
CROSS JOIN boundary b;*/
