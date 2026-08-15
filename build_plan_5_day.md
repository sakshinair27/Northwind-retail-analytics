# 5-Day Build Plan

## Day 1 — Data model foundation
- Review `data_model_design.md` and `sql/` scripts; understand the grain
  and every table's role.
- Stand up `data/retail_dw.db` locally (already built) or load
  `sql/01_create_schema.sql` + `sql/02_load_postgres.sql` into your own
  Postgres/BigQuery instance if you want a cloud-hosted source.
- Run `sql/03_validation_and_kpi_queries.sql` and save the output — this
  is your reconciliation baseline for all 3 dashboards.
- **Milestone:** database live and queryable; ground-truth KPI numbers in hand.

## Day 2 — Power BI build
- Connect data, build the model relationships, mark the date table.
- Add every measure from `powerbi/DAX_measures.md`.
- Build all 4 report pages per `dashboard_panel_specs.md`.
- Reconcile KPI cards against Day 1's ground-truth numbers.
- Publish to a Power BI workspace or Publish to Web.
- **Milestone:** Power BI dashboard live and screenshotted.

## Day 3 — Tableau build
- Connect data, build relationships (not old-style joins), add data
  source filter.
- Add every calculated field from `tableau/calculated_fields.md`,
  including the `Metric Selector` parameter.
- Build all 4 dashboards, add dashboard actions for drill/filter/highlight.
- Reconcile numbers, publish to Tableau Public.
- **Milestone:** Tableau dashboard live and screenshotted.

## Day 4 — Looker / Looker Studio build
- Decide Path A (LookML, if you have Looker access) or Path B (Looker
  Studio, free) per `looker/BUILD_INSTRUCTIONS.md`.
- Path B: load data into Sheets/BigQuery, build calculated fields from
  `looker/calculated_fields.md`, build all 4 report pages, publish with a
  public link.
- Path A: deploy LookML, build Looks, assemble into a Looker dashboard.
- Reconcile numbers, publish.
- **Milestone:** Looker/Looker Studio dashboard live and screenshotted.

## Day 5 — Polish, comparison write-up, and portfolio packaging
- Cross-check the consistency checklist in `dashboard_panel_specs.md`
  across all 3 tools (same date range, same color logic, same numbers).
- Record 3 short GIFs (one per tool) showing an interaction: filter,
  parameter swap, drill-down.
- Finalize the tool-comparison table in `README.md` with your own
  first-hand notes from actually building in all 3 (specific friction
  points make this section much stronger in an interview than generic
  praise/criticism).
- Write the portfolio page / GitHub repo description using the "Why this
  matters" section as a starting point.
- Add the 3 resume bullets from `resume_bullets.md` to your resume, add
  live dashboard links to your portfolio site or LinkedIn Featured section.
- **Milestone:** project fully published across all 3 platforms, resume and portfolio updated.
