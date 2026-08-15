view: dim_geography {
  sql_table_name: retail_dw.dim_geography ;;

  dimension: geography_key {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.geography_key ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}.region ;;
  }

  dimension: state_province {
    type: string
    sql: ${TABLE}.state_province ;;
  }

  dimension: state_code {
    type: string
    map_layer_name: us_states
    sql: ${TABLE}.state_code ;;
  }
}
