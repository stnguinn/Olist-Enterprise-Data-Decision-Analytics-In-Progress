/*
===============================================================================
Project: Olist Enterprise Data & Decision Analytics
File:    01_raw_data_quality.sql

Purpose:
    Profile and validate the Olist raw landing layer before any staging,
    cleaning, or analytical transformation is performed.

    This script is intentionally read-only. It does not modify source data.

Architecture:
    Raw CSV Files
        -> olist_raw
        -> [THIS SCRIPT: Raw Data Quality Assessment]
        -> stage_olist
        -> clean_2017
        -> Analytics / KPI Layer
        -> Decision Analysis

Primary Checks:
    1. Raw table row counts
    2. Critical-field NULL / blank values
    3. Duplicate business keys
    4. Date coverage and timestamp validity
    5. Invalid numeric values stored as TEXT
    6. Range / domain checks
    7. Referential-integrity / orphan checks
    8. Geolocation duplicate profiling
    9. Product-category translation coverage
   10. Basic source-domain distributions
   11. Consolidated quality summary

Design Notes:
    - The raw layer preserves source values primarily as TEXT.
    - A nonzero result does not automatically mean "bad data."
      Some findings are expected source characteristics that require a
      documented transformation rule in stage_olist.
    - Geolocation is intentionally profiled for duplicate and ambiguous ZIP
      mappings before it is used as a lookup source.
    - The translation reference is checked before English category values are
      introduced into the staging layer.

Author:
    Stanley E. Guinn
===============================================================================
*/


-- ============================================================================
-- 0. SESSION INFORMATION
-- ============================================================================

SELECT
    CURRENT_DATABASE() AS database_name,
    CURRENT_USER AS database_user,
    CURRENT_TIMESTAMP AS validation_run_timestamp;


/*=============================================================================
  1. RAW TABLE ROW COUNTS
=============================================================================*/

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM olist_raw.customers

UNION ALL
SELECT 'geolocation', COUNT(*)
FROM olist_raw.geolocation

UNION ALL
SELECT 'order_items', COUNT(*)
FROM olist_raw.order_items

UNION ALL
SELECT 'order_payments', COUNT(*)
FROM olist_raw.order_payments

UNION ALL
SELECT 'order_reviews', COUNT(*)
FROM olist_raw.order_reviews

UNION ALL
SELECT 'orders', COUNT(*)
FROM olist_raw.orders

UNION ALL
SELECT 'product_category_translation', COUNT(*)
FROM olist_raw.product_category_translation

UNION ALL
SELECT 'products', COUNT(*)
FROM olist_raw.products

UNION ALL
SELECT 'sellers', COUNT(*)
FROM olist_raw.sellers

ORDER BY table_name;


/*=============================================================================
  2. CRITICAL-FIELD NULL / BLANK CHECKS
=============================================================================*/

-- Customers
SELECT
    'customers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(customer_id), '') IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(customer_unique_id), '') IS NULL) AS missing_customer_unique_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(customer_zip_code_prefix), '') IS NULL) AS missing_zip_code_prefix,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(customer_city), '') IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(customer_state), '') IS NULL) AS missing_state
FROM olist_raw.customers;


-- Orders
SELECT
    'orders' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_id), '') IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(customer_id), '') IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_status), '') IS NULL) AS missing_order_status,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_purchase_timestamp), '') IS NULL) AS missing_purchase_timestamp,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_approved_at), '') IS NULL) AS missing_approved_at,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_delivered_carrier_date), '') IS NULL) AS missing_carrier_date,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_delivered_customer_date), '') IS NULL) AS missing_customer_delivery_date,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_estimated_delivery_date), '') IS NULL) AS missing_estimated_delivery_date
FROM olist_raw.orders;


