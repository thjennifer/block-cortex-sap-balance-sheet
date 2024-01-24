include: "/views/core/hierarchy_path_to_node_pdt.view"

view: hierarchy_selection_sdt {
  derived_table: {
    sql:
    {% assign start = parameter_pick_start_level._parameter_value | times: 1 %}
    {% assign depth = parameter_pick_depth_level._parameter_value | times: 1 | minus: 1 %}
    select h.client,
       h.ChartOfAccounts,
       h.HierarchyName,
       CompanyCode,
       BusinessArea,
       LedgerInGeneralLedgerAccounting,
       LanguageKey_SPRAS,
       level_number,
       min(level_number) over (partition by client,ChartOfAccounts,HierarchyName,CompanyCode,BusinessArea,LedgerInGeneralLedgerAccounting,LanguageKey_SPRAS) as first_level_number,
       level_count,
       Node,
       NodeText,
       node_text_path,
       node_path,
       split(node_text_path,'/') ntp,
       array_length(split(node_text_path,'/')) as path_size
      ,
       split(node_text_path,'/')[SAFE_OFFSET({{start}} - (level_number - level_count))] AS hier0_node_text, -- start - (level_number - level_count) size - 2
       split(node_text_path,'/')[SAFE_OFFSET({{start | plus: 1}} - (level_number - level_count))] AS hier1_node_text, -- start + 1 - (level_number - level_count) size - 1
       split(node_text_path,'/')[SAFE_OFFSET({{start | plus: 2}} - (level_number - level_count))] AS hier2_node_text, -- start + 2 - (level_number - level_count) or size_of_array
       split(node_text_path,'/')[SAFE_OFFSET({{start | plus: 3}} - (level_number - level_count))] AS hier3_node_text,
       split(node_text_path,'/')[SAFE_OFFSET({{start | plus: 4}} - (level_number - level_count))] AS hier4_node_text,

       split(node_path,'/')[SAFE_OFFSET({{start}} - (level_number - level_count))] AS hier0_node, -- start - (level_number - level_count) size - 2
       split(node_path,'/')[SAFE_OFFSET({{start | plus: 1}} - (level_number - level_count))] AS hier1_node, -- start + 1 - (level_number - level_count) size - 1
       split(node_path,'/')[SAFE_OFFSET({{start | plus: 2}} - (level_number - level_count))] AS hier2_node, -- start + 2 - (level_number - level_count) or size_of_array
       split(node_path,'/')[SAFE_OFFSET({{start | plus: 3}} - (level_number - level_count))] AS hier3_node,
       split(node_path,'/')[SAFE_OFFSET({{start | plus: 4}} - (level_number - level_count))] AS hier4_node



from ${hierarchy_path_to_node_pdt.SQL_TABLE_NAME} h
--,unnest(split(node_text_path,'/')) ntp with offset

where
--level_number = 4 -- start plus depth - 1 e.g., start at 2 show 3 levels
level_number = {{start}} + {{depth}}
--and Client = '100'
--and BusinessArea = '0001'
--and LedgerInGeneralLedgerAccounting = '0L'

    ;;
  }

  fields_hidden_by_default: yes

  parameter: parameter_pick_start_level {
    hidden: no
    type: unquoted
    label: "Select first level of hierarchy to display"
    suggest_explore: balance_sheet
    suggest_dimension: balance_sheet.level
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
    # suggest_dimension: level_number
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
    sql: concat(${client_mandt},${hierarchy_name},${chart_of_accounts},${business_area},${ledger_in_general_ledger_accounting},
      ${company_code},${language_key_spras},${node}) ;;
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

  dimension: company_code {
    type: string
    sql: ${TABLE}.CompanyCode ;;
  }

  dimension: business_area {
    type: string
    sql: ${TABLE}.BusinessArea ;;
  }

  dimension: ledger_in_general_ledger_accounting {
    type: string
    sql: ${TABLE}.LedgerInGeneralLedgerAccounting ;;
  }

  dimension: language_key_spras {
    type: string
    sql: ${TABLE}.LanguageKey_SPRAS ;;
  }

  dimension: level_number {
    type: number
    sql: ${TABLE}.level_number ;;
  }

  dimension: level_string {
    type: string
    sql: cast(${TABLE}.level_number as string) ;;
  }

  dimension: node {
    type: string
    sql: ${TABLE}.node ;;
  }

  dimension: node_text {
    type: string
    sql: ${TABLE}.node_text ;;
  }

  dimension: node_text_path {
    hidden: no
    type: string
    sql: ${TABLE}.node_text_path ;;
  }

  dimension: node_path {
    hidden: no
    type: string
    sql: ${TABLE}.node_text_path ;;
  }

  dimension: hier0_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier0_node_text ;;
    order_by_field: hier0_node
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

  dimension: hier0_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier0_node ;;
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



  }
