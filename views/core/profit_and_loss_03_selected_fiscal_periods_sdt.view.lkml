#########################################################{
# Step 3 of 3 in deriving Current and Comparison Reporting Groups
# Step 3 - Combine Current and Comparison Groups
# This SQL Derived Table (sdt) uses these views:
#     profit_and_loss_01_current_fiscal_periods_sdt (aliased below as cur)
#     profit_and_loss_02_comparison_fiscal_periods_sdt (aliased below as comp)
#
# Purpose:
#   1) Takes user inputs from parameters and filters:
#         profit_and_loss.parameter_display_time_dimension - use either Year, Quarter or Period for timeframes in report
#         profit_and_loss.parameter_compare_to - - compare timeframes selected to either same period(s) last year, most recent period(s) prior or no comparison
#         profit_and_loss.parameter_aggregate - if yes, all timeframes selected will be aggregated into Current/Comparison Period else each timeframe selected will be displayed in report
#         profit_and_loss.filter_fiscal_timeframe - select one or more fiscal periods to include in Income Statement report
#
#   2) Using Liquid, builds SQL statement on the fly based on values selected for above parameters
#      and combines "Current" and "Comparison" rows using UNION ALL
#
#   3) Derives new dimensions:
#         alignment_group_name -- if parameter_aggregate = 'Yes' assign list of timeframes selected else
#                            derive with MAX([timeframe]) OVER (glhierarchy, company_code, alignment_group)
#
#                            If multiple timeframes selected and Aggregate = 'No', each set of comparisons will be given a unique group number
#                            e.g., if user selects 2024.001 and 2024.002 to compare to same periods last year and Aggregate = 'No', two alignment groups will be defined as:
#                            alignment group 1 = 2024.001 compared to 2023.001 and alignment_group_name = 2024.001
#                            alignment group 2 = 2024.002 compared to 2023.002 and alignment_group_name = 2024.002
#
#                            If multiple timeframes selected and Aggregate = 'Yes', all timeframes will be combined into 1 alignment group.
#                            e.g., if user selects 2024.001 and 2024.002 to compare to same periods last year, two alignment groups with focus_timeframe labels will be defined as:
#                            alignment group 1 = 2024.001 + 2024.002 compared to 2023.001 + 2023.002
#                            and alignment_group_name = 2024.001, 2024.002
#
#        selected_timeframes_list -- captures the values selected in filter_fiscal_timeframe as a string (e.g., 2024.001, 2024.002, 2024.003)
#   4) Defines reporting measures:
#         current_amount
#         comparison_amount
#         difference_value
#         difference_percent
#      Note, these measures reference fields from profit_and_loss view
#      so always join this view to profit_and_loss using an inner join on:
#         glhierarchy
#         company_code
#         fiscal_year
#         fiscal_period
#      Note, the profit_and_loss_fiscal_periods_sdt view already filters to the same Client id so it is not needed in the join.
##########################################################}

include: "/views/core/profit_and_loss_0*.view"

