include: "/views/core/balance_sheet_rfn.view"
include: "/views/core/language_map_sdt.view"
include: "/views/core/shared_parameters.view"
include: "/views/core/OPTION2_selected_periods_sdt.view"
include: "/views/core/OPTION4_selected_fiscal_periods_sdt.view"
include: "/views/core/OPTION3_selected_fiscal_date_dim_sdt.view"

explore: balance_sheet {
  always_join: [language_map_sdt]
  always_filter: {filters:[balance_sheet.target_currency_tcurr: "USD"]}

  sql_always_where: ${balance_sheet.client_mandt}='@{CLIENT_ID}'
  ---TEMPORARY
  {% if selected_fiscal_periods_sdt.filter_fiscal_period._in_query %}
     and ${selected_fiscal_periods_sdt.fiscal_period_group} is not null
  {% endif %}
  --and ${target_currency_tcurr} = {% parameter select_global_currency %}
  ;;


  join: language_map_sdt {
    type: inner
    relationship: many_to_one
    sql_on: ${balance_sheet.language_key_spras} = ${language_map_sdt.language_spras} ;;
    fields: []
}

  join: selected_fiscal_periods_sdt {
    type: inner
    relationship: one_to_one
    sql_on: ${balance_sheet.fiscal_year} = ${selected_fiscal_periods_sdt.fiscal_year}
      and ${balance_sheet.fiscal_period} = ${selected_fiscal_periods_sdt.fiscal_period};;
  }


  join: selected_periods_sdt {
    type: inner
    relationship: one_to_one
    sql_on: ${balance_sheet.fiscal_year} = ${selected_periods_sdt.fiscal_year}
          and ${balance_sheet.fiscal_period} = ${selected_periods_sdt.fiscal_period};;

  }

  join: selected_fiscal_date_dim_sdt {
    type: inner
    relationship: one_to_one
    sql_on: ${balance_sheet.fiscal_year} = ${selected_fiscal_date_dim_sdt.fiscal_year}
      and ${balance_sheet.fiscal_period} = ${selected_fiscal_date_dim_sdt.fiscal_period};;

  }

  join: shared_parameters {
    relationship: one_to_one
    sql:  ;;
  }

}
