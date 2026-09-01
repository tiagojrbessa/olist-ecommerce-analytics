-- =====================================================
-- BUSINESS ANALYSIS
-- Project: Olist E-commerce Analytics
-- Author: Tiago Bessa
-- Objective:
-- Analyze business performance, revenue drivers,
-- customer behavior, and operational metrics.
-- =====================================================

-- =====================================================
-- 1. EXECUTIVE KPI OVERVIEW
-- =====================================================

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    ROUND(SUM(op.payment_value),2) AS total_revenue,
    ROUND(
        SUM(op.payment_value)
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
JOIN order_payments op
    ON o.order_id = op.order_id;

    -- =====================================================
-- 2. MONTHLY REVENUE TREND
-- =====================================================

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
    ROUND(SUM(op.payment_value),2) AS revenue
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id
GROUP BY 1
ORDER BY 1;

    -- =====================================================
-- 3. ORDER STATUS DISTRIBUTION
-- =====================================================
SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) * 100.0
        /
        SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- =====================================================
-- BUSINESS INSIGHT
-- =====================================================

-- Approximately 97% of all orders were successfully
-- delivered, indicating strong operational execution
-- across the marketplace.

-- Cancellation and product unavailability rates
-- remain below 1%, suggesting efficient inventory
-- management and order fulfillment processes.

-- The business generated more than R$16 million
-- in revenue from approximately 99 thousand orders,
-- with an average order value of R$160.99.

-- Customer volume is very close to order volume,
-- indicating potentially low purchase frequency and
-- highlighting customer retention as a key area
-- for future investigation.

-- =====================================================
-- 4. REVENUE ANALYSIS
-- =====================================================

WITH monthly_revenue AS
(
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        SUM(op.payment_value) AS revenue
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY 1
)