-- Order Items
SELECT
    'order_items' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_id), '') IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_item_id), '') IS NULL) AS missing_order_item_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_id), '') IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(seller_id), '') IS NULL) AS missing_seller_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(shipping_limit_date), '') IS NULL) AS missing_shipping_limit_date,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(price), '') IS NULL) AS missing_price,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(freight_value), '') IS NULL) AS missing_freight_value
FROM olist_raw.order_items;


-- Order Payments
SELECT
    'order_payments' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_id), '') IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(payment_sequential), '') IS NULL) AS missing_payment_sequential,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(payment_type), '') IS NULL) AS missing_payment_type,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(payment_installments), '') IS NULL) AS missing_payment_installments,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(payment_value), '') IS NULL) AS missing_payment_value
FROM olist_raw.order_payments;


-- Order Reviews
SELECT
    'order_reviews' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(review_id), '') IS NULL) AS missing_review_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(order_id), '') IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(review_score), '') IS NULL) AS missing_review_score,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(review_creation_date), '') IS NULL) AS missing_review_creation_date,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(review_answer_timestamp), '') IS NULL) AS missing_review_answer_timestamp
FROM olist_raw.order_reviews;


-- Products
SELECT
    'products' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_id), '') IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_category_name), '') IS NULL) AS missing_category_name,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_name_lenght), '') IS NULL) AS missing_name_length,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_description_lenght), '') IS NULL) AS missing_description_length,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_photos_qty), '') IS NULL) AS missing_photos_qty,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_weight_g), '') IS NULL) AS missing_weight_g,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_length_cm), '') IS NULL) AS missing_length_cm,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_height_cm), '') IS NULL) AS missing_height_cm,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(product_width_cm), '') IS NULL) AS missing_width_cm
FROM olist_raw.products;


-- Sellers
SELECT
    'sellers' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(seller_id), '') IS NULL) AS missing_seller_id,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(seller_zip_code_prefix), '') IS NULL) AS missing_zip_code_prefix,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(seller_city), '') IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(seller_state), '') IS NULL) AS missing_state
FROM olist_raw.sellers;


-- Geolocation
SELECT
    'geolocation' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(geolocation_zip_code_prefix), '') IS NULL) AS missing_zip_code_prefix,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(geolocation_lat), '') IS NULL) AS missing_latitude,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(geolocation_lng), '') IS NULL) AS missing_longitude,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(geolocation_city), '') IS NULL) AS missing_city,
    COUNT(*) FILTER (WHERE NULLIF(BTRIM(geolocation_state), '') IS NULL) AS missing_state
FROM olist_raw.geolocation;


/*=============================================================================
  3. DUPLICATE BUSINESS-KEY CHECKS
  Improved version: returns explicit zero counts rather than empty result grids.
=============================================================================*/

SELECT
    'customers.customer_id' AS key_test,
    COUNT(*) AS duplicate_groups
FROM (
    SELECT customer_id
    FROM olist_raw.customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1
) d

UNION ALL

SELECT
    'orders.order_id',
    COUNT(*)
FROM (
    SELECT order_id
    FROM olist_raw.orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
) d

UNION ALL

SELECT
    'products.product_id',
    COUNT(*)
FROM (
    SELECT product_id
    FROM olist_raw.products
    GROUP BY product_id
    HAVING COUNT(*) > 1
) d

UNION ALL

SELECT
    'sellers.seller_id',
    COUNT(*)
FROM (
    SELECT seller_id
    FROM olist_raw.sellers
    GROUP BY seller_id
    HAVING COUNT(*) > 1
) d

UNION ALL

SELECT
    'order_items.order_id + order_item_id',
    COUNT(*)
FROM (
    SELECT order_id, order_item_id
    FROM olist_raw.order_items
    GROUP BY order_id, order_item_id
    HAVING COUNT(*) > 1
) d

UNION ALL

SELECT
    'order_payments.order_id + payment_sequential',
    COUNT(*)
FROM (
    SELECT order_id, payment_sequential
    FROM olist_raw.order_payments
    GROUP BY order_id, payment_sequential
    HAVING COUNT(*) > 1
) d

