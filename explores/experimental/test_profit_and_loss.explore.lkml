include: "/views/core/profit_and_loss_rfn.view"
include: "/views/core/language_map_sdt.view"
# include: "/views/core/profit_and_loss_kpi_to_glaccount_map_sdt.view"
include: "/views/experimental/new_profit_and_loss_fiscal_periods_selected_sdt.view"
include: "/views/core/profit_and_loss_03_selected_fiscal_periods_sdt.view"
include: "/views/core/profit_and_loss_hierarchy_selection_sdt.view"
include: "/views/core/profit_and_loss_navigation_ext.view"

explore: profit_and_loss {
  always_join: [language_map_sdt]

  label: "Income Statement"

  always_filter: {filters:[profit_and_loss.glhierarchy: "FPA1",profit_and_loss.company_text: "%CENTRAL%",profit_and_loss.target_currency_tcurr: "USD"]}

  sql_always_where: ${profit_and_loss.client_mandt}='@{CLIENT_ID}'

          ;;

  join: language_map_sdt {
    type: inner
    relationship: many_to_one
    sql_on: ${profit_and_loss.language_key_spras} = ${language_map_sdt.language_spras} ;;
    fields: []
  }

  # join: profit_and_loss_kpi_to_glaccount_map_sdt  {
  #   type: left_outer
  #   relationship: many_to_many
  #   sql_on: ${profit_and_loss.glnode} = ${profit_and_loss_kpi_to_glaccount_map_sdt.gl_account};;
  # }

  # join: new_profit_and_loss_fiscal_periods_selected_sdt  {
  #   type: inner
  #   relationship: many_to_many
  #   sql_on: ${profit_and_loss.glhierarchy} = ${new_profit_and_loss_fiscal_periods_selected_sdt.glhierarchy}
  #     AND ${profit_and_loss.company_code} = ${new_profit_and_loss_fiscal_periods_selected_sdt.company_code}
  #     AND ${profit_and_loss.fiscal_year} = ${new_profit_and_loss_fiscal_periods_selected_sdt.fiscal_year}
  #     and ${profit_and_loss.fiscal_period} = ${new_profit_and_loss_fiscal_periods_selected_sdt.fiscal_period};;
  # }

  join: profit_and_loss_03_selected_fiscal_periods_sdt  {
    type: inner
    relationship: many_to_many
    sql_on: ${profit_and_loss.glhierarchy} = ${profit_and_loss_03_selected_fiscal_periods_sdt.glhierarchy}
      AND ${profit_and_loss.company_code} = ${profit_and_loss_03_selected_fiscal_periods_sdt.company_code}
      AND ${profit_and_loss.fiscal_year} = ${profit_and_loss_03_selected_fiscal_periods_sdt.fiscal_year}
      and ${profit_and_loss.fiscal_period} = ${profit_and_loss_03_selected_fiscal_periods_sdt.fiscal_period};;
  }

  join: profit_and_loss_hierarchy_selection_sdt {
    type: inner
    relationship: many_to_one
    sql_on: ${profit_and_loss.client_mandt} = ${profit_and_loss_hierarchy_selection_sdt.client_mandt} and
            ${profit_and_loss.glhierarchy} = ${profit_and_loss_hierarchy_selection_sdt.glhierarchy} and
            ${profit_and_loss.chart_of_accounts} = ${profit_and_loss_hierarchy_selection_sdt.chart_of_accounts} and
            ${profit_and_loss.language_key_spras} = ${profit_and_loss_hierarchy_selection_sdt.language_key_spras} and
            ${profit_and_loss.glnode} = ${profit_and_loss_hierarchy_selection_sdt.glnode};;

  }

  join: profit_and_loss_navigation_ext {
    view_label: "🔍 Filters & 🛠 Tools"
    relationship: one_to_one
    sql:  ;;
}

}