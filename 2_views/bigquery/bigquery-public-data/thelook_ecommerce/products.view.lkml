include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/products.view.lkml"

view: +products {
  view_label: "Products"

  dimension: id {
    label: "ID"
    description: "The unique identifier for each product."
    synonyms: ["product id", "product number", "product sku"]
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: category {
    label: "Category"
    description: "The product category, such as 'Tops & Tees' or 'Jeans'."
    # synonyms: ["product category"]
    sql: TRIM(${TABLE}.category) ;;
    drill_fields: [item_name]
  }

  dimension: item_name {
    label: "Item Name"
    description: "The specific name of the product item."
    # synonyms: ["product name", "name of item"]
    sql: TRIM(${TABLE}.name) ;;
    drill_fields: [id]
  }

  dimension: brand {
    label: "Brand"
    description: "The brand name of the product."
    # synonyms: ["product brand"]
    sql: TRIM(${TABLE}.brand) ;;
  }

  dimension: retail_price {
    label: "Retail Price"
    description: "The Manufacturer's Suggested Retail Price (MSRP) for the product."
    # synonyms: ["price", "msrp", "list price"]
    type: number
    sql: ${TABLE}.retail_price ;;
  }

  dimension: department {
    label: "Department"
    description: "The department the product belongs to, either 'Men' or 'Women'."
    # synonyms: ["product department"]
    sql: TRIM(${TABLE}.department) ;;
  }

  dimension: sku {
    label: "SKU"
    description: "The Stock Keeping Unit (SKU), a unique code identifying the product."
    # synonyms: ["stock keeping unit"]
    sql: ${TABLE}.sku ;;
  }

  dimension: distribution_center_id {
    label: "Distribution Center ID"
    description: "The identifier for the main distribution center that supplies this product."
    # synonyms: ["dc id", "warehouse id"]
    type: number
    sql: CAST(${TABLE}.distribution_center_id AS INT64) ;;
  }

  measure: count {
    label: "Count"
    description: "The total count of distinct products."
    # synonyms: ["number of products", "product count"]
    type: count
    drill_fields: [detail*]
  }

  measure: brand_count {
    label: "Brand Count"
    description: "The total count of unique brand names."
    # synonyms: ["number of brands"]
    type: count_distinct
    sql: ${brand} ;;
    drill_fields: [brand, detail2*, -brand_count]
  }

  measure: category_count {
    label: "Category Count"
    description: "The total count of unique product categories."
    # synonyms: ["number of categories"]
    alias: [category.count]
    type: count_distinct
    sql: ${category} ;;
    drill_fields: [category, detail2*, -category_count]
  }

  measure: department_count {
    label: "Department Count"
    description: "The total count of unique departments."
    # synonyms: ["number of departments"]
    alias: [department.count]
    type: count_distinct
    sql: ${department} ;;
    drill_fields: [department, detail2*, -department_count]
  }

  set: detail {
    fields: [id, item_name, brand, category, department, retail_price, users.count, order_items.order_count, order_items.count, inventory_items.count]
  }

  set: detail2 {
    fields: [category_count, brand_count, department_count, count, users.count, order_items.order_count, order_items.count, inventory_items.count, products.count]
  }

}
