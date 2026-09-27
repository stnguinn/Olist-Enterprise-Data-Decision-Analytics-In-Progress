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
    4. Date coverage and invalid timestamp values
    5. Invalid numeric values stored as TEXT
    6. Referential-integrity / orphan checks
    7. Geolocation duplicate profiling
    8. Product-category translation coverage
    9. Order-status and payment-type distributions
    10. Summary quality flags

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
=============================================================================*/

-- customer_id should identify one order-level customer record.
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM olist_raw.customers
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, customer_id;


-- order_id should be unique in orders.
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM olist_raw.orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, order_id;


-- product_id should be unique in products.
SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM olist_raw.products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, product_id;


-- seller_id should be unique in sellers.
SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM olist_raw.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, seller_id;


-- Order items are expected to be unique by order_id + order_item_id.
SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM olist_raw.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, order_id, order_item_id;


-- Payments are expected to be unique by order_id + payment_sequential.
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM olist_raw.order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, order_id, payment_sequential;


-- Reviews may contain repeated review_id/order_id combinations; profile them.
SELECT
    review_id,
    order_id,
    COUNT(*) AS duplicate_count
FROM olist_raw.order_reviews
GROUP BY review_id, order_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC, review_id, order_id;


/*=============================================================================
  4. DATE COVERAGE AND TIMESTAMP VALIDITY
=============================================================================*/

-- Valid timestamp pattern used below:
-- YYYY-MM-DD HH:MI:SS
-- Date-only values are also accepted where appropriate.

-- Orders: invalid date/time text counts.
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_purchase_timestamp), '') IS NOT NULL
          AND order_purchase_timestamp !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_purchase_timestamp,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_approved_at), '') IS NOT NULL
          AND order_approved_at !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_approved_at,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_delivered_carrier_date), '') IS NOT NULL
          AND order_delivered_carrier_date !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_delivered_carrier_date,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_delivered_customer_date), '') IS NOT NULL
          AND order_delivered_customer_date !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_delivered_customer_date,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_estimated_delivery_date), '') IS NOT NULL
          AND order_estimated_delivery_date !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_estimated_delivery_date
FROM olist_raw.orders;


-- Purchase date coverage using only values that match the expected pattern.
SELECT
    MIN(order_purchase_timestamp::timestamp) AS min_purchase_timestamp,
    MAX(order_purchase_timestamp::timestamp) AS max_purchase_timestamp
FROM olist_raw.orders
WHERE order_purchase_timestamp ~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$';


-- Order-items shipping-limit date validity and coverage.
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(shipping_limit_date), '') IS NOT NULL
          AND shipping_limit_date !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_shipping_limit_date
FROM olist_raw.order_items;

SELECT
    MIN(shipping_limit_date::timestamp) AS min_shipping_limit_date,
    MAX(shipping_limit_date::timestamp) AS max_shipping_limit_date
FROM olist_raw.order_items
WHERE shipping_limit_date ~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$';


-- Review timestamp validity.
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(review_creation_date), '') IS NOT NULL
          AND review_creation_date !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_review_creation_date,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(review_answer_timestamp), '') IS NOT NULL
          AND review_answer_timestamp !~ '^\d{4}-\d{2}-\d{2}( \d{2}:\d{2}:\d{2})?$'
    ) AS invalid_review_answer_timestamp
FROM olist_raw.order_reviews;


/*=============================================================================
  5. INVALID NUMERIC VALUES STORED AS TEXT
=============================================================================*/

-- Generic patterns:
-- Integer: ^[+-]?\d+$
-- Numeric: ^[+-]?(\d+(\.\d*)?|\.\d+)$

-- Order items
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(order_item_id), '') IS NOT NULL
          AND order_item_id !~ '^[+-]?\d+$'
    ) AS invalid_order_item_id,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(price), '') IS NOT NULL
          AND price !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_price,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(freight_value), '') IS NOT NULL
          AND freight_value !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_freight_value
FROM olist_raw.order_items;


-- Payments
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(payment_sequential), '') IS NOT NULL
          AND payment_sequential !~ '^[+-]?\d+$'
    ) AS invalid_payment_sequential,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(payment_installments), '') IS NOT NULL
          AND payment_installments !~ '^[+-]?\d+$'
    ) AS invalid_payment_installments,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(payment_value), '') IS NOT NULL
          AND payment_value !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_payment_value
