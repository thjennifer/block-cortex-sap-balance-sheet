include: "/views/base/navigation_template.view"

view: navigation_income_statement_ext {
  extends: [navigation_template]

  dimension: dashBindings {
    hidden: yes
    type: string
    sql: 'income_statement_{% parameter which_dashboard_style %}_table|With Comparisons||income_statement_{% parameter which_dashboard_style %}_table_no_comparison|No Comparisons' ;;
    # sql: '114|With Comparisons||115|No Comparisons' ;;
  }

  parameter: which_dashboard_style {
    type: unquoted
    allowed_value: {label:"Marketplace Table (Report)" value:"mktplace_report"}
    allowed_value: {label: "Subtotal Table" value:"subtotal" }
    default_value: "subtotal"
  }

  dimension: filterBindings {
    hidden: yes
    type: string
    # sql: 'filter1|Display+Timeframe' ;;
    sql: 'filter1|Hierarchy||filter2|Display+Timeframe||filter3|Select+Fiscal+Timeframe||filter4|Global+Currency||filter5|Company||filter6|Ledger+Name||filter7|Top+Hierarchy+Level+to+Display' ;;
    # sql: 'filter1|Order+Date||filter2|Country+Name' ;;
  }

  parameter: navigation_focus_page {
    hidden: no
    type: unquoted
    allowed_value: {value:"1"}
    allowed_value: {value:"2"}
    allowed_value: {value:"3"}
    allowed_value: {value:"4"}
    allowed_value: {value:"5"}
    default_value: "1"
  }

  filter: filter1 {
    hidden: no
    type: string
    label: "Hierarchy"
  }

  filter: filter2 {
    hidden: yes
    type: string
    label: "Display Timeframe"
  }

  filter: filter3 {
    hidden: yes
    type: string
    label: "Select Fiscal Timeframe"
  }

  filter: filter4 {
    hidden: yes
    type: string
    label: "Global Currency"
  }

  filter: filter5 {
    hidden: yes
    type: string
    label: "Company"
  }

  filter: filter6 {
    hidden: yes
    type: string
    label: "Ledger Name"
  }

  filter: filter7 {
    hidden: yes
    type: string
    label: "Top Hierarchy Level to Display"
  }



  }
