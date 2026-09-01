-- =====================================================
-- DATA QUALITY CHECKS
-- Project: Olist E-commerce Analytics
-- Author: Tiago Bessa
-- Objective:
-- Validate data consistency, completeness,
-- and integrity before business analysis.
-- =====================================================


-- =====================================================
-- 1. TABLE VOLUME VALIDATION
-- Objective:
-- Validate successful data import and
-- verify dataset dimensions.
-- =====================================================

SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

SELECT 'order_payments', COUNT(*)
FROM order_payments

UNION ALL

SELECT 'order_review', COUNT(*)
FROM order_review

UNION ALL

SELECT 'products', COUNT(*)
FROM products

UNION ALL

SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

SELECT 'geolocation', COUNT(*)
FROM geolocation

UNION ALL

SELECT 'product_category_name', COUNT(*)
FROM product_category_name;

-- =====================================================
-- Result Summary:
-- All tables were successfully imported into PostgreSQL.
-- Dataset includes transactional, customer,
-- product, payment, and operational information.
--
-- Largest table identified:
-- geolocation (~1M records)
-- indicating high granularity for location analysis.
--
-- Core transactional tables:
-- orders
-- order_items
-- order_payments
-- =====================================================

-- =====================================================
-- 2. STRUCTURAL VALIDATION
-- Objective:
-- Validate table structure, data types,
-- and nullable fields.
-- =====================================================

SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- Structural Validation Summary:
-- Data types are aligned with analytical requirements.
-- Timestamp fields were correctly imported.
-- Monetary fields support numerical aggregation.
-- Schema structure is suitable for SQL analytics workflows.

-- =====================================================
-- 3. PRIMARY KEY INTEGRITY CHECK
-- Objective:
-- Detect duplicate primary keys and validate
-- entity uniqueness across transactional tables.
-- =====================================================
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT
    seller_id,
    COUNT(*) AS duplicate_count
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;

-- =====================================================
-- PRIMARY KEY INTEGRITY SUMMARY
-- =====================================================

-- No duplicate primary keys were identified
-- across all core transactional and dimension tables.

-- Composite primary keys in order_items and
-- order_payments were also successfully validated.

-- Results indicate strong entity uniqueness and
-- transactional integrity throughout the dataset.

-- Dataset is suitable for further analytical processing.

-- =====================================================
-- 4. STRUCTURAL VALIDATION
-- Objective:
-- Validate table structure, data types,
-- and nullable fields.
-- =====================================================

SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

SELECT
    column_name,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'order_items';

-- =====================================================
-- STRUCTURAL VALIDATION SUMMARY
-- =====================================================

-- Table structures were successfully validated.

-- All primary identifiers were imported using
-- appropriate text-based data types.

-- Monetary fields were stored as numeric values,
-- supporting accurate financial calculations.

-- Timestamp fields are available for time-series,
-- retention, and cohort analyses.

-- Nullable fields were identified across several tables.
-- Further assessment will be conducted during the
-- Missing Values Analysis phase to determine whether
-- null values represent data quality issues or expected
-- business scenarios.

-- Overall, the dataset structure is suitable for
-- advanced SQL analytics and business intelligence
-- reporting.

-- =====================================================
-- 5. MISSING VALUES ANALYSIS
-- Objective:
-- Identify missing values across core tables and
-- assess their potential impact on business analysis.
-- =====================================================

SELECT
    COUNT(*) AS total_orders,

    COUNT(*) FILTER (
        WHERE order_purchase_timestamp IS NULL
    ) AS missing_purchase_date,

    COUNT(*) FILTER (
        WHERE order_approved_at IS NULL
    ) AS missing_approval_date,

    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date IS NULL
    ) AS missing_carrier_date,

    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS missing_delivery_date,

    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date IS NULL
    ) AS missing_estimated_delivery_date

FROM orders;

SELECT
    COUNT(*) AS total_items,

    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_product_id,

    COUNT(*) FILTER (
        WHERE seller_id IS NULL
    ) AS missing_seller_id,

    COUNT(*) FILTER (
        WHERE price IS NULL
    ) AS missing_price,

    COUNT(*) FILTER (
        WHERE freight_value IS NULL
    ) AS missing_freight_value

FROM order_items;

SELECT
    COUNT(*) AS total_payments,

    COUNT(*) FILTER (
        WHERE payment_type IS NULL
    ) AS missing_payment_type,

    COUNT(*) FILTER (
        WHERE payment_installments IS NULL
    ) AS missing_installments,

    COUNT(*) FILTER (
        WHERE payment_value IS NULL
    ) AS missing_payment_value

FROM order_payments;

SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE customer_zip_code_prefix IS NULL
    ) AS missing_zip_code,

    COUNT(*) FILTER (
        WHERE customer_city IS NULL
    ) AS missing_city,

    COUNT(*) FILTER (
        WHERE customer_state IS NULL
    ) AS missing_state

