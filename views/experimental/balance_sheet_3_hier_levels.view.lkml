view: balance_sheet_3_hier_levels {
  derived_table: {
    persist_for: "3 hours"
    create_process: {
     sql_step:
      create or replace TABLE ${SQL_TABLE_NAME} AS
       --SELECT 1 AS field1
      WITH
  RECURSIVE n AS (
  SELECT
    ChartOfAccounts,
    HierarchyName,
    CompanyCode,
    COALESCE(BusinessArea,'N/A') AS BusinessArea,
    COALESCE(LedgerInGeneralLedgerAccounting,'0L') AS LedgerInGeneralLedgerAccounting,
    LanguageKey_SPRAS,
    CAST(Level AS INT64) AS level_number,
    Parent,
    COALESCE(ParentText,Parent) AS ParentText,
    Node,
    COALESCE(NodeText,Node) AS NodeText
    --FROM `kittycorn-dev-infy.SAP_REPORTING_ECC.BalanceSheet`
  FROM
    `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.BalanceSheet`
  WHERE
    Client = '100' and
    --CAST(Level AS INT64) between 2 and 4 and
    CAST(Level AS INT64) < 10
  GROUP BY
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11 ),
  iterations AS (
  SELECT
    ChartOfAccounts,
    HierarchyName,
    CompanyCode,
    BusinessArea,
    LedgerInGeneralLedgerAccounting,
    LanguageKey_SPRAS,
    level_number,
    Node,
    NodeText,
    Parent,
    ParentText,
    0 AS level_count,
    nodeText AS node_text_path,
    Node AS node_path
  FROM
    n
  WHERE
    level_number = 2
  UNION ALL
  SELECT
    n.ChartOfAccounts,
    n.HierarchyName,
    n.CompanyCode,
    n.BusinessArea,
    n.LedgerInGeneralLedgerAccounting,
    n.LanguageKey_SPRAS,
    n.level_number,
    n.node,
    n.NodeText,
    n.Parent,
    n.ParentText,
    level_count+1 AS level_count,
    CONCAT(node_text_path, '/',n.nodeText) AS node_text_path,
    CONCAT(node_path, '/',n.node) AS node_path
  FROM
    n
  JOIN
    iterations i
  ON
    i.node = n.Parent
    AND i.ChartOfAccounts = n.ChartOfAccounts
    AND i.HierarchyName = n.HierarchyName
    AND i.CompanyCode = n.CompanyCode
    AND i.LanguageKey_SPRAS = n.LanguageKey_SPRAS
    AND i.BusinessArea = n.BusinessArea
    AND i.LedgerInGeneralLedgerAccounting = n.LedgerInGeneralLedgerAccounting )

SELECT
  DISTINCT
  ChartOfAccounts,
  HierarchyName,
  CompanyCode,
  BusinessArea,
  LedgerInGeneralLedgerAccounting,
  LanguageKey_SPRAS,
  level_number,
  node,
  node_text,
  node_text_path,
  level_count,
  hier_text[SAFE_OFFSET(0)] AS hier0_node_text,
  hier_text[SAFE_OFFSET(1)] AS hier1_node_text,
  hier_text[SAFE_OFFSET(2)] AS hier2_node_text,
  hier_code[SAFE_OFFSET(0)] AS hier0_node,
  hier_code[SAFE_OFFSET(1)] AS hier1_node,
  hier_code[SAFE_OFFSET(2)] AS hier2_node
FROM (
  SELECT
    ChartOfAccounts,
    HierarchyName,
    CompanyCode,
    BusinessArea,
    LedgerInGeneralLedgerAccounting,
    LanguageKey_SPRAS,
    node,
    NodeText AS node_text,
    Parent AS parent,
    level_number,
    node_text_path,
    node_path,
    level_count,
    RIGHT('                       ',level_number*5) || NodeText AS parent_child_tree,
    SPLIT(node_text_path,'/') AS hier_text,
    SPLIT(node_path,'/') AS hier_code
  FROM
    iterations )
WHERE
  level_number BETWEEN 2
  AND 4
      ;;
  }
  }


  fields_hidden_by_default: yes

  dimension: key {
    hidden: yes
    type: string
    primary_key: yes
    sql: concat(${hierarchy_name},${chart_of_accounts},${business_area},${ledger_in_general_ledger_accounting},
                ${company_code},${language_key_spras},${node}) ;;
  }

  dimension: chart_of_accounts {
    type: string
    sql: ${TABLE}.ChartOfAccounts ;;
  }

  dimension: hierarchy_name {
    type: string
    sql: ${TABLE}.HierarchyName ;;
  }

  dimension: company_code {
    type: string
    sql: ${TABLE}.CompanyCode ;;
  }

  dimension: business_area {
    type: string
    sql: ${TABLE}.BusinessArea ;;
  }

  dimension: ledger_in_general_ledger_accounting {
    type: string
    sql: ${TABLE}.LedgerInGeneralLedgerAccounting ;;
  }

  dimension: language_key_spras {
    type: string
    sql: ${TABLE}.LanguageKey_SPRAS ;;
  }

  dimension: level_number {
    type: number
    sql: ${TABLE}.level_number ;;
  }

  dimension: node {
    type: string
    sql: ${TABLE}.node ;;
  }

  dimension: node_text {
    type: string
    sql: ${TABLE}.node_text ;;
  }

  dimension: node_text_path {
    hidden: no
    type: string
    sql: ${TABLE}.node_text_path ;;
  }

  dimension: hier0_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier0_node_text ;;
    order_by_field: hier0_node
  }

  dimension: hier1_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier1_node_text ;;
    order_by_field: hier1_node
  }

  dimension: hier2_node_text {
    hidden: no
    type: string
    sql: ${TABLE}.hier2_node_text ;;
    order_by_field: hier2_node
  }

  dimension: hier0_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier0_node ;;
  }

  dimension: hier1_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier1_node ;;
  }

  dimension: hier2_node {
    hidden: no
    type: string
    sql: ${TABLE}.hier2_node ;;
  }


}
