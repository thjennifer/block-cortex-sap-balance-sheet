include: "/explores/profit_and_loss.explore"

view: profit_and_loss_fiscal_periods_ndt {

  derived_table: {
    explore_source: profit_and_loss {
      column: glhierarchy {}
      column: company_code {}
      column: company_text {}
      column: fiscal_year {}
      column: fiscal_quarter_label {}
      column: fiscal_period {}
      column: fiscal_year_period {}
      column: fiscal_year_quarter_label {}
      derived_column: prior_fiscal_year_period {
        sql: LAG(fiscal_year_period) OVER (PARTITION BY glhierarchy, company_code ORDER BY fiscal_year_period) ;;
      }
      # filters: {
      #   field: profit_and_loss.glhierarchy
      #   value: "FPA1"
      # }
      # filters: {
      #   field: profit_and_loss.company_text
      #   value: "%CENTRAL%"
      # }
      # filters: {
      #   field: profit_and_loss.target_currency_tcurr
      #   value: "USD"
      # }
    }
  }
  dimension: glhierarchy {
    label: "Income Statement GL Hierarchy"
    description: "GL Hierarchy Name is same as Financial Statement Version (FSV)"
  }
  dimension: company_code {
    label: "Income Statement Company (code)"
    description: "Company Code"
  }
  dimension: company_text {
    label: "Income Statement Company (text)"
    description: "Company Name"
  }
  dimension: fiscal_year {
    label: "Income Statement Fiscal Year"
    description: "Fiscal Year as YYYY"
  }
  dimension: fiscal_quarter_label {
    label: "Income Statement Fiscal Quarter"
    description: "Fiscal Quarter value of Q1, Q2, Q3, or Q4"
  }
  dimension: fiscal_period {
    label: "Income Statement Fiscal Period"
    description: "Fiscal Period as 3-character string (e.g., 001)"
  }
  dimension: fiscal_year_period {
    label: "Income Statement Fiscal Year Period"
    description: "Fiscal Year and Period as String in form of YYYY.PPP"
  }
  dimension: fiscal_year_quarter_label {
    label: "Income Statement Fiscal Year Quarter"
    description: "Fiscal Quarter value with year in format YYYY.Q#"
  }

  dimension: prior_fiscal_year_period {

  }
}
