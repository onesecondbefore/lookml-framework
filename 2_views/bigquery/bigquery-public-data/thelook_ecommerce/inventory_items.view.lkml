include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/inventory_items.view.lkml"

view: +inventory_items {
  view_label: "Inventory Items"

  dimension: id {
    label: "ID"
    description: "The unique identifier for a single physical item in inventory. Each unit has a unique ID."
    # synonyms: ["inventory item id", "stock id", "unit id"]
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    label: "Cost"
    description: "The cost of acquiring a single inventory item."
    # synonyms: ["item cost", "unit cost", "cost of goods"]
    type: number
    value_format_name: usd
    sql: ${TABLE}.cost ;;
  }

  dimension_group: created {
    label: "Created"
    description: "The date and time when the item was first entered into inventory."
    # synonyms: ["date added to stock", "inventory creation date", "arrival date"]
    type: time
    timeframes: [time, date, week, month, raw]
    sql: CAST(${TABLE}.created_at AS TIMESTAMP) ;;
  }

  dimension: product_id {
    label: "Product ID"
    description: "The identifier for the general product type. Used to link to the Products view. Many inventory items can share the same Product ID."
    # synonyms: ["product number", "product identifier"]
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: sold {
    label: "Sold"
    description: "The date and time when the inventory item was sold to a customer."
    # synonyms: ["date sold", "sale date"]
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.sold_at ;;
  }

  dimension: is_sold {
    label: "Is Sold"
    description: "A yes/no field indicating whether the inventory item has been sold."
    # synonyms: ["sold status", "has been sold"]
    type: yesno
    sql: ${sold_raw} is not null ;;
  }

  dimension: days_in_inventory {
    label: "Days in Inventory"
    description: "Calculates the number of days an item spent in inventory, from the date it was created until the date it was sold. For items still in stock, it calculates days from creation to today."
    # synonyms: ["inventory duration", "shelf time", "days on shelf"]
    type: number
    sql: TIMESTAMP_DIFF(coalesce(${sold_raw}, CURRENT_TIMESTAMP()), ${created_raw}, DAY) ;;
  }

  dimension: days_in_inventory_tier {
    label: "Days In Inventory Tier"
    description: "Groups items into different tiers based on how many days they spent in inventory."
    # synonyms: ["inventory duration bucket", "shelf time group"]
    type: tier
    sql: ${days_in_inventory} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: days_since_arrival {
    label: "Days Since Arrival"
    description: "Calculates the number of days that have passed since the item arrived in inventory. Useful for analyzing the age of current, unsold stock."
    # synonyms: ["age of stock", "days since stocked"]
    type: number
    sql: TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY) ;;
  }

  dimension: days_since_arrival_tier {
    label: "Days Since Arrival Tier"
    description: "Groups items into different tiers based on how many days have passed since they arrived in inventory."
    # synonyms: ["stock age bucket", "age of inventory group"]
    type: tier
    sql: ${days_since_arrival} ;;
    style: integer
    tiers: [0, 5, 10, 20, 40, 80, 160, 360]
  }

  dimension: product_distribution_center_id {
    label: "Product Distribution Center ID"
    description: "The unique identifier for the distribution center where the inventory item is located."
    # synonyms: ["dc id", "warehouse id"]
    hidden: yes
    sql: ${TABLE}.product_distribution_center_id ;;
  }

  ## MEASURES ##

  measure: sold_count {
    label: "Sold Count"
    description: "The total count of inventory items that have been sold."
    # synonyms: ["number of items sold", "count of sold units", "units sold"]
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: sold_percent {
    label: "Sold Percent"
    description: "The percentage of total inventory items that have been sold. Also known as the sell-through rate."
    # synonyms: ["percent of stock sold", "sell-through rate"]
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${sold_count}/(CASE WHEN ${count} = 0 THEN NULL ELSE ${count} END) ;;
  }

  measure: total_cost {
    label: "Total Cost"
    description: "The sum of the costs for all inventory items in the query."
    # synonyms: ["aggregate cost", "sum of cost"]
    type: sum
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: average_cost {
    label: "Average Cost"
    description: "The average cost per inventory item."
    # synonyms: ["avg item cost", "average unit cost"]
    type: average
    value_format_name: usd
    sql: ${cost} ;;
  }

  measure: count {
    label: "Count"
    description: "The total count of all inventory items, both sold and unsold."
    # synonyms: ["total inventory items", "total units", "count of stock"]
    type: count
    drill_fields: [detail*]
  }

  measure: number_on_hand {
    label: "Number On Hand"
    description: "The total count of inventory items that are currently in stock (not sold)."
    # synonyms: ["stock on hand", "unsold items", "current inventory count"]
    type: count
    drill_fields: [detail*]

    filters: {
      field: is_sold
      value: "No"
    }
  }

  measure: stock_coverage_ratio {
    label: "Stock Coverage Ratio"
    description: "A ratio indicating how long the current stock on hand will last based on the sales rate of the last 28 days."
    # synonyms: ["inventory coverage", "days of supply"]
    type:  number
    sql:  1.0 * ${number_on_hand} / nullif(${order_items.count_last_28d}*20.0,0) ;;
    value_format_name: decimal_2
    html: <p style="color: black; background-color: rgba({{ value | times: -100.0 | round | plus: 250 }},{{value | times: 100.0 | round | plus: 100}},100,80); font-size:100%; text-align:center">{{ rendered_value }}</p> ;;
  }

  set: detail {
    fields: [id, products.item_name, products.category, products.brand, products.department, cost, created_time, sold_time]
  }

}
