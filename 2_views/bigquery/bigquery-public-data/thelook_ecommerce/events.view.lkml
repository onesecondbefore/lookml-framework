include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/events.view.lkml"

## Refine the view
# Info: https://docs.cloud.google.com/looker/docs/lookml-refinements#using_refinements_in_your_lookml_project
view: +events {
  view_label: "Events"
}
