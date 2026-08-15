# Tableau — Build & Publish Instructions

## 1. Connect the data source

1. Open Tableau Desktop (or Tableau Public — free, and the easiest way to
   get a **live public link** for a portfolio) → `Connect` → `Text File`
   and select `data/fact_sales.csv`, **or** connect to `data/retail_dw.db`
   via the SQLite connector if you have one installed, **or** connect to a
   Postgres instance loaded with `sql/02_load_postgres.sql`.
2. On the Data Source canvas, drag in all 5 dimension tables and build the
   **relationships** (not old-style left joins — use Tableau's modern
   Relationship model introduced in 2020.2+, which correctly preserves
   the star-schema grain and avoids fan-out/duplicate aggregation):
   - `fact_sales.date_key` ↔ `dim_date.date_key`
   - `fact_sales.customer_key` ↔ `dim_customer.customer_key`
   - `fact_sales.product_key` ↔ `dim_product.product_key`
   - `fact_sales.geography_key` ↔ `dim_geography.geography_key`
   - `fact_sales.channel_key` ↔ `dim_channel.channel_key`
   - `dim_customer.geography_key` ↔ `dim_geography.geography_key`
3. Add a data-source filter: `order_status <> "Cancelled"`.
4. Rename the connection "Northwind Retail Analytics."

## 2. Build calculated fields

Add every field from `calculated_fields.md`, including the `Metric
Selector` parameter.

## 3. Build the 4 worksheets → 1 dashboard set (see `/dashboard_panel_specs.md`)

Build one worksheet per panel, then assemble into 4 **dashboards** (Tableau's
term for a canvas of worksheets) that mirror the other two tools:

1. **KPI Summary** — 5 single-value "BAN" (Big Ass Number) worksheets using
   `Text` marks sized large, arranged in a horizontal container.
2. **Trends** — a line chart (`full_date` on Columns at Month granularity,
   `Selected Metric` on Rows), with the `Metric Selector` parameter control
   shown, plus a second line for the prior-year comparison.
3. **Breakdown** — a highlight table or heat map (Category × Segment,
   color-encoded by Gross Margin %) and a horizontal bar chart of channel
   performance.
4. **Product Drill-Down** — a bar chart of Category, with **Category →
   Subcategory → Product** added as hierarchy fields so users can click
   `+` to drill down natively; add this to a filter action that updates a
   detail table alongside it.

## 4. Add interactivity

- Add **Dashboard Actions** (`Dashboard` → `Actions`): a Filter action from
  the Category bar chart to the Product detail table (click-to-drill), and
  a Highlight action across all 4 dashboards using a global Region filter
  set to "Apply to all sheets using this data source."
- Add filter controls for Year, Channel, and Region as quick filters, and
  set them to apply to all 4 dashboards via **Filters** → `Apply to
  Worksheets` → `All Using This Data Source`.

## 5. Layout polish

- Use a consistent 1600×900 dashboard size across all 4.
- Add a title banner worksheet at the top of each dashboard with the
  Northwind Retail Analytics logo/wordmark and page name.
- Keep to Tableau's recommended max of 5–7 marks per dashboard so it stays
  recruiter-scannable, not a cluttered "kitchen sink" dump.

## 6. Publish

1. `Server` → `Tableau Public` → `Save to Tableau Public As...` (free,
   fully public link — ideal for a resume/portfolio) **or** publish to
   Tableau Server/Cloud if you have access.
2. Copy the public workbook URL for your resume/LinkedIn/portfolio site.
3. Screenshot each of the 4 dashboards for `/screenshots`.
4. Record a short GIF of the Category → Product drill-down action.

## What to save here

`northwind_retail_analytics.twbx` — the packaged Tableau workbook (built
locally in Tableau Desktop/Public, since .twbx files must be created by
the Tableau application itself).
