# Dashboard Panel Specs (shared across Power BI, Looker/Looker Studio, and Tableau)

Build the same 4 views in every tool so the side-by-side comparison in a
portfolio is obvious. Each is described panel by panel, precise enough to
build and screenshot without further decisions.

---

## View 1 — KPI Summary (landing page)

**Layout:** top row of 5 KPI cards, filter bar pinned top-right, one
supporting chart below.

| Panel | Content |
|---|---|
| Filter bar | Year dropdown/parameter, Channel multi-select, Region multi-select, Category multi-select |
| KPI card 1 | **Net Revenue** (large number, YoY % change as a small delta badge, green/red) |
| KPI card 2 | **Gross Profit** with Gross Margin % subtitle |
| KPI card 3 | **Total Orders** |
| KPI card 4 | **Average Order Value** |
| KPI card 5 | **Return Rate %** |
| Below cards | Combo chart: monthly Net Revenue (bars) + monthly Order Count (line, secondary axis), last 24 months |

---

## View 2 — Trend Analysis

**Layout:** one large time-series chart, a metric-selector control, a
comparison toggle.

| Panel | Content |
|---|---|
| Metric selector | Parameter/field-parameter/calculated-field control: Net Revenue / Gross Profit / Units Sold |
| Main chart | Line chart of the selected metric by month, current year vs. prior year overlaid |
| Secondary chart | 3-month rolling average line overlaid as a dashed series |
| Annotation | Callout marking the Nov 20–Dec 24 holiday season window (shaded background band) |
| Bottom strip | Small multiples: one mini sparkline per Channel showing the same trend, for quick channel-level pattern-spotting |

---

## View 3 — Category / Segment Breakdown

**Layout:** matrix/heatmap + two supporting bar charts.

| Panel | Content |
|---|---|
| Heatmap/matrix | Category (rows) × Customer Segment (columns), cell = Net Revenue, color-scaled by Gross Margin % |
| Bar chart (left) | Net Revenue by Channel, sorted descending, with Average Order Value as a data label |
| Bar chart (right) | Net Revenue by Region (top 10), sorted descending |
| Filter | Loyalty Tier segmented control (None / Silver / Gold / Platinum) affecting all 3 panels |

---

## View 4 — Product Drill-Down / Detail

**Layout:** hierarchy drill chart + detail table, click-to-filter linked.

| Panel | Content |
|---|---|
| Drill chart | Bar chart or decomposition tree: Category → Subcategory → Product, measure = Net Revenue, clickable to drill one level at a time |
| Detail table | Top 20 products by Net Revenue: Product Name, Category, Brand, Units Sold, Net Revenue, Gross Profit, Gross Margin % — updates when a category/subcategory is selected in the drill chart |
| KPI strip | Small cards: # Products in current selection, Total Units Sold, Total Net Revenue (recalculates live with the drill selection) |
| Interaction | Clicking a bar in the drill chart cross-filters the detail table (Power BI: drill-through/cross-filter; Looker: drill_fields; Tableau: dashboard filter action) |

---

## Cross-tool consistency checklist (do this before screenshotting)

- [ ] Same date range (Jan 2024–Dec 2025) selected as the default view in all 3 tools
- [ ] Same color for "positive"/revenue (e.g., deep blue) and same accent for negative/returns (e.g., muted red) across all 3
- [ ] Same KPI numbers reconciled against `sql/03_validation_and_kpi_queries.sql` output — if Power BI's Net Revenue card doesn't match the SQL, something's wrong with a relationship or filter, fix it before screenshotting
- [ ] Each tool's screenshots saved to `/screenshots/<tool>/` using the naming convention `01_kpi_summary.png`, `02_trends.png`, `03_breakdown.png`, `04_drilldown.png`
