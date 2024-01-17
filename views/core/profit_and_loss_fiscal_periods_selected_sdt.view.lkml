include: "/views/core/fiscal_periods_sdt.view"

view: profit_and_loss_fiscal_periods_selected_sdt {
    label: "🗓 Pick Fiscal Periods"
    extends: [fiscal_periods_sdt]

    derived_table: {
      sql: --reporting and YoY/Previous Comparison Periods

              {% assign comparison_type = profit_and_loss.parameter_compare_to._parameter_value %}
              {% assign tp = _filters['profit_and_loss.filter_fiscal_timeframe'] | sql_quote | remove: '"' | remove: "'" %}
              {% assign tp_array = tp | split: ',' | uniq | sort %}
              {% assign time_level = profit_and_loss.parameter_display_period_or_quarter._parameter_value %}
              {% if time_level == 'fp' %}
                  {% assign anchor_time = 'fiscal_year_period' %}
                  {% assign max_fp = '@{max_fiscal_period}' %}
                  {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
                  {% assign max_fp_size_neg = max_fp_size | times: -1 %}
                  {% assign pad = '' %}
                    {% for i in (1..max_fp_size) %}
                        {% assign pad = pad | append: '0' %}
                    {% endfor %}

              {% else %}
                  {% assign anchor_time = 'fiscal_year_quarter' %}
                  {% assign max_fp = 'Q4' %}
                  {% assign max_fp_size = 0 %}
                  {% assign max_fp_size_neg = 0 %}
                  {% assign pad = 'Q' %}
              {% endif %}





        select fp.*
        ,'Current' as fiscal_period_group
        , rank() over (order by {{anchor_time}} desc) as alignment_group
        ,'{{tp}}' as selected_period
        ,'{{time_level}}' as selected_time_level

        from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
        where {% condition profit_and_loss.filter_fiscal_timeframe %}
                {% if time_level == 'fp' %}fiscal_year_period
                {% else %} fiscal_year_quarter {% endif %}{% endcondition %}

      {% if comparison_type != 'none'  %}
         UNION ALL
         select fp.*
           ,'Comparison' as fiscal_period_group
           ,rank() over (order by {{anchor_time}} desc) as alignment_group
           ,cast(null as string) as selected_period
           ,cast(null as string) as selected_time_level

       from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
        where
        {% if comparison_type == 'custom' %}

          {% condition profit_and_loss.filter_comparison_timeframe %} {% if time_level == 'fp' %}fiscal_year_period
                  {% else %} fiscal_year_quarter {% endif %} {% endcondition %}

        {% elsif comparison_type == 'yoy' or comparison_type == 'prior' %}
            {% for p in tp_array %}
                {% assign p_array = p | split: '.' %}
                {% if forloop.last != true %}{%assign d = ','%}{%else%}{%assign d = ''%}{%endif%}

                {% if comparison_type == 'yoy' %}
                      {% assign m = p_array[1]  %}
                      {% assign sub_yr = 1 %}

                {% elsif comparison_type == 'prior' %}
                           {% if p_array[1] == '001' or p_array[1] == '01' or p_array[1] == 'Q1' %}
                              {% assign m = max_fp %}{% assign sub_yr = 1 %}

                            {% else %}
                              {% assign m = p_array[1] | remove: 'Q' | times: 1 | minus: 1 | prepend: pad | slice: max_fp_size_neg, max_fp_size %}{% assign sub_yr = 0 %}
                             -- {% assign m = p_array[1] | remove: 'Q' | times: 1 | minus: 1 | prepend: pad %}{% assign sub_yr = 0 %}

                            {% endif %}
                {% endif %}

            {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
            {% assign cp_list = cp_list | append: "'" | append: yr | append: '.'| append: m | append: "'" | append: d %}
            {% endfor%}

        {{anchor_time}} in ( {{cp_list}} )
      {% endif %}
      {% endif %}
        ;;
    }

# {% if comparison_type != 'none'  %}
#         UNION ALL

#         --comparison periods
        # select fp.*
        # ,'Comparison' as fiscal_period_group
        # ,rank() over (order by fiscal_year_period desc) as alignment_group
        # ,cast(null as string) as selected_period

        # from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
        # where
        # {% if comparison_type == 'custom' %}
        # {% condition filter_comparison_period %} fiscal_year_period {% endcondition %}

        # {% elsif comparison_type == 'prior' or comparison_type == 'yoy' %}
        # {% for p in fp_array %}
        # {% assign p_array = p | split: '.' %}
        # {% if forloop.last != true %}{%assign d = ','%}{%else%}{%assign d = ''%}{%endif%}
        # {% if comparison_type == 'prior' %}
        # {% if p_array[1] == '01' %}
        # {% assign m = '12' %}
        # {% assign sub_yr = 1 %}
        # {% else %}
        # {% assign m = p_array[1] | times: 1 | minus: 1 | prepend: '00' | slice: -2, 2 %}
        # {% assign sub_yr = 0 %}
        # {% endif %}
        # {% else %}
        # {% assign m = p_array[1]  %}
        # {% assign sub_yr = 1 %}
        # {% endif %}

        # {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
        # {% assign cp_list = cp_list | append: "'" | append: yr | append: '.'| append: m | append: "'" | append: d %}
        # {% endfor%}

        # fiscal_year_period in ( {{cp_list}} )

#         {% elsif comparison_type == 'equal' %}
#         {% assign fp_sorted = fp_array | sort  %}

#         PARSE_DATE('%Y.%m',fiscal_year_period)  >=
#         date_sub(PARSE_DATE('%Y.%m','{{fp_sorted[0]}}'), INTERVAL {{fp_sorted | size}} MONTH)
#         and PARSE_DATE('%Y.%m',fiscal_year_period) < PARSE_DATE('%Y.%m','{{fp_sorted[0]}}')
#         {% endif %}
#         {% endif %}

    # filter: filter_fiscal_period {
    #   label: "Select Fiscal Periods"
    #   suggest_explore: fiscal_periods_sdt
    #   suggest_dimension: fiscal_periods_sdt.fiscal_year_period
    # }

    # parameter: parameter_compare_to {
    #   label: "Select Comparison Type"
    #   type: unquoted
    #   allowed_value: {
    #     label: "None" value: "none"
    #   }
    #   allowed_value: {
    #     label: "Same Period Last Year" value: "yoy"
    #   }
    #   allowed_value: {
    #     label: "Previous Fiscal Period" value: "prior"
    #   }
    #   # allowed_value: {
    #   #   label: "Equal # Periods Prior" value: "equal"
    #   # }
    #   allowed_value: {
    #     label: "Custom Range" value: "custom"
    #   }
    #   default_value: "none"

    # }

    # filter: filter_comparison_period {
    #   label: "Select Custom Comparison Period"
    #   suggest_explore: fiscal_periods_sdt
    #   suggest_dimension: fiscal_periods_sdt.fiscal_year_period
    # }

    dimension: selected_period {
      type: string
      sql:  ${TABLE}.selected_period;;
    }

    # dimension: what_was_picked_sorted {
    #   type: string
    #   sql:  ${TABLE}.what_was_picked_sorted ;;
    # }

    # dimension: how_many_picked {
    #   type: string
    #   sql:  ${TABLE}.how_many_picked;;
    # }

    # dimension: derived_comparison_periods {
    #   type: string
    #   sql:  ${TABLE}.derived_comparison_periods;;
    # }

    # dimension: first_period {
    #   type: string
    #   sql:  ${TABLE}.first_period;;
    # }

  dimension: fiscal_period_group {
    type: string
    sql:  ${TABLE}.fiscal_period_group;;
  }

  # dimension: anchor_time_period {
  #   type: string
  #   sql:  ${TABLE}.anchor_time_period;;
  # }

  dimension: selected_time_level {
    type: string
    sql: ${TABLE}.selected_time_level ;;
  }

    # dimension: fiscal_period_group {
    #   group_label: "Fiscal Dates"
    #   type: string
    #   sql:    {% if select_fiscal_period._in_query %}
    #               {% assign comparison_type = select_comparison_type._parameter_value %}
    #               {% assign fp = select_fiscal_period._parameter_value %}
    #               {% assign cp = select_custom_comparison_period._parameter_value %}
    #               {% if comparison_type == 'custom' %}
    #                   {% if fp == cp %}{% assign comparison_type = 'none' %}
    #                   {% elsif cp == '' %}{% assign comparison_type = 'yoy' %}
    #                   {% endif %}
    #               {% endif %}

    #     {% if comparison_type == 'yoy' %}{% assign sub = 'YEAR'%}
    #     {% elsif comparison_type == 'prior' %}{% assign sub = 'MONTH' %}
    #     {% endif %}


    #     case  when ${fiscal_year_period} = '{{fp}}' then 'Reporting'
    #     {% if comparison_type != 'none' %}
    #     when PARSE_DATE('%Y.%m',${fiscal_year_period}) =
    #     {% if comparison_type == 'custom' %}
    #     PARSE_DATE('%Y.%m','{{cp}}')
    #     {% else %}
    #     DATE_SUB(PARSE_DATE('%Y.%m','{{fp}}'), INTERVAL 1 {{sub}})
    #     {% endif %}
    #     then 'Comparison'
    #     {% endif %}
    #     end
    #     {% else %} 'No Fiscal Reporting Period has been selected. Add Select Fiscal Period parameter.'
    #     {% endif %};;
    # }

    dimension: alignment_group {
      type: number
      sql: ${TABLE}.alignment_group ;;
    }

    # dimension: selected_display_level {
    #   label: "Selected Display Level"
    #   type: string
    #   # label_from_parameter: shared_parameters.display
    #   sql: {% assign level = shared_parameters.display._parameter_value %}
    #           {% if level == 'fiscal_year'%}${fiscal_year}
    #             {% elsif level == 'fiscal_year_quarter' %} ${fiscal_year_quarter}
    #             {% elsif level == 'fiscal_year_period' %} ${fiscal_year_period}
    #             {% elsif level == 'fiscal_period_group' %} ${fiscal_period_group}

    #     {% else %}'no match on level'
    #     {% endif %}
    #     ;;
    # }

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
    }
