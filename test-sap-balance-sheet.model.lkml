connection: "@{CONNECTION_NAME}"

include: "/components/named_value_formats.lkml"

include: "/views/experimental/test_balance_sheet_rfn.view"
include: "/views/experimental/balance_sheet_3_4.view"
include: "/views/experimental/test_liquid_dates.view"
include: "/explores/experimental/*.explore"
include: "/explores/fiscal_periods_sdt.explore"

explore: balance_sheet_3_4 {}


include: "/views/core/profit_and_loss_fiscal_periods_sdt.view"

explore: profit_and_loss_fiscal_periods_sdt {}
