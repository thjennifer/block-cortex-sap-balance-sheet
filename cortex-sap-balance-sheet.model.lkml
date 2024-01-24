connection: "@{CONNECTION_NAME}"

include: "/components/named_value_formats.lkml"


include: "/explores/balance_sheet.explore"
include: "/explores/profit_and_loss.explore"
include: "/explores/fiscal_periods_sdt.explore"
include: "/dashboards/*.dashboard"


include: "/views/core/hierarchy_selection_sdt.view"
explore: hierarchy_selection_sdt {}