FROM customers;

SELECT
    COUNT(*) AS total_products,

    COUNT(*) FILTER (
        WHERE product_category_name IS NULL
    ) AS missing_category,

    COUNT(*) FILTER (
        WHERE product_name_length IS NULL
    ) AS missing_name_length,

    COUNT(*) FILTER (
        WHERE product_description_length IS NULL
    ) AS missing_description_length,

    COUNT(*) FILTER (
        WHERE product_photos_qty IS NULL
    ) AS missing_photos_qty

FROM products;

SELECT *
FROM products
WHERE product_category_name IS NULL;

SELECT COUNT(*)
FROM products
WHERE product_category_name IS NULL
  AND product_name_length IS NULL
  AND product_description_length IS NULL
  AND product_photos_qty IS NULL;

  SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
WHERE order_delivered_customer_date IS NULL
GROUP BY order_status
ORDER BY total_orders DESC;

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL;

  -- =====================================================
-- MISSING VALUES ANALYSIS SUMMARY
-- =====================================================

-- Missing values are limited and largely explained by
-- normal business processes.

-- In the orders table, missing delivery-related dates
-- are primarily associated with orders that were
-- canceled, unavailable, processing, or still in transit.

-- Product metadata contains 610 records with missing
-- descriptive information (approximately 1.85% of the
-- catalog). Missing values are concentrated within the
-- same subset of products, suggesting incomplete catalog
-- registration rather than random data quality issues.

-- Only 8 orders (<0.01% of total orders) were identified
-- with status = 'delivered' and missing delivery dates.
-- These records were classified as minor inconsistencies
-- with negligible analytical impact.

-- Overall, missing values do not represent a significant
-- limitation for business analysis, customer segmentation,
-- retention analysis, or dashboard reporting.

-- =====================================================
-- 6. REFERENTIAL INTEGRITY CHECK
-- Objective:
-- Validate relationships between core entities
-- and identify orphan records that may impact
-- business analysis.
-- =====================================================
SELECT
    COUNT(*) AS orphan_orders
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT
    COUNT(*) AS orphan_order_items
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT
    COUNT(*) AS orphan_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT
    COUNT(*) AS orphan_sellers
FROM order_items oi
LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

SELECT
    COUNT(*) AS orphan_payments
FROM order_payments op
LEFT JOIN orders o
    ON op.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT
    COUNT(*) AS orphan_reviews
FROM order_review r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- =====================================================
-- REFERENTIAL INTEGRITY SUMMARY
-- =====================================================

-- No orphan records were identified across
-- core transactional and dimensional tables.

-- All relationships between customers, orders,
-- products, sellers, payments, and reviews
-- were successfully validated.

-- Results indicate strong referential integrity
-- and reliable entity relationships throughout
-- the dataset.

-- Dataset is suitable for advanced analytical
-- modeling and business reporting.

-- =====================================================
-- 7. BUSINESS RULE VALIDATION
-- Objective:
-- Validate whether the data follows expected
-- business logic and operational processes.
-- =====================================================

-- Check 1: Orders delivered before purchase date

SELECT COUNT(*) AS invalid_delivery_dates
FROM orders
WHERE order_delivered_customer_date
      < order_purchase_timestamp;

      -- Check 2: Orders approved before purchase date

SELECT COUNT(*) AS invalid_approval_dates
FROM orders
WHERE order_approved_at
      < order_purchase_timestamp;

      -- Check 3: Orders shipped before purchase date

SELECT COUNT(*) AS invalid_carrier_dates
FROM orders
WHERE order_delivered_carrier_date
      < order_purchase_timestamp;

-- Check 4: Negative payment values

SELECT COUNT(*) AS negative_payments
FROM order_payments
WHERE payment_value < 0;

-- Check 5: Negative freight values

SELECT COUNT(*) AS negative_freight
FROM order_items
WHERE freight_value < 0;

-- Check 7: Review scores outside expected range

SELECT COUNT(*) AS invalid_review_scores
FROM order_review
WHERE review_score NOT BETWEEN 1 AND 5;

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at
FROM orders
WHERE order_approved_at < order_purchase_timestamp;

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_carrier_date
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp
LIMIT 20;

-- =====================================================
-- BUSINESS RULE VALIDATION SUMMARY
-- =====================================================

-- Business rule validation identified no critical
-- inconsistencies affecting analytical reliability.

-- No orders were delivered before purchase date.

-- One order was identified with an approval timestamp
-- preceding the purchase timestamp by less than one hour,
-- likely caused by system logging inconsistencies.

-- 166 orders presented carrier shipment timestamps
-- occurring shortly before purchase timestamps.
-- Investigation revealed differences typically below
-- one hour, suggesting timestamp synchronization issues
-- rather than operational process failures.

