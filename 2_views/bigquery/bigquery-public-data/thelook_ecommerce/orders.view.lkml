include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/orders.view.lkml"

## Refine the view
# Info: https://docs.cloud.google.com/looker/docs/lookml-refinements#using_refinements_in_your_lookml_project
view: +orders {
  final: yes
  view_label: "Orders"

  measure: orders {
    type: count_distinct
    sql: ${TABLE}.order_id ;;
    description: "Unique count of the order ID"

  }
}