SELECT
    month,
    ROUND(revenue,2) AS revenue,
    ROUND(
        LAG(revenue) OVER(ORDER BY month),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            revenue -
            LAG(revenue) OVER(ORDER BY month)
        )
        /
        NULLIF(
            LAG(revenue) OVER(ORDER BY month),
            0
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_revenue
ORDER BY month;

WITH monthly_revenue AS
(
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
        SUM(op.payment_value) AS revenue
    FROM orders o
    JOIN order_payments op
        ON o.order_id = op.order_id
    GROUP BY 1
)

SELECT
    month,
    ROUND(revenue,2) AS revenue,
    ROUND(
        LAG(revenue) OVER(ORDER BY month),
        2
    ) AS previous_month_revenue,
    ROUND(
        (
            revenue -
            LAG(revenue) OVER(ORDER BY month)
        )
        /
        NULLIF(
            LAG(revenue) OVER(ORDER BY month),
            0
        ) * 100,
        2
    ) AS revenue_growth_pct
FROM monthly_revenue
WHERE month BETWEEN '2017-01-01' AND '2018-08-01'
ORDER BY month;

-- =====================================================
-- BUSINESS INSIGHT
-- =====================================================

-- Monthly revenue analysis reveals strong and
-- sustained marketplace growth throughout 2017.

-- Revenue increased from approximately R$138k
-- in January 2017 to more than R$674k by August,
-- representing significant business expansion.

-- A major revenue peak occurred in November 2017,
-- likely associated with Black Friday and seasonal
-- holiday shopping behavior.

-- During 2018, monthly revenue stabilized above
-- R$1 million, indicating marketplace maturity
-- and operational scalability.

-- Partial months at the beginning and end of the
-- dataset were excluded from trend interpretation
-- to avoid misleading conclusions.

-- =====================================================
-- 5. PRODUCT CATEGORY REVENUE ANALYSIS
-- =====================================================

SELECT
    COALESCE(
        pcn.product_category_name_english,
        'Unknown'
    ) AS category,
    
    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    COUNT(DISTINCT oi.order_id) AS total_orders

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name pcn
    ON p.product_category_name =
       pcn.product_category_name

GROUP BY 1

ORDER BY revenue DESC;

SELECT
    COALESCE(
        pcn.product_category_name_english,
        'Unknown'
    ) AS category,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name pcn
    ON p.product_category_name =
       pcn.product_category_name

GROUP BY 1

ORDER BY revenue DESC

LIMIT 10;

WITH category_revenue AS
(
    SELECT
        COALESCE(
            pcn.product_category_name_english,
            'Unknown'
        ) AS category,

        SUM(oi.price) AS revenue

    FROM order_items oi

    JOIN products p
        ON oi.product_id = p.product_id

    LEFT JOIN product_category_name pcn
        ON p.product_category_name =
           pcn.product_category_name

    GROUP BY 1
)

SELECT
    category,

    ROUND(revenue,2) AS revenue,

    ROUND(
        revenue
        /
        SUM(revenue) OVER()
        * 100,
        2
    ) AS revenue_pct

FROM category_revenue

ORDER BY revenue DESC;

-- =====================================================
-- BUSINESS INSIGHT
-- =====================================================

-- Revenue is distributed across multiple product
-- categories, reducing dependency on a single
-- business segment.

-- Health & Beauty represents the largest revenue
-- contributor, generating approximately 9.3% of
-- total marketplace revenue.

-- Lifestyle-oriented categories such as Health &
-- Beauty, Watches & Gifts, Bed Bath & Table, and
-- Sports & Leisure dominate marketplace sales,
-- indicating strong consumer demand in these areas.

-- Bed Bath & Table generates high revenue through
-- large order volume, while Watches & Gifts achieves
-- similar revenue levels with fewer transactions,
-- suggesting a higher average order value.

-- Product category diversification appears to be
-- a key strength of the marketplace business model.

-- =====================================================
-- 6. CATEGORY PROFITABILITY ANALYSIS
-- =====================================================

SELECT
    COALESCE(
        pcn.product_category_name_english,
        'Unknown'
    ) AS category,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    ROUND(
        SUM(oi.price),
        2
    ) AS revenue,

    ROUND(
        SUM(oi.price)
        /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value

FROM order_items oi

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN product_category_name pcn
    ON p.product_category_name =
       pcn.product_category_name

GROUP BY 1

HAVING COUNT(DISTINCT oi.order_id) >= 100

ORDER BY average_order_value DESC;

-- =====================================================
-- BUSINESS INSIGHT
-- =====================================================

-- Average Order Value analysis reveals significant
-- differences across product categories.

-- Computers is the highest-value category, with an
-- average order value exceeding R$1,200, almost
-- eight times higher than the marketplace average.

-- While categories such as Health & Beauty and
-- Bed Bath & Table drive revenue through volume,
-- premium categories generate higher revenue per
-- transaction.

-- Watches & Gifts stands out as a strategic category,
-- combining both strong revenue generation and an
-- above-average order value.

-- The marketplace appears to benefit from a balanced
-- mix of high-volume and high-ticket categories.

-- =====================================================
-- 7. CUSTOMER GEOGRAPHIC ANALYSIS
-- Revenue by State
-- =====================================================

SELECT
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS total_customers,

    ROUND(
        SUM(op.payment_value),
        2
    ) AS total_revenue

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_payments op
    ON o.order_id = op.order_id

GROUP BY 1

ORDER BY total_revenue DESC;

SELECT
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(op.payment_value),
        2
    ) AS revenue,

    ROUND(
        SUM(op.payment_value)
        /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN order_payments op
    ON o.order_id = op.order_id

GROUP BY 1

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY average_order_value DESC;

WITH state_revenue AS
(
    SELECT
        c.customer_state,

        SUM(op.payment_value) AS revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    GROUP BY 1
)

SELECT
    customer_state,

    ROUND(revenue,2) AS revenue,

    ROUND(
        revenue
        /
        SUM(revenue) OVER()
        * 100,
        2
    ) AS revenue_pct

FROM state_revenue

ORDER BY revenue DESC;

-- =====================================================
-- BUSINESS INSIGHT
-- =====================================================

-- Revenue is heavily concentrated in São Paulo,
-- which alone contributes approximately 37.5%
-- of total marketplace revenue.

-- The three largest states (SP, RJ and MG)
-- account for more than 60% of all revenue,
-- indicating strong geographic concentration.

-- While São Paulo dominates in volume,
-- several smaller states such as Paraíba (PB),
-- Rondônia (RO) and Alagoas (AL) exhibit
-- significantly higher Average Order Values.

-- These regions may represent attractive
-- expansion opportunities for premium
-- product categories and targeted marketing
-- campaigns.

-- Geographic diversification could reduce
-- revenue concentration risk while supporting
-- future marketplace growth.

-- =====================================================
-- 8. CUSTOMER SEGMENTATION (RFM)
-- =====================================================
-- Objective:
-- Segment customers based on:
-- R = Recency
-- F = Frequency
-- M = Monetary Value

WITH customer_metrics AS
(
    SELECT

        c.customer_unique_id,

        DATE_PART(
            'day',
            (
                SELECT MAX(order_purchase_timestamp)
                FROM orders
            ) - MAX(o.order_purchase_timestamp)
        ) AS recency_days,

        COUNT(DISTINCT o.order_id) AS frequency,

        ROUND(
            SUM(op.payment_value),
            2
        ) AS monetary

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
),

rfm_scores AS
(
    SELECT

        customer_unique_id,

        recency_days,

        frequency,

        monetary,

        NTILE(5) OVER
        (
            ORDER BY recency_days ASC
        ) AS recency_bucket,

        NTILE(5) OVER
        (
            ORDER BY frequency DESC
        ) AS frequency_score,

        NTILE(5) OVER
        (
            ORDER BY monetary DESC
        ) AS monetary_score

    FROM customer_metrics
)

SELECT

    customer_unique_id,

    recency_days,

    frequency,

    monetary,

    6 - recency_bucket AS recency_score,

    frequency_score,

    monetary_score,

    CONCAT(
        6 - recency_bucket,
        frequency_score,
        monetary_score
    ) AS rfm_segment

FROM rfm_scores

ORDER BY monetary DESC;

-- =====================================================
-- 8.1 CUSTOMER SEGMENTATION
-- =====================================================
-- Objective:
-- Classify customers into business-friendly
-- marketing segments based on RFM scores.

WITH customer_metrics AS
(
    SELECT

        c.customer_unique_id,

        DATE_PART(
            'day',
            (
                SELECT MAX(order_purchase_timestamp)
                FROM orders
            ) - MAX(o.order_purchase_timestamp)
        ) AS recency_days,

        COUNT(DISTINCT o.order_id) AS frequency,

        ROUND(
            SUM(op.payment_value),
            2
        ) AS monetary

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
),

rfm_scores AS
(
    SELECT

        customer_unique_id,

        6 - NTILE(5) OVER (ORDER BY recency_days ASC) AS r,

        NTILE(5) OVER (ORDER BY frequency DESC) AS f,

        NTILE(5) OVER (ORDER BY monetary DESC) AS m

    FROM customer_metrics
)

SELECT

    CASE

        WHEN r >= 4 AND f >= 4 AND m >= 4
            THEN 'Champions'

        WHEN r >= 3 AND f >= 4
            THEN 'Loyal Customers'

        WHEN r >= 4 AND f >= 2
            THEN 'Potential Loyalists'

        WHEN r = 5 AND f = 1
            THEN 'New Customers'

        WHEN r <= 2 AND f >= 3
            THEN 'At Risk'

        WHEN r = 1 AND f <= 2
            THEN 'Lost Customers'

        ELSE 'Others'

    END AS customer_segment,

    COUNT(*) AS total_customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM rfm_scores

GROUP BY customer_segment

ORDER BY total_customers DESC;

-- =====================================================
-- Business Insights
-- =====================================================

-- Around 47% of customers fall into either
-- "At Risk" or "Lost Customers", suggesting that
-- customer retention represents a major business opportunity.

-- Loyal Customers account for over 23% of the customer base,
-- providing a strong foundation for loyalty and upselling campaigns.

-- Champions represent less than 1% of customers,
-- highlighting a small but highly valuable customer segment
-- that should receive personalized marketing efforts.

-- Potential Loyalists account for approximately 16%,
-- indicating significant opportunity to increase repeat purchases
-- through targeted engagement strategies.

-- =====================================================
-- 9. CUSTOMER LIFETIME VALUE (CLV)
-- =====================================================

WITH customer_clv AS
(
    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(
            SUM(op.payment_value),
            2
        ) AS lifetime_revenue,

        ROUND(
            AVG(op.payment_value),
            2
        ) AS average_order_value

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
)

SELECT

    COUNT(*) AS total_customers,

    ROUND(
        AVG(lifetime_revenue),
        2
    ) AS average_customer_lifetime_value,

    ROUND(
        AVG(total_orders),
        2
    ) AS average_orders_per_customer,

    ROUND(
        AVG(average_order_value),
        2
    ) AS average_order_value

FROM customer_clv;

WITH customer_clv AS
(
    SELECT

        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        ROUND(
            SUM(op.payment_value),
            2
        ) AS lifetime_revenue,

        ROUND(
            AVG(op.payment_value),
            2
        ) AS average_order_value

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
)

SELECT *

FROM customer_clv

ORDER BY lifetime_revenue DESC

LIMIT 20;

WITH customer_clv AS
(
    SELECT

        c.customer_unique_id,

        ROUND(
            SUM(op.payment_value),
            2
        ) AS lifetime_revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN order_payments op
        ON o.order_id = op.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY c.customer_unique_id
)

SELECT

    CASE

        WHEN lifetime_revenue < 100
            THEN 'Below R$100'

        WHEN lifetime_revenue < 500
            THEN 'R$100 - R$500'

        WHEN lifetime_revenue < 1000
            THEN 'R$500 - R$1,000'

        WHEN lifetime_revenue < 5000
            THEN 'R$1,000 - R$5,000'

        ELSE 'Above R$5,000'

    END AS customer_value_segment,

    COUNT(*) AS customers,

    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage

FROM customer_clv

GROUP BY 1

ORDER BY customers DESC;

-- =====================================================
-- Business Insights
-- =====================================================

-- The average customer lifetime value is R$165.20,
-- with customers placing only 1.03 orders on average,
-- indicating that most customers purchase only once.

-- Nearly 95% of customers generated less than R$500
-- in lifetime revenue, highlighting a strong dependence
-- on one-time purchases.

-- Less than 1.3% of customers generated more than R$1,000
-- in lifetime revenue, representing the highest-value
-- customer segment.

-- A very small number of customers contribute
-- disproportionately to total revenue, suggesting that
-- customer retention and loyalty programs could
-- significantly improve long-term profitability.