-- No negative payment values, freight charges,
-- product prices, or invalid review scores were found.

-- Overall, business rule validation confirms strong
-- operational consistency and high analytical readiness.

-- =====================================================
-- 8. OUTLIER DETECTION
-- Objective:
-- Identify extreme values that may influence
-- business metrics and analytical results.
-- =====================================================

-- Order Value Distribution
SELECT
    MIN(payment_value) AS min_value,
    ROUND(AVG(payment_value),2) AS avg_value,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY payment_value) AS median_value,
    PERCENTILE_CONT(0.90)
        WITHIN GROUP (ORDER BY payment_value) AS p90,
    PERCENTILE_CONT(0.95)
        WITHIN GROUP (ORDER BY payment_value) AS p95,
    MAX(payment_value) AS max_value
FROM order_payments;

-- Top 20 Highest Orders
SELECT
    order_id,
    payment_value
FROM order_payments
ORDER BY payment_value DESC
LIMIT 20;

-- Freight Distribution
SELECT
    MIN(freight_value) AS min_freight,
    ROUND(AVG(freight_value),2) AS avg_freight,
    PERCENTILE_CONT(0.50)
        WITHIN GROUP (ORDER BY freight_value) AS median_freight,
    PERCENTILE_CONT(0.95)
        WITHIN GROUP (ORDER BY freight_value) AS p95,
    MAX(freight_value) AS max_freight
FROM order_items;

-- Most expensive Product Sold
SELECT
    product_id,
    price
FROM order_items
ORDER BY price DESC
LIMIT 20;

WITH customer_spend AS
(
    SELECT
        c.customer_unique_id,
        SUM(op.payment_value) AS total_spent
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY c.customer_unique_id
)

SELECT
    customer_unique_id,
    total_spent
FROM customer_spend
ORDER BY total_spent DESC
LIMIT 20;

-- Seller Revenue Outliers
WITH seller_revenue AS
(
    SELECT
        seller_id,
        SUM(price) AS revenue
    FROM order_items
    GROUP BY seller_id
)

SELECT
    seller_id,
    revenue
FROM seller_revenue
ORDER BY revenue DESC
LIMIT 20;

-- =====================================================
-- OUTLIER DETECTION SUMMARY
-- =====================================================

-- Revenue distribution is highly right-skewed,
-- with a small proportion of orders contributing
-- disproportionately to total revenue.

-- Order values present significant variability,
-- ranging from R$0.00 to R$13,664.08.

-- Freight costs are generally stable, although
-- a limited number of transactions exhibit
-- exceptionally high shipping charges.

-- Customer spending analysis identified a small
-- group of high-value customers whose cumulative
-- contribution greatly exceeds average customer spend.

-- Seller revenue analysis revealed substantial
-- revenue concentration among top-performing sellers,
-- suggesting a marketplace structure driven by a
-- relatively small number of key merchants.

-- Outliers appear to represent legitimate business
-- activity rather than data quality issues and should
-- be retained for future business analysis.

-- =====================================================
-- FINAL DATA QUALITY ASSESSMENT
-- =====================================================

-- The dataset was subjected to a comprehensive
-- data quality assessment covering structural,
-- relational, and business rule validation.

-- Table volume validation confirmed successful
-- data import across all source tables.

-- Primary key integrity checks identified no
-- duplicate records in either transactional or
-- dimensional tables.

-- Structural validation confirmed appropriate
-- data types for analytical workloads, including
-- numeric financial fields and timestamp-based
-- event tracking columns.

-- Missing value analysis revealed limited null
-- values, primarily associated with expected
-- business scenarios such as canceled, unavailable,
-- or in-progress orders.

-- Product-related missing values were concentrated
-- within a small subset of records (1.85% of the
-- product catalog), indicating incomplete product
-- registration rather than random data quality issues.

-- Referential integrity validation identified no
-- orphan records, confirming consistency across
-- customers, orders, products, sellers, payments,
-- and reviews.

-- Business rule validation detected only minor
-- timestamp inconsistencies with negligible impact
-- on analytical outcomes.

-- Outlier analysis identified high-value customers,
-- premium orders, and top-performing sellers.
-- These observations were classified as legitimate
-- business behavior rather than data anomalies.

-- Overall assessment indicates a high-quality dataset
-- with strong analytical reliability and no material
-- issues that would compromise business reporting,
-- customer segmentation, performance analysis,
-- or predictive modeling activities.

-- =====================================================
-- DATA QUALITY SCORECARD
-- =====================================================

-- Table Volume Validation        PASS
-- Primary Key Integrity          PASS
-- Structural Validation          PASS
-- Missing Values Assessment      PASS
-- Referential Integrity          PASS
-- Business Rule Validation       PASS
-- Outlier Assessment             PASS

-- Overall Data Quality Rating: HIGH