view: shared_parameters {
  filter: pick_fiscal_periods {
    view_label: "🗓️ Pick Dates OPTION 2"
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }


  filter: pick_comparison_periods {
    view_label: "🗓️ Pick Dates OPTION 2"
    suggest_explore: fiscal_periods_sdt
    suggest_dimension: fiscal_periods_sdt.fiscal_year_period
  }

  filter: select_reporting_dates {
    view_label: "🗓️ Pick Dates OPTION 3"
    type: date
    convert_tz: no
  }

  parameter: select_compare_to {
    view_label: "🗓️ Pick Dates OPTION 3"
    type: unquoted
    allowed_value: {
      label: "Year over Year" value: "yoy"
    }
    allowed_value: {
      label: "Same # Periods Prior" value: "prior"
    }
    default_value: "yoy"
  }

  dimension: compare_period_start_date {
    view_label: "🗓️ Pick Dates OPTION 3"
    type: date
    sql:{% if select_compare_to._parameter_value == 'yoy' %}
            DATE_SUB(DATE({% date_start select_reporting_dates %}), INTERVAL 1 YEAR)
         {% elsif select_compare_to._parameter_value == 'prior' %}
              DATE_SUB(
                      DATE({% date_start select_reporting_dates %}), INTERVAL
                      DATE_DIFF(DATE({% date_end select_reporting_dates %}),DATE({% date_start select_reporting_dates %}),MONTH)
                      MONTH)
         {% endif %};;
  }

  dimension: compare_period_end_date {
    view_label: "🗓️ Pick Dates OPTION 3"
    type: date
    sql:{% if select_compare_to._parameter_value == 'yoy' %}
           DATE_SUB(DATE({% date_end shared_parameters.select_reporting_dates %}), INTERVAL 1 YEAR)

         {% elsif select_compare_to._parameter_value == 'prior' %}
             DATE({% date_start shared_parameters.select_reporting_dates %})
         {% endif %};;
  }


   }
