view: dim_channel {
  sql_table_name: retail_dw.dim_channel ;;

  dimension: channel_key {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.channel_key ;;
  }

  dimension: channel_name {
    type: string
    sql: ${TABLE}.channel_name ;;
  }

  dimension: channel_type {
    type: string
    sql: ${TABLE}.channel_type ;;
  }
}
