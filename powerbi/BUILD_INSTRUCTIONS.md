# Power BI — Build & Publish Instructions

## 1. Connect the data source

1. Open Power BI Desktop → `Get Data` → `Text/CSV` (fastest path) **or**
   `Get Data` → `ODBC`/`SQLite` if you built `data/retail_dw.db` (see
   `/sql/01b_create_schema_sqlite.sql`) and installed a SQLite ODBC driver.
2. Import all six files/tables: `dim_date`, `dim_geography`, `dim_channel`,
   `dim_product`, `dim_customer`, `fact_sales`.
3. In Power Query Editor, set data types explicitly (Power BI's auto-detect
   is unreliable on CSV): dates → Date, keys → Whole Number, money fields →
   Fixed Decimal Number, `is_weekend`/`is_holiday_season` → True/False.
4. `Close & Apply`.

## 2. Build the star-schema model

1. Go to **Model view**.
2. Create relationships (all single-direction, `fact_sales` = many side):
   - `fact_sales[date_key]` → `dim_date[date_key]`
   - `fact_sales[customer_key]` → `dim_customer[customer_key]`
   - `fact_sales[product_key]` → `dim_product[product_key]`
   - `fact_sales[geography_key]` → `dim_geography[geography_key]`
   - `fact_sales[channel_key]` → `dim_channel[channel_key]`
   - `dim_customer[geography_key]` → `dim_geography[geography_key]`
3. Arrange visually as a star (fact centered, dimensions radiating out) —
   this screenshot itself is portfolio-worthy; include it as
   `screenshots/powerbi_model_view.png`.
4. Mark `dim_date` as the official Date table (`full_date` column).
5. Create the `_Measures` table and add every measure from
   `DAX_measures.md`.

## 3. Build the dashboard (see `/dashboard_panel_specs.md` for the exact panel-by-panel spec — shared across all 3 tools)

Build 4 report pages: **Overview (KPI)**, **Trends**, **Category/Segment
Breakdown**, **Product Drill-Down**.

1. Set a consistent theme: `View` → `Themes` → import a clean neutral theme
   (or use the built-in "Executive" theme) so all 4 pages look cohesive.
2. Add a page-level filter pane pinned to the right: Year, Channel, Region,
   Category (these become interactive slicers).
3. On the Overview page, add **Card** visuals for the 5 headline KPI
   measures, a **Line chart** for the 24-month trend, and a **Bar chart**
   for category breakdown.
4. On the Trends page, add a line chart with `Net Revenue`, `Net Revenue PY`,
   and a **What-if parameter** or **field parameter** letting the user
   toggle between Net Revenue / Gross Profit / Units Sold as the plotted
   measure (this satisfies the "parameter" interactivity requirement).
5. On the Breakdown page, add a **matrix** visual (category × segment ×
   channel) with conditional formatting on `Gross Margin %`.
6. On the Drill-Down page, add a **table** or **decomposition tree** visual
   rooted at `Net Revenue`, broken down by Category → Subcategory →
   Product, with drill-through enabled from the Overview page's category bar
   chart (right-click → Drill through).
7. Add a bookmark-driven "Reset filters" button on each page.

## 4. Publish

1. `Home` → `Publish` → sign in to a Power BI workspace (a free Power BI
   account with "My Workspace" works for a portfolio).
2. In the Power BI Service, open the report → `File` → `Embed report` →
   copy the public/organizational link, or use `Publish to web` if you want
   a fully public, no-login link for your resume/portfolio site.
3. Take screenshots of each page at 1920×1080 for `/screenshots`.
4. Record a 15–20 second screen capture clicking through a filter and a
   drill-through for a portfolio GIF.

## 5. What to name the .pbix

`northwind_retail_analytics.pbix` — save it in this `/powerbi` folder once
built locally (Power BI Desktop is required to actually create the .pbix;
it cannot be generated outside the Windows/macOS desktop app).
