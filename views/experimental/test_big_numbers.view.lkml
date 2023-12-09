explore: test_big_numbers {hidden:yes}
view: test_big_numbers {
  derived_table: {
    sql: select * from unnest(array[942,1234,15900,105321,2893650,50102501546,-15,-2345065,-36489525458]) as nbr
      ;;
  }

  dimension: nbr {
    type: number
    #value_format_name: decimal_2
    #html: @{BigNumbers_format} ;;
  }


  measure: sum_nbr {
    type: sum
    sql: ${nbr} ;;
    html: @{big_numbers_format} <br> something else;;
  }
}
