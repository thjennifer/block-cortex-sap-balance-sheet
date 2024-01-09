include: "/views/base/profit_and_loss.view"

view: +profit_and_loss {

#### NEED TO VALIDATE
  dimension: key {
    primary_key: yes
    hidden: yes
    sql: concat(${client},${company_code}, ${chart_of_accounts}, ${glhierarchy},
          coalesce(${business_area},'is null') ,coalesce(${ledger_in_general_ledger_accounting},'is null'),
          coalesce(${profit_center},'is null'),coalesce(${cost_center},'is null')
          ,${glnode},${fiscal_year},${fiscal_period},${language_key_spras},${target_currency_tcurr});;
  }

  filter: filter_fiscal_period {
    type: string
    view_label: "🗓 Pick Fiscal Periods"
    description: "Select fiscal periods for Profit and Loss Reporting. Each period selected will be compared to same period last year."
    label: "Select Fiscal Period"
    suggest_dimension: fiscal_year_period
    # keep the periods selected plus the same period last year (by adding a year to last year's period to match the selection
    sql: {% condition %}${fiscal_year_period}{%endcondition%} or
         {% condition %}${fiscal_year_period_add_one_year}{%endcondition%}
        ;;
  }



  parameter: pick_period_or_quarter {
    type: unquoted
    allowed_value: {label: "Quarter" value: "qtr"}
    allowed_value: {label: "Fiscal Period" value: "fp"}
    default_value: "qtr"
  }

  dimension: selected_time_dimension {
    label_from_parameter: pick_period_or_quarter
    sql: {% if pick_period_or_quarter._parameter_value == 'qtr' %}${fiscal_quarter_label}
         {% else %}${fiscal_period}
         {% endif %};;
  }



  dimension: client_mandt {
    type: string
    label: "Client"
    sql: ${TABLE}.Client ;;
  }

  dimension: language_key_spras {
    label: "Language Key"
    description: "Language used for text display of Company, Parent and/or Child Node"
  }

  dimension: currency_key {
    label: "Currency (Local)"
    description: "Local Currency"
  }

  dimension: target_currency_tcurr {
    label: "Currency (Global)"
    description: "Target or Global Currency to display in Balance Sheet"
  }

  dimension: glhierarchy {
    label: "GL Hierarchy"
    description: "GL Hierarchy Name is same as Financial Statement Version (FSV)"
  }

  dimension: ledger_in_general_ledger_accounting {
    label: "Ledger"
    description: "Ledger in General Ledger Accounting"
  }

  dimension: company_code {
    label: "Company (code)"
    description: "Company Code"
  }

  dimension: company_text {
    label: "Company (text)"
    description: "Company Name"
  }

  dimension: gllevel {
    label: "GL Level"
  }

  dimension: gllevel_number {
    label: "GL Level (number)"
    sql: parse_numeric(${gllevel}) ;;
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

# Fiscal Year and Period and other forms of Fiscal Dates
# {
  dimension: fiscal_period {
    group_label: "Fiscal Dates"
    description: "Fiscal Period as 3-character string (e.g., 001)"
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
    hidden: yes
    group_label: "Fiscal Dates"
    description: "Fiscal Quarter value of 1, 2, 3, or 4"
  }

  dimension: fiscal_quarter_label {
    group_label: "Fiscal Dates"
    label: "Fiscal Quarter"
    description: "Fiscal Quarter value of Q1, Q2, Q3, or Q4"
    sql: concat('Q',${fiscal_quarter});;
  }

  dimension: fiscal_year {
    group_label: "Fiscal Dates"
    description: "Fiscal Year as YYYY"
  }

  dimension: fiscal_year_period_number {
    hidden: no
    type: number
    group_label: "Fiscal Dates"
    description: "Fiscal Year and Period as a Numeric Value in form of YYYYPP or YYYYPPP"
    sql: {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
         {% if max_fp_size == 2 %} {% assign fp = 'right(${fiscal_period},2)'%}{%else%}{%assign fp = '${fiscal_period}' %}{%endif%}
        parse_numeric(concat(${fiscal_year},{{fp}})) ;;
    value_format_name: id
  }

  dimension: fiscal_year_period_negative_number {
    hidden: yes
    type: number
    sql: -1 * ${fiscal_year_period_number} ;;
  }

  dimension: fiscal_year_period {
    type: string
    group_label: "Fiscal Dates"
    description: "Fiscal Year and Period as String in form of YYYY.PP or YYYY.PPP"
    sql: {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
         {% if max_fp_size == 2 %} {% assign fp = 'right(${fiscal_period},2)'%}{%else%}{%assign fp = '${fiscal_period}' %}{%endif%}
          concat(${fiscal_year},'.',{{fp}});;
    order_by_field: fiscal_year_period_negative_number
  }

  dimension: fiscal_year_quarter {
    type: string
    group_label: "Fiscal Dates"
    description: "Fiscal Year and Quater in form of YYYY.Q#"
    sql: concat(${fiscal_year},'.Q',${fiscal_quarter}) ;;
  }

  dimension: fiscal_year_period_add_one_year {
    type: string
    group_label: "Fiscal Dates"
    sql: {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
         {% if max_fp_size == 2 %} {% assign fp = 'right(${fiscal_period},2)'%}{%else%}{%assign fp = '${fiscal_period}' %}{%endif%}
         concat(${fiscal_year_number} + 1,'.',{{fp}}) ;;
  }

  dimension: fiscal_year_number {
    hidden: yes
    group_label: "Fiscal Dates"
    description: "Fiscal Year as a Numeric Value"
    type: number
    sql: parse_numeric(${fiscal_year}) ;;
    value_format_name: id
  }

  dimension: fiscal_reporting_period {
    group_label: "Fiscal Dates"
    description: "Reporting Period of Current Year or Last Year"
    sql: case when {% condition filter_fiscal_period %}${fiscal_year_period}{%endcondition%} then 'Current Year'
              when {% condition filter_fiscal_period %}${fiscal_year_period_add_one_year}{%endcondition%} then 'Last Year'
         end;;
  }

  dimension: selected_fiscal_period {
    group_label: "Fiscal Dates"
    description: "Both Current Year and Last Year will display the selected fiscal period"
    sql: case when {% condition filter_fiscal_period %}${fiscal_year_period}{%endcondition%} then ${fiscal_year_period}
    when {% condition filter_fiscal_period %}${fiscal_year_period_add_one_year}{%endcondition%} then ${fiscal_year_period_add_one_year}
    end;;

  }
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

  dimension: amount_in_local_currency {
    hidden: yes
  }

  dimension: amount_in_target_currency {
    hidden: yes
    label: "Amount in Global Currency"
  }

  dimension: cumulative_amount_in_local_currency {
    hidden: yes
  }

  dimension: cumulative_amount_in_target_currency {
    hidden: yes
    label: "Cumulative Amount in Global Currency"
    description: "End of Period Cumulative Amount in Global/Target Currency"
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

  measure: reporting_period_current_year_amount_in_global_currency {
    type: sum
    group_label: "Reporting v Comparison Period Metrics"
    label: "Current Year"
    sql: ${amount_in_target_currency} ;;
    filters: [fiscal_reporting_period: "Current Year"]
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: comparison_period_last_year_amount_in_global_currency {
    type: sum
    group_label: "Reporting v Comparison Period Metrics"
    label: "Last Year"
    sql: ${amount_in_target_currency} ;;
    filters: [fiscal_reporting_period: "Last Year"]
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: difference_value {
    type: number
    group_label: "Reporting v Comparison Period Metrics"
    label: "Gain (Loss)"
    description: "Reporting Period Amount - Comparison Period Amount"
    sql: ${reporting_period_current_year_amount_in_global_currency} - ${comparison_period_last_year_amount_in_global_currency} ;;
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: difference_percent {
    type: number
    group_label: "Reporting v Comparison Period Metrics"
    label: "Var %"
    description: "Percentage Change between Reporting and Comparison Periods"
    sql: safe_divide(${reporting_period_current_year_amount_in_global_currency},${comparison_period_last_year_amount_in_global_currency}) - 1 ;;
    value_format_name: percent_1
    html: @{negative_format} ;;
  }




  #} end measures

   }
