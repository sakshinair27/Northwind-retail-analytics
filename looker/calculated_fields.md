# Looker Studio — Calculated Fields (Path B)

If you're building in Looker Studio rather than full Looker, recreate the
LookML measures using Looker Studio's calculated-field formula syntax
(`Resource` → `Manage added data sources` → `Edit` → `Add a field`, or
inline per-chart calculated fields).

```
Net Revenue (calc) = SUM(net_revenue)
```

```
Gross Profit = SUM(net_revenue) - SUM(total_cost)
```

```
Gross Margin % = (SUM(net_revenue) - SUM(total_cost)) / SUM(net_revenue)
```
Format as Percent.

```
Total Orders = COUNT_DISTINCT(order_id)
```

```
Average Order Value = SUM(net_revenue) / COUNT_DISTINCT(order_id)
```

```
Return Flag = CASE WHEN order_status = "Returned" THEN 1 ELSE 0 END
```

```
Return Rate % = SUM(Return Flag) / COUNT(order_status)
```
Format as Percent.

```
Is Holiday Season = CASE
  WHEN REGEXP_MATCH(CAST(full_date AS TEXT), "-11-(2[0-9]|30)") THEN "Holiday"
  WHEN REGEXP_MATCH(CAST(full_date AS TEXT), "-12-(0[1-9]|1[0-9]|2[0-4])") THEN "Holiday"
  ELSE "Regular"
END
```

```
YoY Revenue Change % = 
(SUM(net_revenue) - SUM(net_revenue, DATE_ADD(full_date, -1, "YEAR")))
/ SUM(net_revenue, DATE_ADD(full_date, -1, "YEAR"))
```
(Looker Studio implements this via a comparison date range control rather
than a single formula in most builds — set a comparison date range on the
scorecard instead if the formula above isn't accepted in your data source.)
