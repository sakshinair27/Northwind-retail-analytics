# Tableau — Calculated Fields

Create these under `Analysis` → `Create Calculated Field`. Names in bold
below are the exact field names to use so they match the panel specs in
`/dashboard_panel_specs.md`.

## Core measures

**Net Revenue**
```
SUM([net_revenue])
```

**Gross Profit**
```
SUM([net_revenue]) - SUM([total_cost])
```

**Gross Margin %**
```
ZN(SUM([net_revenue]) - SUM([total_cost])) / ZN(SUM([net_revenue]))
```
Set default number format to Percentage.

**Total Orders**
```
COUNTD([order_id])
```

**Average Order Value**
```
ZN(SUM([net_revenue])) / COUNTD([order_id])
```

**Units Sold**
```
SUM([quantity])
```

**Is Returned**
```
IF [order_status] = "Returned" THEN 1 ELSE 0 END
```

**Return Rate %**
```
SUM([Is Returned]) / COUNT([order_status])
```

## Table calculations (Tableau's tool-specific strength — the syntax and
## the "compute using" partitioning are what's distinctive vs. DAX/LookML)

**Revenue YoY %** (table calc, compute using `Year of full_date`)
```
(ZN(SUM([net_revenue])) - LOOKUP(ZN(SUM([net_revenue])), -1))
/ ABS(LOOKUP(ZN(SUM([net_revenue])), -1))
```

**Revenue 3-Month Rolling Avg** (table calc, compute using `Month of full_date`)
```
WINDOW_AVG(SUM([net_revenue]), -2, 0)
```

**Product Rank by Revenue**
```
RANK(SUM([net_revenue]))
```

**Top 10 Products Flag**
```
IF [Product Rank by Revenue] <= 10 THEN "Top 10" ELSE "Other" END
```

## Parameter-driven measure swap (interactivity requirement)

1. Create a **Parameter** named `Metric Selector` (String, values: `Net
   Revenue`, `Gross Profit`, `Units Sold`).
2. Create a calculated field:

**Selected Metric**
```
CASE [Metric Selector]
    WHEN "Net Revenue" THEN [Net Revenue]
    WHEN "Gross Profit" THEN [Gross Profit]
    WHEN "Units Sold" THEN [Units Sold]
END
```
3. Show the parameter control on the Trends dashboard so users can swap
   the plotted measure without a separate chart — this is the parameter-
   driven interactivity called for in the project requirements.

## Segment-level calc (Enterprise-signal calc, mirrors the DAX/LookML repeat-rate measure)

**Repeat Customer Rate %**
```
{ FIXED [customer_key] : COUNTD([order_id]) }
```
Use as an intermediate calc, then:
```
COUNTD(IF [Repeat Customer Rate %] > 1 THEN [customer_key] END) / COUNTD([customer_key])
```
Name this final field **Repeat Customer Rate**.

## Notes

- Filter `[order_status] <> "Cancelled"` at the data-source filter level
  (Data Source page → Edit Data Source Filters) so it applies consistently
  across every worksheet instead of re-filtering in every calc.
- Level-of-Detail (`FIXED`) expressions like `Repeat Customer Rate %` are a
  Tableau-specific syntax worth calling out explicitly in interviews —
  they solve aggregation problems DAX handles with `CALCULATE`/filter
  context and LookML handles with SQL window functions.
