# Looker / Looker Studio — Build & Publish Instructions

## Important distinction (say this correctly in interviews)

"Looker" and "Looker Studio" are two different Google products:

- **Looker** (formerly Looker BI/Looker on GCP) is the enterprise semantic-
  layer tool that uses **LookML** — the `.view.lkml` / `.explore.lkml` /
  `.model.lkml` files in this folder. It requires a paid Looker instance
  connected to a warehouse (BigQuery, Snowflake, Postgres, etc.).
- **Looker Studio** (formerly Google Data Studio) is the **free**, no-code
  reporting tool. It does not use LookML — it connects directly to a data
  source (Google Sheets, BigQuery, a CSV via Sheets, or a Postgres
  connector) and builds calculated fields with its own formula syntax.

Because a full Looker instance isn't free, this project gives you **both
paths** so you can publish something live regardless of budget:

- **Path A (LookML / "real" Looker)** — use if you have trial/enterprise
  Looker access. Demonstrates the deeper semantic-modeling skill.
- **Path B (Looker Studio, free, recommended for a portfolio you need
  live today)** — publishes a public shareable link in ~30 minutes.

## Path A — Looker (LookML)

1. Load `data/retail_dw.db` (or the CSVs via `sql/02_load_postgres.sql`)
   into a warehouse your Looker instance can connect to (BigQuery is the
   most common free-tier option: create a dataset, load the 6 tables).
2. In the Looker IDE, create a new LookML project and copy in:
   - `looker/views/*.view.lkml`
   - `looker/explores/retail_analytics.explore.lkml`
   - `looker/models/retail_dw.model.lkml`
3. Update `connection: "retail_dw_connection"` in the model file to match
   your actual Looker connection name.
4. Validate LookML (`Validate LookML` button) and commit/deploy to
   production.
5. Open the `retail_analytics` Explore and build 4 Looks (saved queries):
   **KPI Summary**, **Revenue Trend**, **Category/Segment Breakdown**,
   **Product Drill-Down** — matching `/dashboard_panel_specs.md`.
6. Assemble the 4 Looks into one **Looker Dashboard**, add dashboard
   filters (Date, Channel, Region, Category) that cascade to all tiles.
7. Publish/share the dashboard link.

## Path B — Looker Studio (free, no LookML)

1. Load the star schema into Google Sheets (import the 6 CSVs as separate
   sheets) or, better, into a free-tier BigQuery dataset.
2. Go to **lookerstudio.google.com** → `Create` → `Report` → connect the
   `fact_sales` source, then add the 5 dimension sources and **blend
   data** on the matching key columns (Looker Studio's equivalent of the
   star-schema joins) — or, simpler, pre-join everything into one flat
   view using `sql/03_validation_and_kpi_queries.sql` as a starting point
   and connect Looker Studio to that single view.
3. Add **calculated fields** (Looker Studio's tool-specific syntax,
   equivalent to DAX/LookML measures) — see `calculated_fields.md`.
4. Build 4 pages mirroring `/dashboard_panel_specs.md`: KPI Summary,
   Trends, Breakdown, Drill-Down.
5. Add page-level **filter controls** (date range, drop-downs for Channel/
   Region/Category) — Looker Studio calls these "Filter" and "Drop-down
   list" controls; drag them onto the canvas from the toolbar.
6. Add a drill-down chart (Looker Studio's native "Drill down" toggle on a
   bar/tree chart, e.g. Category → Subcategory → Product).
7. `File` → `Share` → `Publish and embed` or `Manage access` → set to
   "Anyone with the link can view" so it's resume-ready.
8. Screenshot each page for `/screenshots`.

## What to save here

- `retail_analytics.lookml_dashboard.lookml` (export from Path A, if used)
- `looker_studio_report_link.md` — paste your published Looker Studio URL
  once live
