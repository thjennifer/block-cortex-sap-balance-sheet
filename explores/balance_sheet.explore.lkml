include: "/views/core/balance_sheet_rfn.view"
include: "/views/core/language_map_sdt.view"

explore: balance_sheet {
  always_join: [language_map_sdt]
  always_filter: {filters:[balance_sheet.target_currency_tcurr: "USD"]}

  sql_always_where: ${balance_sheet.client_mandt}='@{CLIENT_ID}'
  --and ${target_currency_tcurr} = {% parameter select_global_currency %}
  ;;


  join: language_map_sdt {
    type: inner
    relationship: many_to_one
    sql_on: ${balance_sheet.language_key_spras} = ${language_map_sdt.language_spras} ;;
    fields: []
}

}
