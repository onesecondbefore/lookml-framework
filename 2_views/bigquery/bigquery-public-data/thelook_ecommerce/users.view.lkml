include: "/1_sources/bigquery/bigquery-public-data/thelook_ecommerce/users.view.lkml"

view: +users {

  view_label: "Users"

  dimension: id {
    label: "ID"
    description: "The unique identifier for each user or customer."
    # synonyms: ["user id", "customer id", "client id"]
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    tags: ["user_id"]
  }

  dimension: first_name {
    label: "First Name"
    description: "The user's first name, formatted with the first letter capitalized."
    # synonyms: ["given name"]
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${TABLE}.first_name,1,1)), LOWER(SUBSTR(${TABLE}.first_name,2))) ;;
  }

  dimension: last_name {
    label: "Last Name"
    description: "The user's last name, formatted with the first letter capitalized."
    # synonyms: ["surname", "family name"]
    hidden: yes
    sql: CONCAT(UPPER(SUBSTR(${TABLE}.last_name,1,1)), LOWER(SUBSTR(${TABLE}.last_name,2))) ;;
  }

  dimension: name {
    label: "Name"
    description: "The user's full name, combining first and last name."
    # synonyms: ["full name", "customer name", "user name"]
    sql: concat(${first_name}, ' ', ${last_name}) ;;
  }

  dimension: age {
    label: "Age"
    description: "The user's age in years."
    # synonyms: ["customer age"]
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: over_21 {
    label: "Over 21"
    description: "A yes/no field indicating if the user is older than 21."
    # synonyms: ["is over 21"]
    type: yesno
    sql:  ${age} > 21;;
  }

  dimension: age_tier {
    label: "Age Tier"
    description: "Groups users into different age brackets or tiers."
    # synonyms: ["age group", "age bracket", "age range"]
    type: tier
    tiers: [0, 10, 20, 30, 40, 50, 60, 70]
    style: integer
    sql: ${age} ;;
  }

  dimension: gender {
    label: "Gender"
    description: "The user's gender."
    # synonyms: ["sex"]
    sql: ${TABLE}.gender ;;
  }

  dimension: gender_short {
    label: "Gender Short"
    description: "A single-letter abbreviation for the user's gender (e.g., 'm' or 'f')."
    # synonyms: ["gender initial"]
    sql: LOWER(SUBSTR(${gender},1,1)) ;;
  }

  dimension: user_image {
    label: "User Image"
    description: "Displays a representative image for the user based on their gender."
    # synonyms: ["user photo", "profile picture", "avatar"]
    sql: ${image_file} ;;
    html: <img src="{{ value }}" width="220" height="220"/>;;
  }

  dimension: email {
    label: "Email"
    description: "The user's email address."
    # synonyms: ["email address"]
    sql: ${TABLE}.email ;;
  }

  dimension: image_file {
    label: "Image File"
    description: "The URL path to the user's representative image file."
    # synonyms: ["photo url"]
    hidden: yes
    sql: concat('https://docs.looker.com/assets/images/',${gender_short},'.jpg') ;;
  }

  ## Demographics ##

  dimension: city {
    label: "City"
    description: "The city where the user resides."
    # synonyms: ["user city"]
    sql: ${TABLE}.city ;;
    drill_fields: [zip]
  }

  dimension: state {
    label: "State"
    description: "The state or province where the user resides."
    # synonyms: ["user state", "province"]
    sql: ${TABLE}.state ;;
    map_layer_name: us_states
    drill_fields: [zip, city]
  }

  dimension: zip {
    label: "Zip"
    description: "The postal ZIP code for the user's address."
    # synonyms: ["zipcode", "postal code"]
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: uk_postcode {
    label: "UK Postcode"
    description: "The UK postcode area for users located in the United Kingdom."
    # synonyms: ["uk post code"]
    sql: case when ${TABLE}.country = 'UK' then regexp_replace(${zip}, '[0-9]', '') else null end;;
    map_layer_name: uk_postcode_areas
    drill_fields: [city, zip]
  }

  dimension: country {
    label: "Country"
    description: "The country where the user resides."
    # synonyms: ["user country"]
    map_layer_name: countries
    drill_fields: [state, city]
    sql: CASE WHEN ${TABLE}.country = 'UK' THEN 'United Kingdom'
          ELSE ${TABLE}.country
          END
      ;;
  }

  dimension: location {
    label: "Location"
    description: "The precise geographic coordinates (latitude and longitude) of the user."
    # synonyms: ["user coordinates", "lat long"]
    type: location
    sql_latitude: ${TABLE}.latitude ;;
    sql_longitude: ${TABLE}.longitude ;;
  }

  dimension: approx_latitude {
    label: "Approx Latitude"
    description: "The user's latitude, rounded to one decimal place for approximation."
    # synonyms: ["approximate latitude"]
    type: number
    sql: round(${TABLE}.latitude,1) ;;
  }

  dimension: approx_longitude {
    label: "Approx Longitude"
    description: "The user's longitude, rounded to one decimal place for approximation."
    # synonyms: ["approximate longitude"]
    type: number
    sql:round(${TABLE}.longitude,1) ;;
  }

  dimension: approx_location {
    label: "Approx Location"
    description: "The user's approximate geographic location based on rounded coordinates."
    # synonyms: ["approximate user coordinates"]
    type: location
    drill_fields: [location]
    sql_latitude: ${approx_latitude} ;;
    sql_longitude: ${approx_longitude} ;;
    link: {
      label: "Google Directions from {{ distribution_centers.name._value }}"
      url: "{% if distribution_centers.location._in_query %}https://www.google.com/maps/dir/'{{ distribution_centers.latitude._value }},{{ distribution_centers.longitude._value }}'/'{{ approx_latitude._value }},{{ approx_longitude._value }}'{% endif %}"
      icon_url: "http://www.google.com/s2/favicons?domain=www.google.com"
    }

  }

  ## Other User Information ##

  dimension_group: created {
    label: "Created"
    description: "The date and time when the user's account was created."
    # synonyms: ["registration date", "signup date", "join date"]
    type: time
    sql: ${TABLE}.created_at ;;
  }

  dimension: history {
    label: "History"
    description: "A link to the user's complete order history."
    # synonyms: ["order history link"]
    sql: ${TABLE}.id ;;
    html: <a href="/explore/thelook_event/order_items?fields=order_items.detail*&f[users.id]={{ value }}">Order History</a>
      ;;
  }

  dimension: traffic_source {
    label: "Traffic Source"
    description: "The marketing channel or source that brought the user to the site (e.g., 'Search', 'Email')."
    # synonyms: ["acquisition source", "user source"]
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: ssn {
    label: "SSN"
    description: "A randomly generated four-digit string, used as a dummy for the last four digits of a Social Security Number."
    # synonyms: ["social security number"]
    hidden: yes
    type: string
    sql: CONCAT(CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64),
      CAST(FLOOR(10*RAND()) AS INT64),CAST(FLOOR(10*RAND()) AS INT64));;
  }

  dimension: ssn_last_4 {
    label: "SSN Last 4"
    description: "The last four digits of the user's Social Security Number. Access is restricted by user permissions."
    # synonyms: ["last 4 of social"]
    type: string
    sql: ${ssn} ;;
  }

  measure: count {
    label: "Count"
    description: "The total count of unique users."
    # synonyms: ["number of users", "customer count", "user total"]
    type: count
    drill_fields: [detail*]
  }

  measure: count_percent_of_total {
    label: "Count (Percent of Total)"
    description: "The count of users as a percentage of the total number of users in the query result."
    # synonyms: ["% of total users"]
    type: percent_of_total
    sql: ${count} ;;
    drill_fields: [detail*]
  }

  measure: average_age {
    label: "Average Age"
    description: "The average age of the users."
    # synonyms: ["avg user age"]
    type: average
    value_format_name: decimal_2
    sql: ${age} ;;
    drill_fields: [detail*]
  }

  set: detail {
    fields: [id, name, email, age, created_date, order_items.order_count, order_items.count]
  }

}
