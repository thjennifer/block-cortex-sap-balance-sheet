- dashboard: income_statement_mktplace_report_table
  title: Financial Income Statement
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Using the Report (Table) visualization available from Looker Marketplace, this report shows a company's financial performance over a specific period (e.g., a month, quarter, or year) compared to either preceding timeframe or same timeframe last year. This report summarizes Revenues, Expenses and/or Net Income (Loss) at specified hierarchy level."
  filters_location_top: false
  extends: income_statement_template

  elements:
  - title: profit and loss table
    name: profit and loss table
    explore: profit_and_loss
    type: marketplace_viz_report_table::report_table-marketplace
    fields: [profit_and_loss_hierarchy_selection_sdt.hier1_node_text, profit_and_loss_hierarchy_selection_sdt.hier2_node_text,
      profit_and_loss_hierarchy_selection_sdt.hier3_node_text, profit_and_loss_fiscal_periods_selected_sdt.current_amount,
      profit_and_loss_fiscal_periods_selected_sdt.comparison_amount, profit_and_loss_fiscal_periods_selected_sdt.difference_value,
      profit_and_loss_fiscal_periods_selected_sdt.difference_percent, profit_and_loss_fiscal_periods_selected_sdt.focus_timeframe, profit_and_loss_fiscal_periods_selected_sdt.partial_timeframe_note]
    pivots: [profit_and_loss_fiscal_periods_selected_sdt.focus_timeframe, profit_and_loss_fiscal_periods_selected_sdt.partial_timeframe_note]
    # filters:
    #   profit_and_loss.parameter_display_time_dimension: qtr
    #   profit_and_loss.parameter_compare_to: yoy
    #   profit_and_loss.filter_fiscal_timeframe: 2023.Q3
    sorts: [profit_and_loss_fiscal_periods_selected_sdt.focus_timeframe, profit_and_loss_hierarchy_selection_sdt.hier1_node_text,
      profit_and_loss_hierarchy_selection_sdt.hier2_node_text, profit_and_loss_hierarchy_selection_sdt.hier3_node_text]
    show_view_names: false
    theme: contemporary
    layout: auto
    minWidthForIndexColumns: false
    headerFontSize: 12
    bodyFontSize: 12
    showTooltip: true
    showHighlight: true
    columnOrder: {}
    rowSubtotals: true
    colSubtotals: false
    spanRows: true
    spanCols: true
    calculateOthers: true
    sortColumnsBy: pivots
    useViewName: false
    useHeadings: false
    useShortName: false
    useUnit: false
    groupVarianceColumns: false
    genericLabelForSubtotals: false
    indexColumn: false
    transposeTable: false

    label|profit_and_loss_hierarchy_selection_sdt.hier1_node_text: " "
    heading|profit_and_loss_hierarchy_selection_sdt.hier1_node_text: ''
    hide|profit_and_loss_hierarchy_selection_sdt.hier1_node_text: false
    label|profit_and_loss_hierarchy_selection_sdt.hier2_node_text: " "
    heading|profit_and_loss_hierarchy_selection_sdt.hier2_node_text: ''
    hide|profit_and_loss_hierarchy_selection_sdt.hier2_node_text: false
    label|profit_and_loss_hierarchy_selection_sdt.hier3_node_text: " "
    heading|profit_and_loss_hierarchy_selection_sdt.hier3_node_text: ''
    hide|profit_and_loss_hierarchy_selection_sdt.hier3_node_text: false
    label|profit_and_loss_fiscal_periods_selected_sdt.partial_timeframe_note: " "
    subtotalDepth: '1'
    label|profit_and_loss_fiscal_periods_selected_sdt.current_amount: Current Quarter
    heading|profit_and_loss_fiscal_periods_selected_sdt.current_amount: ''
    style|profit_and_loss_fiscal_periods_selected_sdt.current_amount: black_red
    reportIn|profit_and_loss_fiscal_periods_selected_sdt.current_amount: '1'
    unit|profit_and_loss_fiscal_periods_selected_sdt.current_amount: ''
    comparison|profit_and_loss_fiscal_periods_selected_sdt.current_amount: no_variance
    switch|profit_and_loss_fiscal_periods_selected_sdt.current_amount: false
    var_num|profit_and_loss_fiscal_periods_selected_sdt.current_amount: false
    var_pct|profit_and_loss_fiscal_periods_selected_sdt.current_amount: false
    label|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: "\n       \
      \     Last Year\n            "
    heading|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: ''
    style|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: black_red
    reportIn|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: '1'
    unit|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: ''
    comparison|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: no_variance
    switch|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: false
    var_num|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: false
    var_pct|profit_and_loss_fiscal_periods_selected_sdt.comparison_amount: false
    label|profit_and_loss_fiscal_periods_selected_sdt.difference_value: Variance Amount
    heading|profit_and_loss_fiscal_periods_selected_sdt.difference_value: ''
    style|profit_and_loss_fiscal_periods_selected_sdt.difference_value: black_red
    reportIn|profit_and_loss_fiscal_periods_selected_sdt.difference_value: '1'
    unit|profit_and_loss_fiscal_periods_selected_sdt.difference_value: ''
    comparison|profit_and_loss_fiscal_periods_selected_sdt.difference_value: no_variance
    switch|profit_and_loss_fiscal_periods_selected_sdt.difference_value: false
    var_num|profit_and_loss_fiscal_periods_selected_sdt.difference_value: false
    var_pct|profit_and_loss_fiscal_periods_selected_sdt.difference_value: false
    label|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: Variance
      %
    heading|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: ''
    style|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: black_red
    reportIn|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: '1'
    unit|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: ''
    comparison|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: no_variance
    switch|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: false
    var_num|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: false
    var_pct|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: false
    hidden_pivots: {}
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: false
    table_theme: white
    limit_displayed_rows: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    title_hidden: true

    defaults_version: 0
    listen:
      Global Currency: profit_and_loss.target_currency_tcurr
      Select Fiscal Timeframe: profit_and_loss.filter_fiscal_timeframe
      Display Timeframe: profit_and_loss.parameter_display_time_dimension
      Select Comparison Type: profit_and_loss.parameter_compare_to
      Ledger Name: profit_and_loss.ledger_name
      Company: profit_and_loss.company_text
      Hierarchy: profit_and_loss.glhierarchy
      Top Hierarchy Level to Display: profit_and_loss_hierarchy_selection_sdt.parameter_pick_start_level
    row: 3
    col: 0
    width: 24
    height: 8

  - title: navigation
    name: navigation
    filters:
      navigation_income_statement_ext.navigation_focus_page: '1'
      navigation_income_statement_ext.which_dashboard_style: 'mktplace^_report'
