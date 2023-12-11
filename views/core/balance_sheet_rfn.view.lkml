######################
# aggregation of Transactions by the following dimensions:
#   Fiscal Year
#   Fiscal Period
#.  Company Code
#.  Chart of Accounts
#   Hierarchy Name
#   Business Area
#   Ledger
#.  profit center, cost center,
#   Node
#   Languague
#   Global (Target) Currency
#
# Aggregate for:
#    Amount in Local Currency, Amount in Global Currency
#    Cumulative Amount in Local Currency, Cumulative Amount in Global Currency
#
# To query this table, should always include Fiscal Year and Fiscal Period and filter to:
#   - a single Client MANDT (handled with Constant defined in Manifest file)
#   - a single Language (the Explore based on this view uses User Attribute locale to select language in joined view language_map_sdt)
#.  - a single Global Currency
#   - a single Hierarchy Name or Financial Statement Version
#   - is used as an order_by_field for fiscal_year_period
#   - allows the fiscal_year_period to be displayed in descending order in paramter/filter drop-down selectors
######################


include: "/views/base/balance_sheet.view"

view: +balance_sheet {
  dimension: client {hidden: yes}

  dimension: key {
    primary_key: yes
    hidden: yes
    sql: concat($${company_code}, ${chart_of_accounts}, ${hierarchy_name},
          coalesce(${business_area},'is null') ,coalesce(${ledger_in_general_ledger_accounting},'is null')
          ,${node},${fiscal_year},${fiscal_period},${language_key_spras},${target_currency_tcurr});;
  }

  #########################################################
  ## Parameters for Balance Sheet Dashboard
  ## 3 parameters:
  ##   select_fiscal_period
  ##   select_comparison_type
  ##   select_custom_comparison_period
  ##
  ## use parameter selections to define fiscal_period_group values of 'Reporting' or 'Comparison'
  ##
  ## at explore level if select_fiscal_period in query then filter where fiscal_period_group is null
  #########################################################

  parameter: select_fiscal_period {
    view_label: "🗓 Pick Fiscal Periods"
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_year_period
  }

  parameter: select_custom_comparison_period {
    view_label: "🗓 Pick Fiscal Periods"
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_year_period
  }

  parameter: select_comparison_type {
    view_label: "🗓 Pick Fiscal Periods"
    type: unquoted
    allowed_value: {
      label: "None" value: "none"
    }
    allowed_value: {
      label: "Same Period Last Year" value: "yoy"
    }
    allowed_value: {
      label: "Previous Fiscal Period" value: "prior"
    }
    allowed_value: {
      label: "Custom Range" value: "custom"
    }
    default_value: "yoy"

  }

  dimension: client_mandt {
    type: string
    label: "Client MANDT"
    sql: ${TABLE}.Client ;;
  }

  dimension: language_key_spras {
    hidden: no
    label: "Language Key SPRAS"
  }
  dimension: currency_key {
    label: "Currency (Local)"
  }

  dimension: target_currency_tcurr {
    label: "Currency (Global)"
  }

  dimension: hierarchy_name {
    description: "Hierarchy Name is same as Financial Statement Version (FSV)"
  }

  dimension: node_text {
    type: string
    sql: coalesce(${TABLE}.NodeText,${TABLE}.Node) ;;
  }

  dimension: parent_text {
    type: string
    sql: coalesce(${TABLE}.ParentText,${TABLE}.Parent) ;;
  }

  dimension: amount_in_local_currency {
    hidden: yes
  }

  dimension: amount_in_target_currency {
    hidden: yes
    label: "Amount in Global Currency"
  }

  dimension: cumulative_amount_in_target_currency {
    hidden: yes
    label: "Cumulative Amount in Global Currency"
    description: "End of Period Cumulative Amount in Global/Target Currency"
  }

  dimension: fiscal_period {
    group_label: "Fiscal Dates"
  }

  dimension: fiscal_period_number {
    hidden: yes
    group_label: "Fiscal Dates"
    description: "Fiscal Period as a Numeric Value"
    type: number
    sql: parse_numeric(${fiscal_period}) ;;
    value_format_name: id
  }

  dimension: fiscal_quarter {
    group_label: "Fiscal Dates"
  }

  dimension: fiscal_year {
    group_label: "Fiscal Dates"
  }

  dimension: fiscal_year_period_number {
    hidden: yes
    group_label: "Fiscal Dates"
    description: "Fiscal Year and Period as a Numeric Value in form of YYYYPP"
    type: number
    sql: parse_numeric(concat(${fiscal_year},right(${fiscal_period},2))) ;;
    value_format_name: id
  }


  dimension: fiscal_year_period {
    group_label: "Fiscal Dates"
    type: string
    sql: concat(${fiscal_year},'.',right(${fiscal_period},2)) ;;
  }

  dimension: fiscal_year_quarter {
    group_label: "Fiscal Dates"
    type: string
    sql: concat(${fiscal_year},'.Q',${fiscal_quarter}) ;;
  }

  dimension: fiscal_year_number {
    hidden: yes
    group_label: "Fiscal Dates"
    description: "Fiscal Year as a Numeric Value"
    type: number
    sql: parse_numeric(${fiscal_year}) ;;
    value_format_name: id
  }

  dimension: fiscal_period_group {
    group_label: "Fiscal Dates"
    type: string
    sql:    {% if select_fiscal_period._in_query %}
                {% assign comparison_type = select_comparison_type._parameter_value %}
                {% assign fp = select_fiscal_period._parameter_value %}
                {% assign cp = select_custom_comparison_period._parameter_value %}
                {% if comparison_type == 'custom' %}
                    {% if fp == cp %}{% assign comparison_type = 'none' %}
                    {% elsif cp == '' %}{% assign comparison_type = 'yoy' %}
                    {% endif %}
                {% endif %}

      {% if comparison_type == 'yoy' %}{% assign sub = 'YEAR'%}
      {% elsif comparison_type == 'prior' %}{% assign sub = 'MONTH' %}
      {% endif %}

      case  when ${fiscal_year_period} = '{{fp}}' then 'Reporting'
      {% if comparison_type != 'none' %}
      when PARSE_DATE('%Y.%m',${fiscal_year_period}) =
      {% if comparison_type == 'custom' %}
      PARSE_DATE('%Y.%m','{{cp}}')
      {% else %}
      DATE_SUB(PARSE_DATE('%Y.%m','{{fp}}'), INTERVAL 1 {{sub}})
      {% endif %}
      then 'Comparison'
      {% endif %}
      end
      {% else %} 'No Reporting Periods have been selected. Add Select Fiscal Period parameter.'
      {% endif %};;

  }

  measure: count {hidden: yes}

  measure: total_amount_in_local_currency {
    type: sum
    label: "Total Amount (Local Currency)"
    description: "Period Amount in Local Currency"
    sql: ${amount_in_local_currency} ;;
    value_format_name: millions_d1
    drill_fields: [fiscal_year, fiscal_period, level, parent_text, node_text, total_cumulative_amount_in_global_currency]
  }

  measure: total_cumulative_amount_in_local_currency {
    type: sum
    label: "Total Cumulative Amount (Local Currency)"
    description: "End of Period Cumulative Amount in Local Currency"
    sql: ${cumulative_amount_in_local_currency} ;;
    value_format_name: millions_d1
    drill_fields: [fiscal_year, fiscal_period, level, parent_text, node_text, total_cumulative_amount_in_global_currency]
  }

  measure: total_amount_in_global_currency {
    type: sum
    label: "Total Amount (Global Currency)"
    description: "Period Amount in Target or Global Currency"
    sql: ${amount_in_target_currency} ;;
    value_format_name: millions_d1
    drill_fields: [fiscal_year, fiscal_period, level, parent_text, node_text, total_cumulative_amount_in_global_currency]
  }

  measure: total_cumulative_amount_in_global_currency {
    type: sum
    label: "Total Cumulative Amount (Global Currency)"
    description: "End of Period Cumulative Amount in Target or Global Currency"
    sql: ${cumulative_amount_in_target_currency} ;;
    value_format_name: millions_d1
    drill_fields: [fiscal_year, fiscal_period, level, parent_text, node_text, total_cumulative_amount_in_global_currency]
  }









  measure: current_assets {
    type: sum
    sql:  ${cumulative_amount_in_target_currency};;
    filters: [node_text: "Current Assets"]
  }

  measure: current_liabilities {
    type: sum
    sql:  ${cumulative_amount_in_target_currency};;
    filters: [node_text: "Current Liabilities"]
  }

  measure: current_ratio {
    type: number
    sql: safe_divide(${current_assets},${current_liabilities}) * -1;;
    value_format_name: decimal_2
  }

  measure: reporting_period_amount_in_global_currency {
    type: sum
    sql: ${amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Reporting"]
  }

  measure: comparison_period_amount_in_global_currency {
    type: sum
    sql: ${amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Comparison"]
  }

  measure: difference_value {
    type: number
    sql: ${reporting_period_amount_in_global_currency} - ${comparison_period_amount_in_global_currency} ;;
  }

  measure: percent_difference_value {
    type: number
    sql: safe_divide(${reporting_period_amount_in_global_currency},${comparison_period_amount_in_global_currency}) - 1 ;;
    value_format_name: percent_1
  }

 }
