view: selected_periods_sdt {
derived_table: {
  sql:
          {% assign pd = _filters['shared_parameters.pick_fiscal_periods'] | sql_quote | remove: '"' | remove: "'" | remove:"[" | remove:"]" | remove: ">" | remove:"<"|remove:"=" | remove:"(" | remove: ")" %}
          {% assign pd_array = pd | split: "," %}

      select fp.*
          --{{pd}}
      from ${fiscal_periods_sdt.SQL_TABLE_NAME} fp
      where {% condition shared_parameters.pick_fiscal_periods %} fiscal_year_period {% endcondition %}


  ;;
}

dimension: fiscal_year_period {
  sql: ${TABLE}.fiscal_year_period ;;
}



 }