FROM olist_raw.order_payments;


-- Reviews
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(review_score), '') IS NOT NULL
          AND review_score !~ '^[+-]?\d+$'
    ) AS invalid_review_score
FROM olist_raw.order_reviews;


-- Products
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_name_lenght), '') IS NOT NULL
          AND product_name_lenght !~ '^[+-]?\d+$'
    ) AS invalid_product_name_length,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_description_lenght), '') IS NOT NULL
          AND product_description_lenght !~ '^[+-]?\d+$'
    ) AS invalid_product_description_length,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_photos_qty), '') IS NOT NULL
          AND product_photos_qty !~ '^[+-]?\d+$'
    ) AS invalid_product_photos_qty,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_weight_g), '') IS NOT NULL
          AND product_weight_g !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_product_weight_g,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_length_cm), '') IS NOT NULL
          AND product_length_cm !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_product_length_cm,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_height_cm), '') IS NOT NULL
          AND product_height_cm !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_product_height_cm,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(product_width_cm), '') IS NOT NULL
          AND product_width_cm !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_product_width_cm
FROM olist_raw.products;


-- Geolocation
SELECT
    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(geolocation_zip_code_prefix), '') IS NOT NULL
          AND geolocation_zip_code_prefix !~ '^[+-]?\d+$'
    ) AS invalid_zip_code_prefix,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(geolocation_lat), '') IS NOT NULL
          AND geolocation_lat !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_latitude,

    COUNT(*) FILTER (
        WHERE NULLIF(BTRIM(geolocation_lng), '') IS NOT NULL
          AND geolocation_lng !~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
    ) AS invalid_longitude
FROM olist_raw.geolocation;


/*=============================================================================
  6. RANGE / DOMAIN CHECKS
=============================================================================*/

-- Review scores should normally be 1 through 5.
SELECT
    review_score,
    COUNT(*) AS row_count
FROM olist_raw.order_reviews
GROUP BY review_score
ORDER BY review_score;


SELECT
    COUNT(*) AS review_scores_outside_1_to_5
FROM olist_raw.order_reviews
WHERE review_score ~ '^[+-]?\d+$'
  AND review_score::integer NOT BETWEEN 1 AND 5;


-- Negative monetary values should be investigated.
SELECT
    COUNT(*) AS negative_prices
FROM olist_raw.order_items
WHERE price ~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
  AND price::numeric < 0;

SELECT
    COUNT(*) AS negative_freight_values
FROM olist_raw.order_items
WHERE freight_value ~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
  AND freight_value::numeric < 0;

SELECT
    COUNT(*) AS negative_payment_values
FROM olist_raw.order_payments
WHERE payment_value ~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
  AND payment_value::numeric < 0;


-- Geolocation latitude/longitude ranges.
SELECT
    COUNT(*) AS latitude_out_of_range
FROM olist_raw.geolocation
WHERE geolocation_lat ~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
  AND geolocation_lat::numeric NOT BETWEEN -90 AND 90;

SELECT
    COUNT(*) AS longitude_out_of_range
FROM olist_raw.geolocation
WHERE geolocation_lng ~ '^[+-]?(\d+(\.\d*)?|\.\d+)$'
  AND geolocation_lng::numeric NOT BETWEEN -180 AND 180;


/*=============================================================================
  7. REFERENTIAL-INTEGRITY / ORPHAN CHECKS
=============================================================================*/

-- Orders whose customer_id is missing from customers.
SELECT COUNT(*) AS orders_without_customer
FROM olist_raw.orders o
LEFT JOIN olist_raw.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Order items whose order_id is missing from orders.
SELECT COUNT(*) AS order_items_without_order
FROM olist_raw.order_items oi
LEFT JOIN olist_raw.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Order items whose product_id is missing from products.
SELECT COUNT(*) AS order_items_without_product
FROM olist_raw.order_items oi
LEFT JOIN olist_raw.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Order items whose seller_id is missing from sellers.
SELECT COUNT(*) AS order_items_without_seller
FROM olist_raw.order_items oi
LEFT JOIN olist_raw.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Payments whose order_id is missing from orders.
SELECT COUNT(*) AS payments_without_order
FROM olist_raw.order_payments op
LEFT JOIN olist_raw.orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;