view: profit_and_loss_03_selected_fiscal_periods_sdt {
label: "Income Statement"
fields_hidden_by_default: yes

derived_table: {
  sql:
  {% assign comparison_type = profit_and_loss.parameter_compare_to._parameter_value %}
  {% assign tp_list = _filters['profit_and_loss.filter_fiscal_timeframe'] | sql_quote | remove: '"' | remove: "'" | replace: ",",", " %}
  {% assign aggregate = profit_and_loss.parameter_aggregate._parameter_value %}
  {% assign window_partition = "(PARTITION BY glhierarchy, company_code, alignment_group)" %}
  {% if aggregate == 'Yes' %}{% assign alignment_group_name_sql = "'" | append: tp_list | append: "'" %}
    {% else %}{% assign alignment_group_name_sql = "MAX(selected_timeframe) OVER (window_pk)" %}
  {% endif %}

{% if profit_and_loss.filter_fiscal_timeframe._is_filtered %}

  SELECT  glhierarchy,
          company_code,
          fiscal_year,
          fiscal_period,
          fiscal_year_quarter,
          fiscal_year_period,
          fiscal_reporting_group,
          alignment_group,
          {{alignment_group_name_sql}} as alignment_group_name,
          selected_timeframe,
          '{{tp_list}}' as selected_timeframe_list

  FROM (
        SELECT
                glhierarchy,
                company_code,
                fiscal_year,
                fiscal_period,
                fiscal_year_quarter,
                fiscal_year_period,
                fiscal_reporting_group,
                alignment_group,
                selected_timeframe
        FROM ${profit_and_loss_01_current_fiscal_periods_sdt.SQL_TABLE_NAME} cur
    {% if comparison_type != 'none'  %}
        UNION ALL
        SELECT
                glhierarchy,
                company_code,
                fiscal_year,
                fiscal_period,
                fiscal_year_quarter,
                fiscal_year_period,
                fiscal_reporting_group,
                alignment_group,
                selected_timeframe
        FROM ${profit_and_loss_02_comparison_fiscal_periods_sdt.SQL_TABLE_NAME} comp
    {% endif %}
        ) combine
        WINDOW window_pk AS {{window_partition}}
{% endif %}
  ;;
}

  dimension: key {
    type: string
    hidden: yes
    primary_key: yes
    sql: CONCAT(${glhierarchy},${company_code},${fiscal_reporting_group},${fiscal_year},${fiscal_period}) ;;
  }

  dimension: glhierarchy {
    type: string
    sql: ${TABLE}.glhierarchy ;;
  }

  dimension: company_code {
    type: string
    sql: ${TABLE}.company_code ;;
  }

  dimension: fiscal_year {
    type: string
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_period {
    type: string
    sql: ${TABLE}.fiscal_period ;;
  }

  dimension: selected_timeframe {
    type: string
    hidden: no
    description: "Returns either Fiscal Year, Fiscal Year Quarter or Fiscal Year Period as defined by parameter Display Year, Quarter or Period."
    group_label: "Current vs. Comparison Period"
    sql:  ${TABLE}.selected_timeframe;;
  }

  dimension: selected_timeframe_list {
    type: string
    hidden: no
    description: "List of fiscal timeframes selected by user with filter Select Fiscal Timeframes. Example lists include 2024.001, 2024.002 or 2023.Q3, 2023.Q4, 2024.Q1"
    group_label: "Current vs. Comparison Period"
    sql: ${TABLE}.selected_timeframe_list ;;
  }

  dimension: fiscal_reporting_group {
    type: string
    hidden: no
    description: "Identifies the Current or Comparison reporting group. In fiscal reporting, the Current group is determined by the values selected in the Select Fiscal Timeframes filter, while the Comparison group is defined by the Compare To parameter, which can be set to either Year Ago or Prior Timeframe."
    group_label: "Current vs. Comparison Period"
    sql:  ${TABLE}.fiscal_reporting_group;;
  }

  dimension: alignment_group {
    type: number
    hidden: yes
    group_label: "Current vs. Comparison Period"
    sql: ${TABLE}.alignment_group ;;
  }

  dimension: alignment_group_name {
    type: string
    hidden: no
    description: "Name for Grouped Timeframes Included in the same Current vs. Comparison set. For example, if Period 2024.001 is to be compared to a Year Ago, the periods 2024.001 and 2023.001 are assigned to same alignment group and given the label 2024.001."
    group_label: "Current vs. Comparison Period"
    sql: ${TABLE}.alignment_group_name ;;
    order_by_field: alignment_group
  }

  measure: current_amount {
    type: sum_distinct
    hidden: no
    group_label: "Current vs. Comparison Period"
    # Label is Current Amount by default. If filter_fiscal_timeframe in query and parameter_compare_to = 'none' then leave label blank"
    label: "{% assign compare = profit_and_loss.parameter_compare_to._parameter_value %}{% if profit_and_loss.filter_fiscal_timeframe._in_query and compare == 'none'%} {% else %}Current Amount{% endif %}"
    description: "Amount in Global Currency for the Current fiscal reporting group."
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [fiscal_reporting_group: "Current"]
    value_format_name: decimal_0
    html: @{negative_format} ;;
  }

  measure: comparison_amount {
    type: sum_distinct
    hidden: no
    group_label: "Current vs. Comparison Period"
    # Label is Comparison Amount by default. If filter_fiscal_timeframe in query, then Label is Year Ago Amount, Prior Amount or None based on parameter_compare_to
    label: "{% if profit_and_loss.filter_fiscal_timeframe._in_query%}{% assign compare = profit_and_loss.parameter_compare_to._parameter_value %}{% if compare == 'yoy' %}{%assign compare_label = 'Year Ago Amount' %}{%elsif compare == 'prior'%}{%assign compare_label = 'Prior Amount'%}{% else %}{% assign compare_label = 'None' %}{%endif%}{{compare_label}}{%else%}Comparison Amount{%endif%}"
    description: "Amount in Global Currency for the Comparison fiscal reporting group."
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}${profit_and_loss.amount_in_target_currency}{%else%}NULL{%endif%} ;;
    filters: [fiscal_reporting_group: "Comparison"]
    value_format_name: decimal_0
    html: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}@{negative_format}{%else%} {%endif%} ;;
  }

  measure: difference_value {
    type: number
    hidden: no
    group_label: "Current vs. Comparison Period"
    label: "Variance Amount"
    description: "Current Amount - Comparison Amount"
    sql: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}${current_amount} - ${comparison_amount}{%else%}NULL{%endif%} ;;
    value_format_name: decimal_0
    html: {% if profit_and_loss.parameter_compare_to._parameter_value != 'none' %}@{negative_format}{%else%} {%endif%} ;;
  }

  measure: difference_percent {
    type: number
    hidden: no
    group_label: "Current vs. Comparison Period"
    label: "Variance %"
    description: "Percent difference between Current Amount and Comparison Amount."
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
          <a style= "font-size:80%;font-family:'verdana';color: black">Current Fiscal Timeframe:   {{selected_timeframe_list._value}}&nbsp;&nbsp;&nbsp; Net Income: {{profit_and_loss.net_income._rendered_value}}M</a>
          <br>
          <a style= "font-size: 70%; text-align:center;font-family:'verdana';color: black"> Amounts in {{profit_and_loss.target_currency_tcurr}} </a>
       </div>
      ;;
  }
 }
