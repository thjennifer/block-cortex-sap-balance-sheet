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

  dimension: fiscal_year_period {
    type: string
    sql: concat(${fiscal_year},'.',right(${fiscal_period},2)) ;;

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

  filter: select_fiscal_periods {
    type: string
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_year_period
    suggest_persist_for: "1 seconds"
  }



  measure: total_amount_in_global_currency {
    type: sum
    sql: ${amount_in_target_currency} ;;
    value_format_name: decimal_2
  }

  #########################################################
  ## Reporting and Comparison Periods
  ## Option 1
  ## 3 parameters: select_fiscal_period_start, select_fiscal_period_end, compare_to
  #########################################################

  parameter: select_fiscal_period_start {
    view_label: ". Test Stuff"
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_year_period
  }

  parameter: select_fiscal_period_end {
    view_label: ". Test Stuff"
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_year_period
  }

  parameter: compare_to {
    view_label: ". Test Stuff"
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
    view_label: ". Test Stuff"
    type: date
    sql:    {% assign combine = select_fiscal_period_start._parameter_value | append:',' | append:select_fiscal_period_end._parameter_value %}
            {% assign combine_array = combine | split: ',' | sort  %}
            {% assign start_date = combine_array[0] %}


    PARSE_DATE('%Y.%m','{{start_date}}') ;;
  }

  dimension: report_period_end_date {
    view_label: ". Test Stuff"
    type: date
    sql: {% assign combine = select_fiscal_period_start._parameter_value | append:',' | append:select_fiscal_period_end._parameter_value %}
            {% assign combine_array = combine | split: ',' | sort  %}
            {% assign end_date = combine_array[1] %}
      PARSE_DATE('%Y.%m','{{end_date}}') ;;
  }

  dimension: selected_period_count {
    view_label: ". Test Stuff"
    type: number
    sql: 1 + abs(date_diff(${report_period_end_date},${report_period_start_date},MONTH)) ;;
  }

  dimension: compare_period_start_date {
    view_label: ". Test Stuff"
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
    view_label: ". Test Stuff"
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
    view_label: ". Test Stuff"
    type: string
    sql: case when PARSE_DATE('%Y.%m',${fiscal_year_period}) between ${report_period_start_date} and ${report_period_end_date} then 'Reporting Period'
              when PARSE_DATE('%Y.%m',${fiscal_year_period}) between ${compare_period_start_date} and ${compare_period_end_date} then 'Compare Period'
        end ;;
  }

 }
