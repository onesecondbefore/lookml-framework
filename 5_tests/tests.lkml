test: data_exists_in_marketing {
  explore_source: orders_test {
    column: count {
      field: orders_test.count
    }
    limit: 1
  }

  assert: has_data {
    # Must be yesno; fully-qualify the field
    expression: ${orders_test.count} > 0 ;;
  }
}
