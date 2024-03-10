#########################################################
# With this reporting view, users can report on any of the FSV nodes and corresponding amounts will be rolled up or down according to node values
#
# aggregation of General Ledger Transactions by the following dimensions:
#   Client
#   Fiscal Year
#   Fiscal Period
#   Company Code
#   Chart of Accounts
#   Hierarchy Name
#   Business Area
#   Profit Center
#   Cost Center
#   Ledger
#   Hierarchy Node
#   Languague
#   Global (Target) Currency
#
# Measures:
#    Amount in Local Currency, Amount in Global Currency
#    Cumulative Amount in Local Currency, Cumulative Amount in Global Currency
#    Exchange Rate (based on last date in the period)
#    Avg Exchange Rate, Max Exchange Rate
#
# To query this table, filter to:
#   - a single Client MANDT (handled with Constant defined in Manifest file)
#   - a single Language (the Explore based on this view uses User Attribute locale to select language in joined view language_map_sdt)
#   - a single Global Currency
#   - a single Hierarchy Name or Financial Statement Version
#   - a single Chart of Accounts
#   - a single Company
#########################################################


include: "/views/base/profit_and_loss.view"
include: "/views/core/common_fields_finance_ext.view"

view: +profit_and_loss {
extends: [common_fields_finance_ext]

label: "Income Statement"

  dimension: key {
    primary_key: yes
    hidden: yes
    sql:  CONCAT(${client},${company_code}, ${chart_of_accounts}, ${glhierarchy},
          COALESCE(${business_area},'null') ,COALESCE(${ledger_in_general_ledger_accounting},'0L'),
          COALESCE(${profit_center},'null'),COALESCE(${cost_center},'null')
          ,${glnode},${fiscal_year},${fiscal_period},${language_key_spras},${target_currency_tcurr});;
  }

#########################################################
# Parameters & Filters for Income Statement Dashboard and related dimensions
#{
# 3 parameters:
#   parameter_display_time_dimension
#   filter_fiscal_timeframe
#   parameter_compare_to
#
# 2 related dimensions:
#   timeframes_list - based on selection for parameter_display_time_dimension will show either fiscal_year, fiscal_year_quarter_label, fiscal_year_period
#
#########################################################

  parameter: parameter_display_time_dimension {
    type: unquoted
    view_label: "🔍 Filters & 🛠 Tools"
    label: "Display Year, Quarter or Period"
    allowed_value: {label: "Fiscal Period" value: "fp"}
    allowed_value: {label: "Quarter" value: "qtr"}
    allowed_value: {label: "Year" value: "yr"}
    default_value: "qtr"
  }

  # this filter is intended for use on a dashboard only and should be linked to parameter_display_time_dimension
  # so that values in drop-down populate correctly based on the time display selected
  # note, when used in an explore this filter may not reflect changes in parameter_display_time_dimension
  # this filter is applied in view profit_and_loss_hierarchy_selection_sdt (which is joined to this view in the Explore profit_and_loss)
  filter: filter_fiscal_timeframe {
    type: string
    view_label: "🔍 Filters & 🛠 Tools"
    description: "Choose fiscal periods, quarters or years for Income Statement Reporting. To ensure the correct timeframes are listed, add this filter to a dashboard. Add the parameter \'Display Fiscal Period or Quarter\' and select this filter to update when the display parameter changes."
    label: "Select Fiscal Timeframe"
    suggest_dimension: timeframes_list
  }

  parameter: parameter_aggregate {
    type: unquoted
    view_label: "🔍 Filters & 🛠 Tools"
    label: "Combine Selected Timeframes?"
    description: "If multiple timeframes selected, should results be combined or shown for each time period selected?"
    allowed_value: {value: "Yes"}
    allowed_value: {value: "No"}
    default_value: "Yes"
  }

  parameter: parameter_compare_to {
    type: unquoted
    view_label: "🔍 Filters & 🛠 Tools"
    label: "Select Comparison Type"
    allowed_value: {
      label: "None" value: "none"
    }
    allowed_value: {
      label: "Year Ago" value: "yoy"
    }
    allowed_value: {
      label: "Previous Fiscal Timeframe" value: "prior"
    }
    default_value: "none"
  }

  dimension: timeframes_list {
    hidden: yes
    view_label: "🔍 Filters & 🛠 Tools"
    label: "Timeframe"
    description: "Used to populate filter labeled Select Fiscal Timeframe. Timeframes listed depend on whether displaying Fiscal Periods, Quarters or Years in the Income Statement dashboards."
    sql: {% assign display = parameter_display_time_dimension._parameter_value %}
         {% if display == 'yr' %}${fiscal_year}
         {% elsif display == 'qtr' %}${fiscal_year_quarter_label}
         {% else %}${fiscal_year_period}
         {% endif %}
        ;;
    order_by_field: selected_timeframe_level_as_negative_number
  }

  dimension: selected_timeframe_level_as_negative_number {
    hidden: yes
    description: "Used to sort timeframes shown (fiscal periods, quarters or years) in descending order."
    sql: {% assign display = parameter_display_time_dimension._parameter_value %}
         {% if display == 'yr' %}${fiscal_year_negative_number}
         {% elsif display == 'qtr' %}${fiscal_year_quarter_negative_number}
         {% else %}${fiscal_year_period_negative_number}
         {% endif %};;
  }

  # dimension: selected_time_dimension {
  #   label_from_parameter: parameter_display_time_dimension
  #   sql: {% assign display = parameter_display_time_dimension._parameter_value %}
  #       {% if display == 'yr' %}${fiscal_year}
  #       {% elsif display == 'qtr' %}${fiscal_quarter_label}
  #       {% else %}${fiscal_period}
  #       {% endif %};;
  # }

#} end parameters & filters


  # dimension: client_mandt {
  #   type: string
  #   label: "Client"
  #   sql: ${TABLE}.Client ;;
  # }

  # dimension: language_key_spras {
  #   label: "Language Key"
  #   description: "Language used for text display of Company, Parent and/or Child Node"
  # }

  # dimension: currency_key {
  #   label: "Currency (Local)"
  #   description: "Local Currency"
  # }

  # dimension: target_currency_tcurr {
  #   label: "Currency (Global)"
  #   description: "Target or Global Currency to display"
  # }

  # dimension: ledger_in_general_ledger_accounting {
  #   label: "Ledger"
  #   description: "Ledger in General Ledger Accounting"
  #   sql: COALESCE(${TABLE}.LedgerInGeneralLedgerAccounting,'0L') ;;
  # }

  # dimension: ledger_name {
  #   description: "Ledger in General Ledger Accounting"
  #   sql:  CASE ${ledger_in_general_ledger_accounting}
  #         WHEN '0L' THEN '0L - Leading Ledger'
  #         WHEN '2L' THEN '2L - IFRS Non-leading Ledger'
  #         WHEN '0E' THEN '0E - Extension Ledger'
  #         ELSE ${ledger_in_general_ledger_accounting}
  #         END;;
  #   order_by_field: ledger_in_general_ledger_accounting
  # }

  # dimension: company_code {
  #   label: "Company (code)"
  #   description: "Company Code"
  # }

  # dimension: company_text {
  #   label: "Company (text)"
  #   description: "Company Name"
  # }

  dimension: glhierarchy {
    label: "GL Hierarchy"
    description: "GL Hierarchy Name is same as Financial Statement Version (FSV)"
  }

  dimension: gllevel {
    label: "GL Level"
  }

  dimension: gllevel_number {
    type: number
    label: "GL Level (number)"
    sql: PARSE_NUMERIC(${gllevel}) ;;
  }

  dimension: gllevel_string {
    type: string
    hidden: yes
    label: "Level"
    description: "Level as a numeric. Level shows the Parent-Child Relationship. For example depending on the Hierarchy selected, Level 2 will display FPA1 as the Parent with Assets and Liabilities & Equity as Child Nodes. Level 3 will display Assets as Parent with Current Assets and Non-Current Assets as Child Nodes."
    sql: LTRIM(${gllevel},'0') ;;
  }

  dimension: glnode {
    label: "GL Node (code)"
  }

  dimension: glnode_text {
    label: "GL Node (text)"
    order_by_field: glnode
  }

  dimension: glparent {
    label: "GL Parent (code)"
  }

  dimension: glparent_text {
    label: "GL Parent (text)"
    order_by_field: glparent
  }

  dimension: glfinancial_item {
    label: "GL Financial Item"
    description: "A single line-item entry within a GL account"
  }

# Fiscal Year and Period and other forms of Fiscal Dates
# {
  # dimension: fiscal_period {
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Period as 3-character string (e.g., 001)"
  # }

  # dimension: fiscal_period_number {
  #   hidden: yes
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Period as a Numeric Value"
  #   type: number
  #   sql: PARSE_NUMERIC(${fiscal_period}) ;;
  #   value_format_name: id
  # }

  # dimension: fiscal_quarter {
  #   hidden: yes
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Quarter value of 1, 2, 3, or 4"
  # }

  # dimension: fiscal_quarter_label {
  #   group_label: "Fiscal Dates"
  #   label: "Fiscal Quarter"
  #   description: "Fiscal Quarter value of Q1, Q2, Q3, or Q4"
  #   sql: CONCAT('Q',${fiscal_quarter});;
  # }

  # dimension: fiscal_year_quarter_label {
  #   group_label: "Fiscal Dates"
  #   label: "Fiscal Year Quarter"
  #   description: "Fiscal Quarter value with year in format YYYY.Q#"
  #   sql: CONCAT(${fiscal_year},'.Q',${fiscal_quarter}) ;;
  # }

  # dimension: fiscal_year {
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Year as YYYY"
  # }

  # dimension: fiscal_year_period {
  #   type: string
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Year and Period as String in form of YYYY.PPP"
  #   sql: CONCAT(${fiscal_year},'.',${fiscal_period});;
  #   order_by_field: fiscal_year_period_negative_number
  # }

  # dimension: fiscal_year_period_number {
  #   hidden: no
  #   type: number
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Year and Period as a Numeric Value in form of YYYYPPP"
  #   sql: PARSE_NUMERIC(concat(${fiscal_year},${fiscal_period})) ;;
  #   value_format_name: id
  # }

  # dimension: fiscal_year_period_negative_number {
  #   hidden: yes
  #   type: number
  #   sql: -1 * ${fiscal_year_period_number} ;;
  # }

  # dimension: fiscal_year_quarter_negative_number {
  #   hidden: yes
  #   type: number
  #   sql: -1 * PARSE_NUMERIC(concat(${fiscal_year},${fiscal_quarter})) ;;
  # }

  # dimension: fiscal_year_negative_number {
  #   hidden: yes
  #   type: number
  #   sql: -1 * PARSE_NUMERIC(${fiscal_year}) ;;
  # }

  # dimension: fiscal_year_number {
  #   hidden: yes
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Year as a Numeric Value"
  #   type: number
  #   sql: parse_numeric(${fiscal_year}) ;;
  #   value_format_name: id
  # }

  #} end fiscal period

# derived dimensions
# {

#} end derived dimensions

# Hidden dimensions that are restated as measures; Amounts and Exchange Rates
# {
  # hide client and define as client_mandt to match other SAP tables
  dimension: client {
    hidden: yes
  }

  # adjust sign if needed so that Revenue is displayed as positive value and Expense as negative
  dimension: amount_in_local_currency {
    hidden: yes
    sql: @{sign_change_multiplier}
         ${TABLE}.AmountInLocalCurrency * {{multiplier}} ;;
  }

  # flip the signs so Income is positive and Expenses negative
  dimension: amount_in_target_currency {
    hidden: yes
    label: "Amount in Global Currency"
    sql: @{sign_change_multiplier}
         ${TABLE}.AmountInTargetCurrency * {{multiplier}} ;;
  }

  dimension: cumulative_amount_in_local_currency {
    hidden: yes
    sql: @{sign_change_multiplier}
         ${TABLE}.CumulativeAmountInLocalCurrency * {{multiplier}} ;;
  }

  dimension: cumulative_amount_in_target_currency {
    hidden: yes
    label: "Cumulative Amount in Global Currency"
    description: "End of Period Cumulative Amount in Global/Target Currency"
    sql: @{sign_change_multiplier}
         ${TABLE}.CumulativeAmountInTargetCurrency * {{multiplier}} ;;
  }

  dimension: exchange_rate {hidden: yes}
  dimension: avg_exchange_rate {hidden:yes}
  dimension: max_exchange_rate {hidden:yes}
#} end hidden dimensions

#########################################################
# Measures
# {

  measure: count {hidden: yes}

  measure: total_amount_in_local_currency {
    type: sum
    label: "Total Amount (Local Currency)"
    description: "Period Amount in Local Currency"
    sql: ${amount_in_local_currency} ;;
    # value_format_name: millions_d1
  }

  measure: total_cumulative_amount_in_local_currency {
    hidden: yes
    type: sum
    label: "Total Cumulative Amount (Local Currency)"
    description: "End of Period Cumulative Amount in Local Currency"
    sql: ${cumulative_amount_in_local_currency} ;;
    value_format_name: decimal_0
    # value_format_name: millions_d1
  }

  measure: total_amount_in_global_currency {
    type: sum
    label: "Total Amount (Global Currency)"
    description: "Period Amount in Target or Global Currency"
    sql: ${amount_in_target_currency} ;;
    value_format_name: decimal_0
    # value_format_name: millions_d1
  }

  measure: total_cumulative_amount_in_global_currency {
    hidden: yes
    type: sum
    label: "Total Cumulative Amount (Global Currency)"
    description: "End of Period Cumulative Amount in Target or Global Currency"
    sql: ${cumulative_amount_in_target_currency} ;;
    value_format_name: decimal_0
    # value_format_name: millions_d1
  }


  measure: net_income {
    type: sum
    hidden: no
    label: "Total Net Income (Global Currency)"
    sql: ${amount_in_target_currency} ;;
    filters: [gllevel_number: "2"]
    value_format_name: millions_d1
}




  #} end measures




   }
