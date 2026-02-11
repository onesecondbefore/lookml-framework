test: data_exists_in_marketing {
  explore_source: orders {
    column: count {
      field: orders.count
    }
    limit: 1
  }

  assert: has_data {
    # Must be yesno; fully-qualify the field
    expression: ${orders.count} > 0 ;;
  }
}
