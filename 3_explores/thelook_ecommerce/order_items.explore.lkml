include: "/2_views/bigquery/bigquery-public-data/thelook_ecommerce/*.view.lkml"

explore: order_items {
  label: "Order Insights"
  view_name: order_items
  # extension: required

  # join: order_facts {
  #   type: left_outer
  #   view_label: "Order Items"
  #   relationship: many_to_one
  #   sql_on: ${order_facts.order_id} = ${order_items.order_id} ;;
  # }

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

  # join: products {
  #   view_label: "Products"
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${products.id} = ${inventory_items.product_id} ;;
  # }

}
