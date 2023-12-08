include: "/views/core/fiscal_periods_sdt.view"

view: selected_periods_sdt {
  extends: [fiscal_periods_sdt]
  label: "🗓️ Pick Dates OPTION 2"
 derived_table: {

   sql:
      --reporting periods
      select fp.*
            ,'Reporting' as fiscal_period_group
            ,rank() over (order by fiscal_year_period desc) as alignment_group

      from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
      where {% condition pick_fiscal_periods %} fiscal_year_period {% endcondition %}

      UNION ALL

       --comparison periods
      select fp.*
            ,'Comparison' as fiscal_period_group
            ,rank() over (order by fiscal_year_period desc) as alignment_group

      from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
      where {% condition pick_comparison_periods %} fiscal_year_period {% endcondition %}

    ;;

 }


  dimension: fiscal_period_group {
    type: string
    sql: ${TABLE}.fiscal_period_group ;;
  }

  dimension: alignment_group {
    type: number
    sql: ${TABLE}.alignment_group ;;
  }

  filter: pick_fiscal_periods {
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }


  filter: pick_comparison_periods {
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }

  dimension: selected_display_level {
    label: "Selected Display Level"
    type: string
    label_from_parameter: shared_parameters.display
    sql: {% assign level = shared_parameters.display._parameter_value %}
      {% if level == 'fiscal_year'%}${fiscal_year}
        {% elsif level == 'fiscal_year_quarter' %} ${fiscal_year_quarter}
        {% elsif level == 'fiscal_year_period' %} ${fiscal_year_period}
        {% elsif level == 'fiscal_period_group' %} ${fiscal_period_group}

        {% else %}'no match on level'
    {% endif %}
    ;;
  }



 }
