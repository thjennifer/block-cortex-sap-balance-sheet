- dashboard: income_statement_subtotal_table
  title: Financial Income Statement
  layout: newspaper
  preferred_viewer: dashboards-next
  description: "Shows a company's financial performance over a specific period (e.g., a month, quarter, or year) compared to either preceding timeframe or same timeframe last year. This report summarizes Revenues, Expenses and/or Net Income (Loss) at specified hierarchy level."
  filters_location_top: false
  extends: income_statement_template

  elements:
  - title: profit and loss table
    name: profit and loss table
    explore: profit_and_loss
    type: looker_grid
    fields: [profit_and_loss_03_selected_fiscal_periods_sdt.alignment_group_name_with_partial_indicator, profit_and_loss_03_selected_fiscal_periods_sdt.current_amount,
      profit_and_loss_03_selected_fiscal_periods_sdt.comparison_amount, profit_and_loss_03_selected_fiscal_periods_sdt.difference_value,
      profit_and_loss_03_selected_fiscal_periods_sdt.difference_percent, profit_and_loss_hierarchy_selection_sdt.hier1_node_text,
      profit_and_loss_hierarchy_selection_sdt.hier2_node_text, profit_and_loss_hierarchy_selection_sdt.hier3_node_text]
    pivots: [profit_and_loss_03_selected_fiscal_periods_sdt.alignment_group_name_with_partial_indicator]
    filters: {}
    sorts: [profit_and_loss_03_selected_fiscal_periods_sdt.alignment_group_name_with_partial_indicator, profit_and_loss_hierarchy_selection_sdt.hier1_node_text,
      profit_and_loss_hierarchy_selection_sdt.hier2_node_text,profit_and_loss_hierarchy_selection_sdt.hier3_node_text]
    subtotals: [profit_and_loss_hierarchy_selection_sdt.hier1_node_text, profit_and_loss_hierarchy_selection_sdt.hier2_node_text]
    limit: 500
    column_limit: 50
    show_view_names: false
    show_row_numbers: false
    transpose: false
    truncate_text: true
    hide_totals: false
    hide_row_totals: false
    size_to_fit: false
    table_theme: white
    limit_displayed_rows: false
    enable_conditional_formatting: false
    header_text_alignment: center
    header_font_size: '12'
    rows_font_size: '12'
    conditional_formatting_include_totals: false
    conditional_formatting_include_nulls: false
    show_sql_query_menu_options: false
    show_totals: true
    show_row_totals: true
    truncate_header: false
    minimum_column_width: 75
    series_labels:
      profit_and_loss_hierarchy_selection_sdt.hier1_node_text: " "
      profit_and_loss_hierarchy_selection_sdt.hier2_node_text: " "
      profit_and_loss_hierarchy_selection_sdt.hier3_node_text: " "
      profit_and_loss_03_selected_fiscal_periods_sdt.alignment_group_name_with_partial_indicator: " "
    series_collapsed:
      profit_and_loss_hierarchy_selection_sdt.hier2_node_text: false
    hidden_fields: []
    hidden_points_if_no: []
    theme: contemporary
    customTheme: ''
    layout: fixed
    minWidthForIndexColumns: true
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
    groupVarianceColumns: true
    genericLabelForSubtotals: false
    indexColumn: false
    transposeTable: false
    label|profit_and_loss.glparent_text: GL Parent (text)
    heading|profit_and_loss.glparent_text: ''
    hide|profit_and_loss.glparent_text: false
    label|profit_and_loss.glnode_text: GL Node (text)
    heading|profit_and_loss.glnode_text: ''
    hide|profit_and_loss.glnode_text: false
    subtotalDepth: '1'
    label|profit_and_loss.reporting_period_current_year_amount_in_global_currency: Current
      Year
    heading|profit_and_loss.reporting_period_current_year_amount_in_global_currency: ''
    style|profit_and_loss.reporting_period_current_year_amount_in_global_currency: black_red
    reportIn|profit_and_loss.reporting_period_current_year_amount_in_global_currency: '1'
    unit|profit_and_loss.reporting_period_current_year_amount_in_global_currency: ''
    comparison|profit_and_loss.reporting_period_current_year_amount_in_global_currency: no_variance
    switch|profit_and_loss.reporting_period_current_year_amount_in_global_currency: false
    var_num|profit_and_loss.reporting_period_current_year_amount_in_global_currency: true
    var_pct|profit_and_loss.reporting_period_current_year_amount_in_global_currency: false
    label|profit_and_loss.comparison_period_last_year_amount_in_global_currency: Last
      Year
    heading|profit_and_loss.comparison_period_last_year_amount_in_global_currency: ''
    style|profit_and_loss.comparison_period_last_year_amount_in_global_currency: normal
    reportIn|profit_and_loss.comparison_period_last_year_amount_in_global_currency: '1'
    unit|profit_and_loss.comparison_period_last_year_amount_in_global_currency: ''
    comparison|profit_and_loss.comparison_period_last_year_amount_in_global_currency: no_variance
    switch|profit_and_loss.comparison_period_last_year_amount_in_global_currency: false
    var_num|profit_and_loss.comparison_period_last_year_amount_in_global_currency: true
    var_pct|profit_and_loss.comparison_period_last_year_amount_in_global_currency: false
    label|profit_and_loss.difference_value: Gain (Loss)
    heading|profit_and_loss.difference_value: ''
    style|profit_and_loss.difference_value: normal
    reportIn|profit_and_loss.difference_value: '1'
    unit|profit_and_loss.difference_value: ''
    comparison|profit_and_loss.difference_value: no_variance
    switch|profit_and_loss.difference_value: false
    var_num|profit_and_loss.difference_value: true
    var_pct|profit_and_loss.difference_value: false
    comparison|profit_and_loss.total_amount_in_global_currency: profit_and_loss.fiscal_reporting_period
    var_num|profit_and_loss.total_amount_in_global_currency: true
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    y_axis_tick_density_custom: 5
    show_x_axis_label: true
    show_x_axis_ticks: true
    y_axis_scale_mode: linear
    x_axis_reversed: false
    y_axis_reversed: false
    plot_size_by_field: false
    trellis: ''
    stacking: ''
    legend_position: center
    point_style: none
    show_value_labels: false
    label_density: 25
    x_axis_scale: auto
    y_axis_combined: true
    show_null_points: true
    interpolation: linear
    defaults_version: 1
    hidden_pivots: {}
    title_hidden: true

    listen:
      Global Currency: profit_and_loss.target_currency_tcurr
      Select Fiscal Timeframe: profit_and_loss.filter_fiscal_timeframe
      Combine Selected Timeframes?: profit_and_loss.parameter_aggregate
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
      navigation_income_statement_ext.navigation_which_dashboard_style: 'subtotal'

  filters:
  - name: Select Comparison Type
    title: Select Comparison Type
    type: field_filter
    default_value: "yoy"
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
      options:
        - yoy
        - prior
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.parameter_compare_to
