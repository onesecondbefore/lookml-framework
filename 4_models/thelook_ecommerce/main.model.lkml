connection: "bigquery-public-data"
include: "/5_tests/tests.lkml"

include: "/3_explores/thelook_ecommerce/order_items.explore.lkml"
explore: +order_items {
  # view_name: looker_masterclass_intermediate
}

include: "/3_explores/thelook_ecommerce/orders.explore.lkml"
explore: +orders {
  # view_name: looker_masterclass_intermediate
}
