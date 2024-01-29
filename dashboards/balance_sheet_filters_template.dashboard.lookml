- dashboard: balance_sheet_filters_template
  title: Balance Sheet Filters Template
  layout: newspaper
  preferred_viewer: dashboards-next
  extension: required

  filters:
  - name: Fiscal Period
    title: Fiscal Period
    # assumes as 12 month fiscal period that aligns with calendar. Will find last month and select period with same value
    default_value: "{% if _user_attributes['sap_use_demo_data']=='Yes'%}{% assign ym = '2023.011'%}{%else%}{% assign intervalDays = 31 %}{% assign intervalSeconds = intervalDays | times: 86400 %}{% assign daysMinus31 = 'now' | date: '%s' | minus: intervalSeconds %}{% assign m = daysMinus31 | date: '%m' | prepend: '00' | slice: -3,3 %}{% assign ym = daysMinus31 | date: '%Y' | append: '.' | append: m %}{%endif%}{{ym}}"
    allow_multiple_values: false
    required: true
    ui_config:
    type: dropdown_menu
    display: inline
    explore: balance_sheet
    field: balance_sheet.select_fiscal_period

  - name: Comparison Type
    title: Comparison Type
    # type: field_filter
    default_value: yoy
    allow_multiple_values: false
    required: true
    ui_config:
    type: dropdown_menu
    display: inline
    explore: balance_sheet
    field: balance_sheet.select_comparison_type

  - name: Custom Comparison Period
    title: Custom Comparison Period
    # type: field_filter
    default_value: ''
    allow_multiple_values: false
    required: false
    ui_config:
    type: dropdown_menu
    display: inline
    explore: balance_sheet
    field: balance_sheet.select_custom_comparison_period

  - name: Currency
    title: Currency
    # type: field_filter
    default_value: USD
    # default_value: "{% assign dc = _user_attributes['sap_default_global_currency %}{{dc}}"
    allow_multiple_values: false
    required: true
    ui_config:
    type: dropdown_menu
    display: inline
    explore: balance_sheet
    field: balance_sheet.target_currency_tcurr

  - name: Hierarchy
    title: Hierarchy
    # type: field_filter
    default_value: FPA1
    # default_value: "{% assign dh = _user_attributes['sap_balance_sheet_default_hierarchy']%}{{dh}}"
    allow_multiple_values: false
    required: true
    ui_config:
    type: dropdown_menu
    display: inline
    explore: balance_sheet
    field: balance_sheet.hierarchy_name

  - name: Chart of Accounts
    title: Chart of Accounts
    # type: field_filter
    # default_value: CA01
    default_value: "{% if _user_attributes['sap_sql_flavor']=='S4' %}{% assign coa = 'YCOA'%}{%else%}{% assign coa = 'CA01' %}{% endif %}{{coa}}"
    allow_multiple_values: false
    required: true
    ui_config:
    type: dropdown_menu
    display: inline
    explore: balance_sheet
    field: balance_sheet.chart_of_accounts

  - name: Company
    title: Company
    # type: field_filter
    default_value: "%CENTRAL%"
    # default_value: "{% assign dco = _user_attributes['sap_balance_sheet_default_company']%}{{dco}}"
    allow_multiple_values: false
    required: true
    ui_config:
    type: advanced
    display: popover
    explore: balance_sheet
    field: balance_sheet.company_text

  - name: Ledger
    title: Ledger
    # type: field_filter
    default_value: "Leading Ledger"
    allow_multiple_values: true
    required: false
    ui_config:
    type: tag_list
    display: inline
    explore: balance_sheet
    field: balance_sheet.ledger_name

  - name: Top Hierarchy Level
    title: Top Hierarchy Level
    type: field_filter
    default_value: '2'
    allow_multiple_values: true
    required: false
    ui_config:
      type: dropdown_menu
      display: inline
    explore: balance_sheet
    field: hierarchy_selection_sdt.parameter_pick_start_level
