# common hierarchy-related fields and parameters to be extended into balance sheet and profit and loss

view: common_hierarchy_fields_finance_ext {
 extension: required

  parameter: parameter_pick_start_level {
    hidden: no
    type: unquoted
    label: "Select first level of hierarchy to display"
    default_value: "2"
  }

  parameter: parameter_pick_depth_level {
    hidden: no
    type: unquoted
    label: "Select number of hierarchy levels to display"
    description: "Select number of hierarchy levels (1 to 5) to display"
    allowed_value: {value: "1"}
    allowed_value: {value: "2"}
    allowed_value: {value: "3"}
    allowed_value: {value: "4"}
    allowed_value: {value: "5"}
    default_value: "3"
  }

  dimension: node_text_path_string {
    hidden: no
    type: string
    group_label: "Hierarchy Paths to Node"
    label: "Full Hierarchy Path (text)"
    sql: ${TABLE}.NodeTextPath_String ;;
  }

  dimension: node_path_string {
    hidden: no
    type: string
    group_label: "Hierarchy Paths to Node"
    label: "Full Hierarchy Path (code)"

    sql: ${TABLE}.NodePath_String ;;
  }

  dimension: hier1_node_text {
    hidden: no
    type: string
    group_label: "Hierarchy Paths to Node"
    label: "Selected Hierarchy Node 1 (text)"
    description: "Node (text) for Selected Hierarchy Level 1 as set with the parameter Select first level of hierarchy to display"
    sql: ${TABLE}.hier1_node_text ;;
    order_by_field: hier1_node
  }

  dimension: hier2_node_text {
    hidden: no
    type: string
    group_label: "Hierarchy Paths to Node"
    label: "Selected Hierarchy Node 2 (text)"
    description: "Node (text) for Selected Hierarchy Level 2 as set with the parameter Select first level of hierarchy to display"
    sql: ${TABLE}.hier2_node_text ;;
    order_by_field: hier2_node
  }

  dimension: hier3_node_text {
    hidden: no
    type: string
    group_label: "Hierarchy Paths to Node"
    label: "Selected Hierarchy Node 3 (text)"
    description: "Node (text) for Selected Hierarchy Level 3 as set with the parameter Select first level of hierarchy to display"
    sql: ${TABLE}.hier3_node_text ;;
    order_by_field: hier3_node
  }

  dimension: hier4_node_text {
    hidden: no
    type: string
    group_label: "Hierarchy Paths to Node"
    label: "Selected Hierarchy Node 4 (text)"
    description: "Node (text) for Selected Hierarchy Level 4 as set with the parameter Select first level of hierarchy to display"
    sql: ${TABLE}.hier4_node_text ;;
    order_by_field: hier4_node
  }

  dimension: hier5_node_text {
    hidden: no
    type: string
    group_label: "Hierarchy Paths to Node"
    label: "Selected Hierarchy Node 5 (text)"
    description: "Node (text) for Selected Hierarchy Level 5 as set with the parameter Select first level of hierarchy to display"
    sql: ${TABLE}.hier5_node_text ;;
    order_by_field: hier5_node
  }

  dimension: hier1_node {
    hidden: yes
    type: string
    sql: ${TABLE}.hier1_node ;;
  }

  dimension: hier2_node {
    hidden: yes
    type: string
    sql: ${TABLE}.hier2_node ;;
  }

  dimension: hier3_node {
    hidden: yes
    type: string
    sql: ${TABLE}.hier3_node ;;
  }

  dimension: hier4_node {
    hidden: yes
    type: string
    sql: ${TABLE}.hier4_node ;;
  }

  dimension: hier5_node {
    hidden: yes
    type: string
    sql: ${TABLE}.hier5_node ;;
  }
}
