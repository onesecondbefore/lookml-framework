include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/distribution_centers.view.lkml"

## Refine the view
# Info: https://docs.cloud.google.com/looker/docs/lookml-refinements#using_refinements_in_your_lookml_project
view: +distribution_centers {
  final: yes
  view_label: "Distribution Centers"
}
