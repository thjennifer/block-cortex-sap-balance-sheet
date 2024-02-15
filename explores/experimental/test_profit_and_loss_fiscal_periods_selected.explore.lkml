include: "/views/experimental/new_profit_and_loss_fiscal_periods_selected_sdt.view"
include: "/views/core/profit_and_loss_rfn.view"

explore: new_profit_and_loss_fiscal_periods_selected_sdt {
  join: profit_and_loss {
      type: inner
      relationship: many_to_many
      sql_on: ${profit_and_loss.glhierarchy} = ${new_profit_and_loss_fiscal_periods_selected_sdt.glhierarchy}
              AND ${profit_and_loss.company_code} = ${new_profit_and_loss_fiscal_periods_selected_sdt.company_code}
              AND ${profit_and_loss.fiscal_year} = ${new_profit_and_loss_fiscal_periods_selected_sdt.fiscal_year}
              and ${profit_and_loss.fiscal_period} = ${new_profit_and_loss_fiscal_periods_selected_sdt.fiscal_period};;

  }
}
