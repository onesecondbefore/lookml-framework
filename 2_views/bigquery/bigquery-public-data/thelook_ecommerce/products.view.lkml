include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/products.view.lkml"

view: +products {
  view_label: "Products"

  dimension: id {
    hidden: yes
  }

  dimension: distribution_center_id {
    hidden: yes
  }

  measure: count {
    hidden: yes
  }
}
