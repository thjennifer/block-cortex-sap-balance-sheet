include: "/views/base/profit_and_loss.view"

view: +profit_and_loss {

label: "Income Statement"

  dimension: key {
    primary_key: yes
    hidden: yes
    sql: concat(${client},${company_code}, ${chart_of_accounts}, ${glhierarchy},
          coalesce(${business_area},'is null') ,coalesce(${ledger_in_general_ledger_accounting},'0L'),
          coalesce(${profit_center},'is null'),coalesce(${cost_center},'is null')
          ,${glnode},${fiscal_year},${fiscal_period},${language_key_spras},${target_currency_tcurr});;
  }

  parameter: parameter_display_period_or_quarter {
    type: unquoted
    label: "Display Period or Quarter"
    allowed_value: {label: "Quarter" value: "qtr"}
    allowed_value: {label: "Fiscal Period" value: "fp"}
    default_value: "qtr"
  }




  filter: filter_fiscal_timeframe {
    type: string
    view_label: "🗓 Pick Fiscal Periods"
    description: "Choose fiscal periods or quarters for Income Statement Reporting. To ensure the correct timeframes are listed, add this filter to a dashboard. Add the parameter \'Display Fiscal Period or Quarter\' and select this filter to update when the display parameter changes."
    label: "Select Fiscal Timeframe"
    suggest_dimension: timeframes_to_select
    suggest_persist_for: "0 seconds"
    # keep the periods selected plus the same period last year (by adding a year to last year's period to match the selection
    # sql:  {% condition %}{% if parameter_display_period_or_quarter._parameter_value == 'fp' %}${fiscal_year_period}
    #                       {% else %}${fiscal_year_quarter_label}
    #                       {% endif %}
    #       {%endcondition%} or
    #       {% condition %}{% if parameter_display_period_or_quarter._parameter_value == 'fp' %}${fiscal_year_period_add_one_year}
    #                       {% else %}${fiscal_year_quarter_label_add_one_year}
    #                       {% endif %}{%endcondition%}
    #     ;;
  }

  filter: filter_comparison_timeframe {
    type: string
    view_label: "🗓 Pick Fiscal Periods"
    description: "Choose fiscal periods or quarters for Income Statement Reporting. To ensure the correct timeframes are listed, add this filter to a dashboard. Add the parameter \'Display Fiscal Period or Quarter\' and select this filter to update when the display parameter changes."
    label: "Select Custom Comparison"
    suggest_dimension: timeframes_to_select
    suggest_persist_for: "0 seconds"
    # keep the periods selected plus the same period last year (by adding a year to last year's period to match the selection
    # sql:  {% condition %}{% if parameter_display_period_or_quarter._parameter_value == 'fp' %}${fiscal_year_period}
    #                       {% else %}${fiscal_year_quarter_label}
    #                       {% endif %}
    #       {%endcondition%} or
    #       {% condition %}{% if parameter_display_period_or_quarter._parameter_value == 'fp' %}${fiscal_year_period_add_one_year}
    #                       {% else %}${fiscal_year_quarter_label_add_one_year}
    #                       {% endif %}{%endcondition%}
    #     ;;
  }


  parameter: parameter_compare_to {
    label: "Select Comparison Type"
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
  # allowed_value: {
  #     label: "Custom Range" value: "custom"
  #   }
    default_value: "none"

  }



  dimension: timeframes_to_select {
    hidden: no
    view_label: "🗓 Pick Fiscal Periods"
    label: "Timeframe"
    description: "Used to populate filter named Select Fiscal Timeframe. Timeframes shown depend on whether displaying Fiscal Periods or Quarter in the Income Statement dashboards."
    sql: {% if parameter_display_period_or_quarter._parameter_value == 'fp' %}${fiscal_year_period}
         {% else %}${fiscal_year_quarter_label}
         {% endif %}
        ;;
    suggest_persist_for: "0 seconds"
    order_by_field: selected_timeframe_level_as_negative_number
  }

  measure: max_timeframe {
    type: string
    sql: (select max(${timeframes_to_select}) ) ;;
  }

  filter: filter_fiscal_period {
    type: string
    view_label: "🗓 Pick Fiscal Periods"
    description: "Select fiscal periods for Income Statement Reporting. Each period selected will be compared to same period last year."
    label: "Select Fiscal Period"
    suggest_dimension: fiscal_year_period
    suggest_persist_for: "1 seconds"
    # keep the periods selected plus the same period last year (by adding a year to last year's period to match the selection
    sql: {% condition %}${fiscal_year_period}{%endcondition%} or
         {% condition %}${fiscal_year_period_add_one_year}{%endcondition%}
        ;;
  }


  dimension: selected_time_dimension {
    label_from_parameter: parameter_display_period_or_quarter
    sql: {% if parameter_display_period_or_quarter._parameter_value == 'qtr' %}${fiscal_quarter_label}
         {% else %}${fiscal_period_label}
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
    sql: coalesce(${TABLE}.LedgerInGeneralLedgerAccounting,'0L') ;;
  }

  dimension: ledger_name {
    description: "Ledger in General Ledger Accounting"
    # sql: if(${ledger_in_general_ledger_accounting} = '0L','Leading Ledger', ${ledger_in_general_ledger_accounting} );;
    sql: case when ${ledger_in_general_ledger_accounting} = '0L' then 'Leading Ledger'
              when right(${ledger_in_general_ledger_accounting},1)='E' then concat(${ledger_in_general_ledger_accounting},' (Extending Ledger)')
         else ${ledger_in_general_ledger_accounting} end;;
    # html: {% assign l = ledger_in_general_ledger_accounting._value | slice: -1,1 %}
          # {% if l == 'E' %}{% assign addon = ' (Extending Ledger)' %}{% assign assign addon = '' %}{%endif%}
          # {{value | append: addon}};;
    order_by_field: ledger_in_general_ledger_accounting
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
    type: number
    label: "GL Level (number)"
    sql: parse_numeric(${gllevel}) ;;
  }

  # used as filter suggestion for selecting level depth to display
  dimension: gllevel_depth {
    hidden: yes
    type: string
    sql: cast((${gllevel_number} - 1) as string) ;;
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

  dimension: fiscal_period_label {
    type: string
    hidden: yes
    description: "Fiscal Period as either 2- or 3-character string"
    sql: {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
         {% if max_fp_size == 2 %} {% assign fp = 'right(${fiscal_period},2)'%}{%else%}{%assign fp = '${fiscal_period}' %}{%endif%}
         {{fp}};;
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

  dimension: fiscal_year_quarter_label {
    group_label: "Fiscal Dates"
    label: "Fiscal Year Quarter"
    description: "Fiscal Quarter value with year in format YYYY.QN"
    sql: concat(${fiscal_year},'.Q',${fiscal_quarter}) ;;
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

  dimension: fiscal_year_quarter_negative_number {
    hidden: yes
    type: number
    sql: -1 * parse_numeric(concat(${fiscal_year},${fiscal_quarter})) ;;
  }

  dimension: selected_timeframe_level_as_negative_number {
    hidden: yes
    description: "Used to sort timeframes shown (fiscal periods or quarters) in descending order."
    sql: {% if parameter_display_period_or_quarter._parameter_value == 'qtr' %}${fiscal_year_quarter_negative_number}
         {% else %}${fiscal_year_period_negative_number}
         {% endif %};;
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
    hidden: yes
    type: string
    group_label: "Fiscal Dates"
    sql: {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
         {% if max_fp_size == 2 %} {% assign fp = 'right(${fiscal_period},2)'%}{%else%}{%assign fp = '${fiscal_period}' %}{%endif%}
         concat(${fiscal_year_number} + 1,'.',{{fp}}) ;;
  }

  dimension: fiscal_year_quarter_label_add_one_year {
    hidden: yes
    type: string
    group_label: "Fiscal Dates"
    sql: concat(${fiscal_year_number} + 1,'.',${fiscal_quarter_label}) ;;
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

  dimension: reporting_period {
    group_label: "Fiscal Dates"
    description: "Reporting Period of Current Year or Last Year"
    sql: case when {% condition filter_fiscal_timeframe %}{% if parameter_display_period_or_quarter._parameter_value == 'fp' %}${fiscal_year_period}
                          {% else %}${fiscal_year_quarter_label}
                          {% endif %}{%endcondition%} then 'Current Year'
              when {% condition filter_fiscal_timeframe %}{% if parameter_display_period_or_quarter._parameter_value == 'fp' %}${fiscal_year_period_add_one_year}
                          {% else %}${fiscal_year_quarter_label_add_one_year}
                          {% endif %}{%endcondition%} then 'Last Year'
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

  # flip the signs so Income is positive and Expenses negative
  dimension: amount_in_local_currency {
    hidden: yes
    sql: ${TABLE}.AmountInLocalCurrency * -1 ;;
  }

  # flip the signs so Income is positive and Expenses negative
  dimension: amount_in_target_currency {
    hidden: no
    label: "Amount in Global Currency"
    sql: ${TABLE}.AmountInTargetCurrency * -1 ;;
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
    # drill_fields: [drill_profit_to_parent*]
    link: {
      label: "Show Components of Profit at Parent Level"
      url: "{{ drill_profit_to_parent._link }}&sorts=profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,profit_and_loss_kpi_to_glaccount_map_sdt.kpi_name,profit_and_loss.glparent_text"
    }

    link: {
      label: "Show Components of Profit at Parent & Node Level"
      url: "{{ drill_profit_to_child._link }}&sorts=profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,profit_and_loss_kpi_to_glaccount_map_sdt.kpi_name,profit_and_loss.glparent_text,profit_and_loss.glnode_text"
    }

    link: {
      label: "Show Income Statement"
      url: "//cortexdev.cloud.looker.com/dashboards/99?Display+Period+or+Quarter={{ _filters['profit_and_loss.parameter_display_period_or_quarter'] | url_encode }}&Select+Fiscal+Timeframe={{ profit_and_loss.fiscal_year._value | append: '.'| append: profit_and_loss.selected_time_dimension._value }}&Currency={{ _filters['profit_and_loss.target_currency_tcurr'] | url_encode }}&Company={{ _filters['profit_and_loss.company_text'] | url_encode }}"
    }
    # profit_and_loss.parameter_display_period_or_quarter
    # https://cortexdev.cloud.looker.com/dashboards/99?Currency=USD&Select+Fiscal+Timeframe=2023.Q4%2C2023.Q3&Company+%28text%29=C006-CYMBAL+US-CENTRAL&Display+Period+or+Quarter=qtr&Select+Comparison+Type=prior&GL+Level=3&Ledger+Name=Leading+Ledger
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
    # html: @{negative_format} ;;
  }

  measure: comparison_period_last_year_amount_in_global_currency {
    type: sum
    group_label: "Reporting v Comparison Period Metrics"
    label: "Last Year"
    sql: ${amount_in_target_currency} ;;
    filters: [fiscal_reporting_period: "Last Year"]
    value_format_name: decimal_0
    # html: @{negative_format} ;;
  }

  measure: difference_value {
    type: number
    group_label: "Reporting v Comparison Period Metrics"
    label: "Gain (Loss)"
    description: "Reporting Period Amount - Comparison Period Amount"
    sql: ${reporting_period_current_year_amount_in_global_currency} - ${comparison_period_last_year_amount_in_global_currency} ;;
    value_format_name: decimal_0
    # html: @{negative_format} ;;
  }

  measure: difference_percent {
    type: number
    group_label: "Reporting v Comparison Period Metrics"
    label: "Var %"
    description: "Percentage Change between Reporting and Comparison Periods"
    sql: safe_divide(${reporting_period_current_year_amount_in_global_currency},${comparison_period_last_year_amount_in_global_currency}) - 1 ;;
    value_format_name: percent_1
    # html: @{negative_format} ;;
  }




  #} end measures


  set: set_drill_profit_to_parent {
    fields: [profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,
      profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit.kpi_name,
      profit_and_loss.glparent_text,
      profit_and_loss.total_amount_in_global_currency]
  }

  set: set_drill_profit_to_child {
    fields: [profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,
      profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit.kpi_name,
      profit_and_loss.glparent_text,
      profit_and_loss.glnode_text,
      profit_and_loss.total_amount_in_global_currency]
  }

  measure: drill_profit_to_child {
    hidden: yes
    type: number
    sql: 1 ;;
    drill_fields: [set_drill_profit_to_child*]
  }

  measure: drill_profit_to_parent {
    hidden: yes
    type: number
    sql: 1 ;;
    drill_fields: [set_drill_profit_to_parent*]
  }

   }
