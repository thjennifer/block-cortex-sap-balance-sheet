include: "/views/core/profit_and_loss_rfn.view"
include: "/views/core/language_map_sdt.view"

explore: profit_and_loss {
  always_join: [language_map_sdt]

  # always_filter: {filters:[balance_sheet.hierarchy_name: "FPA1",balance_sheet.chart_of_accounts: "CA01",balance_sheet.company_text: "",balance_sheet.target_currency_tcurr: "USD"]}

  sql_always_where: ${profit_and_loss.client_mandt}='@{CLIENT_ID}'

      ;;

  join: language_map_sdt {
    type: inner
    relationship: many_to_one
    sql_on: ${profit_and_loss.language_key_spras} = ${language_map_sdt.language_spras} ;;
    fields: []
  }
}

# {% if balance_sheet.select_fiscal_period._in_query %}
      #   and ${balance_sheet.fiscal_period_group} is not null
      # {% endif %}