UNION ALL

SELECT
    'order_reviews.review_id + order_id',
    COUNT(*)
FROM (
    SELECT review_id, order_id
    FROM olist_raw.order_reviews
    GROUP BY review_id, order_id
    HAVING COUNT(*) > 1
) d

ORDER BY key_test;


/*=============================================================================
  4. DATE COVERAGE AND TIMESTAMP VALIDITY
  Improved version: consolidated into two result sets and uses [0-9] explicitly.
=============================================================================*/

-- 4A. Orders: timestamp validity plus purchase-date coverage.
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_purchase_timestamp), '') IS NOT NULL
          AND order_purchase_timestamp !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_purchase_timestamp,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_approved_at), '') IS NOT NULL
          AND order_approved_at !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_approved_at,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_delivered_carrier_date), '') IS NOT NULL
          AND order_delivered_carrier_date !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_delivered_carrier_date,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_delivered_customer_date), '') IS NOT NULL
          AND order_delivered_customer_date !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_delivered_customer_date,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_estimated_delivery_date), '') IS NOT NULL
          AND order_estimated_delivery_date !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_estimated_delivery_date,

    MIN(
        CASE
            WHEN order_purchase_timestamp ~
                 '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
            THEN order_purchase_timestamp::timestamp
        END
    ) AS min_purchase_timestamp,

    MAX(
        CASE
            WHEN order_purchase_timestamp ~
                 '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
            THEN order_purchase_timestamp::timestamp
        END
    ) AS max_purchase_timestamp

FROM olist_raw.orders;


-- 4B. Shipping-limit coverage plus review timestamp validity.
SELECT
    (
        SELECT COUNT(*)
        FROM olist_raw.order_items
        WHERE NULLIF(BTRIM(shipping_limit_date), '') IS NOT NULL
          AND shipping_limit_date !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_shipping_limit_date,

    (
        SELECT MIN(shipping_limit_date::timestamp)
        FROM olist_raw.order_items
        WHERE shipping_limit_date ~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS min_shipping_limit_date,

    (
        SELECT MAX(shipping_limit_date::timestamp)
        FROM olist_raw.order_items
        WHERE shipping_limit_date ~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS max_shipping_limit_date,

    (
        SELECT COUNT(*)
        FROM olist_raw.order_reviews
        WHERE NULLIF(BTRIM(review_creation_date), '') IS NOT NULL
          AND review_creation_date !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_review_creation_date,

    (
        SELECT COUNT(*)
        FROM olist_raw.order_reviews
        WHERE NULLIF(BTRIM(review_answer_timestamp), '') IS NOT NULL
          AND review_answer_timestamp !~
              '^[0-9]{4}-[0-9]{2}-[0-9]{2}( [0-9]{2}:[0-9]{2}:[0-9]{2})?$'
    ) AS invalid_review_answer_timestamp;


/*=============================================================================
  5. INVALID NUMERIC VALUES STORED AS TEXT
=============================================================================*/

-- Order items
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_item_id), '') IS NOT NULL
          AND order_item_id !~ '^[+-]?[0-9]+$'
    ) AS invalid_order_item_id,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(price), '') IS NOT NULL
          AND price !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_price,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(freight_value), '') IS NOT NULL
          AND freight_value !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_freight_value
FROM olist_raw.order_items;


-- Payments
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(payment_sequential), '') IS NOT NULL
          AND payment_sequential !~ '^[+-]?[0-9]+$'
    ) AS invalid_payment_sequential,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(payment_installments), '') IS NOT NULL
          AND payment_installments !~ '^[+-]?[0-9]+$'
    ) AS invalid_payment_installments,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(payment_value), '') IS NOT NULL
          AND payment_value !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_payment_value
FROM olist_raw.order_payments;


-- Reviews
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(review_score), '') IS NOT NULL
          AND review_score !~ '^[+-]?[0-9]+$'
    ) AS invalid_review_score
