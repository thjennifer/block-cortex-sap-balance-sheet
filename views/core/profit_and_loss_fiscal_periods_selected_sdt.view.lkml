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


include: "/views/core/profit_and_loss_fiscal_periods_sdt.view"

view: profit_and_loss_fiscal_periods_selected_sdt {
  label: "Income Statement"
  extends: [profit_and_loss_fiscal_periods_sdt]

  fields_hidden_by_default: yes

  derived_table: {

    sql:
    {% assign comparison_type = profit_and_loss.parameter_compare_to._parameter_value %}
    {% assign time_level = profit_and_loss.parameter_display_time_dimension._parameter_value %}
    {% assign join2_logic = '' %}{% assign partial_timeframe_note = '' %}
    {% assign tp = _filters['profit_and_loss.filter_fiscal_timeframe'] | sql_quote | remove: '"' | remove: "'" | replace: ",",", " %}
    {% assign tp_array = tp | split: ',' | uniq | sort %}

    {% if time_level == 'fp' %}
      {% assign anchor_time = 'fiscal_year_period' %}
      {% assign check_for_partial_with = '1' %}{% assign check_for_partial_against = '1' %}
      {% assign check_for_partial_max_in_timeframe = ''%}{% assign check_for_partial_max_in_alignment = ''%}
      {% assign check_for_partial_note = '' %}{% assign window = '(PARTITION BY 1)'%}
      --{% assign check_for_partial_against = '0' %}
      --{% assign check_for_partial_then = '' %}
    {% elsif time_level == 'qtr' %}
      {% assign anchor_time = 'fiscal_year_quarter' %}
      {% assign join2_logic = 'AND fp0.period_order_in_quarter = fp1.period_order_in_quarter' %}
      {% assign check_for_partial_with = 'period_order_in_quarter' %}{% assign check_for_partial_against = 'max_periods_in_quarter' %}
      {% assign window = '(PARTITION BY glhierarchy, company_code, fiscal_year, fiscal_quarter)' %}
      {% assign check_for_partial_max_in_timeframe = 'MAX(' | append: check_for_partial_with | append: ') OVER (check_partial_window) '%}
      {% assign check_for_partial_max_in_alignment = 'MAX(partial_max_in_timeframe) OVER (partition_alignment_group)' %}
      {% assign check_for_partial_note = "CONCAT('QTD (',"| append: check_for_partial_max_in_alignment | append: ",' periods)')" %}
   {% else %}
      {% assign anchor_time = 'fiscal_year' %}
      {% assign join2_logic = 'AND fp0.fiscal_period = fp1.fiscal_period' %}
      {% assign check_for_partial_with = 'fiscal_period' %}{% assign check_for_partial_against = 'max_fiscal_period_in_year' %}
      {% assign window = '(PARTITION BY glhierarchy, company_code, fiscal_year)' %}
      {% assign check_for_partial_max_in_timeframe = 'MAX(' | append: check_for_partial_with | append: ') OVER (check_partial_window) '%}
      {% assign check_for_partial_max_in_alignment = 'MAX(partial_max_in_timeframe) OVER (partition_alignment_group)' %}
      {% assign check_for_partial_note = "CONCAT('YTD (through period ',"| append: check_for_partial_max_in_alignment | append: ",')')" %}
   {% endif %}

      {% assign comparison_field = 'fp0.' | append: comparison_type | append: '_' | append: anchor_time %}
      {% assign current_field = 'fp1.' | append: anchor_time %}
      {% assign join1_logic = 'AND ' | append: comparison_field | append: ' = ' | append: current_field %}

      {% if profit_and_loss.filter_fiscal_timeframe._is_filtered %}
      SELECT
        glhierarchy,
        company_code,
        fiscal_year,
        fiscal_period,
        fiscal_year_quarter,
        fiscal_year_period,
        fiscal_period_group,
        alignment_group,
        selected_timeframe,
        MAX(selected_timeframe) OVER (partition_alignment_group) AS focus_timeframe,
        comparison_type,
        {% if time_level != 'fp'%}MAX(is_partial_timeframe) OVER (partition_alignment_group){% else %}false{%endif%}  as is_partial_timeframe,
        {% if time_level != 'fp'%}MAX(partial_max_in_timeframe) OVER (partition_alignment_group){% else %}null{%endif%} as partial_timeframe_max,
        {% if time_level != 'fp'%}if(MAX(is_partial_timeframe) OVER (partition_alignment_group),{{check_for_partial_note}},''){% else %}''{%endif%} as partial_timeframe_note,
        selected_timeframes_string

      FROM (
          -- part 1: select Current timeframes based on values selected in filter_fiscal_timeframe
          SELECT
            glhierarchy,
            company_code,
            fiscal_year,
            fiscal_period,
            fiscal_year_quarter,
            fiscal_year_period,
            'Current' as fiscal_period_group,
            RANK() OVER (PARTITION BY glhierarchy, company_code ORDER BY {{anchor_time}} DESC) AS alignment_group,
            {{anchor_time}} AS selected_timeframe,
            '{{comparison_type}}' AS comparison_type,
            {% if time_level != 'fp'%}{{check_for_partial_max_in_timeframe}} < {{check_for_partial_against}}
            {%else%}CAST(NULL as BOOL){%endif%} as is_partial_timeframe,
            {% if time_level != 'fp'%}cast({{check_for_partial_max_in_timeframe}} as STRING){%else%}''{%endif%}  as partial_max_in_timeframe,
            '{{tp}}' as selected_timeframes_string
          FROM ${profit_and_loss_fiscal_periods_sdt.SQL_TABLE_NAME} fp
          WHERE {% condition profit_and_loss.filter_fiscal_timeframe %}{{anchor_time}}{% endcondition %}
          WINDOW check_partial_window AS {{window}}

        {% if comparison_type != 'none'  %}
        -- part 2: UNION ALL for Comparison timeframes as derived from values selected in filter_fiscal_timeframe and parameter_compare_to
        UNION ALL
          SELECT
              fp1.glhierarchy,
              fp1.company_code,
              fp1.fiscal_year,
              fp1.fiscal_period,
              fp1.fiscal_year_quarter,
              fp1.fiscal_year_period,
              'Comparison' AS fiscal_period_group,
              RANK() OVER (PARTITION BY fp1.glhierarchy, fp1.company_code ORDER BY fp1.{{anchor_time}} DESC) AS alignment_group,
              fp1.{{anchor_time}} AS selected_timeframe,
              '{{comparison_type}}' AS comparison_type,
              CAST(NULL AS BOOL) as is_partial_timeframe,
              CAST(NULL AS STRING) as partial_max_in_timeframe,
               '{{tp}}' as selected_timeframes_string
          FROM ${profit_and_loss_fiscal_periods_sdt.SQL_TABLE_NAME} fp0
          JOIN ${profit_and_loss_fiscal_periods_sdt.SQL_TABLE_NAME} fp1
          ON fp0.glhierarchy = fp1.glhierarchy
          AND fp0.company_code = fp1.company_code
          {{join1_logic}}
          {{join2_logic}}
          WHERE {% condition profit_and_loss.filter_fiscal_timeframe %}fp0.{{anchor_time}}{% endcondition %}

        {% endif %}
      ) t0
      WINDOW partition_alignment_group AS (PARTITION BY glhierarchy, company_code, alignment_group)
      {% else %}
      SELECT
          glhierarchy,
          company_code,
          fiscal_year,
          fiscal_period,
          fiscal_year_quarter,
          fiscal_year_period,
          'Current' AS fiscal_period_group,
          1 as alignment_group,
          {{anchor_time}} AS selected_timeframe,
          MAX({{anchor_time}}) OVER (partition_alignment_group) AS focus_timeframe,
          CAST(null as STRING) AS focus_timeframe,
          CAST(null as STRING) as partial_timeframe_note,
          '{{comparison_type}}' AS comparison_type,
          CAST(NULL AS BOOL) as is_partial_timeframe,
          CAST(NULL AS STRING) as partial_timeframe_max,
          CAST(NULL AS STRING) as partial_timeframe_note,
          '{{tp}}' as selected_timeframes_string

      FROM ${profit_and_loss_fiscal_periods_sdt.SQL_TABLE_NAME} fp
      {% endif %}
      ;;
  }


  dimension: key {
    hidden: yes
    primary_key: yes
    sql: CONCAT(${unique_id},${fiscal_period_group}) ;;
  }



  dimension: unique_id {
    primary_key: no
  }

  dimension: selected_timeframe {
    type: string
    hidden: no
    group_label: "Current v Comparison Period"
    sql:  ${TABLE}.selected_timeframe;;
  }

  dimension: selected_timeframes_string {
    type: string
    hidden: no
    group_label: "Current v Comparison Period"
    sql: ${TABLE}.selected_timeframes_string ;;
  }

  dimension: comparison_type {
    type: string
    sql:  ${TABLE}.comparison_type ;;
  }

  dimension: fiscal_period_group {
    type: string
    hidden: no
    sql:  ${TABLE}.fiscal_period_group;;
  }

  dimension: alignment_group {
    type: number
    hidden: no
    group_label: "Current v Comparison Period"
    sql: ${TABLE}.alignment_group ;;
  }

  dimension: focus_timeframe {
    type: string
    hidden: yes
    group_label: "Current v Comparison Period"
    sql: ${TABLE}.focus_timeframe ;;
  }

  # if only a partial year comparison, use this dimension to build YTD through period XXX statement that can be included in dashboard
  dimension: max_fiscal_period_per_year {
    type: string
    hidden: no
    group_label: "Current v Comparison Period"
    sql: {% if profit_and_loss.parameter_display_time_dimension._parameter_value == 'yr'%}${TABLE}.max_fiscal_period_per_year{% else %}" "{%endif%} ;;
    html: {% if profit_and_loss.parameter_display_time_dimension._parameter_value == 'yr'%}<p style=font-size:80%;><em>YTD through period {{value}}</em></p>{% else %} {%endif%} ;;
  }

  dimension: partial_timeframe_note {
    type: string
    hidden: no
    group_label: "Current v Comparison Period"
    sql: ${TABLE}.partial_timeframe_note ;;
  }

  measure: current_amount {
    type: sum_distinct
    hidden: no
    group_label: "Current v Comparison Period"
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% assign timelevel = profit_and_loss.parameter_display_time_dimension._parameter_value %}Current {%if timelevel =='yr'%}Year{% elsif timelevel == 'qtr' %}Quarter{%else%}Period{%endif%}{%else%}Current Amount{%endif%}"
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Current"]
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: comparison_amount {
    type: sum_distinct
    hidden: no
    group_label: "Current v Comparison Period"
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
    hidden: no
    group_label: "Current v Comparison Period"
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}Variance Amount{%else%} . {%endif%}{%else%}Variance Amount{%endif%}"
    sql: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}${current_amount} - ${comparison_amount}{%else%}NULL{%endif%} ;;
    value_format_name: decimal_0
    html: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}@{negative_format}{%else%} {%endif%} ;;
  }

  measure: difference_percent {
    type: number
    hidden: no
    group_label: "Current v Comparison Period"
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}Variance %{%else%} . {%endif%}{%else%}Variance %{%endif%}"
    # sql: safe_divide(${current_amount},${comparison_amount}) - 1 ;;
    # use ABS for denominator as negative values are possible in both numerator and denominator. ABS allows for % Change to be negative when both are negative.
    sql: SAFE_DIVIDE( (${current_amount} - ${comparison_amount}),ABS(${comparison_amount})) ;;
    value_format_name: percent_1
    html: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}@{negative_format}{%else%} {%endif%} ;;
  }

# used in Income Statement dashboard; add to a single-value visualization
  measure: title_income_statement {
    type: number
    description: "Used in Income Statement dashboard as Summary visualization with Company, Global Currency, Fiscal Timeframes and Net Income."
    hidden: no
    sql: 1 ;;
    html:
      <div  style="font-size:100pct; background-color:rgb((169,169,169,.5); text-align:center;  line-height: .8; font-family:'Noto Sans SC'; font-color: #808080">
          <a style="font-size:100%;font-family:'verdana';color: black"><b>Income Statement</b></a><br>
          <a style= "font-size:80%;font-family:'verdana';color: black">{{profit_and_loss.company_text._value}}</a><br>
          <a style= "font-size:80%;font-family:'verdana';color: black">Fiscal Timeframes:   {{selected_timeframes_string._value}}&nbsp;&nbsp;&nbsp; Net Income: {{profit_and_loss.net_income._rendered_value}}M</a>
          <br>
          <a style= "font-size: 70%; text-align:center;font-family:'verdana';color: black"> Amounts in {{profit_and_loss.target_currency_tcurr}} </a>
       </div>
      ;;
  }

}
