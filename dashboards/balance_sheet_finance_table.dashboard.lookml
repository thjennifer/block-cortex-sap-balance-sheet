- dashboard: balance_sheet_finance_table
  title: Balance Sheet
  layout: newspaper
  preferred_viewer: dashboards-next
  filters_location_top: false
  description: ''
  preferred_slug: p5RoU7HojJDemQZCfJnJIV
  elements:
  - title: Draft D Pick Fiscal Compare To or Custom Compare
    name: Draft D Pick Fiscal Compare To or Custom Compare
    explore: balance_sheet
    type: marketplace_viz_report_table::report_table-marketplace
    fields: [balance_sheet.parent, balance_sheet.parent_text, balance_sheet.node,
      balance_sheet.node_text, balance_sheet.total_cumulative_amount_in_global_currency, balance_sheet.fiscal_year_period]
    pivots: [balance_sheet.fiscal_year_period]
    filters:
      balance_sheet.level_number: '2,3,4'
    sorts: [balance_sheet.fiscal_year_period, balance_sheet.parent,balance_sheet.node]
    limit: 5000
    total: true
    hidden_fields: [balance_sheet.parent, balance_sheet.node]
    hidden_points_if_no: []
    series_labels: {}
    show_view_names: false
    theme: contemporary
    # customTheme: ''
    layout: auto
    minWidthForIndexColumns: true
    headerFontSize: 12
    bodyFontSize: 12
    showTooltip: true
    showHighlight: true
    # columnOrder: {}
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
    label|balance_sheet.parent_text: Parent
    heading|balance_sheet.parent_text: ''
    hide|balance_sheet.parent_text: false
    label|balance_sheet.node_text: Node
    heading|balance_sheet.node_text: ''
    hide|balance_sheet.node_text: false
    subtotalDepth: '1'
    label|balance_sheet.total_cumulative_amount_in_global_currency: Amount
    heading|balance_sheet.total_cumulative_amount_in_global_currency: ''
    style|balance_sheet.total_cumulative_amount_in_global_currency: black_red
    reportIn|balance_sheet.total_cumulative_amount_in_global_currency: '1'
    unit|balance_sheet.total_cumulative_amount_in_global_currency: ''
    comparison|balance_sheet.total_cumulative_amount_in_global_currency: balance_sheet.fiscal_year_period
    switch|balance_sheet.total_cumulative_amount_in_global_currency: false
    var_num|balance_sheet.total_cumulative_amount_in_global_currency: true
    var_pct|balance_sheet.total_cumulative_amount_in_global_currency: true
    show_row_numbers: false
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: left
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_cell_visualizations:
      balance_sheet.total_cumulative_amount_in_global_currency:
        is_active: false
    hidden_pivots: {}
    defaults_version: 0
    y_axes: []
    title_hidden: true
    listen:
      Global Currency: balance_sheet.target_currency_tcurr
      Comparison Type: balance_sheet.select_comparison_type
      Custom Comparison (Optional): balance_sheet.select_custom_comparison_period
      Chart of Accounts: balance_sheet.chart_of_accounts
      Company: balance_sheet.company_text
      Fiscal Period: balance_sheet.select_fiscal_period
      Hierarchy: balance_sheet.hierarchy_name
    row: 2
    col: 0
    width: 15
    height: 13
  - title: title
    name: title
    explore: balance_sheet
    type: single_value
    fields: [balance_sheet.title_balance_sheet]
    filters:
      balance_sheet.level_number: '2,3,4'
    custom_color_enabled: true
    show_single_value_title: false
    show_comparison: false
    comparison_type: value
    comparison_reverse_colors: false
    show_comparison_label: true
    enable_conditional_formatting: false
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_view_names: false
    show_row_numbers: true
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: true
    table_theme: white
    limit_displayed_rows: false
    header_text_alignment: left
    header_font_size: 12
    rows_font_size: 12
    defaults_version: 1
    listen:
      Global Currency: balance_sheet.target_currency_tcurr
      Chart of Accounts: balance_sheet.chart_of_accounts
      Company: balance_sheet.company_text
      Fiscal Period: balance_sheet.select_fiscal_period
      Hierarchy: balance_sheet.hierarchy_name
    row: 0
    col: 0
    width: 15
    height: 2
  filters:
  - name: Fiscal Period
    title: Fiscal Period
    type: field_filter
    # default_value: '2023.11'
    default_value: '2023.10'
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    listens_to_filters: []
    field: balance_sheet.select_fiscal_period
  - name: Comparison Type
    title: Comparison Type
    type: field_filter
    default_value: yoy
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    listens_to_filters: []
    field: balance_sheet.select_comparison_type
  - name: Custom Comparison (Optional)
    title: Custom Comparison (Optional)
    type: field_filter
    default_value: ''
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    listens_to_filters: []
    field: balance_sheet.select_custom_comparison_period
  - name: Global Currency
    title: Global Currency
    type: field_filter
    default_value: USD
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    listens_to_filters: []
    field: balance_sheet.target_currency_tcurr
  - name: Hierarchy
    title: Hierarchy
    type: field_filter
    # default_value: ''
    default_value: FPA1
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    listens_to_filters: []
    field: balance_sheet.hierarchy_name
  - name: Chart of Accounts
    title: Chart of Accounts
    type: field_filter
    default_value: CA01
    # default_value: ''
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    listens_to_filters: []
    field: balance_sheet.chart_of_accounts
  - name: Company
    title: Company
    type: field_filter
    # default_value: ''
    default_value: CYMBAL US06 US CENTRAL
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    listens_to_filters: []
    field: balance_sheet.company_text
