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
    label: "Amount in Global Currency"
  }

  dimension: cumulative_amount_in_target_currency {
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

  # filter: select_fiscal_periods {
  #   type: string
  #   suggest_explore: fiscal_periods_sdt
  #   suggest_dimension: fiscal_year_period
  #   suggest_persist_for: "1 seconds"
  # }



  measure: total_amount_in_global_currency {
    type: sum
    sql: ${cumulative_amount_in_target_currency} ;;
    value_format_name: millions_d1
    drill_fields: [fiscal_year, fiscal_period, level, parent_text, node_text, total_amount_in_global_currency]
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

  dimension: selected_display_level {
    view_label: "🗓️ Pick Dates OPTION 1"
    label: "Selected Display Level"
    type: string
    # label_from_parameter: shared_parameters.display
    sql: {% assign level = shared_parameters.display._parameter_value %}
      {% if level == 'fiscal_year'%}${fiscal_year}
        {% elsif level == 'fiscal_year_quarter' %} ${fiscal_year_quarter}
        {% elsif level == 'fiscal_year_period' %} ${fiscal_year_period}
        {% elsif level == 'fiscal_period_group' %} ${period_group}
        {% else %}'no match on level'
    {% endif %}
    ;;
  }

  # sql: {% assign level = display._parameter_value %}
  # {% if shared_parameters.pick_fiscal_periods._in_query %}
  # {% if level == 'fiscal_year'%}${selected_periods_sdt.fiscal_year}
  # {% elsif level == 'fiscal_year_quarter' %}${selected_periods_sdt.fiscal_year_quarter}
  # {% elsif level == 'fiscal_year_period' %}${selected_periods_sdt.fiscal_year_period}
  # {% else %}'no match on level'
  # {% endif %}
  # {% elsif shared_parameters.select_reporting_dates._in_query %}
  # {% if level == 'fiscal_year'%}${selected_fiscal_date_dim_sdt.fiscal_year}
  # {% elsif level == 'fiscal_year_quarter' %}${selected_fiscal_date_dim_sdt.fiscal_year_quarter}
  # {% elsif level == 'fiscal_year_period' %}${selected_fiscal_date_dim_sdt.fiscal_year_period}
  # {% else %}'no match on level'
  # {% endif %}
  # {% elsif select_fiscal_period_start._in_query %}
  # {% if level == 'fiscal_year'%}${fiscal_year}
  # {% elsif level == 'fiscal_year_quarter' %}${fiscal_year_quarter}
  # {% elsif level == 'fiscal_year_period' %}${fiscal_year_period}
  # {% else %}'no match on level'
  # {% endif %}
  # {% else %} "not in query" {% endif %};;

  #########################################################
  ## Reporting and Comparison Periods
  ## Option 1
  ## 3 parameters: select_fiscal_period_start, select_fiscal_period_end, compare_to
  #########################################################

  parameter: select_fiscal_period_start {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_year_period
  }

  parameter: select_fiscal_period_end {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_year_period
  }

  parameter: compare_to {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: unquoted
    allowed_value: {
      label: "Year over Year" value: "yoy"
    }
    allowed_value: {
      label: "Previous Period" value: "previous"
    }
    default_value: "yoy"
  }

  dimension: report_period_start_date {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: date
    sql:    {% assign combine = select_fiscal_period_start._parameter_value | append:',' | append:select_fiscal_period_end._parameter_value %}
            {% assign combine_array = combine | split: ',' | sort  %}
            {% assign start_date = combine_array[0] %}


    PARSE_DATE('%Y.%m','{{start_date}}') ;;
  }

  dimension: report_period_end_date {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: date
    sql: {% assign combine = select_fiscal_period_start._parameter_value | append:',' | append:select_fiscal_period_end._parameter_value %}
            {% assign combine_array = combine | split: ',' | sort  %}
            {% assign end_date = combine_array[1] %}
      PARSE_DATE('%Y.%m','{{end_date}}') ;;
  }

  dimension: selected_period_count {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: number
    sql: 1 + abs(date_diff(${report_period_end_date},${report_period_start_date},MONTH)) ;;
  }

  dimension: compare_period_start_date {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: date
    sql:    {% assign combine = select_fiscal_period_start._parameter_value | append:',' | append:select_fiscal_period_end._parameter_value %}
            {% assign combine_array = combine | split: ',' | sort  %}
            {% assign start_date = combine_array[0] %}
        {% if compare_to._parameter_value == 'yoy' %}
         date_sub(PARSE_DATE('%Y.%m','{{start_date}}'), INTERVAL 1 YEAR)
        {% elsif compare_to._parameter_value == 'previous' %}

         date_sub(PARSE_DATE('%Y.%m','{{start_date}}'), INTERVAL ${selected_period_count} MONTH)
        {% else %}
         cast(null as date)
        {% endif %};;
  }

  # dimension: testing {
  #   view_label: ". Test Stuff"
  #   type: string
  #   sql: {% assign combine = select_fiscal_period_start._parameter_value | append: ',' | append: select_fiscal_period_end._parameter_value %}
  #       {% assign combine_array = combine | split: ',' | sort %}
  #           {% assign start_date = combine_array[0] %}
  #   '{{combine_array[0]}}';;
  # }

  dimension: compare_period_end_date {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: date
    sql:
            {% assign combine = select_fiscal_period_start._parameter_value | append:',' | append:select_fiscal_period_end._parameter_value %}
            {% assign combine_array = combine | split: ',' | sort  %}
            {% assign start_date = combine_array[0] %}
            {% assign end_date = combine_array[1] %}
        {% if compare_to._parameter_value == 'yoy' %}
         date_sub(PARSE_DATE('%Y.%m','{{end_date}}'), INTERVAL 1 YEAR)
        {% elsif compare_to._parameter_value == 'previous' %}
         date_sub(PARSE_DATE('%Y.%m','{{start_date}}'), INTERVAL 1 MONTH)
        {% else %}
        cast(null as date)
        {% endif %};;
  }

  dimension: period_group {
    view_label: "🗓️ Pick Dates OPTION 1"
    type: string
    sql: case when PARSE_DATE('%Y.%m',${fiscal_year_period}) between ${report_period_start_date} and ${report_period_end_date} then 'Reporting Period'
              when PARSE_DATE('%Y.%m',${fiscal_year_period}) between ${compare_period_start_date} and ${compare_period_end_date} then 'Comparison Period'
        end ;;
  }

  measure: current_assets {
    type: sum
    sql:  ${amount_in_target_currency};;
    filters: [node_text: "Current Assets"]
  }

  measure: current_liabilities {
    type: sum
    sql:  ${amount_in_target_currency};;
    filters: [node_text: "Current Liabilities"]
  }

  measure: current_ratio {
    type: number
    sql: safe_divide(${current_assets},${current_liabilities}) * -1;;
    value_format_name: decimal_2
  }






 }
