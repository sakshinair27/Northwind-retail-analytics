"""
Generates a realistic star-schema dataset for the
"Northwind Retail Analytics" BI portfolio project.

Domain: Retail / E-commerce sales performance (2024-01-01 through 2025-12-31)

Outputs (written to /data):
    dim_date.csv
    dim_customer.csv
    dim_product.csv
    dim_geography.csv
    dim_channel.csv
    fact_sales.csv

Run: python3 generate_data.py
"""

import csv
import random
import datetime
from pathlib import Path

random.seed(42)

OUT_DIR = Path(__file__).resolve().parent.parent / "data"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# ---------------------------------------------------------------------------
# DIM_DATE
# ---------------------------------------------------------------------------
start_date = datetime.date(2024, 1, 1)
end_date = datetime.date(2025, 12, 31)

dim_date_rows = []
d = start_date
date_key_map = {}
fiscal_key = 1
while d <= end_date:
    date_key = int(d.strftime("%Y%m%d"))
    date_key_map[d] = date_key
    quarter = (d.month - 1) // 3 + 1
    is_weekend = d.weekday() >= 5
    # simple US holiday flag set for retail seasonality signal
    is_holiday_season = d.month in (11, 12)
    dim_date_rows.append(
        {
            "date_key": date_key,
            "full_date": d.isoformat(),
            "day_of_week": d.strftime("%A"),
            "day_num_in_week": d.isoweekday(),
            "day_num_in_month": d.day,
            "day_num_in_year": d.timetuple().tm_yday,
            "week_of_year": int(d.strftime("%V")),
            "month_num": d.month,
            "month_name": d.strftime("%B"),
            "month_year": d.strftime("%b-%Y"),
            "quarter": f"Q{quarter}",
            "year": d.year,
            "is_weekend": is_weekend,
            "is_holiday_season": is_holiday_season,
        }
    )
    d += datetime.timedelta(days=1)

