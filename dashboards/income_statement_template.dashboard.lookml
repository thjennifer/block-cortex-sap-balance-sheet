- dashboard: income_statement_template
  title: Income Statement Template
  description: "Common filters and tiles used by Income Statement dashboards"
  layout: newspaper
  preferred_viewer: dashboards-next
  tile_size: 100
  extension: required

  elements:
  - name: Income Statement Summary
    title: Income Statement Summary
    model: cortex-sap-balance-sheet
    explore: profit_and_loss
    type: single_value
    fields: [profit_and_loss_03_selected_fiscal_periods_sdt.title_income_statement]
    filters:
      profit_and_loss.gllevel: '000002'
      profit_and_loss_03_selected_fiscal_periods_sdt.fiscal_reporting_group: Current
    show_single_value_title: false
    listen:
      Global Currency: profit_and_loss.target_currency_tcurr
      Select Fiscal Timeframe: profit_and_loss.filter_fiscal_timeframe
      Display Timeframe: profit_and_loss.parameter_display_time_dimension
      Select Comparison Type: profit_and_loss.parameter_compare_to
      Ledger Name: profit_and_loss.ledger_name
      Company: profit_and_loss.company_text
      Hierarchy: profit_and_loss.glhierarchy
    row: 2
    col: 0
    width: 24
    height: 3

  - title: navigation
    name: navigation
    explore: profit_and_loss
    type: single_value
    fields: [navigation_income_statement_ext.navigation]
    filters:
      navigation_income_statement_ext.navigation_focus_page: '1'
      navigation_income_statement_ext.navigation_style: 'small'
      navigation_income_statement_ext.navigation_which_dashboard_style: 'subtotal'
    show_single_value_title: false
    show_comparison: false
    listen:
      Hierarchy: navigation_income_statement_ext.filter1
      Display Timeframe: navigation_income_statement_ext.filter2
      Select Fiscal Timeframe: navigation_income_statement_ext.filter3
      Global Currency: navigation_income_statement_ext.filter4
      Company: navigation_income_statement_ext.filter5
      Ledger Name: navigation_income_statement_ext.filter6
      Top Hierarchy Level to Display: navigation_income_statement_ext.filter7
      Combine Selected Timeframes?: navigation_income_statement_ext.filter8
    row: 10
    col: 0
    width: 24
    height: 1



  filters:
  - name: Hierarchy
    title: Hierarchy
    type: field_filter
    default_value: FPA1
    allow_multiple_values: false
    required: true
    ui_config:
      type: dropdown_menu
      display: inline
    explore: profit_and_loss
    field: profit_and_loss.glhierarchy

  - name: Display Timeframe
    title: Display Timeframe
    type: field_filter
    default_value: qtr
    allow_multiple_values: false
    required: false
    ui_config:
      type: button_toggles
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.parameter_display_time_dimension

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
    listens_to_filters: [Display Timeframe]
    field: profit_and_loss.filter_fiscal_timeframe

  - name: Combine Selected Timeframes?
    title: Combine Selected Timeframes?
    type: field_filter
    default_value: "Yes"
    allow_multiple_values: false
    required: false
    ui_config:
      type: button_toggles
      display: inline
    explore: profit_and_loss
    field: profit_and_loss.parameter_aggregate

  - name: Select Comparison Type
    title: Select Comparison Type
    type: field_filter
    default_value: yoy
    allow_multiple_values: false
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: profit_and_loss
    listens_to_filters: []
    field: profit_and_loss.parameter_compare_to

  - name: Global Currency
    title: Global Currency
    type: field_filter
    default_value: USD
    allow_multiple_values: false
    required: true
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
    default_value: '0L - Leading Ledger'
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