-- =============================================================================
-- Northwind Retail Analytics — Star Schema DDL (SQLite variant)
-- Use this for the fastest local path: build a single .db file that Power BI,
-- Tableau, and (via a Postgres/BigQuery re-load) Looker can all connect to.
-- =============================================================================

PRAGMA foreign_keys = ON;

CREATE TABLE dim_date (
    date_key            INTEGER PRIMARY KEY,
    full_date            TEXT NOT NULL,
    day_of_week          TEXT,
    day_num_in_week      INTEGER,
    day_num_in_month     INTEGER,
    day_num_in_year      INTEGER,
    week_of_year         INTEGER,
    month_num            INTEGER,
    month_name           TEXT,
    month_year            TEXT,
    quarter               TEXT,
    year                  INTEGER,
    is_weekend            INTEGER,   -- 0/1
    is_holiday_season     INTEGER    -- 0/1
);

CREATE TABLE dim_geography (
    geography_key        INTEGER PRIMARY KEY,
    country               TEXT NOT NULL,
    region                TEXT NOT NULL,
    state_province        TEXT NOT NULL,
    state_code            TEXT NOT NULL
);

CREATE TABLE dim_channel (
    channel_key           INTEGER PRIMARY KEY,
    channel_name          TEXT NOT NULL,
    channel_type          TEXT NOT NULL
);

CREATE TABLE dim_product (
    product_key           INTEGER PRIMARY KEY,
    product_name          TEXT NOT NULL,
    category              TEXT NOT NULL,
    subcategory           TEXT NOT NULL,
    brand                 TEXT NOT NULL,
    unit_cost             REAL NOT NULL,
    list_price            REAL NOT NULL
);

CREATE TABLE dim_customer (
    customer_key          INTEGER PRIMARY KEY,
    customer_name         TEXT NOT NULL,
    segment                TEXT NOT NULL,
    loyalty_tier           TEXT NOT NULL,
    signup_date            TEXT NOT NULL,
    geography_key          INTEGER NOT NULL REFERENCES dim_geography(geography_key)
);

CREATE TABLE fact_sales (
    sales_line_key        INTEGER PRIMARY KEY,
    order_id               INTEGER NOT NULL,
    date_key                INTEGER NOT NULL REFERENCES dim_date(date_key),
    customer_key            INTEGER NOT NULL REFERENCES dim_customer(customer_key),
    product_key             INTEGER NOT NULL REFERENCES dim_product(product_key),
    geography_key           INTEGER NOT NULL REFERENCES dim_geography(geography_key),
    channel_key             INTEGER NOT NULL REFERENCES dim_channel(channel_key),
    order_status             TEXT NOT NULL,
    quantity                  INTEGER NOT NULL,
    unit_price                REAL NOT NULL,
    discount_pct               REAL NOT NULL,
    discount_amount             REAL NOT NULL,
    gross_revenue                REAL NOT NULL,
    net_revenue                   REAL NOT NULL,
    total_cost                     REAL NOT NULL
);

CREATE INDEX idx_fact_sales_date       ON fact_sales(date_key);
CREATE INDEX idx_fact_sales_customer   ON fact_sales(customer_key);
CREATE INDEX idx_fact_sales_product    ON fact_sales(product_key);
CREATE INDEX idx_fact_sales_geography  ON fact_sales(geography_key);
CREATE INDEX idx_fact_sales_channel    ON fact_sales(channel_key);

-- Load with the SQLite CLI, e.g.:
--   sqlite3 retail_dw.db < 01b_create_schema_sqlite.sql
--   sqlite3 retail_dw.db
--   .mode csv
--   .import --skip 1 ../data/dim_date.csv dim_date
--   .import --skip 1 ../data/dim_geography.csv dim_geography
--   .import --skip 1 ../data/dim_channel.csv dim_channel
--   .import --skip 1 ../data/dim_product.csv dim_product
--   .import --skip 1 ../data/dim_customer.csv dim_customer
--   .import --skip 1 ../data/fact_sales.csv fact_sales
