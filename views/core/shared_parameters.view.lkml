view: shared_parameters {




  parameter: display {
    view_label: "Balance Sheet"
    label: "Select Display Level"
    type: unquoted
    allowed_value: {label: "Fiscal Year" value: "fiscal_year"}
    allowed_value: {label: "Fiscal Quarter" value: "fiscal_year_quarter"}
    allowed_value: {label: "Fiscal Period" value: "fiscal_year_period"}
    allowed_value: {label: "Reporting v Comparison" value: "fiscal_period_group" }
    default_value: "fiscal_year_period"
  }


   }
