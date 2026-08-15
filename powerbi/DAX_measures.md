# Power BI — DAX Measures

Create these as a dedicated **measure table** (`_Measures`) rather than
scattering them across dimension/fact tables — this is a best-practice
signal recruiters and hiring panels look for.

`Modeling` → `New Table` → paste: `_Measures = { BLANK() }`, hide the
column, then add every measure below to that table.

## Core measures

```dax
Net Revenue =
SUM ( fact_sales[net_revenue] )
```

```dax
Gross Profit =
SUMX (
    fact_sales,
    fact_sales[net_revenue] - fact_sales[total_cost]
)
```

```dax
Gross Margin % =
DIVIDE ( [Gross Profit], [Net Revenue], 0 )
```

```dax
Total Orders =
DISTINCTCOUNT ( fact_sales[order_id] )
```

```dax
Units Sold =
SUM ( fact_sales[quantity] )
```

```dax
Average Order Value =
DIVIDE ( [Net Revenue], [Total Orders], 0 )
```

```dax
Return Rate % =
VAR ReturnedLines =
    CALCULATE (
        COUNTROWS ( fact_sales ),
        fact_sales[order_status] = "Returned"
    )
VAR TotalLines = COUNTROWS ( fact_sales )
RETURN
    DIVIDE ( ReturnedLines, TotalLines, 0 )
```

## Time-intelligence measures (the tool-specific differentiator for Power BI)

> Requires `dim_date[full_date]` marked as the **Date table** in Model view
> (`Table tools` → `Mark as Date Table`).

```dax
Net Revenue PY =
CALCULATE (
    [Net Revenue],
    SAMEPERIODLASTYEAR ( dim_date[full_date] )
)
```

```dax
Net Revenue YoY % =
DIVIDE (
    [Net Revenue] - [Net Revenue PY],
    [Net Revenue PY],
    0
)
```

```dax
Net Revenue MTD =
TOTALMTD ( [Net Revenue], dim_date[full_date] )
```

```dax
Net Revenue 3M Rolling Avg =
AVERAGEX (
    DATESINPERIOD (
        dim_date[full_date],
        MAX ( dim_date[full_date] ),
        -3,
        MONTH
    ),
    [Net Revenue]
)
```

## Ranking / drill-down support measures

```dax
Product Rank by Revenue =
RANKX (
    ALL ( dim_product[product_name] ),
    [Net Revenue],
    ,
    DESC
)
```

```dax
Top 10 Products Flag =
IF ( [Product Rank by Revenue] <= 10, "Top 10", "Other" )
```

## Segment / cohort measure (Enterprise-signal calc)

```dax
Repeat Customer Rate % =
VAR CustomersWithMultipleOrders =
    COUNTROWS (
        FILTER (
            VALUES ( fact_sales[customer_key] ),
            CALCULATE ( DISTINCTCOUNT ( fact_sales[order_id] ) ) > 1
        )
    )
VAR TotalCustomers = DISTINCTCOUNT ( fact_sales[customer_key] )
RETURN
    DIVIDE ( CustomersWithMultipleOrders, TotalCustomers, 0 )
```

## Notes on modeling choices

- All measures use `CALCULATE`/`SUMX`/`DIVIDE` (never bare `/`) to avoid
  divide-by-zero errors when filters return an empty context — this is a
  detail interviewers ask about directly.
- `Net Revenue`, `Gross Profit`, and `Return Rate %` are filtered to exclude
  cancelled order lines at the fact level upstream (see `sql/03_validation_and_kpi_queries.sql`
  for the equivalent SQL) rather than filtering in every measure, keeping
  the model simpler. If you want cancelled orders visible for an
  operational view, add a `Net Revenue (All Statuses)` variant.
