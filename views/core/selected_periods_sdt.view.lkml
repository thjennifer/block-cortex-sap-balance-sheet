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
      where {% condition shared_parameters.pick_fiscal_periods %} fiscal_year_period {% endcondition %}

      UNION ALL

       --comparison periods
      select fp.*
            ,'Comparison' as fiscal_period_group
            ,rank() over (order by fiscal_year_period desc) as alignment_group

      from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
      where {% condition shared_parameters.pick_comparison_periods %} fiscal_year_period {% endcondition %}
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



 }
