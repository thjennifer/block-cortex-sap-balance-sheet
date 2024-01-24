include: "/views/core/fiscal_periods_sdt.view"

view: profit_and_loss_fiscal_periods_selected_sdt {
    label: "🗓 Pick Fiscal Periods"
    extends: [fiscal_periods_sdt]

    derived_table: {

      sql:    {% assign comparison_type = profit_and_loss.parameter_compare_to._parameter_value %}
              {% assign tp = _filters['profit_and_loss.filter_fiscal_timeframe'] | sql_quote | remove: '"' | remove: "'" %}
              {% assign tp_array = tp | split: ',' | uniq | sort %}
              {% assign time_level = profit_and_loss.parameter_display_period_or_quarter._parameter_value %}
              {% if comparison_type == 'custom' and profit_and_loss.filter_comparison_timeframe._is_filtered == false %}
                  {% assign comparison_type = 'yoy' %}
              {% endif %}
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
                  {% assign max_fp = 'Q4' %}{% assign max_fp_size = 2 %}{% assign max_fp_size_neg = -2 %}{% assign pad = 'Q' %}
              {% endif %}
  {% if profit_and_loss.filter_fiscal_timeframe._is_filtered %}

  select fiscal_year,
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
    from (
       select
          fiscal_year,
          fiscal_period,
          fiscal_year_quarter,
          fiscal_year_period,
          negative_fiscal_year_period_number,
          negative_fiscal_year_quarter_number,
          'Current' as fiscal_period_group,
          rank() over (order by {{anchor_time}} desc) as alignment_group,
          {{anchor_time}} as selected_timeframe,
          '{{comparison_type}}' as comparison_type
        from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
        where {% condition profit_and_loss.filter_fiscal_timeframe %}
                {% if time_level == 'fp' %}fiscal_year_period{% else %} fiscal_year_quarter {% endif %}
              {% endcondition %}

      {% if comparison_type != 'none'  %}
         UNION ALL
         select
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

    dimension: selected_timeframe {
      type: string
      sql:  ${TABLE}.selected_timeframe;;
    }

    dimension: comparison_type {
      type: string
      sql:  ${TABLE}.comparison_type ;;
    }

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




  dimension: alignment_group {
    type: number
    sql: ${TABLE}.alignment_group ;;
  }

  dimension: focus_timeframe {
    type: string
    sql: ${TABLE}.focus_timeframe ;;
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
      html: @{negative_format} ;;
    }

    measure: difference_percent {
      type: number
      group_label: "Current v Comparison Period Metrics"
      label: "Var %"
      sql: safe_divide(${current_amount},${comparison_amount}) - 1 ;;
      value_format_name: percent_1
      html: @{negative_format} ;;
    }
    }
