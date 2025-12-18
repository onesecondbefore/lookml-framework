connection: "bigquery-public-data"
include: "/5_tests/tests.lkml"

include: "/3_explores/thelook_ecommerce/orders.explore.lkml"
explore: +orders {

}

include: "/3_explores/thelook_ecommerce/products.explore.lkml"
explore: +products {

}
