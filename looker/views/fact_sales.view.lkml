view: fact_sales {
  sql_table_name: retail_dw.fact_sales ;;

  dimension: sales_line_key {
    primary_key: yes
    type: number
    sql: ${TABLE}.sales_line_key ;;
    hidden: yes
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: date_key {
    type: number
    hidden: yes
    sql: ${TABLE}.date_key ;;
  }

  dimension: customer_key {
    type: number
    hidden: yes
    sql: ${TABLE}.customer_key ;;
  }

  dimension: product_key {
    type: number
    hidden: yes
    sql: ${TABLE}.product_key ;;
  }

  dimension: geography_key {
    type: number
    hidden: yes
    sql: ${TABLE}.geography_key ;;
  }

  dimension: channel_key {
    type: number
    hidden: yes
    sql: ${TABLE}.channel_key ;;
  }

  dimension: order_status {
    type: string
    sql: ${TABLE}.order_status ;;
  }

  dimension: is_completed {
    type: yesno
    sql: ${TABLE}.order_status = 'Completed' ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: unit_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.unit_price ;;
  }

  dimension: discount_pct {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.discount_pct ;;
  }

  dimension: discount_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}.discount_amount ;;
  }

  dimension: gross_revenue {
    type: number
    value_format_name: usd
    sql: ${TABLE}.gross_revenue ;;
  }

  dimension: net_revenue {
    type: number
    value_format_name: usd
    sql: ${TABLE}.net_revenue ;;
  }

  dimension: total_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.total_cost ;;
  }

  # ---------------------------------------------------------------------
  # Measures — this is Looker's tool-specific syntax equivalent to Power
  # BI's DAX / Tableau's calculated fields
  # ---------------------------------------------------------------------

  measure: total_orders {
    type: count_distinct
    sql: ${order_id} ;;
    filters: [order_status: "-Cancelled"]
    drill_fields: [order_id, product.product_name, net_revenue]
  }

  measure: units_sold {
    type: sum
    sql: ${quantity} ;;
    filters: [order_status: "-Cancelled"]
  }

  measure: net_revenue_total {
    label: "Net Revenue"
    type: sum
    sql: ${net_revenue} ;;
    value_format_name: usd
    filters: [order_status: "-Cancelled"]
    drill_fields: [product.product_name, net_revenue_total]
  }

  measure: gross_profit {
    type: number
    sql: SUM(CASE WHEN ${TABLE}.order_status <> 'Cancelled'
              THEN ${TABLE}.net_revenue - ${TABLE}.total_cost ELSE 0 END) ;;
    value_format_name: usd
  }

  measure: gross_margin_pct {
    type: number
    sql: SAFE_DIVIDE(${gross_profit}, ${net_revenue_total}) ;;
    value_format_name: percent_1
  }

  measure: average_order_value {
    type: number
    sql: SAFE_DIVIDE(${net_revenue_total}, ${total_orders}) ;;
    value_format_name: usd
  }

  measure: return_rate_pct {
    type: number
    sql: SAFE_DIVIDE(
           COUNTIF(${TABLE}.order_status = 'Returned'),
           COUNT(*)
         ) ;;
    value_format_name: percent_1
  }

  # Repeat-customer-rate style measure: tool-specific calc that requires a
  # nested aggregation, showing LookML's reusable-measure strength
  measure: repeat_customer_rate_pct {
    type: number
    sql: SAFE_DIVIDE(
           COUNT(DISTINCT CASE WHEN ${customer_order_count} > 1
                 THEN ${TABLE}.customer_key END),
           COUNT(DISTINCT ${TABLE}.customer_key)
         ) ;;
    value_format_name: percent_1
  }

  dimension: customer_order_count {
    hidden: yes
    type: number
    sql: COUNT(DISTINCT ${TABLE}.order_id) OVER (PARTITION BY ${TABLE}.customer_key) ;;
  }
}
