view: fiscal_periods_sdt {
  derived_table: {
    sql:
      SELECT
        FiscalYear as fiscal_year,
        FiscalPeriod as fiscal_period,
        CONCAT(b.FiscalYear,'.Q',b.FiscalQuarter) AS fiscal_year_quarter,
        CONCAT(b.FiscalYear,'.',b.FiscalPeriod)  AS fiscal_year_period,
        PARSE_NUMERIC(CONCAT(b.FiscalYear,b.FiscalPeriod)) * -1 AS negative_fiscal_year_period_number,
        PARSE_NUMERIC(CONCAT(b.FiscalYear,b.FiscalQuarter)) * -1 AS negative_fiscal_year_quarter_number,
        PARSE_NUMERIC(b.FiscalYear) * -1 as negative_fiscal_year_number
      FROM `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.BalanceSheet`  AS b
      WHERE Client = '@{CLIENT_ID}'
      GROUP BY
        fiscal_year,
        fiscal_period,
        fiscal_year_quarter,
        fiscal_year_period,
        negative_fiscal_year_period_number,
        negative_fiscal_year_quarter_number;;
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

  dimension: negative_fiscal_year_quarter_number {
    hidden: yes
    type: number
    sql: ${TABLE}.negative_fiscal_year_quarter_number ;;
  }

  dimension: negative_fiscal_year_number {
    hidden: yes
    type: number
    sql: ${TABLE}.negative_fiscal_year_number ;;
  }


}
