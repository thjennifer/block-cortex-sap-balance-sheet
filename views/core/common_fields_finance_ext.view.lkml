#########################################################
# common fields and parameters to be extended into:
#   balance_sheet_rfn
#   profit_and_loss_rfn
#
# includes:
#   client_mandt
#   language_key_spras
#   currency_key
#   target_currency_tcurr
#   ledger_in_general_ledger_accounting
#   ledger_name
#   company_code
#   company_text
#   fiscal_period, fiscal_period_number, fiscal_year_period, fiscal_year_period_number, fiscal_year_period_negative_number
#   fiscal_quarter, fiscal_quarter_label, fiscal_year_quarter_label, fiscal_year_quarter_negative_number
#   fiscal_year, fiscal_year_number, fiscal_year_negative_number
#########################################################


view: common_fields_finance_ext {

  dimension: client_mandt {
    type: string
    label: "Client"
    sql: ${TABLE}.Client ;;
  }

  dimension: language_key_spras {
    label: "Language Key"
    description: "Language used for text display of Company, Parent and/or Child Node"
  }

  dimension: currency_key {
    label: "Currency (Local)"
    description: "Local Currency"
  }

  dimension: target_currency_tcurr {
    label: "Currency (Global)"
    description: "Target or Global Currency to display"
  }

  dimension: ledger_in_general_ledger_accounting {
    label: "Ledger"
    description: "Ledger in General Ledger Accounting"
    sql: COALESCE(${TABLE}.LedgerInGeneralLedgerAccounting,'0L') ;;
  }

  dimension: ledger_name {
    description: "Ledger in General Ledger Accounting"
    sql:  CASE ${ledger_in_general_ledger_accounting}
          WHEN '0L' THEN '0L - Leading Ledger'
          WHEN '2L' THEN '2L - IFRS Non-leading Ledger'
          WHEN '0E' THEN '0E - Extension Ledger'
          ELSE ${ledger_in_general_ledger_accounting}
          END;;
    order_by_field: ledger_in_general_ledger_accounting
  }

  dimension: company_code {
    label: "Company (code)"
    description: "Company Code"
  }

  dimension: company_text {
    label: "Company (text)"
    description: "Company Name"
  }

  # Fiscal Year and Period and other forms of Fiscal Dates
  # {
  dimension: fiscal_period {
    group_label: "Fiscal Dates"
    description: "Fiscal Period as 3-character string (e.g., 001)"
  }

  dimension: fiscal_period_number {
    hidden: yes
    group_label: "Fiscal Dates"
    description: "Fiscal Period as a Numeric Value"
    type: number
    sql: PARSE_NUMERIC(${fiscal_period}) ;;
    value_format_name: id
  }

  dimension: fiscal_year_period {
    type: string
    group_label: "Fiscal Dates"
    description: "Fiscal Year and Period as String in form of YYYY.PPP"
    sql: CONCAT(${fiscal_year},'.',${fiscal_period});;
    order_by_field: fiscal_year_period_negative_number
  }

  dimension: fiscal_year_period_number {
    hidden: no
    type: number
    group_label: "Fiscal Dates"
    description: "Fiscal Year and Period as a Numeric Value in form of YYYYPPP"
    sql: PARSE_NUMERIC(concat(${fiscal_year},${fiscal_period})) ;;
    value_format_name: id
  }

  dimension: fiscal_year_period_negative_number {
    hidden: yes
    type: number
    sql: -1 * ${fiscal_year_period_number} ;;
  }

  dimension: fiscal_quarter {
    hidden: no
    group_label: "Fiscal Dates"
    description: "Fiscal Quarter value of 1, 2, 3, or 4"
  }

  dimension: fiscal_quarter_label {
    group_label: "Fiscal Dates"
    label: "Fiscal Quarter"
    description: "Fiscal Quarter value of Q1, Q2, Q3, or Q4"
    sql: CONCAT('Q',${fiscal_quarter});;
  }

  dimension: fiscal_year_quarter_label {
    group_label: "Fiscal Dates"
    label: "Fiscal Year Quarter"
    description: "Fiscal Quarter value with year in format YYYY.Q#"
    sql: CONCAT(${fiscal_year},'.Q',${fiscal_quarter}) ;;
  }

  dimension: fiscal_year_quarter_negative_number {
    hidden: yes
    type: number
    sql: -1 * PARSE_NUMERIC(concat(${fiscal_year},${fiscal_quarter})) ;;
  }

  dimension: fiscal_year {
    group_label: "Fiscal Dates"
    description: "Fiscal Year as YYYY"
  }

  dimension: fiscal_year_number {
    hidden: yes
    group_label: "Fiscal Dates"
    description: "Fiscal Year as a Numeric Value"
    type: number
    sql: parse_numeric(${fiscal_year}) ;;
    value_format_name: id
  }

  dimension: fiscal_year_negative_number {
    hidden: yes
    type: number
    sql: -1 * PARSE_NUMERIC(${fiscal_year}) ;;
  }



#} end fiscal period

 }
