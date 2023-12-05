constant: CONNECTION_NAME {
  value: "qa-thjennifer3"
  export: override_required
}


constant: GCP_PROJECT_ID {
  value: "zeeshanqayyum1"
  export: override_required
}

constant: REPORTING_DATASET {
  value: "SAP_REPORTING_ECC"
  export: override_required
}

constant: CLIENT_ID {
  value: "100"
  export: override_required
}

constant: USE_DEMO_DATA {
  value: "Yes"
  export: override_required
}

constant: TEST_big {
  value: "{% if value < 0 %}
              {% assign abs_value = value | times: -1.0 %}
              {% assign pos_neg = '-' %}
          {% else %}
              {% assign abs_value = value | times: 1.0 %}
              {% assign pos_neg = '' %}
          {% endif %}
          {% if abs_value >= 1000000000.0 %}
              {{pos_neg}}{{ abs_value | divided_by: 1000000000.0 | round: 2 }}B
          {% elsif abs_value >= 1000000 %}
              {{pos_neg}}{{ abs_value | divided_by: 1000000.0 | round: 2 }}M
          {% elsif abs_value >= 1000.0 %}
              {{pos_neg}}{{ abs_value | divided_by: 1000.0 | round: 2 }}K
          {% else %}
              {{pos_neg}}{{ abs_value }}
           {% endif %}"
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
