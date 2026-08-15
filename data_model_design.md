# Data Model Design — Northwind Retail Analytics

## Business problem & domain choice

A recurring 2026 hiring signal for entry-level Data Analyst roles is
retail/e-commerce sales performance analysis: revenue trends, category and
channel mix, customer segmentation, and margin/return analysis. Of the
three candidate domains (retail/e-commerce, SaaS subscription/churn, supply
chain/logistics), **retail/e-commerce** was selected because it is the
single most commonly requested analysis type across current Data
Analyst postings, translates cleanly to adjacent domains (a hiring manager
evaluating a SaaS or logistics candidate still recognizes "revenue by
segment over time with drill-down"), and supports a rich, recognizable
star schema without requiring niche domain knowledge to explain in an
interview.

## ER diagram (described)

```
                         ┌─────────────────┐
                         │    dim_date      │
                         │  date_key (PK)   │
                         └────────┬─────────┘
                                  │
┌──────────────────┐    ┌────────▼─────────┐    ┌──────────────────┐
│   dim_product     │    │                  │    │   dim_channel     │
│  product_key (PK) ├───►│   fact_sales     │◄───┤  channel_key (PK) │
└──────────────────┘    │ (grain: 1 row =  │    └──────────────────┘
                         │  1 order line)   │
┌──────────────────┐    │                  │    ┌──────────────────┐
│  dim_customer     ├───►│  FKs: date_key,  │◄───┤  dim_geography    │
│  customer_key (PK)│    │  customer_key,   │    │ geography_key(PK) │
│  geography_key(FK)├───►│  product_key,    │◄───┘                  │
└──────────────────┘    │  geography_key,  │
                         │  channel_key     │
                         └──────────────────┘
```

`fact_sales` sits at the center; every dimension has a 1-to-many
relationship into it (classic star schema, single join hop from fact to
any dimension — no snowflaking). `dim_customer.geography_key` also joins
directly to `dim_geography`, so customer-level and order-level geography
analysis both resolve to the same dimension.

## Grain statement

**`fact_sales` grain: one row per product line item within an order.**
An order with 3 distinct products produces 3 fact rows sharing one
`order_id`. This grain supports both order-level metrics (`COUNT DISTINCT
order_id`) and line-item/product-level metrics (`SUM(net_revenue)` by
product) without any aggregation-level ambiguity — a detail worth stating
explicitly in an interview, since grain mistakes are the most common
data-modeling error junior analysts make.

## Table schemas

### fact_sales (~77,500 rows / 45,000 orders)
| Column | Type | Description |
|---|---|---|
| sales_line_key | PK | Surrogate key, one per line item |
| order_id | FK-like | Groups line items into orders |
| date_key | FK → dim_date | Order date |
| customer_key | FK → dim_customer | Purchasing customer |
| product_key | FK → dim_product | Product sold |
| geography_key | FK → dim_geography | Ship-to region (denormalized from customer for query simplicity) |
| channel_key | FK → dim_channel | Sales channel |
| order_status | string | Completed / Returned / Cancelled |
| quantity | int | Units on this line |
| unit_price | decimal | List price charged |
| discount_pct / discount_amount | decimal | Discount applied |
| gross_revenue / net_revenue | decimal | Pre- and post-discount revenue |
| total_cost | decimal | COGS for this line (quantity × unit_cost) |

### dim_date (731 rows — 2 full years)
date_key, full_date, day_of_week, week_of_year, month_num, month_name,
quarter, year, is_weekend, is_holiday_season.

### dim_customer (3,000 rows)
customer_key, customer_name, segment (Consumer/Small Business/Enterprise),
loyalty_tier (None/Silver/Gold/Platinum), signup_date, geography_key (FK).

### dim_product (385 rows)
product_key, product_name, category, subcategory, brand, unit_cost,
list_price. 6 categories × 4–5 subcategories, realistic retail taxonomy
(Apparel, Home & Kitchen, Electronics, Beauty & Personal Care, Sports &
Outdoors, Toys & Games).

### dim_geography (34 rows)
geography_key, country, region, state_province, state_code — 30 US states
+ 4 Canadian provinces across 4 US regions (West/South/Midwest/Northeast).

### dim_channel (5 rows)
channel_key, channel_name, channel_type (Digital/Physical) — Website,
Mobile App, Marketplace, Retail Store, Wholesale/B2B.

## Why a star schema instead of a flat file

A flat, pre-joined table would let all three BI tools "just work" faster,
but it fails the actual signal this project is meant to send: hiring
managers want to see that a candidate understands dimensional modeling,
not just chart-building. A star schema also:

- lets each tool demonstrate its own join/relationship handling (Power
  BI's model relationships, Tableau's Relationship canvas, Looker's
  `join:` blocks) — which is itself part of the tool-versatility story;
- keeps the fact table narrow and fast to aggregate, since descriptive
  attributes live in dimensions rather than being repeated on every row;
- mirrors how real analytics teams actually receive data (from a
  warehouse with a modeled schema, not a CSV export).

## Known simplification (call this out proactively in interviews)

`dim_customer` is modeled as **Type-1 SCD** (overwrite on change, no
history) for simplicity. A production system tracking loyalty-tier
changes over time would use **Type-2 SCD** (row versioning with
effective/expiry dates). This is a deliberate scope decision, not an
oversight — flagging it demonstrates awareness of the tradeoff.
