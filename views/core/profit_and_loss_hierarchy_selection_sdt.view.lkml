include: "/views/core/profit_and_loss_path_to_node_pdt.view"
include: "/views/core/common_hierarchy_fields_finance_ext.view"

view: profit_and_loss_hierarchy_selection_sdt {
 extends: [common_hierarchy_fields_finance_ext]
 label: "Income Statement"
 fields_hidden_by_default: yes

 derived_table: {
  sql:
    {% assign start = parameter_pick_start_level._parameter_value | times: 1 | minus: 2 %}
    {% assign depth = parameter_pick_depth_level._parameter_value | times: 1 | minus: 1 %}
    select
       h.Client,
       h.ChartOfAccounts,
       h.GLHierarchy,
       LanguageKey_SPRAS,
       LevelNumber,
       LevelSequenceNumber,
       GLNode,
       GLNodeText,
       NodeTextPath_String,
       NodePath_String,
       NodeTextPath[SAFE_OFFSET({{start}})] AS hier1_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 1}})] AS hier2_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 2}})] AS hier3_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 3}})] AS hier4_node_text,
       NodeTextPath[SAFE_OFFSET({{start | plus: 4}})] AS hier5_node_text,

       NodePath[SAFE_OFFSET({{start}})] AS hier1_node,
       NodePath[SAFE_OFFSET({{start | plus: 1}})] AS hier2_node,
       NodePath[SAFE_OFFSET({{start | plus: 2}})] AS hier3_node,
       NodePath[SAFE_OFFSET({{start | plus: 3}})] AS hier4_node,
       NodePath[SAFE_OFFSET({{start | plus: 4}})] AS hier5_node
   from ${profit_and_loss_path_to_node_pdt.SQL_TABLE_NAME} h

   where
    --filter to ending level as start + depth + 2 (add 2 as minimum level in hierarchy is 2)
    --cap at max number of levels if start + depth + 2 exceeds
    LevelNumber = least({{start}} + {{depth}} + 2,MaxLevelNumber)

    ;;
}

  parameter: parameter_pick_start_level {
    hidden: no
    suggest_explore: profit_and_loss
    suggest_dimension: profit_and_loss.gllevel
   }


  dimension: key {
    hidden: yes
    type: string
    primary_key: yes
    sql: concat(${client_mandt},${glhierarchy},${chart_of_accounts},${language_key_spras},${glnode}) ;;
  }


  dimension: client_mandt {
    type: string
    sql: ${TABLE}.client ;;
  }

  dimension: chart_of_accounts {
    type: string
    sql: ${TABLE}.ChartOfAccounts ;;
  }

  dimension: glhierarchy {
    type: string
    sql: ${TABLE}.GLHierarchy ;;
  }

  dimension: language_key_spras {
    type: string
    sql: ${TABLE}.LanguageKey_SPRAS ;;
  }

  dimension: glnode {
    type: string
    sql: ${TABLE}.glnode ;;
  }

  dimension: glnode_text {
    type: string
    sql: ${TABLE}.GLNodeText ;;
  }

}
