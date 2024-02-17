######################
# Finds the Fiscal Years and Periods available in Balance Sheet
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
        SELECT  CONCAT(glhierarchy,company_code,fiscal_year,fiscal_period) as unique_id,
              glhierarchy,
              company_code,
              fiscal_year,
              fiscal_quarter,
              fiscal_period,
              CONCAT(fiscal_year,'.Q',fiscal_quarter) AS fiscal_year_quarter,
              CONCAT(fiscal_year,'.',fiscal_period) as fiscal_year_period,
              CAST(PARSE_NUMERIC(fiscal_year) - 1 AS STRING) as prior_fiscal_year,
              LAG(CONCAT(fiscal_year,'.Q',fiscal_quarter),3) OVER (PARTITION BY glhierarchy, company_code ORDER BY fiscal_year, fiscal_quarter) as prior_fiscal_year_quarter,
              LAG(CONCAT(fiscal_year,'.',fiscal_period)) OVER (PARTITION BY glhierarchy, company_code ORDER BY fiscal_year, fiscal_period) as prior_fiscal_year_period,
              CAST(PARSE_NUMERIC(fiscal_year) - 1 AS STRING) as yoy_fiscal_year,
              CONCAT(PARSE_NUMERIC(fiscal_year) - 1,'.Q',fiscal_quarter) as yoy_fiscal_year_quarter,
              CONCAT(PARSE_NUMERIC(fiscal_year) - 1,'.',fiscal_period) as yoy_fiscal_year_period,
              MAX(fiscal_period) OVER (PARTITION BY glhierarchy, company_code) as max_fiscal_period_in_year,
              COUNT (DISTINCT fiscal_period) OVER (PARTITION BY glhierarchy, company_code, fiscal_quarter) as max_periods_in_quarter,
              RANK() OVER (PARTITION BY glhierarchy, company_code, fiscal_year, fiscal_quarter ORDER by fiscal_period) as period_order_in_quarter
        FROM (
            SELECT
              GLHierarchy as glhierarchy,
              CompanyCode as company_code,
              FiscalYear as fiscal_year,
              FiscalQuarter as fiscal_quarter,
              FiscalPeriod as fiscal_period
              --,
              --CONCAT(pl.FiscalYear,'.Q',pl.FiscalQuarter) AS fiscal_year_quarter,
              --CONCAT(pl.FiscalYear,'.',pl.FiscalPeriod)  AS fiscal_year_period
            FROM `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.ProfitAndLoss`  AS pl
            WHERE Client = '@{CLIENT_ID}'
            --AND CONCAT(pl.FiscalYear,'.',pl.FiscalPeriod) <= '2023.011'
            GROUP BY
              glhierarchy,
              company_code,
              fiscal_year,
              fiscal_quarter,
              fiscal_period
            ) p
            ;;
  }

  dimension: unique_id {
    type: string
    primary_key: yes
    sql: ${TABLE}.unique_id ;;
  }

  dimension: glhierarchy {
    type: string
    sql: ${TABLE}.glhierarchy ;;
  }

  dimension: company_code {
    type: string
    sql: ${TABLE}.company_code ;;
  }

  dimension: fiscal_year {
    type: string
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_quarter {
    type: string
    sql: ${TABLE}.fiscal_quarter ;;
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
    sql: ${TABLE}.fiscal_year_period ;;
    # order_by_field: negative_fiscal_year_period_number
  }

  dimension: fiscal_year_period_number {
    type: number
    sql: PARSE_NUMERIC(${fiscal_year_period}) ;;
    # order_by_field: negative_fiscal_year_period_number
  }

  dimension: prior_fiscal_year {
    type: string
    sql: ${TABLE}.prior_fiscal_year ;;
  }

  dimension: prior_fiscal_year_quarter {
    type: string
    sql: ${TABLE}.prior_fiscal_year_quarter ;;
  }

  dimension: prior_fiscal_year_period {
    type: string
    sql: ${TABLE}.prior_fiscal_year_period ;;
  }

  dimension: yoy_fiscal_year {
    type: string
    sql: ${TABLE}.yoy_fiscal_year ;;
  }

  dimension: yoy_fiscal_year_quarter {
    type: string
    sql: ${TABLE}.yoy_fiscal_year_quarter ;;
  }

  dimension: yoy_fiscal_year_period {
    type: string
    sql: ${TABLE}.yoy_fiscal_year_period ;;
  }


}
