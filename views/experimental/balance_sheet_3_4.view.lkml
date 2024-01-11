view: balance_sheet_3_4 {
  derived_table: {
    sql: with l3 as (
        select Parent, ParentText, Node, NodeText, sum(CumulativeAmountInTargetCurrency) as CumulativeAmountInTargetCurrency
        FROM
          `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.BalanceSheet`
        WHERE
          ChartOfAccounts = 'YCOA'
          AND HierarchyName = 'FPA1'
          AND TargetCurrency_TCURR = 'USD'
          AND LanguageKey_SPRAS = 'E'
          AND CAST(Level AS INT64) = 3
          and FiscalYear = '2023'
          and FiscalPeriod = '009'
          and CompanyCode = 'C006'
          and LedgerInGeneralLedgerAccounting = '0L'
          group by 1,2,3,4

      )
      ,
      l4 as (select Parent, ParentText, Node, NodeText, sum(CumulativeAmountInTargetCurrency) as CumulativeAmountInTargetCurrency
        FROM
          `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.BalanceSheet`
        WHERE
          ChartOfAccounts = 'YCOA'
          AND HierarchyName = 'FPA1'
          AND TargetCurrency_TCURR = 'USD'
          AND LanguageKey_SPRAS = 'E'
          AND CAST(Level AS INT64) = 4
          and FiscalYear = '2023'
          and FiscalPeriod = '009'
          and CompanyCode = 'C006'
          and LedgerInGeneralLedgerAccounting = '0L'
          group by 1,2,3,4
      )
      select l3.ParentText as ParentText_l3, l3.Parent as Parent_l3, l3.Node as Node_l3, l3.NodeText as NodeText_l3, l4.Node as Node_l4 , l4.NodeText as NodeText_l4
      ,coalesce(l4.CumulativeAmountInTargetCurrency,l3.CumulativeAmountInTargetCurrency) as CumulativeAmountInTargetCurrency
      from l3
      left join l4 on l3.Node = l4.Parent

      order by Parent_l3, Node_l3, Node_l4 ;;
  }

  measure: count {
    type: count

  }

  dimension: parent_text_l3 {
    type: string
    sql: ${TABLE}.ParentText_l3 ;;
  }

  dimension: parent_l3 {
    type: string
    sql: ${TABLE}.Parent_l3 ;;
  }

  dimension: node_l3 {
    type: string
    sql: ${TABLE}.Node_l3 ;;
  }

  dimension: node_text_l3 {
    type: string
    sql: ${TABLE}.NodeText_l3 ;;
  }

  dimension: node_l4 {
    type: string
    sql: ${TABLE}.Node_l4 ;;
  }

  dimension: node_text_l4 {
    type: string
    sql: ${TABLE}.NodeText_l4 ;;
  }

  dimension: cumulative_amount_in_target_currency {
    type: number
    sql: ${TABLE}.CumulativeAmountInTargetCurrency ;;
  }

  measure: total_amount_target_currency {
    type: sum
    sql: ${cumulative_amount_in_target_currency} ;;
  }

}
