view: testing_links_to_drill_into_profit {
 # tried this in profit_and_loss_rfn but it introduces required fields for fiscal year and dates
# put this back into profit_and_loss_rfn to test

  # measure: total_amount_in_global_currency {
  #   type: sum
  #   label: "Total Amount (Global Currency)"
  #   description: "Period Amount in Target or Global Currency"
  #   sql: ${amount_in_target_currency} ;;
  #   value_format_name: decimal_0
  #   # drill_fields: [drill_profit_to_parent*]
  #   # link: {
  #   #   label: "Show Components of Profit at Parent Level"
  #   #   url: "{{ drill_profit_to_parent._link }}&sorts=profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,profit_and_loss_kpi_to_glaccount_map_sdt.kpi_name,profit_and_loss.glparent_text"
  #   # }

  #   # link: {
  #   #   label: "Show Components of Profit at Parent & Node Level"
  #   #   url: "{{ drill_profit_to_child._link }}&sorts=profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,profit_and_loss_kpi_to_glaccount_map_sdt.kpi_name,profit_and_loss.glparent_text,profit_and_loss.glnode_text"
  #   # }

  #   # link: {
  #   #   label: "Show Income Statement"
  #   #   url: "//cortexdev.cloud.looker.com/dashboards/99?Display+Period+or+Quarter={{ _filters['profit_and_loss.parameter_display_time_dimension'] | url_encode }}&Select+Fiscal+Timeframe={{ profit_and_loss.fiscal_year._value | append: '.'| append: profit_and_loss.selected_time_dimension._value }}&Currency={{ _filters['profit_and_loss.target_currency_tcurr'] | url_encode }}&Company={{ _filters['profit_and_loss.company_text'] | url_encode }}"
  #   # }
  #   # profit_and_loss.parameter_display_time_dimension
  #   # https://cortexdev.cloud.looker.com/dashboards/99?Currency=USD&Select+Fiscal+Timeframe=2023.Q4%2C2023.Q3&Company+%28text%29=C006-CYMBAL+US-CENTRAL&Display+Period+or+Quarter=qtr&Select+Comparison+Type=prior&GL+Level=3&Ledger+Name=Leading+Ledger
  #   # value_format_name: millions_d1
  # }



  # set: set_drill_profit_to_parent {
  #   fields: [profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,
  #     profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit.kpi_name,
  #     profit_and_loss.glparent_text,
  #     profit_and_loss.total_amount_in_global_currency]
  # }

  # set: set_drill_profit_to_child {
  #   fields: [profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,
  #     profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit.kpi_name,
  #     profit_and_loss.glparent_text,
  #     profit_and_loss.glnode_text,
  #     profit_and_loss.total_amount_in_global_currency]
  # }

  # measure: drill_profit_to_child {
  #   hidden: yes
  #   type: number
  #   sql: 1 ;;
  #   drill_fields: [set_drill_profit_to_child*]
  # }

  # measure: drill_profit_to_parent {
  #   hidden: yes
  #   type: number
  #   sql: 1 ;;
  #   drill_fields: [set_drill_profit_to_parent*]
  # }
 }
