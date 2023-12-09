######################
# Defines Fiscal Period filter/parameters needed for the Balance Sheet Dashboard
#
# Extends view fiscal_periods_sdt in order to capture dimensions/measures already defined
#
# Includes the dimension negative_fiscal_year_period_number which:
#   - is used as an order_by_field for fiscal_year_period
#   - allows the fiscal_year_period to be displayed in descending order in paramter/filter drop-down selectors
######################


include: "/views/core/fiscal_periods_sdt.view.lkml"


view: fiscal_periods_selected_sdt {
  label: "🗓 Pick Fiscal Periods"
  extends: [fiscal_periods_sdt]


  derived_table: {
    sql:    {% assign comparison_type = select_comparison_type._parameter_value %}
            {% assign fp = select_fiscal_period._parameter_value %}
            {% assign cp_check = select_custom_comparison_period._parameter_value %}
            {% if comparison_type == 'custom' %}
                {% if fp == cp_check %}{% assign comparison_type = 'none' %}
                {% elsif cp_check == '' %}{% assign comparison_type = 'yoy' %}
                {% endif %}
            {% endif %}

            {% if comparison_type == 'custom' %}{% assign cp = cp_check | prepend: ",'" | append: "'" %}
            {% elsif comparison_type == 'yoy' or comparison_type == 'prior'%}
                {% assign p_array = fp | split: '.' %}
                    {% if comparison_type == 'prior' %}
                        {% if p_array[1] == '01' %}
                              {% assign m = '12' %}{% assign sub_yr = 1 %}
                        {% else %}
                              {% assign m = p_array[1] | times: 1 | minus: 1 | prepend: '00' | slice: -2, 2 %}{% assign sub_yr = 0 %}
                        {% endif %}
                  {% else %} {% assign m = p_array[1]  %}{% assign sub_yr = 1 %}
                  {% endif %}
                {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
                {% assign cp = ",'" | append: yr | append: '.'| append: m | append: "'" %}
            {%else%}{% assign cp = ' ' %}
            {% endif %}

            select fp.*
                  ,case fiscal_year_period when '{{fp}}' then 'Reporting'
                                  {% if comparison_type != 'none' %}
                                          when {{cp | remove: ','}} then 'Comparison'
                                  {% endif %}
                  end as fiscal_period_group
                  ,rank() over (order by fiscal_year_period desc) as alignment_group
                  ,'{{fp}}' as reporting_period

            from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
            where fiscal_year_period in ('{{fp}}'{{cp}})


      ;;
  }



  parameter: select_fiscal_period {
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }

  parameter: select_comparison_type {
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

  parameter: select_custom_comparison_period {
    type: unquoted
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }

  dimension: reporting_period {
    type: string
    sql:  ${TABLE}.reporting_period;;
  }


  dimension: fiscal_period_group {
    type: string
    sql:  ${TABLE}.fiscal_period_group;;
  }

  dimension: alignment_group {
    type: number
    sql: ${TABLE}.alignment_group ;;
  }



  # measure: reporting_amount {
  #   type: sum
  #   sql: ${balance_sheet.amount_in_target_currency} ;;
  #   filters: [fiscal_period_group: "Reporting"]
  # }

  # measure: comparison_amount {
  #   type: sum
  #   sql: ${balance_sheet.amount_in_target_currency} ;;
  #   filters: [fiscal_period_group: "Comparison"]
  # }

  # measure: difference_value {
  #   type: number
  #   sql: ${reporting_amount} - ${comparison_amount} ;;
  # }

  # measure: percent_difference_value {
  #   type: number
  #   sql: safe_divide(${reporting_amount},${comparison_amount}) - 1 ;;
  #   value_format_name: percent_1
  # }

  # measure: title_balance_sheet {
  #   type: number
  #   sql: 1 ;;
  #   # html: Balance Sheet <br> Current Ratio {{ balance_sheet.current_ratio._rendered_value }} ;;

  #   # html: <p style="color: black; background-color: #CFDBD5; font-size:100%; text-align:center">Balance Sheet</p>
  #   html:
  #   <div  style="font-size:100pct; background-color:rgb((207,219,213,.5); text-align:center;  line-height: .8; font-family:'Noto Sans SC'; font-color: #808080">

  #         <a style="font-size:100%;font-family:'verdana';color: black"><b>Balance Sheet</b></a><br>
  #         <a style= "font-size:80%;font-family:'verdana';color: black">{{balance_sheet.company_text._value}}</a><br>
  #         <a style= "font-size:80%;font-family:'verdana';color: black">Reporting Period:   {{selected_period._value}}&nbsp;&nbsp;&nbsp; Current Ratio: {{balance_sheet.current_ratio._rendered_value}}</a>
  #         <br>
  #         <a style= "font-size: 70%; text-align:center;font-family:'verdana';color: black"> Amounts in Millions  {{balance_sheet.target_currency_tcurr}} </a>

  #     </div>
  #     ;;


  # }
}
