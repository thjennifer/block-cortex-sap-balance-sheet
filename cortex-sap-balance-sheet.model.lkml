connection: "@{CONNECTION_NAME}"

include: "/components/named_value_formats.lkml"
include: "/components/datagroups.lkml"

include: "/explores/balance_sheet.explore"
include: "/explores/profit_and_loss.explore"
include: "/explores/balance_sheet_fiscal_periods_sdt.explore"
include: "/dashboards/*.dashboard"



include: "/views/core/balance_sheet_hierarchy_selection_sdt.view"
explore: balance_sheet_hierarchy_selection_sdt {}