-- Reviews whose order_id is missing from orders.
SELECT COUNT(*) AS reviews_without_order
FROM olist_raw.order_reviews r
LEFT JOIN olist_raw.orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;


/*=============================================================================
  8. GEOLOCATION DUPLICATE PROFILING
=============================================================================*/

-- Exact duplicate geolocation rows.
SELECT
    COUNT(*) AS exact_duplicate_geolocation_rows
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


-- Total excess rows caused by exact geolocation duplicates.
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


-- ZIP prefixes associated with multiple city/state combinations.
SELECT
    geolocation_zip_code_prefix,
    COUNT(DISTINCT (geolocation_city, geolocation_state)) AS city_state_combinations
FROM olist_raw.geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT (geolocation_city, geolocation_state)) > 1
ORDER BY city_state_combinations DESC, geolocation_zip_code_prefix;


/*=============================================================================
  9. PRODUCT-CATEGORY TRANSLATION COVERAGE
=============================================================================*/

-- Products with a category but no English translation.
SELECT
    COUNT(*) AS products_without_category_translation
FROM olist_raw.products p
LEFT JOIN olist_raw.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE NULLIF(BTRIM(p.product_category_name), '') IS NOT NULL
  AND t.product_category_name IS NULL;


-- List categories that do not have a translation.
SELECT DISTINCT
    p.product_category_name
FROM olist_raw.products p
LEFT JOIN olist_raw.product_category_translation t
    ON p.product_category_name = t.product_category_name
WHERE NULLIF(BTRIM(p.product_category_name), '') IS NOT NULL
  AND t.product_category_name IS NULL
ORDER BY p.product_category_name;


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
  11. QUALITY SUMMARY
=============================================================================*/

WITH quality_summary AS (

    SELECT
        'orders_without_customer' AS check_name,
        COUNT(*)::bigint AS issue_count
    FROM olist_raw.orders o
    LEFT JOIN olist_raw.customers c
        ON o.customer_id = c.customer_id
    WHERE c.customer_id IS NULL

    UNION ALL

    SELECT
        'order_items_without_order',
        COUNT(*)::bigint
    FROM olist_raw.order_items oi
    LEFT JOIN olist_raw.orders o
        ON oi.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL

    SELECT
        'order_items_without_product',
        COUNT(*)::bigint
    FROM olist_raw.order_items oi
    LEFT JOIN olist_raw.products p
        ON oi.product_id = p.product_id
    WHERE p.product_id IS NULL

    UNION ALL

    SELECT
        'order_items_without_seller',
        COUNT(*)::bigint
    FROM olist_raw.order_items oi
    LEFT JOIN olist_raw.sellers s
        ON oi.seller_id = s.seller_id
    WHERE s.seller_id IS NULL

    UNION ALL

    SELECT
        'payments_without_order',
        COUNT(*)::bigint
    FROM olist_raw.order_payments op
    LEFT JOIN olist_raw.orders o
        ON op.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL

    SELECT
        'reviews_without_order',
        COUNT(*)::bigint
    FROM olist_raw.order_reviews r
    LEFT JOIN olist_raw.orders o
        ON r.order_id = o.order_id
    WHERE o.order_id IS NULL

    UNION ALL

    SELECT
        'products_without_category_translation',
        COUNT(*)::bigint
    FROM olist_raw.products p
    LEFT JOIN olist_raw.product_category_translation t
        ON p.product_category_name = t.product_category_name
    WHERE NULLIF(BTRIM(p.product_category_name), '') IS NOT NULL
      AND t.product_category_name IS NULL
)

SELECT
    check_name,
    issue_count,
    CASE
        WHEN issue_count = 0 THEN 'PASS'
        ELSE 'REVIEW'
    END AS quality_status
FROM quality_summary
ORDER BY
    CASE WHEN issue_count = 0 THEN 1 ELSE 0 END,
    issue_count DESC,
    check_name;


/*=============================================================================
  END OF FILE

  Next Step:
      Review and document the findings produced by this script before creating
      the stage_olist schema and applying data-type conversions, standardization,
      de-duplication rules, or other transformation logic.
=============================================================================*/
