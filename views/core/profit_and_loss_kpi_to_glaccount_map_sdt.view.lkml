view: profit_and_loss_kpi_to_glaccount_map_sdt {

  derived_table: {
    sql: SELECT kpi_name, lpad(cast(gl_account as string),10,'0') as gl_account
       FROM
       (
        select[
        struct("Advertising and Third Party Expenses" as kpi_name,[610010,610020,650000,650005,650010,650020,650030,650040,650050,650060,650085,650500,651000,652000,653000,654000,655000] as gl_accounts),
        struct("Building Expense" as kpi_name,[630000,630005,630010,630020,630030,630040,630050,630060] as gl_accounts),
        struct("COGS" as kpi_name,[500000,500010,500020,510000,510005,510006,510010,510020,520000,520060,520065,520100,530000] as gl_accounts),
        struct("Depreciation and Amortization" as kpi_name,[640200] as gl_accounts),
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
        struct("Sales Deduction" as kpi_name,[440000, 440010, 440020, 440025, 440026, 440027, 440030, 440040, 440050] as gl_accounts),
        struct("Taxes" as kpi_name,[750020,750030] as gl_accounts)
       ] as kpi_gl_map
      )
      ,UNNEST(kpi_gl_map) as k
      ,UNNEST(gl_accounts) as gl_account ;;
  }

  dimension: key {
    hidden: yes
    type: string
    primary_key: yes
    sql: concat(${kpi_name},${gl_account}) ;;
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
    type: sum
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [kpi_name: "COGS"]
  }

  measure: gross_profit {
    type: number
    sql: ${net_revenue} - ${cost_of_goods_sold} ;;
  }

  measure: expenses {
    type: sum
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [kpi_name: "Operating Expense, Non-Operating Expense, Interest Expense, Foreign Curency Expense"]
  }

  measure: other_income {
    type: sum
    sql: ${profit_and_loss.amount_in_target_currency} ;;
    filters: [kpi_name: "Non-Operating Revenue, Interest Income"]

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
    sql: ${kpi_name} in ('Employee Expense','Building Expense','Depreciation & Amortization','Miscellaneous and Other Operating Expense',
      'Advertising and Third Party Expenses')
       ;;
  }

  }
