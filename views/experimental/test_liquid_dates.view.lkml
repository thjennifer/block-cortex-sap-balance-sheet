explore: test_liquid_dates {}

view: test_liquid_dates {
  derived_table: {
    sql:  select 1 as test_field ;;
  }

dimension: liquid_current_date {

  sql: {% assign intervalDays = 31 %}{% assign intervalSeconds = intervalDays | times: 86400 %}
       {% assign daysMinus31 = 'now' | date: '%s' | minus: intervalSeconds %}
       {% assign m = daysMinus31 | date: '%m' | prepend: '00' | slice: -3,3 %}{% assign m3 = m | prepend: '00' | slice: -3,3 %}
       {% assign y = daysMinus31 | date: '%Y'%}'{{y | append: '.' | append: m}}'
       ;;


}
}
