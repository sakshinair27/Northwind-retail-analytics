view: dim_product {
  sql_table_name: retail_dw.dim_product ;;

  dimension: product_key {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.product_key ;;
  }

  dimension: product_name {
    type: string
    sql: ${TABLE}.product_name ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: subcategory {
    type: string
    sql: ${TABLE}.subcategory ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: unit_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.unit_cost ;;
  }

  dimension: list_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.list_price ;;
  }

  measure: product_count {
    type: count
    drill_fields: [product_name, category, brand]
  }
}
