include: "/2_views/bigquery/bigquery-public-data/thelook_ecommerce/*.view.lkml"

explore: orders {
  label: "Orders"
  view_name: orders
  extension: required # required, or error

  join: order_items {
    type: left_outer
    view_label: "Order Items"
    relationship: many_to_one
    sql_on: ${orders.order_id} = ${order_items.order_id} ;;
  }

  join: inventory_items {
    view_label: "Inventory Items"
    #Left Join only brings in items that have been sold as order_item
    type: full_outer
    relationship: one_to_one
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
  }
  join: distribution_centers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory_items.product_distribution_center_id}=${distribution_centers.id} ;;
  }
  join: users {
    view_label: "Users"
    type: left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${users.id} ;;
  }
  join: events {
    view_label: "Events"
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${users.id}=${events.user_id};;
  }

  join: products {
    view_label: "Products"
    type: left_outer
    relationship: many_to_one
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
  }

}
