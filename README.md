# Northwind Retail Analytics

A retail/e-commerce sales analytics project built on a star-schema data
warehouse, with the same core analysis implemented natively in three BI
platforms: **Power BI**, **Looker (LookML) / Looker Studio**, and
**Tableau**.

## Overview

The dataset models two years (2024–2025) of retail sales for a
multi-channel company selling across web, mobile, marketplace, retail
store, and wholesale channels. The analysis answers four standard
business questions:

- What are the headline KPIs (revenue, profit, orders, AOV, return rate)?
- How is revenue trending over time, and how does it compare year over year?
- How does performance break down by product category, customer segment,
  and channel?
- Which specific products are driving revenue, and how does that change
  when you drill from category → subcategory → product?

Each platform implements the same four views — **KPI Summary**, **Trend
Analysis**, **Category/Segment Breakdown**, and **Product Drill-Down** —
against the same underlying data model, using that platform's own
calculation syntax (DAX, LookML, and Tableau calculated fields/LOD
expressions respectively).

## Tech stack

| Layer | Tool |
|---|---|
| Data modeling / warehouse | Star schema, SQL (PostgreSQL + SQLite variants) |
| Dashboard 1 | Power BI (DAX) |
| Dashboard 2 | Looker / Looker Studio (LookML) |
| Dashboard 3 | Tableau (calculated fields, LOD expressions) |
| Data generation | Python |

## Data model

Star schema: one fact table, five dimensions.

- **`fact_sales`** — 77,495 line items across 45,000 orders. Grain: one
  row per product line item per order.
- **`dim_date`** — 731 days (2024-01-01 to 2025-12-31)
- **`dim_customer`** — 3,000 customers (segment, loyalty tier, signup date)
- **`dim_product`** — 385 SKUs across 6 categories / 24 subcategories
- **`dim_geography`** — 34 US states + Canadian provinces
- **`dim_channel`** — 5 sales channels (web, mobile app, marketplace,
  retail store, wholesale)

Full ER diagram and column-level schema: [`data_model_design.md`](./data_model_design.md).

## Key findings

Pulled directly from the SQL layer (`sql/03_validation_and_kpi_queries.sql`)
and used as the reconciliation baseline for all three dashboards:

- **Holiday season lift:** average daily net revenue during the Nov 20–Dec
  24 window is ~85% higher than the yearly baseline.
- **Category mix:** Apparel is the top-performing category at 23.7% of
  total net revenue, followed by Electronics (19.6%) and Home & Kitchen (17.0%).
- **Channel performance:** the website channel drives the largest share of
  revenue, with average order value fairly consistent (~$715–$730) across
  all five channels — channel choice affects volume more than basket size.

## Repository structure

```
northwind-retail-analytics/
├── README.md
├── data_model_design.md            ← ER diagram + schema design rationale
├── dashboard_panel_specs.md        ← panel-by-panel layout spec, shared by all 3 tools
├── build_plan_5_day.md             ← daily build milestones
├── resume_bullets.md
├── data/
│   ├── dim_date.csv
│   ├── dim_customer.csv
│   ├── dim_product.csv
│   ├── dim_geography.csv
│   ├── dim_channel.csv
│   ├── fact_sales.csv
│   └── retail_dw.db                ← pre-built SQLite DB (schema + data loaded)
├── sql/
│   ├── 01_create_schema.sql        ← PostgreSQL DDL
│   ├── 01b_create_schema_sqlite.sql← SQLite DDL (matches retail_dw.db)
│   ├── 02_load_postgres.sql        ← \copy load script
│   └── 03_validation_and_kpi_queries.sql
├── powerbi/
│   ├── DAX_measures.md
│   └── BUILD_INSTRUCTIONS.md
├── looker/
│   ├── views/*.view.lkml
│   ├── explores/retail_analytics.explore.lkml
│   ├── models/retail_dw.model.lkml
│   ├── calculated_fields.md        ← Looker Studio formula syntax (no-LookML path)
│   └── BUILD_INSTRUCTIONS.md
├── tableau/
│   ├── calculated_fields.md
│   └── BUILD_INSTRUCTIONS.md
└── screenshots/
    ├── powerbi/
    ├── looker/
    └── tableau/
```

## Setup / how to run

1. Clone or download this repo.
2. The data is ready to query as-is — open `data/retail_dw.db` with any
   SQLite client, or load the CSVs in `data/` directly into a tool of
   your choice.
3. To rebuild the warehouse from scratch: run `sql/01_create_schema.sql`
   (or the SQLite variant `01b_create_schema_sqlite.sql`), then load the
   CSVs via `sql/02_load_postgres.sql` or the equivalent import.
4. Run `sql/03_validation_and_kpi_queries.sql` to get ground-truth KPI
   numbers — use these to sanity-check each dashboard as it's built.
5. Follow `powerbi/BUILD_INSTRUCTIONS.md`, `looker/BUILD_INSTRUCTIONS.md`,
   and `tableau/BUILD_INSTRUCTIONS.md` to build each dashboard. All three
   implement the same four views specified panel-by-panel in
   `dashboard_panel_specs.md`.

## Tool comparison

| | **Power BI** | **Looker (LookML)** | **Tableau** |
|---|---|---|---|
| **Data modeling** | Relationships + DAX measure table live in one file | LookML is version-controlled and git-backed, one reusable semantic layer across every downstream report | Modern Relationship model (2020.2+) handles star schemas correctly; calculations live per-workbook |
| **Calculation syntax** | DAX — powerful, real learning curve around filter/row context | LookML — SQL-adjacent, measures reusable across every Explore | Calculated fields + LOD expressions (`FIXED`/`INCLUDE`/`EXCLUDE`) |
| **Interactivity** | Native drill-through, bookmarks, field parameters | Looker dashboards support drill fields; Looker Studio filters are simpler | Dashboard actions (filter/highlight/URL) |
| **Visual polish** | Good, some layout constraints | Looker Studio: fast and presentable; full Looker: functional, less flexible | Most granular control over visual design |
| **Cost to publish** | Free (Power BI Desktop + free workspace) | LookML needs a paid Looker instance; Looker Studio is free | Free via Tableau Public |

## Notes on the data model

`dim_customer` is modeled as Type-1 SCD (overwrite on change, no history)
for simplicity — see `data_model_design.md` for the tradeoff this makes
versus a Type-2 design.

## Screenshots

Dashboard screenshots and GIFs go in `screenshots/<tool>/`, named
`01_kpi_summary.png`, `02_trends.png`, `03_breakdown.png`,
`04_drilldown.png` per the convention in `dashboard_panel_specs.md`.
*(Placeholders until each dashboard is built and published.)*
