include: "/views/core/shared_parameters.view"

explore: selected_fiscal_date_dim_sdt {
  join: shared_parameters {
    relationship: one_to_one
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
                {% condition shared_parameters.select_reporting_dates %} timestamp(fdd.Date) {% endcondition %}
                then 'Reporting' else 'Comparison' end as fiscal_period_group,
            MIN(date) AS fiscal_period_start_date,
            MAX(Date) AS fiscal_period_end_date
      FROM
        `zeeshanqayyum1.SAP_REPORTING_ECC.fiscal_date_dim` fdd
      WHERE
        mandt = '@{CLIENT_ID}'
        AND periv = 'K4'
        AND (

          {% condition shared_parameters.select_reporting_dates %} timestamp(fdd.Date) {% endcondition %}

          OR
          {% assign compare = shared_parameters.select_compare_to._parameter_value %}

          {% if compare == 'yoy' %}
              --
            fdd.Date >=
             DATE_SUB(DATE({% date_start shared_parameters.select_reporting_dates %}), INTERVAL 1 YEAR)


            and
            fdd.Date <
            DATE_SUB(DATE({% date_end shared_parameters.select_reporting_dates %}), INTERVAL 1 YEAR)

          {% elsif compare == 'prior' %}
            fdd.Date >=
              DATE_SUB(
                      DATE({% date_start shared_parameters.select_reporting_dates %}), INTERVAL
                      DATE_DIFF(DATE({% date_end shared_parameters.select_reporting_dates %}),DATE({% date_start shared_parameters.select_reporting_dates %}),MONTH)
                      MONTH)
              and
                fdd.Date <
                DATE({% date_start shared_parameters.select_reporting_dates %})
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
# DATE_SUB(
#               {% date_start shared_parameters.select_reporting_dates %}
#               INTERVAL 1 YEAR)

#               AND

#                         {% date_end shared_parameters.select_reporting_dates %}

# DATE_SUB(
#               DATE_ADD(
#                     DATE(
#                         {% date_end shared_parameters.select_reporting_dates %}
#                         )
#                     INTERVAL 1 DAY)
#               INTERVAL 1 YEAR)

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


}
