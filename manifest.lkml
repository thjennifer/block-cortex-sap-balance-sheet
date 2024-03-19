constant: CONNECTION_NAME {
  value: "qa-thjennifer3"
  export: override_required
}


constant: GCP_PROJECT_ID {
  value: "thjennifer3"
  # value: "zeeshanqayyum1"
  # value: "kittycorn-dev-infy"
  export: override_required
}

constant: REPORTING_DATASET {
  value: "CORTEX_SAP_REPORTING"
  # value: "SAP_REPORTING_ECC"
  # value: "SAP_REPORTING_S4"
  export: override_required
}

constant: CLIENT_ID {
  value: "100"
  export: override_required
}

# Revenue is generally displayed in general ledger as a negative number, which indicates a credit.
# By setting Sign Change value to 'yes', it's displayed as a positive number in income statement reports.
constant: SIGN_CHANGE {
  value: "yes"
  export: override_required
}

# constant: FISCAL_MONTH_OFFSET {
#   value: "0"
# }

# constant: USE_DEMO_DATA {
#   value: "Yes"
#   export: override_required
# }

# # specify either ECC or S4
# constant: SQL_FLAVOR {
#   value: "S4"
#   export: override_required
# }



# to show negative values in red, at this constant to the html: parameter
# For example:
#         measure: profit {
#            type: number
#            sql: ${total_sales} - ${total_cost} ;;
#            html: @{negative_format} ;;
#         }

constant: negative_format {
  value: "{% if value < 0 %}<p style='color:red;'>({{rendered_value | remove: '-'}})</p>{% else %} {{rendered_value}} {% endif %}"
}

# enter the max number of fiscal periods in a fiscal year.
# used to derive previous previous period when 1st period is selected
# constant: max_fiscal_period {
#   value: "12"
#   export: override_optional
# }

# balance sheet comparison period derived based on select_comparison_type parameter:
  #     if yoy then subtract year from period
  #     if prior then subtract 1 from period (if period 001 then substract 1 year and use max_fiscal_period for period)
  #     if custom then use value from select_custom_comparison_period
# constant: derive_comparison_period {
#   value: "{% assign comparison_type = select_comparison_type._parameter_value %}
#                 {% assign fp = select_fiscal_period._parameter_value %}
#                 {% assign cp = select_custom_comparison_period._parameter_value %}
#                 {% assign max_fp_size = '3' | times: 1 %}
#                 {% assign max_fp_size_neg = max_fp_size | times: -1 %}
#                 {% assign pad = '00' %}

#                 {% if comparison_type == 'custom' %}
#                     {% if fp == cp %}{% assign comparison_type = 'none' %}
#                     {% elsif cp == '' %}{% assign comparison_type = 'yoy' %}
#                     {% endif %}
#                 {% endif %}

#                 {% if comparison_type == 'prior' or comparison_type == 'yoy' %}
#                   {% assign p_array = fp | split: '.' %}
#                       {% if comparison_type == 'prior' %}
#                             {% if p_array[1] == '001' %}
#                               {% assign m = '@{max_fiscal_period}' | prepend: pad | slice: max_fp_size_neg, max_fp_size %}{% assign sub_yr = 1 %}
#                             {% else %}
#                               {% assign m = p_array[1] | times: 1 | minus: 1 | prepend: pad | slice: max_fp_size_neg, max_fp_size %}{% assign sub_yr = 0 %}
#                             {% endif %}
#                       {% else %}
#                           {% assign m = p_array[1] %}{% assign sub_yr = 1 %}
#                       {% endif %}
#                   {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
#                   {% assign cp =  yr | append: '.'| append: m %}
#                 {% elsif comparison_type == 'none' %} {% assign cp = '' %}
#                 {% endif %}"
# }

# based on value of SIGN_CHANGE assigned during installation, derive a multiplier to be applied to dimension amounts in profit_and_loss view. For example:
# dimension: amount_in_local_currency {
#   sql: @{sign_change_multiplier}
#        ${TABLE}.AmountInLocalCurrency * {{multiplier}} ;;
#   }
constant: sign_change_multiplier {
  value: "{% assign choice = '@{SIGN_CHANGE}' | downcase %}
          {% if choice == 'yes' %}{% assign multiplier = -1 %}{% else %}{% assign multiplier = 1 %}{% endif %}"
}

constant: big_numbers_format {
  value: "
  {% if value < 0 %}
  {% assign abs_value = value | times: -1.0 %}
  {% assign pos_neg = '-' %}
  {% else %}
  {% assign abs_value = value | times: 1.0 %}
  {% assign pos_neg = '' %}
  {% endif %}

  {% if abs_value >=1000000000 %}
  {{pos_neg}}{{ abs_value | divided_by: 1000000000.0 | round: 2 }}B
  {% elsif abs_value >=1000000 %}
  {{pos_neg}}{{ abs_value | divided_by: 1000000.0 | round: 2 }}M
  {% elsif abs_value >=1000 %}
  {{pos_neg}}{{ abs_value | divided_by: 1000.0 | round: 2 }}K
  {% else %}
  {{pos_neg}}{{ abs_value }}
  {% endif %}

  "
}

constant: test_vis_config {
  value: "\"show_view_names\":false,\"show_row_numbers\":true,\"transpose\":false,\"truncate_text\":true,\"hide_totals\":false,\"hide_row_totals\":false,\"size_to_fit\":false,\"table_theme\":\"white\",\"limit_displayed_rows\":false,\"enable_conditional_formatting\":false,\"header_text_alignment\":\"center\",\"header_font_size\":\"12\",\"rows_font_size\":\"12\",\"conditional_formatting_include_totals\":false,\"conditional_formatting_include_nulls\":false,\"show_sql_query_menu_options\":false,\"show_totals\":true,\"show_row_totals\":true,\"truncate_header\":false,\"minimum_column_width\":100,\"series_labels\":{\"balance_sheet.parent_text\":\"Parent\",\"balance_sheet.node_text\":\"Node\"},\"series_column_widths\":{\"balance_sheet.node_text\":200},\"series_cell_visualizations\":{\"balance_sheet.reporting_period_amount_in_global_currency\":{\"is_active\":true}},\"series_text_format\":{\"balance_sheet.parent_text\":{\"align\":\"left\"}},\"type\":\"looker_grid\",\"x_axis_gridlines\":false,\"y_axis_gridlines\":true,\"show_y_axis_labels\":true,\"show_y_axis_ticks\":true,\"y_axis_tick_density\":\"default\",\"y_axis_tick_density_custom\":5,\"show_x_axis_label\":true,\"show_x_axis_ticks\":true,\"y_axis_scale_mode\":\"linear\",\"x_axis_reversed\":false,\"y_axis_reversed\":false,\"plot_size_by_field\":false,\"trellis\":\"\",\"stacking\":\"\",\"legend_position\":\"center\",\"point_style\":\"none\",\"show_value_labels\":false,\"label_density\":25,\"x_axis_scale\":\"auto\",\"y_axis_combined\":true,\"ordering\":\"none\",\"show_null_labels\":false,\"show_totals_labels\":false,\"show_silhouette\":false,\"totals_color\":\"#808080\",\"defaults_version\":1,\"series_types\":{}"
}
