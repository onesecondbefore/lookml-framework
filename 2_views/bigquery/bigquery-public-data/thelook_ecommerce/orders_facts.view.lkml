# include: "/3_explores/thelook_ecommerce/order_items.explore.lkml"

# view: orders_facts {

#   view_label: "Order Facts"
#   derived_table: {
#     explore_source: order_items {
#       column: order_id {field: order_items.order_id_no_actions }
#       column: items_in_order { field: order_items.count }
#       column: order_amount { field: order_items.total_sale_price }
#       column: order_cost { field: inventory_items.total_cost }
#       column: user_id {field: order_items.user_id }
#       column: created_at {field: order_items.created_raw}
#       column: order_gross_margin {field: order_items.total_gross_margin}
#       derived_column: order_sequence_number {
#         sql: RANK() OVER (PARTITION BY user_id ORDER BY created_at) ;;
#       }
#     }
#   }

#   dimension: order_id {
#     label: "Order ID"
#     description: "A unique identifier for each customer order. This is the primary key for this view."
#     # synonyms: ["purchase id", "transaction id"]
#     type: number
#     hidden: yes
#     primary_key: yes
#     sql: ${TABLE}.order_id ;;
#   }

#   dimension: items_in_order {
#     label: "Items in Order"
#     description: "The total count of individual line items included in the order."
#     # synonyms: ["number of items", "item count", "quantity in order"]
#     type: number
#     sql: ${TABLE}.items_in_order ;;
#     hidden: yes
#   }

#   dimension: order_amount {
#     label: "Order Amount"
#     description: "The total sale price (revenue) for the entire order, summing up all items."
#     # synonyms: ["total order value", "order revenue", "order total"]
#     type: number
#     value_format_name: usd
#     sql: ${TABLE}.order_amount ;;
#     hidden: yes
#   }

#   dimension: order_cost {
#     label: "Order Cost"
#     description: "The total cost of goods sold for all items in the order."
#     # synonyms: ["total cost of order", "cogs for order"]
#     type: number
#     value_format_name: usd
#     sql: ${TABLE}.order_cost ;;
#     hidden: yes
#   }

#   dimension: order_gross_margin {
#     label: "Order Gross Margin"
#     description: "The total profit for the order, calculated as the order amount minus the order cost."
#     # synonyms: ["order profit", "total margin on order"]
#     type: number
#     value_format_name: usd
#     hidden: yes
#   }

#   dimension: order_sequence_number {
#     label: "Order Sequence Number"
#     description: "A number indicating the chronological order of a customer's purchases. '1' is their first purchase, '2' is their second, and so on."
#     # synonyms: ["customer purchase number", "purchase sequence"]
#     type: number
#     sql: ${TABLE}.order_sequence_number ;;
#   }

#   dimension: is_first_purchase {
#     label: "Is First Purchase"
#     description: "A yes/no field that is 'Yes' if this is the customer's first-ever purchase and 'No' otherwise."
#     # synonyms: ["first order", "new customer purchase", "initial purchase"]
#     type: yesno
#     sql: ${order_sequence_number} = 1 ;;
#   }

# }
