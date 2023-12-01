view: shared_parameters {
  filter: pick_fiscal_periods {
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }


  filter: pick_comparison_periods {
    suggest_explore: remaining_periods_available_sdt
    suggest_dimension: remaining_periods_available_sdt.fiscal_year_period
  }

   }
