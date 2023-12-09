###########
### OPTION 3
### date filter select_reporting_dates
### parameter Select Compare to: Previous Period or YoY, if custom, user provide values for filter Comparison Period
###
###
###
###########

include: "/views/experimental/shared_parameters.view"

explore: selected_fiscal_date_dim_sdt {
 join: shared_parameters {
   relationship:one_to_one
   sql:  ;;
 }
}
view: selected_fiscal_date_dim_sdt {
  label: "🗓️ Pick Dates OPTION 3"
  derived_table: {
    sql: SELECT
            FiscalYear AS fiscal_year,
            FiscalPeriod AS fiscal_period,
            FiscalQuarter AS fiscal_quarter,
            case when
                {% condition select_reporting_dates %} timestamp(fdd.Date) {% endcondition %}
                then 'Reporting' else 'Comparison' end as fiscal_period_group,
            MIN(date) AS fiscal_period_start_date,
            MAX(Date) AS fiscal_period_end_date
      FROM
        `zeeshanqayyum1.SAP_REPORTING_ECC.fiscal_date_dim` fdd
      WHERE
        mandt = '@{CLIENT_ID}'
        AND periv = 'K4'
        AND (

          {% condition select_reporting_dates %} timestamp(fdd.Date) {% endcondition %}

          OR
          {% assign compare = select_compare_to._parameter_value %}

          {% if compare == 'yoy' %}
              --
            fdd.Date >=
             DATE_SUB(DATE({% date_start select_reporting_dates %}), INTERVAL 1 YEAR)


            and
            fdd.Date <
            DATE_SUB(DATE({% date_end select_reporting_dates %}), INTERVAL 1 YEAR)

          {% elsif compare == 'prior' %}
            fdd.Date >=
              DATE_SUB(
                      DATE({% date_start select_reporting_dates %}), INTERVAL
                      DATE_DIFF(DATE({% date_end select_reporting_dates %}),DATE({% date_start select_reporting_dates %}),MONTH)
                      MONTH)
              and
                fdd.Date <
                DATE({% date_start select_reporting_dates %})
          {% else %}   fdd.Date between '2022-01-02' and '2022-01-30'
          {% endif %}
        )

      GROUP BY
        1,
        2,
        3,
        4
        ;;
  }


  dimension: fiscal_year {
    type: string
    sql: ${TABLE}.fiscal_year ;;
  }

  dimension: fiscal_period {
    type: string
    sql: ${TABLE}.fiscal_period ;;
  }

  dimension: fiscal_year_period {
    type: string
    sql: concat(${TABLE}.fiscal_year,'.',right(${TABLE}.fiscal_period,2) ) ;;
  }

  dimension: fiscal_period_group {
    type: string
    sql: ${TABLE}.fiscal_period_group ;;
  }

  dimension: fiscal_quarter {
    type: number
    sql: ${TABLE}.fiscal_quarter ;;
  }

  dimension: fiscal_year_quarter {
    type: number
    sql: concate(${TABLE}.fiscal_year,'.Q',${TABLE}.fiscal_quarter) ;;
  }

  dimension: fiscal_period_start_date {
    type: date
    datatype: date
    sql: ${TABLE}.fiscal_period_start_date ;;
  }

  dimension: fiscal_period_end_date {
    type: date
    datatype: date
    sql: ${TABLE}.fiscal_period_end_date ;;
  }

  filter: select_reporting_dates {
    type: date
    convert_tz: no
  }

  parameter: select_compare_to {
    type: unquoted
    allowed_value: {
      label: "Year over Year" value: "yoy"
    }
    allowed_value: {
      label: "Same # Periods Prior" value: "prior"
    }
    default_value: "yoy"
  }

  dimension: compare_period_start_date {
    type: date
    sql:{% if select_compare_to._parameter_value == 'yoy' %}
            DATE_SUB(DATE({% date_start select_reporting_dates %}), INTERVAL 1 YEAR)
         {% elsif select_compare_to._parameter_value == 'prior' %}
              DATE_SUB(
                      DATE({% date_start select_reporting_dates %}), INTERVAL
                      DATE_DIFF(DATE({% date_end select_reporting_dates %}),DATE({% date_start select_reporting_dates %}),MONTH)
                      MONTH)
         {% endif %};;
  }

  dimension: compare_period_end_date {
     type: date
    sql:{% if select_compare_to._parameter_value == 'yoy' %}
           DATE_SUB(DATE({% date_end select_reporting_dates %}), INTERVAL 1 YEAR)

      {% elsif select_compare_to._parameter_value == 'prior' %}
      DATE({% date_start select_reporting_dates %})
      {% endif %};;
  }

  dimension: selected_display_level {
    label: "Selected Display Level"
    type: string
    # label_from_parameter: balance_sheet.display
    sql: {% assign level = shared_parameters.display._parameter_value %}
      {% if level == 'fiscal_year'%}${fiscal_year}
        {% elsif level == 'fiscal_year_quarter' %} ${fiscal_year_quarter}
        {% elsif level == 'fiscal_year_period' %} ${fiscal_year_period}
        {% elsif level == 'fiscal_period_group' %}  ${fiscal_period_group}
           {% else %}'no match on level'
    {% endif %}
    ;;
  }


}
