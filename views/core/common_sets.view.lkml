view: common_sets {
  extension: required

  set: drill_profit {
    fields: [profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit,
            profit_and_loss_kpi_to_glaccount_map_sdt.component_of_profit.kpi_name,
            profit_and_loss.glparent_text,
            profit_and_loss.total_amount_in_global_currency]
  }
  }
