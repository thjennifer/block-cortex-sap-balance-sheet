- dashboard: income_statement_mktplace_report_table_no_comparison
  title: Financial Income Statement
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Using the Report (Table) visualization available from Looker Marketplace, this report shows a company's financial performance over a specific period (e.g., a month, quarter, or year). This report summarizes Revenues, Expenses and/or Net Income (Loss) at specified hierarchy level."
  filters_location_top: false
  extends: [income_statement_template]

  elements:
  - title: profit and loss table
    name: profit and loss table
    explore: profit_and_loss
    type: marketplace_viz_report_table::report_table-marketplace
    fields: [profit_and_loss_hierarchy_selection_sdt.hier1_node_text, profit_and_loss_hierarchy_selection_sdt.hier2_node_text,
      profit_and_loss_hierarchy_selection_sdt.hier3_node_text, profit_and_loss_03_selected_fiscal_periods_sdt.alignment_group_name,
      profit_and_loss_03_selected_fiscal_periods_sdt.current_amount]
    pivots: [profit_and_loss_03_selected_fiscal_periods_sdt.alignment_group_name]
    sorts: [profit_and_loss_03_selected_fiscal_periods_sdt.alignment_group_name, profit_and_loss_hierarchy_selection_sdt.hier1_node_text,
      profit_and_loss_hierarchy_selection_sdt.hier2_node_text, profit_and_loss_hierarchy_selection_sdt.hier3_node_text]
    # subtotals: [profit_and_loss_hierarchy_selection_sdt.hier1_node_text, profit_and_loss_hierarchy_selection_sdt.hier2_node_text]
    label|profit_and_loss_hierarchy_selection_sdt.hier1_node_text: " "
    heading|profit_and_loss_hierarchy_selection_sdt.hier1_node_text: ''
    hide|profit_and_loss_hierarchy_selection_sdt.hier1_node_text: false
    label|profit_and_loss_hierarchy_selection_sdt.hier2_node_text: " "
    heading|profit_and_loss_hierarchy_selection_sdt.hier2_node_text: ''
    hide|profit_and_loss_hierarchy_selection_sdt.hier2_node_text: false
    label|profit_and_loss_hierarchy_selection_sdt.hier3_node_text: " "
    heading|profit_and_loss_hierarchy_selection_sdt.hier3_node_text: ''
    hide|profit_and_loss_hierarchy_selection_sdt.hier3_node_text: false
    style|profit_and_loss_03_selected_fiscal_periods_sdt.current_amount: black_red
    subtotalDepth: '1'
    limit: 500
    column_limit: 50
    total: false
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: true
    hide_row_totals: true
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: center
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: false
    show_row_totals: false
    truncate_header: false
    minimum_column_width: 75
    hidden_pivots: {}
    defaults_version: 1
    title_hidden: true
    minWidthForIndexColumns: false
    showTooltip: true
    rowSubtotals: true
    theme: contemporary

    listen:
      Global Currency: profit_and_loss.target_currency_tcurr
      Select Fiscal Timeframe: profit_and_loss.filter_fiscal_timeframe
      Display Timeframe: profit_and_loss.parameter_display_time_dimension
      Ledger Name: profit_and_loss.ledger_name
      Select Comparison Type: profit_and_loss.parameter_compare_to
      Company: profit_and_loss.company_text
      Hierarchy: profit_and_loss.glhierarchy
      Top Hierarchy Level to Display: profit_and_loss_hierarchy_selection_sdt.parameter_pick_start_level
      Combine Selected Timeframes?: profit_and_loss.parameter_aggregate
    row: 3
    col: 0
    width: 24
    height: 8


  - title: navigation
    name: navigation
    filters:
      navigation_income_statement_ext.navigation_focus_page: '2'
      navigation_income_statement_ext.navigation_which_dashboard_style: 'mktplace^_report'

  filters:
  - name: Select Comparison Type
    title: Select Comparison Type
    type: field_filter
    default_value: "none"
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
      options:
      - none
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.parameter_compare_to