include: "/views/*.view.lkml"

explore: fact_sales {
  label: "Retail Sales Analytics"
  description: "One row per order line item. Join in dimensions to slice by date, product, customer, geography, and channel."

  join: dim_date {
    type: left_outer
    sql_on: ${fact_sales.date_key} = ${dim_date.date_key} ;;
    relationship: many_to_one
  }

  join: dim_product {
    type: left_outer
    sql_on: ${fact_sales.product_key} = ${dim_product.product_key} ;;
    relationship: many_to_one
  }

  join: dim_customer {
    type: left_outer
    sql_on: ${fact_sales.customer_key} = ${dim_customer.customer_key} ;;
    relationship: many_to_one
  }

  join: dim_geography {
    type: left_outer
    sql_on: ${fact_sales.geography_key} = ${dim_geography.geography_key} ;;
    relationship: many_to_one
  }

  join: dim_channel {
    type: left_outer
    sql_on: ${fact_sales.channel_key} = ${dim_channel.channel_key} ;;
    relationship: many_to_one
  }

  always_filter: {
    filters: [fact_sales.order_status: "-Cancelled"]
  }
}
