- dashboard: income_statement_filter_template
  title: Income Statement Filter Template
  layout: newspaper
  preferred_viewer: dashboards-next
  tile_size: 100
  extension: required

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
    allow_multiple_values: true
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

  elements:
  - title: navigation
    name: navigation
    explore: profit_and_loss
    type: single_value
    fields: [navigation_income_statement_ext.navigation]
    filters:
      navigation_income_statement_ext.navigation_focus_page: '1'
      navigation_income_statement_ext.navigation_style: 'small'
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
    row: 12
    col: 0
    width: 24
    height: 1
