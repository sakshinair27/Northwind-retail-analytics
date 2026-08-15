-- =============================================================================
-- Northwind Retail Analytics — Star Schema DDL
-- Target: PostgreSQL (also valid, with minor type tweaks, in Snowflake/BigQuery)
-- A SQLite-compatible version is in 01b_create_schema_sqlite.sql
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS retail_dw;
SET search_path TO retail_dw;

-- -----------------------------------------------------------------------------
-- DIMENSION: dim_date
-- -----------------------------------------------------------------------------
CREATE TABLE dim_date (
    date_key            INT PRIMARY KEY,          -- YYYYMMDD surrogate key
    full_date            DATE NOT NULL,
    day_of_week          VARCHAR(10),
    day_num_in_week      SMALLINT,
    day_num_in_month     SMALLINT,
    day_num_in_year      SMALLINT,
    week_of_year         SMALLINT,
    month_num            SMALLINT,
    month_name           VARCHAR(10),
    month_year            VARCHAR(10),
    quarter               VARCHAR(2),
    year                  SMALLINT,
    is_weekend            BOOLEAN,
    is_holiday_season     BOOLEAN
);

-- -----------------------------------------------------------------------------
-- DIMENSION: dim_geography
-- -----------------------------------------------------------------------------
CREATE TABLE dim_geography (
    geography_key        INT PRIMARY KEY,
    country               VARCHAR(50) NOT NULL,
    region                VARCHAR(50) NOT NULL,
    state_province        VARCHAR(50) NOT NULL,
    state_code            VARCHAR(5)  NOT NULL
);

-- -----------------------------------------------------------------------------
-- DIMENSION: dim_channel
-- -----------------------------------------------------------------------------
CREATE TABLE dim_channel (
    channel_key           INT PRIMARY KEY,
    channel_name          VARCHAR(60) NOT NULL,
    channel_type          VARCHAR(20) NOT NULL      -- Digital / Physical
);

-- -----------------------------------------------------------------------------
-- DIMENSION: dim_product
-- -----------------------------------------------------------------------------
CREATE TABLE dim_product (
    product_key           INT PRIMARY KEY,
    product_name          VARCHAR(120) NOT NULL,
    category              VARCHAR(60)  NOT NULL,
    subcategory           VARCHAR(60)  NOT NULL,
    brand                 VARCHAR(60)  NOT NULL,
    unit_cost             NUMERIC(10,2) NOT NULL,
    list_price            NUMERIC(10,2) NOT NULL
);

-- -----------------------------------------------------------------------------
-- DIMENSION: dim_customer  (Type-1 SCD for this project; see README for
-- notes on how to evolve this to Type-2 if history-tracking is required)
-- -----------------------------------------------------------------------------
CREATE TABLE dim_customer (
    customer_key          INT PRIMARY KEY,
    customer_name         VARCHAR(120) NOT NULL,
    segment                VARCHAR(30) NOT NULL,     -- Consumer / Small Business / Enterprise
    loyalty_tier           VARCHAR(20) NOT NULL,     -- None / Silver / Gold / Platinum
    signup_date            DATE NOT NULL,
    geography_key          INT NOT NULL REFERENCES dim_geography(geography_key)
);

-- -----------------------------------------------------------------------------
-- FACT: fact_sales  (grain = one row per order line item)
-- -----------------------------------------------------------------------------
CREATE TABLE fact_sales (
    sales_line_key        BIGINT PRIMARY KEY,
    order_id               BIGINT NOT NULL,
    date_key                INT NOT NULL REFERENCES dim_date(date_key),
    customer_key            INT NOT NULL REFERENCES dim_customer(customer_key),
    product_key             INT NOT NULL REFERENCES dim_product(product_key),
    geography_key           INT NOT NULL REFERENCES dim_geography(geography_key),
    channel_key             INT NOT NULL REFERENCES dim_channel(channel_key),
    order_status             VARCHAR(20) NOT NULL,   -- Completed / Returned / Cancelled
    quantity                  INT NOT NULL,
    unit_price                NUMERIC(10,2) NOT NULL,
    discount_pct               NUMERIC(5,2) NOT NULL,
    discount_amount             NUMERIC(10,2) NOT NULL,
    gross_revenue                NUMERIC(12,2) NOT NULL,
    net_revenue                   NUMERIC(12,2) NOT NULL,
    total_cost                     NUMERIC(12,2) NOT NULL
);

-- -----------------------------------------------------------------------------
-- Indexes to support BI-tool query patterns (filter/group by date, product,
-- customer, geography, channel)
-- -----------------------------------------------------------------------------
CREATE INDEX idx_fact_sales_date       ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer   ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_product    ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_geography  ON fact_sales(geography_key);
CREATE INDEX idx_fact_sales_channel    ON fact_sales(channel_key);
CREATE INDEX idx_fact_sales_status     ON fact_sales(order_status);
