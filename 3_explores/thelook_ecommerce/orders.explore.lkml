include: "/2_views/bigquery/bigquery-public-data/thelook_ecommerce/*.view.lkml"


explore: orders {
  label: "Order Insights"

  join: order_items {
    view_label: "Order Items"
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id}=${order_items.order_id} ;;
  }
  join: users {
    view_label: "Users"
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }
  join: inventory_items {
    view_label: "Inventory Items"
    type: left_outer
    relationship: one_to_many
    sql_on: ${order_items.inventory_item_id}=${inventory_items.id} ;;
  }
  join: distribution_centers {
    view_label: "Distribution Centers"
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory_items.product_distribution_center_id}=${distribution_centers.id} ;;
  }
  join: products {
    view_label: "Products"
    type: left_outer
    relationship: one_to_many
    sql_on: ${order_items.product_id}=${products.id} ;;
  }
  join: events {
    view_label: "Events"
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${users.id}=${events.user_id};;
  }


}
