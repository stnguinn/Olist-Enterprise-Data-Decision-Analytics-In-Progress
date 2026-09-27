/*
===============================================================================
Project: Olist Enterprise Data & Decision Analytics
File:    00_create_raw_schema.sql

Purpose:
    Create the raw PostgreSQL landing schema and source tables for the
    Brazilian Olist e-commerce dataset.

Architecture:
    Raw CSV Files
        -> olist_raw
        -> stage_olist
        -> clean_2017
        -> Analytics / KPI Layer
        -> Decision Analysis

Design Decision:
    Source fields are initially stored primarily as TEXT in the raw layer.
    Data types, validation rules, standardization, and cleaning will occur
    later in the staging layer.

Author:
    Stanley E. Guinn
===============================================================================
*/


-- ============================================================================
-- 1. CREATE RAW SCHEMA
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS olist_raw;


-- ============================================================================
-- 2. CUSTOMERS
-- Source: olist_customers_dataset.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.customers (
    raw_row_id BIGSERIAL PRIMARY KEY,
    customer_id TEXT,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 3. GEOLOCATION
-- Source: olist_geolocation_dataset.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.geolocation (
    raw_row_id BIGSERIAL PRIMARY KEY,
    geolocation_zip_code_prefix TEXT,
    geolocation_lat TEXT,
    geolocation_lng TEXT,
    geolocation_city TEXT,
    geolocation_state TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 4. ORDER ITEMS
-- Source: olist_order_items_dataset.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.order_items (
    raw_row_id BIGSERIAL PRIMARY KEY,
    order_id TEXT,
    order_item_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price TEXT,
    freight_value TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 5. ORDER PAYMENTS
-- Source: olist_order_payments_dataset.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.order_payments (
    raw_row_id BIGSERIAL PRIMARY KEY,
    order_id TEXT,
    payment_sequential TEXT,
    payment_type TEXT,
    payment_installments TEXT,
    payment_value TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 6. ORDER REVIEWS
-- Source: olist_order_reviews_dataset.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.order_reviews (
    raw_row_id BIGSERIAL PRIMARY KEY,
    review_id TEXT,
    order_id TEXT,
    review_score TEXT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 7. ORDERS
-- Source: olist_orders_dataset.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.orders (
    raw_row_id BIGSERIAL PRIMARY KEY,
    order_id TEXT,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TEXT,
    order_approved_at TEXT,
    order_delivered_carrier_date TEXT,
    order_delivered_customer_date TEXT,
    order_estimated_delivery_date TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 8. PRODUCTS
-- Source: olist_products_dataset.csv
--
-- Note:
-- The original Olist CSV intentionally uses the misspelled source-column
-- names "product_name_lenght" and "product_description_lenght".
-- The raw layer preserves those source names exactly.
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.products (
    raw_row_id BIGSERIAL PRIMARY KEY,
    product_id TEXT,
    product_category_name TEXT,
    product_name_lenght TEXT,
    product_description_lenght TEXT,
    product_photos_qty TEXT,
    product_weight_g TEXT,
    product_length_cm TEXT,
    product_height_cm TEXT,
    product_width_cm TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 9. SELLERS
-- Source: olist_sellers_dataset.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.sellers (
    raw_row_id BIGSERIAL PRIMARY KEY,
    seller_id TEXT,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 10. PRODUCT CATEGORY TRANSLATION
-- Source: product_category_name_translation.csv
-- ============================================================================

CREATE TABLE IF NOT EXISTS olist_raw.product_category_translation (
    raw_row_id BIGSERIAL PRIMARY KEY,
    product_category_name TEXT,
    product_category_name_english TEXT,
    loaded_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================================
-- 11. VERIFY RAW TABLE CREATION
-- ============================================================================

SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'olist_raw'
ORDER BY table_name;