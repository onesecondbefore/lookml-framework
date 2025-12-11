connection: "bigquery-public-data"

include: "/3_explores/thelook_ecommerce/thelook_ecommerce.explore.lkml"
explore: +order_items {
  # view_name: looker_masterclass_intermediate
}
