include: "/views/core/shared_parameters.view"
include: "/views/core/balance_sheet_rfn.view"

explore: test_compare_metrics {hidden: yes
  join: shared_parameters{
    relationship: one_to_one
    sql: ;;
  }
    join: balance_sheet {
      type: inner
      relationship: one_to_one
      sql_on: ${test_compare_metrics.fiscal_year} = ${balance_sheet.fiscal_year}
        and ${test_compare_metrics.fiscal_period} = ${balance_sheet.fiscal_period};;
    }
  }

view: test_compare_metrics {
 label: "🗓️ Pick Dates OPTION 5"
  derived_table:  {
    sql:
        select sfp.*
              ,max(case when fiscal_period_group = 'Reporting' then fiscal_year_period end)
                over(partition by alignment_group) as alignment_label
        from (
            {% assign comparison_type = parameter_compare_to._parameter_value %}
      {% assign fp = _filters['filter_fiscal_period'] | sql_quote | remove: '"' | remove: "'" %}
      {% assign fp_array = fp | split: ',' | uniq | sort %}


      select fp.*
            ,'Reporting' as fiscal_period_group
            ,rank() over (order by fiscal_year_period desc) as alignment_group

      from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
      where {% condition filter_fiscal_period %} fiscal_year_period {% endcondition %}


   {% if comparison_type != 'none'  %}
      UNION ALL

       --comparison periods
      select fp.*
            ,'Comparison' as fiscal_period_group
            ,rank() over (order by fiscal_year_period desc) as alignment_group


      from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
      where
      {% if comparison_type == 'custom' %}
          {% condition filter_comparison_period %} fiscal_year_period {% endcondition %}

      {% elsif comparison_type == 'prior' or comparison_type == 'yoy' %}
          {% for p in fp_array %}
              {% assign p_array = p | split: '.' %}
              {% if forloop.last != true %}{%assign d = ','%}{%else%}{%assign d = ''%}{%endif%}
              {% if comparison_type == 'prior' %}
                  {% if p_array[1] == '01' %}
                      {% assign m = '12' %}
                      {% assign sub_yr = 1 %}
                  {% else %}
                    {% assign m = p_array[1] | times: 1 | minus: 1 | prepend: '00' | slice: -2, 2 %}
                    {% assign sub_yr = 0 %}
                  {% endif %}
              {% else %}
                    {% assign m = p_array[1]  %}
                    {% assign sub_yr = 1 %}
              {% endif %}

              {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
              {% assign cp_list = cp_list | append: "'" | append: yr | append: '.'| append: m | append: "'" | append: d %}
          {% endfor%}

          fiscal_year_period in ( {{cp_list}} )

      {% elsif comparison_type == 'equal' %}
          {% assign fp_sorted = fp_array | sort  %}

          PARSE_DATE('%Y.%m',fiscal_year_period)  >=
            date_sub(PARSE_DATE('%Y.%m','{{fp_sorted[0]}}'), INTERVAL {{fp_sorted | size}} MONTH)
           and PARSE_DATE('%Y.%m',fiscal_year_period) < PARSE_DATE('%Y.%m','{{fp_sorted[0]}}')
      {% endif %}
   {% endif %}

        ) sfp ;;
  }

  dimension: alignment_label {
    sql:${TABLE}.alignment_label ;;
  }

  filter: filter_fiscal_period {
    label: "Select Fiscal Periods"
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }

  parameter: parameter_compare_to {
    label: "Select Comparison Type"
    type: unquoted
    allowed_value: {
      label: "None" value: "none"
    }
    allowed_value: {
      label: "Year over Year" value: "yoy"
    }
    allowed_value: {
      label: "Previous Fiscal Period" value: "prior"
    }
    allowed_value: {
      label: "Equal # Periods Prior" value: "equal"
    }
    allowed_value: {
      label: "Custom Range" value: "custom"
    }
    default_value: "none"

  }

  filter: filter_comparison_period {
    label: "Select Custom Comparison Period"
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }



  dimension: fiscal_period_group {
    type: string
    sql:  ${TABLE}.fiscal_period_group;;
  }

  dimension: alignment_group {
    type: number
    sql: ${TABLE}.alignment_group ;;
  }

  dimension: selected_display_level {
    label: "Selected Display Level"
    type: string
    # label_from_parameter: shared_parameters.display
    sql: {% assign level = shared_parameters.display._parameter_value %}
      {% if level == 'fiscal_year'%}${fiscal_year}
        {% elsif level == 'fiscal_year_quarter' %} ${fiscal_year_quarter}
        {% elsif level == 'fiscal_year_period' %} ${fiscal_year_period}
        {% elsif level == 'fiscal_period_group' %} ${fiscal_period_group}

      {% else %}'no match on level'
      {% endif %}
      ;;
  }

  dimension: fiscal_year {
    type: string
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_period {
    type: string
    sql: ${TABLE}.fiscal_period ;;
  }

  dimension: fiscal_year_quarter {
    type: string
    sql: ${TABLE}.fiscal_year_quarter ;;
  }

  dimension: fiscal_year_period {
    type: string
    primary_key: yes
    sql: ${TABLE}.fiscal_year_period ;;

  }

  measure: reporting_amount {
    type: sum
    sql: ${balance_sheet.amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Reporting"]
    value_format_name: "millions_d1"
  }

  measure: comparison_amount {
    label_from_parameter: shared_parameters.display
    type: sum
    sql: ${balance_sheet.amount_in_target_currency} ;;
    filters: [fiscal_period_group: "Comparison"]
  }

  measure: difference_value {
    label: "{% if shared_parameters.display._parameter_value == 'yoy'%} Difference from Last Year
            {% elsif shared_parameters.display._parameter_value  == 'prior' %} Difference from Prior Period
            {%else%}Difference
            {%endif%}"
    type: number
    sql: ${reporting_amount} - ${comparison_amount} ;;
  }

  measure: percent_difference_value {
    label: "{% if shared_parameters.display._parameter_value == 'yoy'%} % change from Last Year
    {% elsif shared_parameters.display._parameter_value == 'prior' %} % change from Prior Period
    {%else%}% change
    {%endif%}"
    type: number
    sql: safe_divide(${reporting_amount},${comparison_amount}) - 1 ;;
    html: {%if value >= 0 %}<a style="background-color: #90EE90; color:#003f5c;font-size:12px"> <b> ⬆️  {{rendered_value}} </b></a>
          {% elsif value < 0 %}⬇️ {{rendered_value}}
          {% endif %};;
  # html: {% if value == 0 %}
  #   <a style= "color:#003f5c;"> {{rendered_value}} </a>
  #   {% elsif value > .50 %}<a style="color:#003f5c;font-size:16px"> <b> ⬆️{{rendered_value}} </b> </a>
  #   {% elsif %} {%if value >= 0 %}⬆️  {{rendered_value}}
  #   {% else %}
  #   <a style="color:#003f5c;font-size:12px"> <b> ⬇️{{rendered_value}} </b> </a>
  #   {% endif %};;

    value_format_name: percent_1
  }




 }
