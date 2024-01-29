include: "/views/core/hierarchy_path_to_node_pdt.view"

view: hierarchy_selection_sdt {
  derived_table: {
    sql:
    {% assign start = parameter_pick_start_level._parameter_value | times: 1 | minus: 2 %}
    {% assign depth = parameter_pick_depth_level._parameter_value | times: 1 | minus: 1 %}
    select
      --{{start}}
      --{{start | plus: 1}}
       h.Client,
       h.ChartOfAccounts,
       h.HierarchyName,
       LanguageKey_SPRAS,
       LevelNumber,
       LevelSequenceNumber,
       Node,
       NodeText,
       NodeTextPath_String,
       NodePath_String,
       --split(node_text_path,'/') ntp,
      -- array_length(split(node_text_path,'/')) as path_size

       NodeTextPath[SAFE_OFFSET({{start}})] AS hier1_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 1}})] AS hier2_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 2}})] AS hier3_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 3}})] AS hier4_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 4}})] AS hier5_node_text,

       NodePath[SAFE_OFFSET({{start}})] AS hier1_node,
       NodePath[SAFE_OFFSET({{start | plus: 1}})] AS hier2_node,
       NodePath[SAFE_OFFSET({{start | plus: 2}})] AS hier3_node,
       NodePath[SAFE_OFFSET({{start | plus: 3}})] AS hier4_node,
       NodePath[SAFE_OFFSET({{start | plus: 4}})] AS hier5_node
from ${hierarchy_path_to_node_pdt.SQL_TABLE_NAME} h
where
--filter to ending level as start + depth + 2 (add 2 as minimum level in hierarchy is 2)
--cap at Max Number of Levels if requested depth exceeds
LevelNumber = least({{start}} + {{depth}} + 2,MaxLevelNumber)
    ;;
  }

  label: "Balance Sheet"
  fields_hidden_by_default: yes

  parameter: parameter_pick_start_level {
    hidden: no
    type: unquoted
    label: "Select first level of hierarchy to display"
    suggest_explore: balance_sheet
    suggest_dimension: balance_sheet.level_string
    # allowed_value: {value: "1"}
    # allowed_value: {value: "2"}
    # allowed_value: {value: "3"}
    # allowed_value: {value: "4"}
    # allowed_value: {value: "5"}
    default_value: "2"
  }

  parameter: parameter_pick_depth_level {
    hidden: no
    type: unquoted
    label: "Select number of hierarchy levels to display"
    description: "Select number of hierarchy levels (1 to 5) to display"
    # suggest_explore: balance_sheet
    # suggest_dimension: balance_sheet.level_depth
    #
    allowed_value: {value: "1"}
    allowed_value: {value: "2"}
    allowed_value: {value: "3"}
    allowed_value: {value: "4"}
    allowed_value: {value: "5"}
    default_value: "3"
  }



  dimension: key {
    hidden: yes
    type: string
    primary_key: yes
    sql: concat(${client_mandt},${hierarchy_name},${chart_of_accounts},${language_key_spras},${node}) ;;
  }

  dimension: client_mandt {
    type: string
    sql: ${TABLE}.client ;;
  }

  dimension: chart_of_accounts {
    type: string
    sql: ${TABLE}.ChartOfAccounts ;;
  }

  dimension: hierarchy_name {
    type: string
    sql: ${TABLE}.HierarchyName ;;
  }

  dimension: language_key_spras {
    type: string
    sql: ${TABLE}.LanguageKey_SPRAS ;;
  }

  dimension: level_number {
    type: number
    sql: ${TABLE}.LevelNumber ;;
  }

  dimension: node {
    type: string
    sql: ${TABLE}.node ;;
  }

  dimension: node_text {
    type: string
    sql: ${TABLE}.NodeText ;;
  }

  dimension: node_text_path_string {
    hidden: no
    type: string
    sql: ${TABLE}.NodeTextPath_String ;;
  }

  dimension: node_path_string {
    hidden: no
    type: string
    sql: ${TABLE}.NodePath_String ;;
  }



  dimension: hier1_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier1_node_text ;;
    order_by_field: hier1_node
  }

  dimension: hier2_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier2_node_text ;;
    order_by_field: hier2_node
  }

  dimension: hier3_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier3_node_text ;;
    order_by_field: hier3_node
  }

  dimension: hier4_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier4_node_text ;;
    order_by_field: hier4_node
  }

  dimension: hier5_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier5_node_text ;;
    order_by_field: hier5_node
  }



  dimension: hier1_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier1_node ;;
  }

  dimension: hier2_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier2_node ;;
  }

  dimension: hier3_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier3_node ;;
  }

  dimension: hier4_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier4_node ;;
  }

  dimension: hier5_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier5_node ;;
  }



  }
