connection: "retail_dw_connection"  # name of your Looker DB connection (e.g. BigQuery, Postgres, Snowflake)

include: "/views/*.view.lkml"
include: "/explores/*.explore.lkml"

datagroup: retail_dw_default_datagroup {
  sql_trigger: SELECT MAX(date_key) FROM retail_dw.fact_sales ;;
  max_cache_age: "24 hours"
}

persist_with: retail_dw_default_datagroup
