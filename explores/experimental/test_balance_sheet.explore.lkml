include: "/views/experimental/test_balance_sheet_rfn.view"
include: "/views/core/language_map_sdt.view"
include: "/views/experimental/shared_parameters.view"
include: "/views/experimental/OPTION2_selected_periods_sdt.view"
include: "/views/experimental/OPTION4_selected_fiscal_periods_sdt.view"
include: "/views/experimental/OPTION3_selected_fiscal_date_dim_sdt.view"
include: "/views/experimental/balance_sheet_3_hier_levels.view"

explore: test_balance_sheet {
  view_name: balance_sheet
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

  join: balance_sheet_3_hier_levels {
    type: inner
    relationship: many_to_one
    sql_on: ${balance_sheet.hierarchy_name} = ${balance_sheet_3_hier_levels.hierarchy_name} and
            ${balance_sheet.chart_of_accounts} = ${balance_sheet_3_hier_levels.chart_of_accounts} and
            ${balance_sheet.business_area} = ${balance_sheet_3_hier_levels.business_area} and
            ${balance_sheet.ledger_in_general_ledger_accounting} = ${balance_sheet_3_hier_levels.ledger_in_general_ledger_accounting} and
            ${balance_sheet.company_code} = ${balance_sheet_3_hier_levels.company_code} and
            ${balance_sheet.language_key_spras} = ${balance_sheet_3_hier_levels.language_key_spras} and
            ${balance_sheet.node} = ${balance_sheet_3_hier_levels.node};;
  }

}
