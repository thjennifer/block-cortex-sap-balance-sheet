- dashboard: income_statement_mktplace_report_table
  title: Income Statement
  layout: newspaper
  preferred_viewer: dashboards-next
  description: ''
  filters_location_top: false

  elements:
  - title: profit and loss table
    name: profit and loss table
    explore: profit_and_loss
    type: marketplace_viz_report_table::report_table-marketplace
    fields: [profit_and_loss_hierarchy_selection_sdt.hier1_node_text, profit_and_loss_hierarchy_selection_sdt.hier2_node_text,
      profit_and_loss_hierarchy_selection_sdt.hier3_node_text, profit_and_loss_fiscal_periods_selected_sdt.current_amount,
      profit_and_loss_fiscal_periods_selected_sdt.comparison_amount, profit_and_loss_fiscal_periods_selected_sdt.difference_value,
      profit_and_loss_fiscal_periods_selected_sdt.difference_percent, profit_and_loss_fiscal_periods_selected_sdt.focus_timeframe]
    pivots: [profit_and_loss_fiscal_periods_selected_sdt.focus_timeframe]
    # filters:
    #   profit_and_loss.parameter_display_period_or_quarter: qtr
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
    label|profit_and_loss_fiscal_periods_selected_sdt.difference_value: Gain (Loss)
    heading|profit_and_loss_fiscal_periods_selected_sdt.difference_value: ''
    style|profit_and_loss_fiscal_periods_selected_sdt.difference_value: black_red
    reportIn|profit_and_loss_fiscal_periods_selected_sdt.difference_value: '1'
    unit|profit_and_loss_fiscal_periods_selected_sdt.difference_value: ''
    comparison|profit_and_loss_fiscal_periods_selected_sdt.difference_value: no_variance
    switch|profit_and_loss_fiscal_periods_selected_sdt.difference_value: false
    var_num|profit_and_loss_fiscal_periods_selected_sdt.difference_value: false
    var_pct|profit_and_loss_fiscal_periods_selected_sdt.difference_value: false
    label|profit_and_loss_fiscal_periods_selected_sdt.difference_percent: Gain (Loss)
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
      Currency: profit_and_loss.target_currency_tcurr
      Select Fiscal Timeframe: profit_and_loss.filter_fiscal_timeframe
      Display Period or Quarter: profit_and_loss.parameter_display_period_or_quarter
      Select Comparison Type: profit_and_loss.parameter_compare_to
      Ledger Name: profit_and_loss.ledger_name
      Company: profit_and_loss.company_text
      Hierarchy: profit_and_loss.glhierarchy
      Top Hierarchy Level to Display: profit_and_loss_hierarchy_selection_sdt.parameter_pick_start_level
    row: 0
    col: 0
    width: 16
    height: 12

  filters:
  - name: Hierarchy
    title: Hierarchy
    type: field_filter
    default_value: FPA1
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.glhierarchy
  - name: Display Period or Quarter
    title: Display Period or Quarter
    type: field_filter
    default_value: qtr
    allow_multiple_values: true
    required: false
    ui_config:
      type: button_toggles
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.parameter_display_period_or_quarter
  - name: Select Fiscal Timeframe
    title: Select Fiscal Timeframe
    type: field_filter
    default_value: 2023.Q3
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    explore: profit_and_loss
    listens_to_filters: [Display Period or Quarter]
    field: profit_and_loss.filter_fiscal_timeframe
  - name: Select Comparison Type
    title: Select Comparison Type
    type: field_filter
    default_value: yoy
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.parameter_compare_to
  - name: Currency
    title: Currency
    type: field_filter
    default_value: USD
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.target_currency_tcurr
  - name: Company
    title: Company
    type: field_filter
    default_value: C006-CYMBAL US-CENTRAL
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.company_text
  - name: Ledger Name
    title: Ledger Name
    type: field_filter
    default_value: Leading Ledger
    allow_multiple_values: true
    required: false
    ui_config:
      type: tag_list
      display: popover
    explore: profit_and_loss
    listens_to_filters: [Hierarchy]
    field: profit_and_loss.ledger_name

  - name: Top Hierarchy Level to Display
    title: Top Hierarchy Level to Display
    type: field_filter
    default_value: '2'
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss_hierarchy_selection_sdt.parameter_pick_start_level
