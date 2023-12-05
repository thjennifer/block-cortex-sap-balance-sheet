view: fiscal_periods_sdt {
  derived_table: {
    sql: select
              FiscalYear as fiscal_year,
              FiscalPeriod as fiscal_period,
              concat(b.FiscalYear,'.Q',b.FiscalQuarter) as fiscal_year_quarter,
              concat(b.FiscalYear,'.',right(b.FiscalPeriod,2))  AS fiscal_year_period,
              parse_numeric(concat(b.FiscalYear,right(b.FiscalPeriod,2))) * -1 as trick_sort_desc_fiscal_year_period
      FROM `zeeshanqayyum1.SAP_REPORTING_ECC.BalanceSheet`  AS b
      group by 1,2,3,4,5
      order by 1 desc ;;
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
    order_by_field: trick_sort_desc_fiscal_year_period
  }

  dimension: trick_sort_desc_fiscal_year_period {
    hidden: yes
    type: number
    sql: ${TABLE}.trick_sort_desc_fiscal_year_period ;;
  }


}
