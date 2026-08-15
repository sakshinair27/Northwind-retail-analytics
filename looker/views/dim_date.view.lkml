view: dim_date {
  sql_table_name: retail_dw.dim_date ;;

  dimension: date_key {
    primary_key: yes
    type: number
    hidden: yes
    sql: ${TABLE}.date_key ;;
  }

  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, month_name, quarter, quarter_of_year, year]
    sql: ${TABLE}.full_date ;;
  }

  dimension: is_weekend {
    type: yesno
    sql: ${TABLE}.is_weekend ;;
  }

  dimension: is_holiday_season {
    type: yesno
    label: "Holiday Season (Nov 20 - Dec 24)"
    sql: ${TABLE}.is_holiday_season ;;
  }
}