FROM olist_raw.order_reviews;


-- Products
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_name_lenght), '') IS NOT NULL
          AND product_name_lenght !~ '^[+-]?[0-9]+$'
    ) AS invalid_product_name_length,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_description_lenght), '') IS NOT NULL
          AND product_description_lenght !~ '^[+-]?[0-9]+$'
    ) AS invalid_product_description_length,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_photos_qty), '') IS NOT NULL
          AND product_photos_qty !~ '^[+-]?[0-9]+$'
    ) AS invalid_product_photos_qty,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_weight_g), '') IS NOT NULL
          AND product_weight_g !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_product_weight_g,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_length_cm), '') IS NOT NULL
          AND product_length_cm !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_product_length_cm,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_height_cm), '') IS NOT NULL
          AND product_height_cm !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_product_height_cm,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_width_cm), '') IS NOT NULL
          AND product_width_cm !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_product_width_cm
FROM olist_raw.products;


-- Geolocation
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(geolocation_zip_code_prefix), '') IS NOT NULL
          AND geolocation_zip_code_prefix !~ '^[+-]?[0-9]+$'
    ) AS invalid_zip_code_prefix,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(geolocation_lat), '') IS NOT NULL
          AND geolocation_lat !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_latitude,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(geolocation_lng), '') IS NOT NULL
          AND geolocation_lng !~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
    ) AS invalid_longitude
FROM olist_raw.geolocation;


/*=============================================================================
  6. RANGE / DOMAIN CHECKS
=============================================================================*/

-- Review-score distribution.
SELECT
    review_score,
    COUNT(*) AS row_count
FROM olist_raw.order_reviews
GROUP BY review_score
ORDER BY
    CASE
        WHEN review_score ~ '^[+-]?[0-9]+$' THEN review_score::integer
        ELSE NULL
    END NULLS LAST,
    review_score;


-- Review scores outside expected 1-5 range.
SELECT
    COUNT(*) AS review_scores_outside_1_to_5
FROM olist_raw.order_reviews
WHERE review_score ~ '^[+-]?[0-9]+$'
  AND review_score::integer NOT BETWEEN 1 AND 5;


-- Monetary values below zero.
SELECT
    COUNT(*) AS negative_prices
FROM olist_raw.order_items
WHERE price ~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
  AND price::numeric < 0;

SELECT
    COUNT(*) AS negative_freight_values
FROM olist_raw.order_items
WHERE freight_value ~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
  AND freight_value::numeric < 0;

SELECT
    COUNT(*) AS negative_payment_values
FROM olist_raw.order_payments
WHERE payment_value ~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
  AND payment_value::numeric < 0;


-- Geolocation coordinate ranges.
SELECT
    COUNT(*) AS latitude_out_of_range
FROM olist_raw.geolocation
WHERE geolocation_lat ~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
  AND geolocation_lat::numeric NOT BETWEEN -90 AND 90;

SELECT
    COUNT(*) AS longitude_out_of_range
FROM olist_raw.geolocation
WHERE geolocation_lng ~ '^[+-]?([0-9]+(\.[0-9]*)?|\.[0-9]+)$'
  AND geolocation_lng::numeric NOT BETWEEN -180 AND 180;


/*=============================================================================
  7. REFERENTIAL-INTEGRITY / ORPHAN CHECKS
=============================================================================*/

SELECT COUNT(*) AS orders_without_customer
FROM olist_raw.orders o
LEFT JOIN olist_raw.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


SELECT COUNT(*) AS order_items_without_order
FROM olist_raw.order_items oi
LEFT JOIN olist_raw.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


SELECT COUNT(*) AS order_items_without_product
FROM olist_raw.order_items oi
LEFT JOIN olist_raw.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


SELECT COUNT(*) AS order_items_without_seller
FROM olist_raw.order_items oi
LEFT JOIN olist_raw.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