with open(OUT_DIR / "dim_date.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(dim_date_rows[0].keys()))
    writer.writeheader()
    writer.writerows(dim_date_rows)

print(f"dim_date: {len(dim_date_rows)} rows")

# ---------------------------------------------------------------------------
# DIM_GEOGRAPHY  (US states + a handful of Canadian provinces)
# ---------------------------------------------------------------------------
us_states = [
    ("CA", "California", "West"), ("TX", "Texas", "South"), ("NY", "New York", "Northeast"),
    ("FL", "Florida", "South"), ("IL", "Illinois", "Midwest"), ("WA", "Washington", "West"),
    ("PA", "Pennsylvania", "Northeast"), ("OH", "Ohio", "Midwest"), ("GA", "Georgia", "South"),
    ("NC", "North Carolina", "South"), ("MI", "Michigan", "Midwest"), ("NJ", "New Jersey", "Northeast"),
    ("VA", "Virginia", "South"), ("AZ", "Arizona", "West"), ("MA", "Massachusetts", "Northeast"),
    ("CO", "Colorado", "West"), ("OR", "Oregon", "West"), ("TN", "Tennessee", "South"),
    ("IN", "Indiana", "Midwest"), ("MN", "Minnesota", "Midwest"), ("WI", "Wisconsin", "Midwest"),
    ("MO", "Missouri", "Midwest"), ("MD", "Maryland", "Northeast"), ("NV", "Nevada", "West"),
    ("CT", "Connecticut", "Northeast"), ("UT", "Utah", "West"), ("SC", "South Carolina", "South"),
    ("LA", "Louisiana", "South"), ("KY", "Kentucky", "South"), ("OK", "Oklahoma", "South"),
]
ca_provinces = [
    ("ON", "Ontario", "Canada"), ("BC", "British Columbia", "Canada"),
    ("QC", "Quebec", "Canada"), ("AB", "Alberta", "Canada"),
]

dim_geo_rows = []
geo_key = 1
for code, name, region in us_states:
    dim_geo_rows.append({
        "geography_key": geo_key, "country": "United States",
        "region": region, "state_province": name, "state_code": code,
    })
    geo_key += 1
for code, name, region in ca_provinces:
    dim_geo_rows.append({
        "geography_key": geo_key, "country": "Canada",
        "region": region, "state_province": name, "state_code": code,
    })
    geo_key += 1

with open(OUT_DIR / "dim_geography.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(dim_geo_rows[0].keys()))
    writer.writeheader()
    writer.writerows(dim_geo_rows)

print(f"dim_geography: {len(dim_geo_rows)} rows")

# ---------------------------------------------------------------------------
# DIM_CHANNEL
# ---------------------------------------------------------------------------
channels = [
    (1, "Online - Website", "Digital"),
    (2, "Online - Mobile App", "Digital"),
    (3, "Marketplace (Amazon/Walmart.com)", "Digital"),
    (4, "Retail Store", "Physical"),
    (5, "Wholesale / B2B", "Physical"),
]
dim_channel_rows = [
    {"channel_key": k, "channel_name": n, "channel_type": t} for k, n, t in channels
]
with open(OUT_DIR / "dim_channel.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(dim_channel_rows[0].keys()))
    writer.writeheader()
    writer.writerows(dim_channel_rows)

print(f"dim_channel: {len(dim_channel_rows)} rows")

# ---------------------------------------------------------------------------
# DIM_PRODUCT
# ---------------------------------------------------------------------------
categories = {
    "Apparel": ["Men's Tops", "Women's Tops", "Outerwear", "Activewear", "Footwear"],
    "Home & Kitchen": ["Cookware", "Small Appliances", "Bedding", "Storage & Organization"],
    "Electronics": ["Audio", "Wearables", "Smart Home", "Accessories"],
    "Beauty & Personal Care": ["Skincare", "Haircare", "Fragrance"],
    "Sports & Outdoors": ["Fitness Equipment", "Camping", "Cycling"],
    "Toys & Games": ["Building Sets", "Board Games", "Outdoor Play"],
}
brands = ["Aurora", "Northgate", "Sable & Co", "Pinnacle", "CoastalGear", "Lumen",
          "Meridian", "Trailhead", "Vantage", "Willowbrook", "Crestline", "Basecamp"]
adjectives = ["Pro", "Essential", "Classic", "Ultra", "Everyday", "Signature", "Compact", "Deluxe"]

dim_product_rows = []
product_key = 1
for category, subcats in categories.items():
    for subcat in subcats:
        n_products = random.randint(12, 22)
        for i in range(n_products):
            brand = random.choice(brands)
            adj = random.choice(adjectives)
            cost = round(random.uniform(4, 180), 2)
            margin_multiplier = random.uniform(1.6, 3.2)
            list_price = round(cost * margin_multiplier, 2)
            dim_product_rows.append({
                "product_key": product_key,
                "product_name": f"{brand} {adj} {subcat[:-1] if subcat.endswith('s') else subcat} {i+1}",
                "category": category,
                "subcategory": subcat,
                "brand": brand,
                "unit_cost": cost,
                "list_price": list_price,
            })
            product_key += 1

with open(OUT_DIR / "dim_product.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(dim_product_rows[0].keys()))
    writer.writeheader()
    writer.writerows(dim_product_rows)

print(f"dim_product: {len(dim_product_rows)} rows")

# ---------------------------------------------------------------------------
# DIM_CUSTOMER
# ---------------------------------------------------------------------------
first_names = ["James","Mary","Robert","Patricia","John","Jennifer","Michael","Linda","David","Elizabeth",
               "William","Barbara","Richard","Susan","Joseph","Jessica","Thomas","Sarah","Charles","Karen",
               "Christopher","Nancy","Daniel","Lisa","Matthew","Betty","Anthony","Margaret","Mark","Sandra",
               "Priya","Wei","Fatima","Carlos","Aisha","Diego","Yuki","Amara","Liam","Sofia"]
last_names = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez",
              "Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin",
              "Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson"]
segments = ["Consumer", "Small Business", "Enterprise"]
segment_weights = [0.65, 0.25, 0.10]
loyalty_tiers = ["None", "Silver", "Gold", "Platinum"]
loyalty_weights = [0.45, 0.30, 0.18, 0.07]

dim_customer_rows = []
n_customers = 3000
for cust_key in range(1, n_customers + 1):
    fn, ln = random.choice(first_names), random.choice(last_names)
    geo = random.choice(dim_geo_rows)
    signup_date = start_date + datetime.timedelta(days=random.randint(0, (end_date - start_date).days - 30))
    dim_customer_rows.append({
        "customer_key": cust_key,
        "customer_name": f"{fn} {ln}",
        "segment": random.choices(segments, weights=segment_weights)[0],
        "loyalty_tier": random.choices(loyalty_tiers, weights=loyalty_weights)[0],
        "signup_date": signup_date.isoformat(),
        "geography_key": geo["geography_key"],
    })

with open(OUT_DIR / "dim_customer.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(dim_customer_rows[0].keys()))
    writer.writeheader()
    writer.writerows(dim_customer_rows)

print(f"dim_customer: {len(dim_customer_rows)} rows")

# ---------------------------------------------------------------------------
# FACT_SALES
# ---------------------------------------------------------------------------
# Build a weighted date list so volume trends upward over time and spikes
# around Nov/Dec (holiday season) - gives trend charts a real story to tell.
all_dates = list(date_key_map.keys())

def date_weight(dt: datetime.date) -> float:
    # gentle YoY growth
    days_from_start = (dt - start_date).days
    growth = 1.0 + (days_from_start / (end_date - start_date).days) * 0.35
    # holiday spike
    seasonal = 1.0
    if dt.month == 11 and dt.day >= 20:
        seasonal = 2.6  # Black Friday / Cyber Monday window
    elif dt.month == 12 and dt.day <= 24:
        seasonal = 2.1
    elif dt.month in (1,):
        seasonal = 0.75  # post-holiday lull
    elif dt.month in (7, 8):
        seasonal = 1.15  # summer bump
    # weekend bump for consumer retail
    weekend = 1.2 if dt.weekday() >= 5 else 1.0
    return growth * seasonal * weekend

weights = [date_weight(dt) for dt in all_dates]

n_orders = 45000
order_dates = random.choices(all_dates, weights=weights, k=n_orders)

statuses = ["Completed", "Completed", "Completed", "Completed", "Returned", "Cancelled"]

fact_rows = []
order_id = 100000
line_id = 1
for od in order_dates:
    order_id += 1
    customer = random.choice(dim_customer_rows)
    channel = random.choices(dim_channel_rows, weights=[0.38, 0.17, 0.15, 0.22, 0.08])[0]
    status = random.choices(statuses, weights=[80, 80, 80, 80, 12, 8])[0]
    n_lines = random.choices([1, 2, 3, 4], weights=[55, 25, 13, 7])[0]
    products_in_order = random.sample(dim_product_rows, k=min(n_lines, len(dim_product_rows)))
    for prod in products_in_order:
        qty = random.choices([1, 2, 3, 4, 5], weights=[50, 25, 12, 8, 5])[0]
        discount_pct = random.choices([0, 0.05, 0.10, 0.15, 0.20, 0.30],
                                       weights=[45, 20, 15, 10, 7, 3])[0]
        unit_price = prod["list_price"]
        gross_revenue = round(unit_price * qty, 2)
        discount_amount = round(gross_revenue * discount_pct, 2)
        net_revenue = round(gross_revenue - discount_amount, 2)
        total_cost = round(prod["unit_cost"] * qty, 2)
        fact_rows.append({
            "sales_line_key": line_id,
            "order_id": order_id,
            "date_key": date_key_map[od],
            "customer_key": customer["customer_key"],
            "product_key": prod["product_key"],
            "geography_key": customer["geography_key"],
            "channel_key": channel["channel_key"],
            "order_status": status,
            "quantity": qty,
            "unit_price": unit_price,
            "discount_pct": discount_pct,
            "discount_amount": discount_amount,
            "gross_revenue": gross_revenue,
            "net_revenue": net_revenue,
            "total_cost": total_cost,
        })
        line_id += 1

with open(OUT_DIR / "fact_sales.csv", "w", newline="") as f:
    writer = csv.DictWriter(f, fieldnames=list(fact_rows[0].keys()))
    writer.writeheader()
    writer.writerows(fact_rows)

print(f"fact_sales: {len(fact_rows)} rows across {n_orders} orders")
print("Done. Files written to:", OUT_DIR)
