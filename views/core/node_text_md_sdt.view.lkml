view: node_text_md_sdt {
  derived_table: {
    sql: select
            mandt as Client,
            hierarchyname as GLHiearchy,
            chartofaccounts as ChartOfAccounts,
            node as Node,
            nodetext as NodeText,
            languagekey as LanguageKey_SPRAS
    from `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.node_glaccount_mapping`
    group by 1,2,3,4,5,6 ;;
  }

  measure: count {
    type: count
  }

  dimension: client {
    type: string
    sql: ${TABLE}.Client ;;
  }

  dimension: glhiearchy {
    type: string
    sql: ${TABLE}.GLHiearchy ;;
  }

  dimension: chart_of_accounts {
    type: string
    sql: ${TABLE}.ChartOfAccounts ;;
  }

  dimension: node {
    type: string
    sql: ${TABLE}.Node ;;
  }

  dimension: node_text {
    type: string
    sql: ${TABLE}.NodeText ;;
  }

  dimension: language_key_spras {
    type: string
    sql: ${TABLE}.LanguageKey_SPRAS ;;
  }


}
