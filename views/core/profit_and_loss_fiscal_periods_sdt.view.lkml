######################
# Finds the Fiscal Years and Periods available in Profit and Loss
#
# Used as source for Fiscal Period parameter or filter selections
# Depending on max_fp_size, fiscal_year_period will display either YYYY.PP or YYYY.PPP
# includes dimension negative_fiscal_year_period_number which:
#   - is used as an order_by_field for fiscal_year_period
#   - allows the fiscal_year_period to be displayed in descending order in paramter/filter drop-down selectors
######################


view: profit_and_loss_fiscal_periods_sdt {
  derived_table: {
    sql:
      {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
      {% if max_fp_size == 2 %}{% assign fp = 'right(b.FiscalPeriod,2)'%}
      {% else %}{%assign fp = 'b.FiscalPeriod' %}{%endif%}
      select
        FiscalYear as fiscal_year,
        FiscalPeriod as fiscal_period,
        concat(pl.FiscalYear,'.Q',pl.FiscalQuarter) as fiscal_year_quarter,
        concat(pl.FiscalYear,'.',{{fp}})  AS fiscal_year_period,
        parse_numeric(concat(pl.FiscalYear,{{fp}})) * -1 as negative_fiscal_year_period_number
      FROM `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.ProfitAndLoss`  AS pl
      GROUP BY
        fiscal_year,
        fiscal_period,
        fiscal_year_quarter,
        fiscal_year_period,
        negative_fiscal_year_period_number ;;
  }

  dimension: fiscal_year {
    type: string
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_period {
    type: string
    sql: ${TABLE}.fiscal_period ;;
  }

  dimension: fiscal_year_quarter {
    type: string
    sql: ${TABLE}.fiscal_year_quarter ;;
  }

  dimension: fiscal_year_period {
    type: string
    primary_key: yes
    sql: ${TABLE}.fiscal_year_period ;;
    order_by_field: negative_fiscal_year_period_number
  }

  dimension: negative_fiscal_year_period_number {
    hidden: yes
    type: number
    sql: ${TABLE}.negative_fiscal_year_period_number ;;
  }


}
