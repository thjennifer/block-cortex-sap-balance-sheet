include: "/views/base/balance_sheet.view"

view: +balance_sheet {
  dimension: client {hidden: yes}

  dimension: client_mandt {
    type: string
    label: "Client"
    sql: ${TABLE}.Client ;;
  }

  dimension: language_key_spras {
    hidden: no
    label: "Language Key"
  }

  dimension: target_currency_tcurr {
    label: "Global Currency"
  }

  dimension: amount_in_target_currency {
    hidden: yes
    label: "Amount in Global Currency"
  }

  dimension: cumulative_amount_in_target_currency {
    hidden: yes
    label: "Cumulative Amount in Global Currency"
    description: "End of Period Net Amount in Target Currency"
  }

  dimension: fiscal_year_period {
    type: string
    sql: concat(${fiscal_year},'.',right(${fiscal_period},2)) ;;

  }

  dimension: fiscal_year_quarter {
    type: string
    sql: concat(${fiscal_year},'.Q',${fiscal_quarter}) ;;
  }

  dimension: fiscal_year_number {
    type: number
    sql: parse_numeric(${fiscal_year}) ;;
    value_format_name: id
  }

  dimension: fiscal_period_number {
    type: number
    sql: parse_numeric(${fiscal_period}) ;;
    value_format_name: id
  }

  dimension: fiscal_year_period_number {
    type: number
    sql: parse_numeric(concat(${fiscal_year},right(${fiscal_period},2))) ;;
    value_format_name: id
  }


  measure: total_amount_in_global_currency {
    type: sum
    label: "Total Amount (Global Currency)"
    description: "Period in Target or Global Currency"
    sql: ${cumulative_amount_in_target_currency} ;;
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



  # measure: reporting_period_amount_in_global_currency {
  #   type: sum
  #   sql: ${amount_in_target_currency} ;;
  #   filters: [period_group: "Reporting Period"]
  # }

  # measure: comparison_period_amount_in_global_currency {
  #   type: sum
  #   sql: ${amount_in_target_currency} ;;
  #   filters: [period_group: "Comparison Period"]
  # }

  # measure: difference_value {
  #   type: number
  #   sql: ${reporting_period_amount_in_global_currency} - ${comparison_period_amount_in_global_currency} ;;
  # }

  # measure: percent_difference_value {
  #   type: number
  #   sql: safe_divide(${reporting_period_amount_in_global_currency},${comparison_period_amount_in_global_currency}) - 1 ;;
  #   value_format_name: percent_1
  # }



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



  dimension: fiscal_period_group {
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






 }
