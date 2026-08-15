-- =============================================================================
-- Northwind Retail Analytics — Data load (PostgreSQL)
-- Run after 01_create_schema.sql. Adjust the path to wherever /data lives
-- on the machine running psql (COPY requires server-side file access; use
-- \copy from the psql client if you don't have superuser/server FS access).
-- =============================================================================

SET search_path TO retail_dw;

\copy dim_date        FROM '../data/dim_date.csv'        WITH (FORMAT csv, HEADER true);
\copy dim_geography    FROM '../data/dim_geography.csv'    WITH (FORMAT csv, HEADER true);
\copy dim_channel      FROM '../data/dim_channel.csv'      WITH (FORMAT csv, HEADER true);
\copy dim_product      FROM '../data/dim_product.csv'      WITH (FORMAT csv, HEADER true);
\copy dim_customer     FROM '../data/dim_customer.csv'     WITH (FORMAT csv, HEADER true);
\copy fact_sales       FROM '../data/fact_sales.csv'       WITH (FORMAT csv, HEADER true);

-- Sanity check row counts
SELECT 'dim_date' AS table_name, COUNT(*) FROM dim_date
UNION ALL SELECT 'dim_geography', COUNT(*) FROM dim_geography
UNION ALL SELECT 'dim_channel', COUNT(*) FROM dim_channel
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales;
