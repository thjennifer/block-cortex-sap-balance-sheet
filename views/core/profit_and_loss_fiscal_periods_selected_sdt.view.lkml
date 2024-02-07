#########################################################
# This SQL Derived Table (sdt):
#   1) Takes user inputs from parameters and filters:
#         profit_and_loss.parameter_display_period_or_quarter - display either Period or Quarter in report
#         profit_and_loss.filter_fiscal_timeframe - select one or more fiscal periods to include in Income Statement report
#         profit_and_loss.parameter_compare_to - compare timeframes selected to either same period(s) last year, most recent period(s) prior or no comparison
#   2) Using Liquid, builds SQL statement on the fly based on values selected for above parameters and filters
#         * part 1: select "Current" timeframes based on values selected in filter_fiscal_timeframe (using templated filter)
#         * part 2: if comparison type <> 'none', select "Comparison" timeframes as a UNION ALL statement.
#                   Dervie the WHERE clause using liquid to loop through each timeframe selected in filter_fiscal_timeframe
#                   and compute the comparison period based on value in parameter_compare_to.
#                   Results in list of periods seperated by commas:
#                      - For example, if Periods 2023.009 and 2023.008 selected with comparison to last year,
#                        then the derived WHERE clause for the Comparison periods is:
#                           WHERE fiscal_year_period in ('2022.009','2022.008')
#                      - For another example, if Quarters 2023.Q4 and 2023.Q3 are selected with comparison to last year,
#                        then the derived WHERE clause is:
#                           WHERE fiscal_year_quarter in ('2022.Q4','2022.Q3')
#
#   3) Uses the existing view fiscal_periods_sdt. All this view is based on BalanceSheet, ProfitAndLoss shares the same fiscal periods.
#      Dimensions already defined and labeled in the fiscal_periods_sdt are extended into this view using the extends parameter
#
#   4) Defines measures current_amount, comparison_amount, difference_value and difference_percent. These measures reference fields from profit_and_loss view
#      so always join to profit_and_loss using an inner join on:
#         fiscal_year
#         fiscal_period
#      Note, the fiscal_periods_sdt view already filters to the same Client id so it is not needed in the join.
#########################################################


include: "/views/core/fiscal_periods_sdt.view"

