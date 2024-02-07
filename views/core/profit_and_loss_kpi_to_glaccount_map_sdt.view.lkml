# include: "/views/core/common_sets.view"
view: profit_and_loss_kpi_to_glaccount_map_sdt {
  # extends: [common_sets]
  derived_table: {
    sql: {% assign sql_flavor = '_user_attributes[\'sap_sql_flavor\']' %}
          {% if sql_flavor == 'ECC' %}{% assign lpad_setting = "10,'0'" %}
          {% else %}{% assign lpad_setting = "11,'100'" %}
          {% endif %}
          {% assign profit_type = pick_profit_type._parameter_value %}
       SELECT kpi_name,
              lpad(cast(gl_account as string),{{lpad_setting}}) as gl_account,

              case when kpi_name in ('Net Revenue','Cost of Goods Sold') then kpi_name
              {% if profit_type == "'np'" %}
                   when kpi_name in ('Operating Expense', 'Non-Operating Expense', 'Interest Expense', 'Foreign Currency Expense') then 'Expenses'
                   when kpi_name in ('Non-Operating Revenue', 'Interest Income', 'Foreign Currency Income') then 'Other Income'
              {% endif %} end as component_of_profit,

              case when kpi_name = 'Net Revenue' then 1
                   when kpi_name = 'Cost of Goods Sold' then 2
              {% if profit_type == "'np'" %}
                   when kpi_name in ('Operating Expense', 'Non-Operating Expense', 'Interest Expense', 'Foreign Currency Expense') then 3
                   when kpi_name in ('Non-Operating Revenue', 'Interest Income', 'Foreign Currency Income') then 4
              {% endif %} end as component_of_profit_sort_order,

              case when kpi_name in ('Net Revenue','Cost of Goods Sold') then kpi_name end as component_of_gross_profit,

              case when kpi_name in ('Net Revenue','Cost of Goods Sold') then kpi_name
                   when kpi_name in ('Operating Expense', 'Non-Operating Expense', 'Interest Expense', 'Foreign Currency Expense') then 'Expenses'
                   when kpi_name in ('Non-Operating Revenue', 'Interest Income', 'Foreign Currency Income') then 'Other Income'
              end as component_of_net_profit,

              case when kpi_name = 'Net Revenue' then 1
                   when kpi_name = 'Cost of Goods Sold' then 2
                   when kpi_name in ('Operating Expense', 'Non-Operating Expense', 'Interest Expense', 'Foreign Currency Expense') then 3
                   when kpi_name in ('Non-Operating Revenue', 'Interest Income', 'Foreign Currency Income') then 4
              end as component_of_net_profit_sort_order,

              case when kpi_name = 'Net Revenue' then 1
                   when kpi_name = 'Cost of Goods Sold' then 2
              end as component_of_gross_profit_sort_order
       FROM
       (
        select[
        {% if sql_flavor == 'ECC' %}
        struct("Advertising and Third Party Expenses" as kpi_name,[610010,610020,650000,650005,650010,650020,650030,650040,650050,650060,650085,650500,651000,652000,653000,654000,655000] as gl_accounts),
        struct("Building Expense" as kpi_name,[630000,630005,630010,630020,630030,630040,630050,630060] as gl_accounts),
        struct("Cost of Goods Sold" as kpi_name,[500000,500010,500020,510000,510005,510006,510010,510020,520000,520060,520065,520100,530000] as gl_accounts),
        struct("Depreciation and Amortization" as kpi_name,[640010, 640040, 640050, 640060, 640070, 640080, 640200] as gl_accounts),
        struct("Employee Expense" as kpi_name,[610060,610070,610080,610100,610200,610210,610220,610230,610510,610600,610610,611000,611030,612000] as gl_accounts),
        struct("Foreign Currency Expense" as kpi_name,[720100,720200,720400] as gl_accounts),
        struct("Foreign Currency Income" as kpi_name,[725100,725200,725300,725400] as gl_accounts),
        struct("Gross Margin" as kpi_name,[410000, 410004, 410005, 410006, 410007, 410010, 410015, 410020, 410030, 410040, 410050, 410060, 410070, 440000, 440010, 440020, 440025, 440026, 440027, 440030, 440040, 440050, 500000, 500010, 500020, 510000, 510005, 510006, 510010, 510020, 520000, 520060, 520065, 520100, 530000] as gl_accounts),
        struct("Gross Revenue" as kpi_name,[410000, 410004, 410005, 410006, 410007, 410010, 410015, 410020, 410030, 410040, 410050, 410060, 410070] as gl_accounts),
        struct("Interest" as kpi_name,[700100, 700110, 700600, 700610] as gl_accounts),
        struct("Interest Expense" as kpi_name,[700100, 700110] as gl_accounts),
        struct("Interest Income" as kpi_name,[700600, 700610] as gl_accounts),
        struct("Miscellaneous and Other Operating Expense" as kpi_name,[615000, 620000, 660000, 660005, 690000] as gl_accounts),
        struct("Net Income (P&L)" as kpi_name,[410000, 410004, 410005, 410006, 410007, 410010, 410015, 410020, 410030, 410040, 410050, 410060, 410070, 440000, 440010, 440020, 440025, 440026, 440027, 440030, 440040, 440050, 500000, 500005, 500010, 500020, 510000, 510005, 510006, 510010, 510020, 510050, 510060, 510080, 510085, 510086, 510090, 520000, 520010, 520020, 520040, 520050, 520055, 520060, 520065, 520070, 520075, 520076, 520085, 520100, 520110, 520111, 520120, 520130, 530000, 530030, 530050, 530060, 610010, 610020, 610030, 610040, 610060, 610070, 610080, 610100, 610200, 610210, 610220, 610230, 610510, 610600, 610610, 611000, 611030, 612000, 615000, 620000, 630000, 630005, 630010, 630020, 630030, 630040, 630050, 630060, 640000, 640010, 640020, 640030, 640040, 640050, 640060, 640070, 640080, 640200, 650000, 650005, 650010, 650020, 650030, 650040, 650050, 650060, 650085, 650500, 651000, 652000, 653000, 654000, 655000, 660000, 660005, 690000, 700000, 700050, 700100, 700110, 700130, 700210, 700400, 700410, 700420, 700500, 700600, 700610, 700800, 701000, 720100, 720200, 720400, 725100, 725200, 725300, 725400, 750020, 750030] as gl_accounts),
        struct("Net Revenue" as kpi_name,[410000, 410004, 410005, 410006, 410007, 410010, 410015, 410020, 410030, 410040, 410050, 410060, 410070, 440000, 440010, 440020, 440025, 440026, 440027, 440030, 440040, 440050] as gl_accounts),
        struct("Non-Operating Expense" as kpi_name,[700000, 700050, 700130, 700400, 700410, 700420, 700800] as gl_accounts),
        struct("Non-Operating Revenue" as kpi_name,[700210] as gl_accounts),
        struct("Operating Expense" as kpi_name,[610010, 610020, 610030, 610040, 610060, 610070, 610080, 610100, 610200, 610210, 610220, 610230, 610510, 610600, 610610, 611000, 611030, 612000, 615000, 620000, 630000, 630005, 630010, 630020, 630030, 630040, 630050, 630060, 640010, 640020, 640040, 640050, 640060, 640070, 640080, 640200, 650000, 650010, 650020, 650030, 650085, 651000, 652000, 653000, 654000, 660000, 660005, 690000] as gl_accounts),
        struct("Other Income and Expense" as kpi_name,[700000, 700050, 700130, 700210, 700400, 700410, 700420, 700500, 700800, 701000, 720100, 720200, 720400, 725100, 725200, 725300, 725400] as gl_accounts),
        struct("Sales Deductions" as kpi_name,[440000, 440010, 440020, 440025, 440026, 440027, 440030, 440040, 440050] as gl_accounts),
        struct("Taxes" as kpi_name,[750020,750030] as gl_accounts)
        {% else %}
        struct("Building Expense" as kpi_name,[63004000,63005000] as gl_accounts),
        struct("Cost of Goods Sold" as kpi_name,[50300000, 50302000, 51100000, 51500000, 51600000, 51950000, 52041000, 54053000, 54083000, 54400000, 55100000, 59900000, 70040000] as gl_accounts),
        struct("Depreciation and Amortization" as kpi_name,[64001000, 64002000, 64004000, 64005000, 64006000, 64007000, 64008000, 64043000] as gl_accounts),
        struct("Employee Expense" as kpi_name,[61003000, 61004000, 61005000, 61006000, 61007000, 61008000, 61010000, 61020000, 61021000, 61021100, 61022000, 61022100, 61051000, 61052000, 61060000, 61061000, 61101000, 61102000, 61200000, 61201000, 63006000, 63007000, 63008000, 65001000, 65008000, 65008300, 65100000, 65150000, 65200000, 65300000, 65400000] as gl_accounts),
        struct("Foreign Currency Expense" as kpi_name,[72010000,72020000,72040000] as gl_accounts),
        struct("Foreign Currency Income" as kpi_name,[72510000,72520000,72540000] as gl_accounts),
        struct("Gross Margin" as kpi_name,[41000000, 41000400, 41001000, 41001500, 44001000, 44002000, 50300000, 50302000, 51100000, 51500000, 51600000, 51950000, 52041000, 54053000, 54083000, 54400000, 55100000, 59900000, 70040000] as gl_accounts),
        struct("Gross Revenue" as kpi_name,[41000000, 41000400, 41001000, 41001500] as gl_accounts),
        struct("Interest" as kpi_name,[70100000,70200000] as gl_accounts),
        struct("Interest Expense" as kpi_name,[22542300, 64060000, 71100000, 71100300, 71100400, 71100500, 71100600, 71300000, 71400200, 71400300, 71500000] as gl_accounts),
        struct("Interest Income" as kpi_name,[70100000,70200000] as gl_accounts),
        struct("Net Income (P&L)" as kpi_name,[11009100, 11009200, 11999099, 11999100, 11999200, 12551000, 12600010, 12605900, 12605901, 12605902, 12605903, 12605905, 12605907, 12605910, 12605911, 12605914, 12605915, 12605917, 12605918, 12605919, 12605920, 12605924, 12609000, 12609112, 12610100, 12618000, 12619000, 12631000, 12660000, 12701000, 12702000, 12702100, 12702200, 12703000, 13711400, 21531000, 21532000, 21536000, 21537000, 21539002, 21539101, 21539105, 22006081, 22007000, 22009999, 22542100, 22542300, 41000000, 41000400, 41001000, 41001500, 41002000, 41003000, 41004000, 41007100, 41007200, 41090000, 41090011, 41910000, 41940000, 41970000, 44000000, 44001000, 44002000, 44002100, 44002200, 44003000, 44003100, 44003200, 44004000, 44005000, 44006000, 44007000, 44007001, 44007002, 44007003, 44007004, 44401100, 44405600, 44420000, 44421000, 44910000, 44940000, 44970000, 49999900, 50100000, 50150000, 50200000, 50300000, 50301000, 50302000, 50303000, 50304000, 50305000, 50306000, 50307000, 50308000, 50309000, 50309500, 51100000, 51500000, 51600000, 51700000, 51900000, 51950000, 52001000, 52003000, 52011000, 52013000, 52021000, 52023000, 52030000, 52031000, 52033000, 52041000, 52041500, 52042000, 52043000, 52044000, 52045000, 52046000, 52051000, 52053000, 52060000, 52070000, 52070500, 52071000, 52072000, 52073000, 52074000, 52075000, 52076000, 52077000, 52078000, 52079000, 52080000, 52501000, 52503000, 52511000, 52513000, 52521000, 52523000, 52530000, 52531000, 52532000, 52541000, 52541100, 52541200, 52541500, 52542000, 52543000, 52544000, 52545000, 52546000, 52551000, 52552000, 52560000, 52570000, 52570500, 52580000, 52590000, 54011000, 54011100, 54011200, 54013000, 54040000, 54051000, 54053000, 54070000, 54083000, 54084000, 54093000, 54200000, 54300000, 54400000, 54441000, 54442000, 54444000, 55100000, 55110000, 59900000, 61002000, 61003000, 61004000, 61005000, 61006000, 61007000, 61008000, 61010000, 61020000, 61021000, 61021100, 61022000, 61022010, 61022020, 61022030, 61022100, 61023010, 61023020, 61023030, 61023040, 61023050, 61023060, 61051000, 61052000, 61060000, 61061000, 61062000, 61063000, 61100000, 61101000, 61102000, 61103000, 61104000, 61200000, 61201000, 61310000, 61400000, 61401000, 61500000, 61500100, 62000000, 62010000, 62020000, 63000000, 63000500, 63001000, 63002000, 63003000, 63004000, 63005000, 63006000, 63007000, 63008000, 63009000, 63009100, 63009200, 63009300, 63009400, 63009500, 63009600, 63009700, 63010100, 63010200, 63010300, 63010400, 63010500, 63010600, 63010700, 63020100, 63020200, 63020300, 63020400, 63020500, 63020600, 63020700, 64000000, 64000100, 64001000, 64001010, 64001100, 64002000, 64002100, 64003000, 64004000, 64004100, 64005000, 64005100, 64006000, 64006100, 64007000, 64007100, 64008000, 64010000, 64020000, 64021000, 64030000, 64031000, 64032000, 64040000, 64043000, 64050000, 64060000, 65000000, 65000500, 65001000, 65002000, 65003000, 65004000, 65008000, 65008300, 65008400, 65008410, 65008420, 65008430, 65008500, 65009000, 65050000, 65100000, 65150000, 65200000, 65300000, 65301000, 65400000, 65900000, 66000000, 66000500, 66000600, 66010000, 66019900, 68000000, 68001000, 68002000, 68010000, 69999010, 69999011, 69999020, 69999021, 69999030, 69999031, 69999040, 69999041, 69999060, 69999061, 69999070, 69999071, 69999080, 69999081, 69999090, 69999091, 69999100, 69999101, 69999110, 69999111, 69999112, 69999120, 69999121, 70010000, 70015000, 70020000, 70030000, 70040000, 70050000, 70100000, 70200000, 70200100, 70200200, 70201000, 70201100, 70201200, 70210000, 70220000, 70220100, 70220200, 70230000, 70300000, 70300100, 70400000, 70500000, 70700000, 70700100, 70700200, 70700300, 70700400, 70800000, 70800100, 70800200, 70900000, 71000000, 71000100, 71000200, 71010000, 71010100, 71010200, 71010300, 71010400, 71010500, 71010600, 71010700, 71010800, 71015000, 71040000, 71050000, 71055000, 71100000, 71100100, 71100200, 71100300, 71100400, 71100500, 71100600, 71100700, 71300000, 71400000, 71400100, 71400200, 71400300, 71500000, 71600000, 71600100, 71600200, 71700000, 71700100, 71700200, 71800000, 72010000, 72010100, 72020000, 72040000, 72050000, 72050100, 72050200, 72060000, 72060100, 72060200, 72510000, 72520000, 72530000, 72531000, 72532000, 72540000, 72550000, 72550100, 72550200, 72560000, 72560100, 72560200, 75001000, 75002000, 75002100, 75002200, 75002300, 75003000, 75004000, 75004010, 75004020, 75004030, 75004040, 75005000, 75007000, 75008000, 75008010, 75008020, 75008050, 75009000, 75009900, 90001000, 90002000, 92101500, 92101800, 92105100, 92105200, 92105300, 92105400, 93100000, 93111100, 93112000, 93113000, 93114000, 93115000, 93116000, 94111000, 94112000, 94113000, 94114000, 94201000, 94202000, 94220000, 94221000, 94222000, 94223000, 94224000, 94225000, 94226000, 94227000, 94228000, 94229000, 94229900, 94301000, 94302000, 94303000, 94304000, 94305000, 94306000, 94307000, 94308000, 94308100, 94308500, 94309000, 94310000, 94311000] as gl_accounts),
        struct("Net Revenue" as kpi_name,[41000000, 41000400, 41001000, 41001500, 44001000, 44002000] as gl_accounts),
        struct("Non-Operating Expense" as kpi_name,[22009999, 22542100, 70050000, 71000000, 71010600, 72550100, 72560000, 90001000, 90002000] as gl_accounts),
        struct("Non-Operating Revenue" as kpi_name,[70010000, 70300100, 70700000, 70700100, 70700200, 70700300, 70700400, 71100200, 71100700, 72530000, 72560100] as gl_accounts),
        struct("Operating Expense" as kpi_name,[61003000, 61004000, 61005000, 61006000, 61007000, 61008000, 61010000, 61020000, 61021000, 61021100, 61022000, 61022100, 61051000, 61052000, 61060000, 61061000, 61101000, 61102000, 61200000, 61201000, 62000000, 63001000, 63002000, 63004000, 63005000, 63006000, 63007000, 63008000, 64001000, 64002000, 64004000, 64005000, 64006000, 64007000, 64008000, 64043000, 65001000, 65002000, 65008000, 65008300, 65008500, 65100000, 65150000, 65200000, 65300000, 65301000, 65400000, 66000000, 71000100, 71000200, 71050000] as gl_accounts),
        struct("Other Income and Expense" as kpi_name,[71000000,72010000,72510000] as gl_accounts),
        struct("Other Operating Expense" as kpi_name,[62000000, 65002000, 65008500, 65301000, 66000000, 71000100, 71000200, 71050000] as gl_accounts),
        struct("Sales Deductions" as kpi_name,[44001000,44002000] as gl_accounts),
        struct("Taxes" as kpi_name,[12600010, 12605900, 12605901, 12605902, 12605903, 12605905] as gl_accounts)
        {% endif %}

       ] as kpi_gl_map
      )
      ,UNNEST(kpi_gl_map) as k
      ,UNNEST(gl_accounts) as gl_account ;;
  }

# y Employee Expense +
# y Building Expense +
# Depreciation and Amortization
# y Miscellaneous and Other Operating Expense +
# y Advertising and Third Party Expenses



  dimension: key {
    hidden: yes
    type: string
    primary_key: yes
    sql: concat(${kpi_name},${gl_account}) ;;
  }

  parameter: pick_profit_type {
    type: string
    allowed_value: {label: "Gross Profit" value: "gp"}
    allowed_value: {label: "Net Profit" value: "np" }
    default_value: "np"
  }

  dimension: kpi_name {
    label: "KPI Name"
    type: string
    sql: ${TABLE}.kpi_name ;;
  }

  dimension: gl_account {
    hidden: yes
    type: string
    sql: ${TABLE}.gl_account ;;
  }

  measure: net_revenue {
    type: sum_distinct
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [kpi_name: "Net Revenue"]
  }

  measure: cost_of_goods_sold {
    type: sum_distinct
    sql_distinct_key: ${profit_and_loss.key} ;;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [kpi_name: "Cost of Goods Sold"]
  }

  # cogs is negative so add
  # measure: gross_profit {
  #   type: number
  #   sql: ${net_revenue} + ${cost_of_goods_sold} ;;
  # }

  # measure: gross_profit {
  #   type: sum_distinct
  #   sql_distinct_key: ${profit_and_loss.key} ;;
  #   sql: ${profit_and_loss.amount_in_target_currency} ;;
  #   filters: [component_of_gross_profit: "-NULL"]
  #   drill_fields: [drill_profit*]
  # }

  # measure: expenses {
  #   type: sum_distinct
  #   sql_distinct_key: ${profit_and_loss.key} ;;
  #   sql: ${profit_and_loss.amount_in_target_currency} ;;
  #   filters: [component_of_net_profit: "Expenses"]
  #   # filters: [kpi_name: "Operating Expense, Non-Operating Expense, Interest Expense, Foreign Currency Expense"]
  # }

  # measure: other_income {
  #   type: sum_distinct
  #   sql_distinct_key: ${profit_and_loss.key} ;;
  #   sql: ${profit_and_loss.amount_in_target_currency} ;;
  #   filters: [component_of_net_profit: "Other Income"]
  #   # filters: [kpi_name: "Non-Operating Revenue, Interest Income, Foreign Currency Income"]
  # }


# Gross Profit - Expenses+Other Income
  # measure: net_profit {
  #   type: number
  #   # normally gross - expenses + other income but reversing as income is negative and expenses positive
  #   sql: ${gross_profit} + ${expenses} + ${other_income} ;;
  #   drill_fields: [drill_profit*]

  # }

  # measure: net_profit {
  #   type: sum_distinct
  #   sql_distinct_key: ${profit_and_loss.key} ;;
  #   sql: ${profit_and_loss.amount_in_target_currency} ;;
  #   filters: [component_of_net_profit: "-NULL"]
  #   drill_fields: [drill_profit*]
  #   link: {
  #     label: "Drill"
  #     url: "{{ link }}&sorts=profit_and_loss.total_amount_in_global_currency+desc"
  #   }
  # }

  # measure: selected_measure_to_display {
  #   # label_from_parameter: pick_profit_type
  #   label: "{% if pick_profit_type._in_query %}
  #           {% if pick_profit_type._parameter_value == 'gp' %}Gross Profit{%else%}Net Profit{%endif%}
  #           {% else %}Selected Measure to Display{%endif%}"
  #   type: number
  #   sql: {% if pick_profit_type._parameter_value == "'gp'" %}${gross_profit}
  #       {% elsif pick_profit_type._parameter_value == "'np'" %} ${net_profit}
  #       {% else %}max(null)
  #       {% endif %};;
  #   drill_fields: [drill_profit*]
  #   link: {
  #     label: "Show components of profit"
  #     url: "{{ link }}&sorts=component_of_net_profit,profit_and_loss.total_amount_in_global_currency+desc"
  #   }
  # }

  dimension: component_of_profit {
    type: string
    label: "Component of {% if component_of_profit._in_query %}{% if pick_profit_type == \"'gp'\"%}Gross {% else %}Net {%endif%}{%endif%}Profit"
    sql: ${TABLE}.component_of_profit ;;
    order_by_field: component_of_profit_sort_order
  }

  dimension: component_of_profit_sort_order {
    type: string
    sql: ${TABLE}.component_of_profit_sort_order ;;
  }

  measure: gross_margin {
    type: sum_distinct
    sql_distinct_key:  ${profit_and_loss.key};;
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [kpi_name: "Gross Margin"]
  }

  dimension: is_income {
    type: yesno
    sql: ${kpi_name} in ('Gross Revenue' , 'Net Revenue', 'Gross Margin', 'Net Income (P&L)') ;;
  }

  dimension: is_expense {
    type: yesno
    sql: ${kpi_name} in ('Sales Deductions','Cost of Goods Sold','Operating Expense','Interest','Taxes','Other Income and Expense') ;;
  }

  dimension: is_operating_expense {
    type: yesno
    sql: ${kpi_name} in ('Employee Expense','Building Expense','Depreciation and Amortization','Miscellaneous and Other Operating Expense',
      'Advertising and Third Party Expenses')
       ;;
  }

  # dimension: component_of_net_profit {
  #   sql: ${TABLE}.component_of_net_profit;;
  #   order_by_field: component_of_net_profit_sort_order
  # }

  # dimension: component_of_net_profit_sort_order {
  #   hidden: yes
  #   type: number
  #   sql: ${TABLE}.component_of_net_profit_sort_order;;
  # }

  # dimension: component_of_gross_profit_sort_order {
  #   hidden: yes
  #   type: number
  #   sql: ${TABLE}.component_of_net_profit_sort_order;;
  # }

  # dimension: component_of_gross_profit {
  #   sql: ${TABLE}.component_of_gross_profit;;
  # }

  measure: count_gl_account {
    type: count
  }

  measure: count_distinct_gl_account {
    type: count_distinct
    sql: ${gl_account} ;;
  }

  set: drill_profit {
    fields: [component_of_profit,kpi_name,profit_and_loss.glparent_text,profit_and_loss.total_amount_in_global_currency]
  }

  }
