include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/order_items.view.lkml"

view: +order_items {
  view_label: "Order Items"

  dimension: id {
    label: "Order Item ID"
    description: "The unique identifier for each specific item within an order. An order with three products will have three unique Order Item IDs."
    # synonyms: ["line item id", "order line item number", "item id"]
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    value_format: "00000"
  }

  dimension: order_id {
    label: "Order ID"
    description: "The identifier that groups all items belonging to a single customer transaction. Multiple order items can share the same Order ID."
    # synonyms: ["order number", "purchase id", "transaction id"]
    type: number
    sql: ${TABLE}.order_id ;;
    value_format: "00000"
  }

  dimension: inventory_item_id {
    label: "Inventory Item ID"
    description: "The unique identifier for the product in the inventory system. Used to join to the inventory items view."
    # synonyms: ["inventory id", "stock number", "product identifier"]
    type: number
    hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: user_id {
    label: "User Id"
    description: "The unique identifier for the user who placed the order. Used to join to the users view."
    # synonyms: ["customer id", "client number", "purchaser id"]
    type: number
    hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: count {
    label: "Count"
    description: "The total count of order line items. This represents the number of individual product lines sold."
    # synonyms: ["number of order items", "count of line items", "quantity of products sold"]
    type: count
    drill_fields: [detail*]
  }

  measure: count_last_28d {
    label: "Count Sold in Trailing 28 Days"
    description: "The total number of distinct order items sold in the last 28 days."
    # synonyms: ["items sold in trailing 28 days", "count of recent sales"]
    type: count_distinct
    sql: ${id} ;;
    hidden: yes
    filters:
    {field:created_date
      value: "28 days"
    }}

  measure: order_count {
    description: "The total count of unique orders placed."
    # synonyms: ["number of orders", "count of purchases", "total transactions"]
    type: count_distinct
    drill_fields: [detail*]
    sql: ${order_id} ;;
  }

  # measure: first_purchase_count {
  #   description: "The total count of unique orders that were a customer's very first purchase."
  #   # synonyms: ["number of first time orders", "new customer order count"]
  #   type: count_distinct
  #   sql: ${order_id} ;;
  #   filters: {
  #     field: order_facts.is_first_purchase
  #     value: "Yes"
  #   }
  #   drill_fields: [user_id, users.name, users.email, order_id, created_date, users.traffic_source]
  # }

  dimension: order_id_no_actions {
    label: "Order ID No Actions"
    description: "The order identifier, specifically intended for use in contexts where drill-down actions are not desired."
    # synonyms: ["order number no drill", "plain order id"]
    type: number
    hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  ########## Time Dimensions ##########

  dimension_group: returned {
    description: "The date and time when the order item was returned by the customer."
    # synonyms: ["return date", "date returned"]
    type: time
    timeframes: [time, date, week, month, raw]
    sql: ${TABLE}.returned_at ;;
  }

  dimension_group: shipped {
    description: "The date and time when the order item was shipped from the warehouse."
    # synonyms: ["shipping date", "date dispatched", "dispatch date"]
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.shipped_at AS TIMESTAMP) ;;
  }

  dimension_group: delivered {
    description: "The date and time when the order item was delivered to the customer."
    # synonyms: ["delivery date", "date received by customer"]
    type: time
    timeframes: [date, week, month, raw]
    sql: CAST(${TABLE}.delivered_at AS TIMESTAMP) ;;
  }

  dimension_group: created {
    description: "The date and time when the order was placed by the customer."
    # synonyms: ["order date", "purchase date", "transaction date", "sale date"]
    type: time
    timeframes: [time, hour, date, week, month, quarter, year, hour_of_day, day_of_week, month_num, raw, week_of_year,month_name]
    sql: ${TABLE}.created_at ;;
  }

  dimension: reporting_period {
    group_label: "Order Date"
    description: "Categorizes orders into 'This Year to Date' or 'Last Year to Date' based on the creation date, allowing for year-over-year comparisons."
    # synonyms: ["ytd period", "time period for reporting", "YoY comparison period"]
    sql: CASE
        WHEN EXTRACT(YEAR from ${created_raw}) = EXTRACT(YEAR from CURRENT_TIMESTAMP())
        AND ${created_raw} < CURRENT_TIMESTAMP()
        THEN 'This Year to Date'

      WHEN EXTRACT(YEAR from ${created_raw}) + 1 = EXTRACT(YEAR from CURRENT_TIMESTAMP())
      AND CAST(FORMAT_TIMESTAMP('%j', ${created_raw}) AS INT64) <= CAST(FORMAT_TIMESTAMP('%j', CURRENT_TIMESTAMP()) AS INT64)
      THEN 'Last Year to Date'

      END
      ;;
  }

  dimension: days_since_sold {
    label: "Days Since Sold"
    description: "Calculates the number of days that have passed since the item was sold (created)."
    # synonyms: ["age of sale", "days from purchase"]
    hidden: yes
    sql: TIMESTAMP_DIFF(${created_raw},CURRENT_TIMESTAMP(), DAY) ;;
  }

  dimension: months_since_signup {
    label: "Months Since Signup"
    description: "Calculates the number of months between when a user signed up and when they placed this order. Useful for analyzing customer tenure."
    # synonyms: ["customer tenure in months", "months from registration"]
    type: number
    sql: CAST(FLOOR(TIMESTAMP_DIFF(${created_raw}, ${users.created_raw}, DAY)/30) AS INT64) ;;
  }

########## Logistics ##########

  dimension: status {
    label: "Status"
    description: "The current processing status of the order item, such as 'Processing', 'Shipped', 'Complete', 'Returned', or 'Cancelled'."
    # synonyms: ["order status", "fulfillment state", "item status"]
    sql: ${TABLE}.status ;;
  }

  dimension: days_to_process {
    label: "Days to Process"
    description: "The number of days between when an order was placed and when it was shipped."
    # synonyms: ["processing time", "fulfillment lead time", "days to ship"]
    type: number
    sql: CASE
        WHEN ${status} = 'Processing' THEN TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ${created_raw}, DAY)*1.0
        WHEN ${status} IN ('Shipped', 'Complete', 'Returned') THEN TIMESTAMP_DIFF(${shipped_raw}, ${created_raw}, DAY)*1.0
        WHEN ${status} = 'Cancelled' THEN NULL
      END
        ;;
  }

  dimension: shipping_time {
    label: "Shipping Time"
    description: "The number of days it took for an item to be delivered to the customer after it was shipped."
    # synonyms: ["delivery time", "transit time", "time in transit"]
    type: number
    sql: TIMESTAMP_DIFF(${delivered_raw}, ${shipped_raw}, DAY)*1.0 ;;
  }


  measure: average_days_to_process {
    label: "Average Days to Process"
    description: "The average number of days it takes to process and ship an order item after it has been placed."
    # synonyms: ["avg processing time", "average fulfillment lead time", "avg days to ship"]
    type: average
    value_format_name: decimal_2
    sql: ${days_to_process} ;;
  }

  measure: average_shipping_time {
    label: "Average Shipping Time"
    description: "The average number of days an item is in transit from the time it is shipped until it is delivered."
    # synonyms: ["avg delivery time", "average transit time"]
    type: average
    value_format_name: decimal_2
    sql: ${shipping_time} ;;
  }

########## Financial Information ##########

  dimension: sale_price {
    label: "Sale Price"
    description: "The price at which a single item was sold to the customer, before any order-level discounts."
    # synonyms: ["item price", "selling price", "line item revenue"]
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.sale_price;;
    hidden: yes
  }

  dimension: gross_margin {
    label: "Gross Margin"
    description: "The profit made on a single item, calculated as the sale price minus the item's cost."
    # synonyms: ["item profit", "line item margin"]
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost};;
    hidden: yes
  }

  dimension: item_gross_margin_percentage {
    label: "Item Gross Margin Percentage"
    description: "The gross margin of a single item expressed as a percentage of its sale price."
    # synonyms: ["item profit margin percent", "line item gm %"]
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
    hidden: yes
  }

  dimension: item_gross_margin_percentage_tier {
    label: "Item Gross Margin Percentage Tier"
    description: "Groups items into tiers based on their gross margin percentage. Useful for analyzing profitability brackets."
    # synonyms: ["profitability tier", "margin bucket", "gm percentage group"]
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: interval
  }

  measure: total_sale_price {
    label: "Total Sale Price"
    description: "The total revenue from all items in the query. This is the sum of the sale prices of all line items."
    # synonyms: ["total revenue", "total sales", "gross sales", "sum of sales"]
    type: sum
    value_format_name: usd_0
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: total_sale_target {
    label: "Total Sale Target"
    description: "A calculated sales target, set at 95% of the total sale price. Used for performance comparison."
    # synonyms: ["sales goal", "revenue target"]
    type: number
    value_format_name: usd_0
    sql: ${total_sale_price} * 0.95 ;;
    drill_fields: [detail*]
  }

  measure: total_sale_target_comparison {
    label: "Total Sale Target Comparison"
    description: "Shows how the total sale price compares to the sales target, expressed as a percentage. Positive means over target, negative means under."
    # synonyms: ["sales vs target", "variance to goal"]
    type: number
    value_format_name: percent_2
    sql: if(${total_sale_target}=0,0,(${total_sale_price} - ${total_sale_target}) / ${total_sale_target}) ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin {
    label: "Total Gross Margin"
    description: "The total profit from all items in the query, calculated as the sum of all individual item gross margins."
    # synonyms: ["total profit", "sum of gross margin", "aggregate profit"]
    type: sum
    value_format_name: usd_0
    sql: ${gross_margin} ;;
    drill_fields: [user_id, average_sale_price, total_gross_margin]
  }

  measure: average_sale_price {
    label: "Average Sale Price"
    description: "The average sale price per order item."
    # synonyms: ["avg item price", "average selling price", "asp"]
    type: average
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: median_sale_price {
    label: "Median Sale Price"
    description: "The median sale price per order item. This is the middle value, which is less affected by extremely high or low priced items than the average."
    # synonyms: ["midpoint sale price"]
    type: median
    value_format_name: usd
    sql: ${sale_price} ;;
    drill_fields: [detail*]
  }

  measure: average_gross_margin {
    label: "Average Gross Margin"
    description: "The average profit per order item."
    # synonyms: ["avg item profit", "average line item margin"]
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
    drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    label: "Total Gross Margin Percentage"
    description: "The overall profitability of all items in the query, calculated as total gross margin divided by total sale price."
    # synonyms: ["overall profit margin", "blended margin percentage", "total gm %"]
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/ nullif(${total_sale_price},0) ;;
  }

  measure: average_spend_per_user {
    label: "Average Spend per User"
    description: "The average total amount spent per user in the queried dataset."
    # synonyms: ["average revenue per user", "arpu", "avg customer spend"]
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / nullif(${users.count},0) ;;
    drill_fields: [detail*]
  }

########## Sets ##########

  set: detail {
    fields: [order_id, status, created_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }
  set: return_detail {
    fields: [id, order_id, status, created_date, returned_date, sale_price, products.brand, products.item_name, users.portrait, users.name, users.email]
  }

}
