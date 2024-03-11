view: profit_and_loss_path_to_node_pdt {
  derived_table: {
    persist_for: "1000 hours"
    # datagroup_trigger: balance_sheet_node_count
    create_process: {
      sql_step:

      CREATE OR REPLACE TABLE ${SQL_TABLE_NAME} as
      WITH
        RECURSIVE n AS (
        SELECT
          Client,
          ChartOfAccounts,
          GLHierarchy,
          LanguageKey_SPRAS,
          CAST(GLLevel AS INT64) AS LevelNumber,
          GLParent,
          COALESCE(GLParentText,GLParent) AS GLParentText,
          GLNode,
          COALESCE(GLNodeText,GLNode) AS GLNodeText
        FROM
          `@{GCP_PROJECT_ID}.@{REPORTING_DATASET}.ProfitAndLoss`
        GROUP BY
          Client,
          ChartOfAccounts,
          GLHierarchy,
          LanguageKey_SPRAS,
          CAST(GLLevel AS INT64),
          GLParent,
          COALESCE(GLParentText,GLParent),
          GLNode,
          COALESCE(GLNodeText,GLNode)
          --1, 2, 3, 4, 5, 6, 7, 8, 9
          ),
        iterations AS (
        SELECT
          Client,
          ChartOfAccounts,
          GLHierarchy,
          LanguageKey_SPRAS,
          LevelNumber,
          GLNode,
          GLNodeText,
          GLParent,
          GLParentText,
          0 AS LevelSequenceNumber,
          GLnodeText AS NodeTextPath_String,
          GLNode AS NodePath_String
        FROM
          n
        WHERE
          LevelNumber = 2
        UNION ALL
        SELECT
          n.Client,
          n.ChartOfAccounts,
          n.GLHierarchy,
          n.LanguageKey_SPRAS,
          n.LevelNumber,
          n.GLNode,
          n.GLNodeText,
          n.GLParent,
          n.GLParentText,
          LevelSequenceNumber+1 AS LevelSequenceNumber,
          CONCAT(NodeTextPath_String, '-->',n.GLNodeText) AS NodeTextPath_String,
          CONCAT(NodePath_String, '-->',n.GLNode) AS NodePath_String
        FROM
          n
        JOIN
          iterations i
        ON
          i.GLNode = n.GLParent
          AND i.Client = n.Client
          AND i.ChartOfAccounts = n.ChartOfAccounts
          AND i.GLHierarchy = n.GLHierarchy
          AND i.LanguageKey_SPRAS = n.LanguageKey_SPRAS
          AND i.LevelSequenceNumber < 12
          )
      SELECT Client,
             ChartOfAccounts,
             GLHierarchy,
             LanguageKey_SPRAS,
             GLNode,
             GLNodeText,
             GLParentText,
             LevelNumber,
             LevelSequenceNumber,
             MAX(LevelNumber) OVER (PARTITION BY Client,ChartOfAccounts,GLHierarchy) AS MaxLevelNumber,
             NodeTextPath_String,
             NodePath_String,
             SPLIT(NodeTextPath_String,'-->') AS NodeTextPath,
             SPLIT(NodePath_String,'-->') AS NodePath
      FROM iterations
       ;;
    }
  }
}