SELECT COUNT(*) AS payments_without_order
FROM olist_raw.order_payments op
LEFT JOIN olist_raw.orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


SELECT COUNT(*) AS reviews_without_order
FROM olist_raw.order_reviews r
LEFT JOIN olist_raw.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


/*=============================================================================
  8. GEOLOCATION DUPLICATE PROFILING
=============================================================================*/

-- Number of exact duplicate geolocation groups.
SELECT
    COUNT(*) AS exact_duplicate_geolocation_groups
FROM (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        COUNT(*) AS row_count
    FROM olist_raw.geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT(*) > 1
) d;


-- Number of excess physical rows caused by exact duplicates.
SELECT
    COALESCE(SUM(row_count - 1), 0) AS duplicate_excess_rows
FROM (
    SELECT
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state,
        COUNT(*) AS row_count
    FROM olist_raw.geolocation
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_lat,
        geolocation_lng,
        geolocation_city,
        geolocation_state
    HAVING COUNT(*) > 1
) d;


-- Summary of ZIP prefixes mapped to multiple city/state combinations.
WITH zip_city_state AS (
    SELECT
        geolocation_zip_code_prefix,
        COUNT(DISTINCT (geolocation_city, geolocation_state)) AS city_state_combinations
    FROM olist_raw.geolocation
    GROUP BY geolocation_zip_code_prefix
)
SELECT
    city_state_combinations,
    COUNT(*) AS zip_prefix_count
FROM zip_city_state
WHERE city_state_combinations > 1
GROUP BY city_state_combinations
ORDER BY city_state_combinations;


/*=============================================================================
  9. PRODUCT-CATEGORY TRANSLATION COVERAGE
=============================================================================*/

-- Count products whose nonblank Portuguese category lacks an English mapping.
SELECT
    COUNT(*) AS products_without_category_translation
FROM olist_raw.products p
LEFT JOIN olist_raw.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE NULLIF(BTRIM(p.product_category_name), '') IS NOT NULL
  AND t.product_category_name IS NULL;


-- List affected source categories and product counts.
SELECT
    p.product_category_name,
    COUNT(*) AS affected_products
FROM olist_raw.products p
LEFT JOIN olist_raw.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE NULLIF(BTRIM(p.product_category_name), '') IS NOT NULL
  AND t.product_category_name IS NULL
GROUP BY p.product_category_name
ORDER BY affected_products DESC, p.product_category_name;


/*=============================================================================
  10. BASIC SOURCE-DOMAIN DISTRIBUTIONS
=============================================================================*/

-- Order status distribution.
SELECT
    order_status,
    COUNT(*) AS order_count,
    ROUND(
        100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS pct_of_orders
FROM olist_raw.orders
GROUP BY order_status
ORDER BY order_count DESC, order_status;


-- Payment type distribution.
SELECT
    payment_type,
    COUNT(*) AS payment_row_count,
    ROUND(
        100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0),
        2
    ) AS pct_of_payment_rows
FROM olist_raw.order_payments
GROUP BY payment_type
ORDER BY payment_row_count DESC, payment_type;


-- Customer state distribution.
SELECT
    customer_state,
    COUNT(*) AS customer_count
FROM olist_raw.customers
GROUP BY customer_state
ORDER BY customer_count DESC, customer_state;


-- Seller state distribution.
SELECT
    seller_state,
    COUNT(*) AS seller_count
FROM olist_raw.sellers
GROUP BY seller_state
ORDER BY seller_count DESC, seller_state;


/*=============================================================================
  11. CONSOLIDATED QUALITY SUMMARY
=============================================================================*/

