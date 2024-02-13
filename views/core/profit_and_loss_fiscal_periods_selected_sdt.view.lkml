#########################################################
# This SQL Derived Table (sdt):
#   1) Takes user inputs from parameters and filters:
#         profit_and_loss.parameter_display_time_dimension - display either Period or Quarter in report
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
#           NOTE: A UNION is used because a user is able to select multiple periods to display in report there Reporting and Comparison periods may overlap
#   3) Uses the existing view fiscal_periods_sdt. All this view is based on BalanceSheet, ProfitAndLoss shares the same fiscal periods.
#      Dimensions already defined and labeled in the fiscal_periods_sdt are extended into this view using the extends parameter
#
#   4) Defines reporting measures:
#         current_amount
#         comparison_amount
#         difference_value
#         difference_percent
#      Note, these measures reference fields from profit_and_loss view
#      so always join this view to profit_and_loss using an inner join on:
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
              {% assign time_level = profit_and_loss.parameter_display_time_dimension._parameter_value %}

              {% if time_level == 'fp' %}
                  {% assign anchor_time = 'fiscal_year_period' %}
                  {% assign max_fp = '@{max_fiscal_period}' %}
                  {% assign pad = '00' %}{% assign max_fp_size = 3 %}{% assign max_fp_size_neg = -3 %}
              {% elsif time_level == 'qtr' %}
                  {% assign anchor_time = 'fiscal_year_quarter' %}
                  {% assign max_fp = 'Q4' %}{% assign pad = 'Q' %}{% assign max_fp_size = 2 %}{% assign max_fp_size_neg = -2 %}
              {% else %}
                  {% assign anchor_time = 'fiscal_year' %}
                  {% assign max_fp = 'NA' %}{% assign pad = '' %}{% assign max_fp_size = 4 %}{% assign max_fp_size_neg = -4 %}
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
      MAX(selected_timeframe) OVER (PARTITION BY alignment_group) AS focus_timeframe,
      comparison_type,
      max_fiscal_period_per_year
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
            RANK() OVER (ORDER BY {{anchor_time}} DESC) AS alignment_group,
            {{anchor_time}} AS selected_timeframe,
            '{{comparison_type}}' AS comparison_type,
            MAX(fiscal_period) OVER (PARTITION BY fiscal_year) as max_fiscal_period_per_year
          FROM ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
          WHERE {% condition profit_and_loss.filter_fiscal_timeframe %}
                   --{% if time_level == 'fp' %}fiscal_year_period{% else %} fiscal_year_quarter {% endif %}
                  {{anchor_time}}
                {% endcondition %}

      {% if comparison_type != 'none'  %}
        -- part 2: UNION ALL for Comparison timeframes as derived from values selected in filter_fiscal_timeframe and parameter_compare_to
         UNION ALL
          SELECT
            fp.fiscal_year,
            fp.fiscal_period,
            fiscal_year_quarter,
            fiscal_year_period,
            negative_fiscal_year_period_number,
            negative_fiscal_year_quarter_number,
            'Comparison' AS fiscal_period_group,
            RANK() OVER (ORDER BY fp.{{anchor_time}} DESC) AS alignment_group,
            fp.{{anchor_time}} AS selected_timeframe,
            '{{comparison_type}}' AS comparison_type,
            MAX(fp.fiscal_period) OVER (PARTITION BY fp.fiscal_year) as max_fiscal_period_per_year
          FROM ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
          {% if time_level == 'yr' %}
            --if current year is only a partial year, keep equivalent ytd periods for comparison
            JOIN (SELECT fiscal_year,
                         CAST(PARSE_NUMERIC(fiscal_year) - 1 as STRING) as comparison_year,
                         MAX(fiscal_period) as max_fiscal_period
                  FROM ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
                  WHERE {% condition profit_and_loss.filter_fiscal_timeframe %}{{anchor_time}}{% endcondition %}
                  GROUP BY fiscal_year, comparison_year) mfp
             ON fp.fiscal_year = mfp.comparison_year
             AND fp.fiscal_period <= mfp.max_fiscal_period
          {% endif %}
          WHERE
          {% if comparison_type == 'yoy' or comparison_type == 'prior' %}
             {% for p in tp_array %}
                {% assign p_array = p | split: '.' %}
                {% if forloop.last == true %}{%assign d = ''%}{%else%}{%assign d = ','%}{%endif%}
                {% assign delim = '.' %}

                {% if time_level == 'yr' %}
                   {% assign m = ''%}
                   {% assign sub_yr = 1 %}
                   {% assign delim = '' %}
                {% elsif time_level != 'yr' and comparison_type == 'yoy' %}
                      {% assign m = p_array[1] %}
                      {% assign sub_yr = 1 %}

                {% elsif time_level != 'yr' and comparison_type == 'prior' %}
                           {% if p_array[1] == '001' or p_array[1] == 'Q1' %}
                              {% assign m = max_fp | prepend: pad | slice: max_fp_size_neg, max_fp_size%}{% assign sub_yr = 1 %}
                            {% else %}
                              {% assign m = p_array[1] | remove: 'Q' | times: 1 | minus: 1 | prepend: pad | slice: max_fp_size_neg, max_fp_size %}{% assign sub_yr = 0 %}
                            {% endif %}
                {% endif %}

                {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
                {% assign cp_list = cp_list | append: "'" | append: yr | append: delim | append: m | append: "'" | append: d %}
            {% endfor%}

        fp.{{anchor_time}} in ( {{cp_list}} )
        {% endif %}

      {% endif %}
      ) t0

      {% else %}
      SELECT
            fiscal_year,
            fiscal_period,
            fiscal_year_quarter,
            fiscal_year_period,
            negative_fiscal_year_period_number,
            negative_fiscal_year_quarter_number,
            'Current' AS fiscal_period_group,
            1 as alignment_group,
            {{anchor_time}} AS selected_timeframe,
            CAST(null as STRING) AS focus_timeframe
      FROM ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
      {% endif %}
        ;;
    }

  dimension: key {
    hidden: yes
    primary_key: yes
    sql: CONCAT(${fiscal_period_group},${fiscal_year_period}) ;;
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

  # if only a partial year comparison, use this dimension to build YTD through period XXX statement that can be included in dashboard
  dimension: max_fiscal_period_per_year {
    type: string
    sql: {% if profit_and_loss.parameter_display_time_dimension._parameter_value == 'yr'%}${TABLE}.max_fiscal_period_per_year{% else %}" "{%endif%} ;;
    html: {% if profit_and_loss.parameter_display_time_dimension._parameter_value == 'yr'%}<p style=font-size:80%;><em>YTD through period {{value}}</em></p>{% else %} {%endif%} ;;
  }

  measure: current_amount {
    type: sum_distinct
    group_label: "Current v Comparison Period Metrics"
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% assign timelevel = profit_and_loss.parameter_display_time_dimension._parameter_value %}Current {%if timelevel =='yr'%}Year{% elsif timelevel == 'qtr' %}Quarter{%else%}Period{%endif%}{%else%}Current Amount{%endif%}"
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Current"]
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: comparison_amount {
    type: sum_distinct
    group_label: "Current v Comparison Period Metrics"
    # label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% assign compare = profit_and_loss.parameter_compare_to._parameter_value %}
    #         {% assign timelevel = profit_and_loss.parameter_display_time_dimension._parameter_value %}{% if compare == 'yoy' %}Prior Year
    #         {% elsif compare == 'prior'%}Prior {% if timelevel == 'yr'%}Year{% elsif timelevel == 'qtr' %}Quarter{%else%}Period{%endif%}
    #         {% elsif compare == 'none'%} .
    #         {%else%}Comparison{%endif%}{%else%}Comparison Amount{%endif%}"
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% assign compare = profit_and_loss.parameter_compare_to._parameter_value %}{% case profit_and_loss.parameter_display_time_dimension._parameter_value %}{% when 'qtr'%}{%assign timelabel = 'Quarter'%}{% when 'fp' %}{% assign timelabel = 'Period'%}{%else%}{% if compare == 'yoy'%}{% assign timelabel = ''%}{%else%}{%assign timelabel = 'Year'%}{%endif%}{% endcase %}{% if compare == 'yoy'%}{{timelabel | append: ' Prior Year'}}{%elsif compare == 'prior' %}Prior {{timelabel}}{%elsif compare == 'none'%}.{%else%}Comparison Amount{%endif%}
            {%else%}Comparison Amount{%endif%}"
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}${profit_and_loss.amount_in_target_currency}{%else%}NULL{%endif%} ;;
    filters: [fiscal_period_group: "Comparison"]
    value_format_name: decimal_0
    html: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}@{negative_format}{%else%} {%endif%} ;;
  }

  measure: difference_value {
    type: number
    group_label: "Current v Comparison Period Metrics"
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}Variance Amount{%else%} . {%endif%}{%else%}Variance Amount{%endif%}"
    sql: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}${current_amount} - ${comparison_amount}{%else%}NULL{%endif%} ;;
    value_format_name: decimal_0
    html: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}@{negative_format}{%else%} {%endif%} ;;
  }

  measure: difference_percent {
    type: number
    group_label: "Current v Comparison Period Metrics"
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}Variance %{%else%} . {%endif%}{%else%}Variance %{%endif%}"
    # sql: safe_divide(${current_amount},${comparison_amount}) - 1 ;;
    # use ABS for denominator as negative values are possible in both numerator and denominator. ABS allows for % Change to be negative when both are negative.
    sql: SAFE_DIVIDE( (${current_amount} - ${comparison_amount}),ABS(${comparison_amount})) ;;
    value_format_name: percent_1
    html: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}@{negative_format}{%else%} {%endif%} ;;
  }
    }
