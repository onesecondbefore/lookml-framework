include: "/2_views/bigquery/bigquery-public-data/thelook_ecommerce/*.view.lkml"


explore: products {

  join: inventory_items {
    view_label: "Inventory Items"
    type: left_outer
    relationship: one_to_many
    sql_on: ${products.id}=${inventory_items.product_id} ;;
  }
  join: distribution_centers {
    view_label: "Distribution Centers"
    type: left_outer
    relationship: one_to_many
    sql_on: ${products.distribution_center_id}=${distribution_centers.id} ;;
  }

}
