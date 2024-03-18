#########################################################
# This SQL Derived Table (sdt):
#   1) Takes user inputs from parameters:
#          parameter_pick_start_level - select top level of hierarchy to show
#          parameter_pick_depth_level - how many levels should be shown (1 to 5 levels)
#   2) Derives node_text and node values for hier1 to hier5 by placing the top level selected by user into hier_1 and subsequent levels into hier2 to hier5
#   3) Filters to the last level selected by user. For example, if Top Level to Display of 2 and a depth of 3 is selected:
#         LevelNumber = 5
#         derived as: 0 (start) + 3 (depth) + 2 (adjustment because minimum level possible = 2)
#
# If more than 5 hierarchy levels are needed, update the parameter_pick_depth_level and add additional hierN dimensions for node and node_text
#
# EXTENDED FIELDS
# The following parameters and dimensions are extended from view common_hierarchy_fields_finance_ext and can be further customized for Balance Sheet reporting:
#   parameter_pick_start_level
#   parameter_pick_depth_level
#   hier1_node_text ... hier5_node_text
#   hier1_node ... hier5_node
#
# This view should be joined to balance sheet using an inner join on:
#   client_mandt
#   glhierarchy
#   chart_of_accounts
#   language_key_spras
#   glnode
#########################################################}

include: "/views/core/balance_sheet_path_to_node_pdt.view"
include: "/views/core/common_hierarchy_fields_finance_ext.view"

view: balance_sheet_hierarchy_selection_sdt {
  extends: [common_hierarchy_fields_finance_ext]
  label: "Balance Sheet"
  fields_hidden_by_default: yes

  derived_table: {
    sql:
          {% assign start = parameter_pick_start_level._parameter_value | times: 1 | minus: 2 %}
          {% assign depth = parameter_pick_depth_level._parameter_value | times: 1 | minus: 1 %}
        SELECT
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
        FROM ${balance_sheet_path_to_node_pdt.SQL_TABLE_NAME} h
        WHERE LevelNumber = least({{start}} + {{depth}} + 2,MaxLevelNumber)
        ;;
  }

  dimension: key {
    hidden: yes
    type: string
    primary_key: yes
    sql: CONCAT(${client_mandt},${hierarchy_name},${chart_of_accounts},${language_key_spras},${node}) ;;
  }

  parameter: parameter_pick_start_level {
    suggest_explore: balance_sheet
    suggest_dimension: balance_sheet.level_string
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


}
