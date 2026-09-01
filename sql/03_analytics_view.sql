-- =====================================================
-- 03_ANALYTICS_VIEWS.SQL
-- =====================================================
-- Project: Olist E-commerce Analytics
--
-- Objective:
-- Create a dimensional model (Star Schema)
-- optimized for Business Intelligence reporting
-- and Power BI visualization.
--
-- Methodology:
-- Fact & Dimension Modeling
--
-- Views Included:
-- 1. fact_sales
-- 2. dim_customers
-- 3. dim_products
-- 4. dim_sellers
-- 5. dim_payments
--
-- Granularity
-- fact_sales:
-- One row = One order item
-- =====================================================

-- =====================================================
-- VIEW 1 - FACT SALES
-- =====================================================
-- Granularity:
-- One row = One product sold in one order
-- =====================================================

DROP VIEW IF EXISTS fact_sales;

CREATE VIEW fact_sales AS

SELECT

    -- Order Keys
    o.order_id,
    oi.order_item_id,

    -- Dimension Keys
    o.customer_id,
    oi.product_id,
    oi.seller_id,

    -- Order Information
o.order_purchase_timestamp,
DATE(o.order_purchase_timestamp) AS order_date,
o.order_status,

    -- Sales Measures
    oi.price,
    oi.freight_value,

    -- Operational KPI
    (
        o.order_delivered_customer_date::date
        -
        o.order_purchase_timestamp::date
    ) AS delivery_days

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id;

-- =====================================================
-- VIEW 2 - DIM CUSTOMERS
-- =====================================================
-- One row = One customer
-- =====================================================

CREATE OR REPLACE VIEW dim_customers AS

SELECT

    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state

FROM customers;


-- =====================================================
-- VIEW 3 - DIM PRODUCTS
-- =====================================================
-- One row = One product
-- =====================================================

CREATE OR REPLACE VIEW dim_products AS

SELECT

    p.product_id,

    COALESCE(p.product_category_name, 'Unknown') AS product_category,

    p.product_name_length,
    p.product_description_length,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm

FROM products p;

SELECT
    COUNT(*) AS orphan_product_rows
FROM fact_sales f
LEFT JOIN dim_products p
    ON f.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT
    COUNT(*) AS null_categories
FROM dim_products
WHERE product_category IS NULL;

-- =====================================================
-- VIEW 4 - DIM SELLERS
-- =====================================================

CREATE OR REPLACE VIEW dim_sellers AS

SELECT

    seller_id,

    seller_zip_code_prefix,

    seller_city,

    seller_state

FROM sellers;

SELECT COUNT(*) FROM fact_sales;

SELECT COUNT(*) FROM dim_customers;

SELECT COUNT(*) FROM dim_products;

SELECT COUNT(*) FROM dim_sellers;

SELECT *
FROM fact_sales
LIMIT 5;

SELECT *
FROM dim_customers
LIMIT 5;

SELECT *
FROM dim_products
LIMIT 5;

SELECT *
FROM dim_sellers
LIMIT 5;


-- =====================================================
-- VIEW 5 - DIM DATE
-- =====================================================

CREATE OR REPLACE VIEW dim_date AS

SELECT DISTINCT

    DATE(o.order_purchase_timestamp) AS date,

    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS year,

    EXTRACT(QUARTER FROM o.order_purchase_timestamp) AS quarter,

    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_number,

    TO_CHAR(o.order_purchase_timestamp,'YYYY-MM') AS year_month,

    TO_CHAR(o.order_purchase_timestamp,'YYYYMM')::INT AS year_month_key,

    TO_CHAR(o.order_purchase_timestamp, 'Month') AS month_name,

    TO_CHAR(o.order_purchase_timestamp, 'Mon') AS month_short,

    EXTRACT(WEEK FROM o.order_purchase_timestamp) AS week,

    EXTRACT(DAY FROM o.order_purchase_timestamp) AS day,

    TO_CHAR(o.order_purchase_timestamp, 'Day') AS weekday_name,

    EXTRACT(ISODOW FROM o.order_purchase_timestamp) AS weekday_number,

    CASE
        WHEN EXTRACT(ISODOW FROM o.order_purchase_timestamp) IN (6,7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type

FROM orders o

ORDER BY date;

SELECT COUNT(*)
FROM dim_date;

SELECT *
FROM dim_date
LIMIT 10;

SELECT COUNT(*) FROM fact_sales;
SELECT COUNT(*) FROM dim_date;

SELECT *
FROM fact_sales
LIMIT 5;

