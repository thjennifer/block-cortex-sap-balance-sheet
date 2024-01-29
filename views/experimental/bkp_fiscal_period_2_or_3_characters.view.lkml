view: bkp_fiscal_period_2_or_3_characters {
  # dimension: fiscal_year_period {
  #   type: string
  #   group_label: "Fiscal Dates"
  #   description: "Fiscal Year and Period as String in form of YYYY.PP or YYYY.PPP"
  #   sql: {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
  #       {% if max_fp_size == 2 %} {% assign fp = 'right(${fiscal_period},2)'%}{%else%}{%assign fp = '${fiscal_period}' %}{%endif%}
  #         concat(${fiscal_year},'.',{{fp}});;
  #   order_by_field: fiscal_year_period_negative_number
  # }


# comparison period derived based on select_comparison_type parameter:
  #     if yoy then subtract year from period
  #     if prior then subtract 1 from period (if period 001 then substract 1 year and use max_fiscal_period for period)
  #     if custom then use value from select_custom_comparison_period

  # constant: derive_comparison_period {
  #   value: "{% assign comparison_type = select_comparison_type._parameter_value %}
  #   {% assign fp = select_fiscal_period._parameter_value %}
  #   {% assign cp = select_custom_comparison_period._parameter_value %}
  #   {% assign max_fp_size = '@{max_fiscal_period}' | remove_first: '0' | size | times: 1 %}
  #   {% assign max_fp_size_neg = max_fp_size | times: -1 %}
  #   {% assign pad = '' %}
  #   {% for i in (1..max_fp_size) %}
  #   {% assign pad = pad | append: '0' %}
  #   {% endfor %}
  #   {% if comparison_type == 'custom' %}
  #   {% if fp == cp %}{% assign comparison_type = 'none' %}
  #   {% elsif cp == '' %}{% assign comparison_type = 'yoy' %}
  #   {% endif %}
  #   {% endif %}

  #   {% if comparison_type == 'prior' or comparison_type == 'yoy' %}
  #   {% assign p_array = fp | split: '.' %}
  #   {% if comparison_type == 'prior' %}
  #   {% if p_array[1] == '001' or p_array[1] == '01' %}
  #   {% assign m = '@{max_fiscal_period}' %}{% assign sub_yr = 1 %}
  #   {% else %}
  #   {% assign m = p_array[1] | times: 1 | minus: 1 | prepend: pad | slice: max_fp_size_neg, max_fp_size %}{% assign sub_yr = 0 %}
  #   {% endif %}
  #   {% else %}
  #   {% assign m = p_array[1] %}{% assign sub_yr = 1 %}
  #   {% endif %}
  #   {% assign yr = p_array[0] | times: 1 | minus: sub_yr %}
  #   {% assign cp =  yr | append: '.'| append: m %}
  #   {% elsif comparison_type == 'none' %} {% assign cp = '' %}
  #   {% endif %}"
  # }

 }
