view: fiscal_periods_sdt {
  derived_table: {
    sql: select
              FiscalYear,
              FiscalPeriod,
              concat(balance_sheet.FiscalYear,'.',right(balance_sheet.FiscalPeriod,2))  AS fiscal_year_period,
              parse_numeric(concat(balance_sheet.FiscalYear,right(balance_sheet.FiscalPeriod,2))) * -1 as trick_sort_desc_fiscal_year_period
      FROM `zeeshanqayyum1.SAP_REPORTING_ECC.BalanceSheet`  AS balance_sheet
      group by 1,2
      order by 1 desc ;;
  }



  dimension: fiscal_year_period {
    type: string
    sql: ${TABLE}.fiscal_year_period ;;
    order_by_field: trick_sort_desc_fiscal_year_period
  }

  dimension: trick_sort_desc_fiscal_year_period {
    hidden: yes
    type: number
    sql: ${TABLE}.trick_sort_desc_fiscal_year_period ;;
  }


}
