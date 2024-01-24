view: hierarchy_path_to_node_pdt {
  derived_table: {
    persist_for: "24 hours"
    create_process: {
      sql_step:

CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} as
WITH
  RECURSIVE n AS (
  SELECT
    Client,
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
  GROUP BY
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ),
  iterations AS (
  SELECT
    Client,
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
    n.Client,
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
    AND i.Client = n.Client
    AND i.ChartOfAccounts = n.ChartOfAccounts
    AND i.HierarchyName = n.HierarchyName
    AND i.CompanyCode = n.CompanyCode
    AND i.LanguageKey_SPRAS = n.LanguageKey_SPRAS
    AND i.BusinessArea = n.BusinessArea
    AND i.LedgerInGeneralLedgerAccounting = n.LedgerInGeneralLedgerAccounting )
select * from iterations

      ;;
    }
  }
   }
