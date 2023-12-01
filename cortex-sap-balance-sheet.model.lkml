connection: "@{CONNECTION_NAME}"

include: "/views/base/*.view"
include: "/views/core/*.view"
include: "/explores/*.explore"


explore: language_map_sdt {}
explore: selected_periods_sdt {
  join: shared_parameters {
    relationship: one_to_one
    sql:  ;;
  }
}
