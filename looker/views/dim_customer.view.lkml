view: dim_customer {
  sql_table_name: retail_dw.dim_customer ;;

  dimension: customer_key {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.customer_key ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.customer_name ;;
  }

  dimension: segment {
    type: string
    sql: ${TABLE}.segment ;;
  }

  dimension: loyalty_tier {
    type: string
    sql: ${TABLE}.loyalty_tier ;;
  }

  dimension_group: signup {
    type: time
    timeframes: [raw, date, month, year]
    sql: ${TABLE}.signup_date ;;
  }

  dimension: geography_key {
    type: number
    hidden: yes
    sql: ${TABLE}.geography_key ;;
  }

  measure: customer_count {
    type: count_distinct
    sql: ${customer_key} ;;
  }
}