WITH quality_summary AS (

    SELECT
        'orders_without_customer' AS check_name,
        COUNT(*)::bigint AS issue_count,
        'Core relationship integrity' AS check_category,
        'PASS when 0' AS interpretation
    FROM olist_raw.orders o
    LEFT JOIN olist_raw.customers c
        ON o.customer_id = c.customer_id
    WHERE c.customer_id IS NULL

    UNION ALL

    SELECT
        'order_items_without_order',
        COUNT(*)::bigint,
        'Core relationship integrity',
        'PASS when 0'
    FROM olist_raw.order_items oi
    LEFT JOIN olist_raw.orders o
        ON oi.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL

    SELECT
        'order_items_without_product',
        COUNT(*)::bigint,
        'Core relationship integrity',
        'PASS when 0'
    FROM olist_raw.order_items oi
    LEFT JOIN olist_raw.products p
        ON oi.product_id = p.product_id
    WHERE p.product_id IS NULL

    UNION ALL

    SELECT
        'order_items_without_seller',
        COUNT(*)::bigint,
        'Core relationship integrity',
        'PASS when 0'
    FROM olist_raw.order_items oi
    LEFT JOIN olist_raw.sellers s
        ON oi.seller_id = s.seller_id
    WHERE s.seller_id IS NULL

    UNION ALL

    SELECT
        'payments_without_order',
        COUNT(*)::bigint,
        'Core relationship integrity',
        'PASS when 0'
    FROM olist_raw.order_payments op
    LEFT JOIN olist_raw.orders o
        ON op.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL

    SELECT
        'reviews_without_order',
        COUNT(*)::bigint,
        'Core relationship integrity',
        'PASS when 0'
    FROM olist_raw.order_reviews r
    LEFT JOIN olist_raw.orders o
        ON r.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL

    SELECT
        'products_without_category_translation',
        COUNT(*)::bigint,
        'Reference-data coverage',
        'REVIEW when > 0'
    FROM olist_raw.products p
    LEFT JOIN olist_raw.product_category_translation t
        ON p.product_category_name = t.product_category_name
    WHERE NULLIF(BTRIM(p.product_category_name), '') IS NOT NULL
      AND t.product_category_name IS NULL

    UNION ALL

    SELECT
        'duplicate_geolocation_excess_rows',
        COALESCE(SUM(row_count - 1), 0)::bigint,
        'Expected source characteristic',
        'REVIEW: use controlled ZIP-level staging logic'
    FROM (
        SELECT
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state,
            COUNT(*) AS row_count
        FROM olist_raw.geolocation
        GROUP BY
            geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
        HAVING COUNT(*) > 1
    ) g
)

SELECT
    check_category,
    check_name,
    issue_count,
    CASE
        WHEN check_name = 'duplicate_geolocation_excess_rows'
             AND issue_count > 0
            THEN 'REVIEW'
        WHEN check_name = 'products_without_category_translation'
             AND issue_count > 0
            THEN 'REVIEW'
        WHEN issue_count = 0
            THEN 'PASS'
        ELSE 'REVIEW'
    END AS quality_status,
    interpretation
FROM quality_summary
ORDER BY
    CASE
        WHEN check_name = 'duplicate_geolocation_excess_rows' THEN 0
        WHEN check_name = 'products_without_category_translation' THEN 1
        ELSE 2
    END,
    issue_count DESC,
    check_name;


/*=============================================================================
  END OF FILE

  Current transformation decisions supported by this assessment:
      1. Convert validated text dates/timestamps to PostgreSQL timestamp types
         in stage_olist.
      2. Convert validated numeric text fields to appropriate integer/numeric
         types in stage_olist.
      3. Preserve core relationships because no orphan records were identified
         during validation.
      4. Do not join customer/seller records directly to raw geolocation by ZIP
         prefix. Build a controlled ZIP-level geolocation reference first.
      5. Preserve the original Portuguese product category and use a documented
         English-translation fallback for categories missing from the reference
         table.
      6. Review unusually late shipping-limit dates during staging/business-rule
         validation rather than classifying them as timestamp-format errors.

  Next Step:
      Create 02_create_stage_schema.sql and apply controlled type conversion,
      standardization, geolocation consolidation, and reference-data handling.
=============================================================================*/