view: profit_and_loss_fiscal_periods_selected_sdt {
    label: "🗓 Pick Fiscal Periods"
    extends: [fiscal_periods_sdt]

    derived_table: {

      sql:    {% assign comparison_type = profit_and_loss.parameter_compare_to._parameter_value %}
              {% assign tp = _filters['profit_and_loss.filter_fiscal_timeframe'] | sql_quote | remove: '"' | remove: "'" %}
              {% assign tp_array = tp | split: ',' | uniq | sort %}
              {% assign time_level = profit_and_loss.parameter_display_period_or_quarter._parameter_value %}

              {% if time_level == 'fp' %}
                  {% assign anchor_time = 'fiscal_year_period' %}
                  {% assign max_fp = '@{max_fiscal_period}' %}
                  {% assign pad = '00' %}{% assign max_fp_size = 3 %}{% assign max_fp_size_neg = -3 %}
              {% else %}
                  {% assign anchor_time = 'fiscal_year_quarter' %}
                  {% assign max_fp = 'Q4' %}{% assign pad = 'Q' %}{% assign max_fp_size = 2 %}{% assign max_fp_size_neg = -2 %}
              {% endif %}

    {% if profit_and_loss.filter_fiscal_timeframe._is_filtered %}
    SELECT
      fiscal_year,
      fiscal_period,
      fiscal_year_quarter,
      fiscal_year_period,
      negative_fiscal_year_period_number,
      negative_fiscal_year_quarter_number,
      fiscal_period_group,
      alignment_group,
      selected_timeframe,
      max(selected_timeframe) over (partition by alignment_group) as focus_timeframe,
      comparison_type
    FROM (
        -- part 1: select Current timeframes based on values selected in filter_fiscal_timeframe
          SELECT
            fiscal_year,
            fiscal_period,
            fiscal_year_quarter,
            fiscal_year_period,
            negative_fiscal_year_period_number,
            negative_fiscal_year_quarter_number,
            'Current' as fiscal_period_group,
            RANK() over (ORDER BY {{anchor_time}} DESC) as alignment_group,
            {{anchor_time}} as selected_timeframe,
            '{{comparison_type}}' as comparison_type
          FROM ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
          WHERE {% condition profit_and_loss.filter_fiscal_timeframe %}
                   {% if time_level == 'fp' %}fiscal_year_period{% else %} fiscal_year_quarter {% endif %}
                {% endcondition %}

      {% if comparison_type != 'none'  %}
        -- part 2: UNION ALL for Comparison timeframes as derived from values selected in filter_fiscal_timeframe and parameter_compare_to
         UNION ALL
          SELECT
            fiscal_year,
            fiscal_period,
            fiscal_year_quarter,
            fiscal_year_period,
            negative_fiscal_year_period_number,
            negative_fiscal_year_quarter_number,
            'Comparison' as fiscal_period_group,
            rank() over (order by {{anchor_time}} desc) as alignment_group,
            {{anchor_time}} as selected_timeframe,
            '{{comparison_type}}' as comparison_type
          FROM ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
          WHERE
        {% if comparison_type == 'yoy' or comparison_type == 'prior' %}
             {% for p in tp_array %}
                {% assign p_array = p | split: '.' %}
                {% if forloop.last == true %}{%assign d = ''%}{%else%}{%assign d = ','%}{%endif%}

                {% if comparison_type == 'yoy' %}
                      {% assign m = p_array[1]  %}
                      {% assign sub_yr = 1 %}

                {% elsif comparison_type == 'prior' %}
                           {% if p_array[1] == '001' or p_array[1] == 'Q1' %}
                              {% assign m = max_fp | prepend: pad | slice: max_fp_size_neg, max_fp_size%}{% assign sub_yr = 1 %}
                            {% else %}
                              {% assign m = p_array[1] | remove: 'Q' | times: 1 | minus: 1 | prepend: pad | slice: max_fp_size_neg, max_fp_size %}{% assign sub_yr = 0 %}
                            {% endif %}
                {% endif %}

                {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
                {% assign cp_list = cp_list | append: "'" | append: yr | append: '.'| append: m | append: "'" | append: d %}
            {% endfor%}

        {{anchor_time}} in ( {{cp_list}} )
        {% endif %}
      {% endif %}
      ) t0

      {% else %}
      select
            fiscal_year,
            fiscal_period,
            fiscal_year_quarter,
            fiscal_year_period,
            negative_fiscal_year_period_number,
            negative_fiscal_year_quarter_number,
            'Current' as fiscal_period_group,
            1 as alignment_group,
            {{anchor_time}} as selected_timeframe,
            cast(null as string) as focus_timeframe
        from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
        {% endif %}
        ;;
    }

  dimension: key {
    hidden: yes
    primary_key: yes
    sql: concat(${fiscal_period_group},${fiscal_year_period}) ;;
  }

  dimension: fiscal_year_period {
    primary_key: no
  }

  dimension: selected_timeframe {
    type: string
    sql:  ${TABLE}.selected_timeframe;;
  }

  dimension: comparison_type {
    type: string
    sql:  ${TABLE}.comparison_type ;;
  }

  dimension: fiscal_period_group {
    type: string
    sql:  ${TABLE}.fiscal_period_group;;
  }

  dimension: alignment_group {
    type: number
    sql: ${TABLE}.alignment_group ;;
  }

  dimension: focus_timeframe {
    type: string
    sql: ${TABLE}.focus_timeframe ;;
  }

  measure: current_amount {
    type: sum_distinct
    group_label: "Current v Comparison Period Metrics"
    label: "{% assign timelevel = profit_and_loss.parameter_display_period_or_quarter._parameter_value %}Current {% if timelevel == 'qtr' %}Quarter{%else%}Period{%endif%}"
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Current"]
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: comparison_amount {
    type: sum_distinct
    group_label: "Current v Comparison Period Metrics"
    label: "{% assign compare = profit_and_loss.parameter_compare_to._parameter_value %}
            {% assign timelevel = profit_and_loss.parameter_display_period_or_quarter._parameter_value %}{% if compare == 'yoy' %}Last Year
            {%elsif compare == 'prior'%}Prior {% if timelevel == 'qtr' %}Quarter{%else%}Period{%endif%}
            {%else%}Comparison{%endif%}"
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Comparison"]
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: difference_value {
    type: number
    group_label: "Current v Comparison Period Metrics"
    label: "Gain (Loss)"
    sql: ${current_amount} - ${comparison_amount} ;;
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: difference_percent {
    type: number
    group_label: "Current v Comparison Period Metrics"
    label: "Var %"
    # sql: safe_divide(${current_amount},${comparison_amount}) - 1 ;;
    sql: SAFE_DIVIDE( (${current_amount} - ${comparison_amount}),abs(${comparison_amount})) ;;
    value_format_name: percent_1
    html: @{negative_format} ;;
  }
    }
