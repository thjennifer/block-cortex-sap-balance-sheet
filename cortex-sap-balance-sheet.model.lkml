connection: "@{CONNECTION_NAME}"

include: "/components/named_value_formats.lkml"


include: "/explores/balance_sheet.explore"
include: "/explores/fiscal_periods_sdt.explore"

include: "/views/core/fiscal_periods_selected_sdt.view"
explore: fiscal_periods_selected_sdt {hidden:yes}
