###########
### OPTION 4
### filter Fiscal Period
### parameter Compare to: Previous Period or YoY or CUSTOM, if custom, user provide values for filter Comparison Period
### optional filter Comparison Period
###########
include: "/views/core/fiscal_periods_sdt.view"

view: bkp_option4 {


    label: "🗓️ Pick Dates OPTION 4"
    extends: [fiscal_periods_sdt]

    derived_table: {
      sql: --reporting and YoY/Previous Comparison Periods

              {% assign comparison_type = parameter_compare_to._parameter_value %}
              {% assign fp = _filters['filter_fiscal_period'] | sql_quote | remove: '"' | remove: "'" %}
              {% assign fp_array = fp | split: ',' | uniq | sort %}
              {% assign fp_count = 0 %}
              {% assign fp_sorted = '' %}
              {% assign first_fp = '' %}
              {% assign cp_list = '' %}
              {% if comparison_type == 'yoy' %}
                  --year over year selected
                  {% for p in fp_array %}
                      {% assign p_array = p | split: '.' %}
                      {% if forloop.last != true %}{%assign d = ','%}{%else%}{%assign d = ''%}{%endif%}
                      {% assign yr = p_array[0] | times: 1 | minus: 1 %}
                      {% assign cp_list = cp_list | append: "'" | append: yr | append: '.'| append: p_array[1] | append: "'" | append: d %}
                  {% endfor%}

              {% elsif comparison_type == 'prior' %}
                  --prior periods
                  {% for p in fp_array %}
                      {% assign p_array = p | split: '.' %}
                      {% if forloop.last != true %}{%assign d = ','%}{%else%}{%assign d = ''%}{%endif%}

                        {% if p_array[1] == '01' %}
                            {% assign m = 12 %}
                            {% assign yr = p_array[0] | times: 1 | minus: 1 %}
                        {% else%}
                            {% assign m = p_array[1] | times: 1 | minus: 1 | prepend: '00' | slice: -2, 2 %}
                            {% assign yr = p_array[0] %}
                        {% endif %}
                    {% assign cp_list = cp_list | append: "'" | append: yr | append: '.'| append: m | append: "'" | append: d %}
                  {% endfor %}
              {% elsif comparison_type == 'equal' %}
                  --equal # prior periods selected
                  {% assign fp_count = fp_array.size %}
                  {% assign fp_sorted = fp_array | sort  %}
                  {% assign first_fp = fp_sorted[0] %}
              {% else %}
                  {% assign cp_list = '' %}
              {% endif %}
              select fp.*
                    ,case when {% condition filter_fiscal_period %} fiscal_year_period {% endcondition %} then 'Reporting'
                     {% if comparison_type == 'yoy' %}
                          when fiscal_year_period in ( {{cp_list}} ) then 'Comparison'
                      {% elsif comparison_type == 'equal' %}
                          when PARSE_DATE('%Y.%m',fiscal_year_period)  >=
                                    date_sub(PARSE_DATE('%Y.%m','{{first_fp}}'), INTERVAL {{fp_count}} MONTH)
                                and PARSE_DATE('%Y.%m',fiscal_year_period) < PARSE_DATE('%Y.%m','{{first_fp}}') then 'Comparison'
                      {% endif %}
                      end as fiscal_period_group
                    ,rank() over (order by fiscal_year_period desc) as alignment_group
                    ,'{{fp}}' as what_was_picked
                    ,'{{fp_count}}' as how_many_picked
                    ,'{{fp_sorted | join: ',' }}' as what_was_picked_sorted
                    ,"{{cp_list}}" as derived_comparison_periods
                    ,'{{ first_fp }}' as first_period

        from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
        where {% condition filter_fiscal_period %} fiscal_year_period {% endcondition %}

        {% if comparison_type == 'yoy' %}
        --yoy selected
        OR fiscal_year_period in ( {{cp_list}} )
        {% elsif comparison_type == 'equal' %}
        --equal # prior period selected
        OR (
        PARSE_DATE('%Y.%m',fiscal_year_period)  >=
        date_sub(PARSE_DATE('%Y.%m','{{first_fp}}'), INTERVAL {{fp_count}} MONTH)
        and PARSE_DATE('%Y.%m',fiscal_year_period) < PARSE_DATE('%Y.%m','{{first_fp}}')
        )

        {% endif %}

        {% if comparison_type == 'custom' or comparison_type == 'prior' %}
        UNION ALL

        --comparison periods
        select fp.*
        ,'Comparison' as fiscal_period_group
        ,rank() over (order by fiscal_year_period desc) as alignment_group
        ,'{{fp}}' as what_was_picked
        ,'{{fp_count}}' as how_many_picked
        ,'{{fp_sorted | join: ',' }}'
        ,"{{cp_list}}"
        ,'{{ first_fp }}'

        from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp

        {% if comparison_type == 'custom' %}
        where {% condition filter_comparison_period %} fiscal_year_period {% endcondition %}
        {% elsif comparison_type == 'prior' %}
        where fiscal_year_period in ( {{cp_list}} )
        {% endif %}
        {% endif %}
        ;;
    }

    # {% assign fp_array = fp | split: ',' | uniq | sort %}
    #         {% asssign cp_list = '' %}
    #         {% for p in fp_array %}
    #             {% assign p_array = p | split: '.' %}
    #             {% assign yr = p_array[0] | times: 1 | minus: 1 %}
    #             {% assign cp_list = cp_list | append: "'" | append: yr | append: '.' | append p_array[1] | append: "'" %}
    #             {{cp_list}}{% if forloop.last != true %} , {% endif %}
    #         {% endfor %}

    filter: filter_fiscal_period {
      label: "Select Fiscal Periods"
      suggest_explore: fiscal_periods_sdt
      suggest_dimension: fiscal_periods_sdt.fiscal_year_period
    }

    parameter: parameter_compare_to {
      label: "Select Comparison"
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
      suggest_explore: fiscal_periods_sdt
      suggest_dimension: fiscal_periods_sdt.fiscal_year_period
    }

    dimension: what_was_picked {
      type: string
      sql:  ${TABLE}.what_was_picked;;
    }

    dimension: what_was_picked_sorted {
      type: string
      sql:  ${TABLE}.what_was_picked_sorted ;;
    }

    dimension: how_many_picked {
      type: string
      sql:  ${TABLE}.how_many_picked;;
    }

    dimension: derived_comparison_periods {
      type: string
      sql:  ${TABLE}.derived_comparison_periods;;
    }

    dimension: first_period {
      type: string
      sql:  ${TABLE}.first_period;;
    }

    dimension: fiscal_period_group {
      type: string
      sql:  ${TABLE}.fiscal_period_group;;
    }

    dimension: alignment_group {
      type: number
      sql: ${TABLE}.alignment_group ;;
    }


  }
