CREATE OR REPLACE PACKAGE cadvent AS
  type num_arr_typ is table of number index by pls_integer;
  --
  function get_fuel_requirement(p_mass number) return number;
  function get_fuel_requirement_rec(p_mass number) return number;
  function csv_to_num_arr(p_input varchar2) return num_arr_typ;
  function intcode (p_input varchar2) return num_arr_typ;
END cadvent;
/

CREATE OR REPLACE PACKAGE ut_cadvent AS
  procedure run;
END ut_cadvent;
/


CREATE OR REPLACE PACKAGE BODY cadvent AS
  function get_fuel_requirement(p_mass number) return number
  is
    v_total number := 0;
  begin
    v_total := floor(p_mass/3) -2;
    if v_total > 0 then
      return v_total;
    else
      return 0;
    end if;
  end get_fuel_requirement;
  
  function get_fuel_requirement_rec(p_mass number) return number
  is
    v_fuel number := 0;
    v_total number := 0;
  begin
    v_fuel := get_fuel_requirement(p_mass);
    v_total := v_fuel;
    if v_fuel > 0 then
      v_total := v_total + get_fuel_requirement_rec(v_fuel);
    end if;
    return v_total;
    
  end get_fuel_requirement_rec;
  --
  function csv_to_num_arr(p_input varchar2) 
  return num_arr_typ
  is
    cursor cur_string
    is
    select regexp_substr(replace(replace(p_input, ' ', ''), chr(10), ''), '[^,]+', 1, level) input,
           level
    from   dual
    connect by regexp_substr(replace(p_input, ' ', ''), '[^,]+', 1, level) is not null
    order by level;
    --
    v_input varchar2(1000);
    v_arr num_arr_typ;
  begin
    for i in cur_string loop
      v_arr(i.level-1) := i.input;
    end loop;
    return v_arr;
  end csv_to_num_arr;
  --
  function intcode (p_input varchar2)
  return num_arr_typ
  is
    v_arr num_arr_typ;
    v_place number := 0;
    v_val_0 number := 666;
    v_val_1 number;
    v_val_2 number;
    v_val_3 number;
    v_total number;
  begin
  --('1,9,10,3,2,3,11,0,99,30,40,50')
    v_arr := csv_to_num_arr(p_input);
 --   dbms_output.put_line('The Array:');
    for i in 0..v_arr.count-1 loop
      dbms_output.put_line(v_arr(i));
    end loop;
    v_val_0 := v_arr(v_place);
    while v_val_0 != 99 loop
      v_val_1 := v_arr(v_place + 1);
      v_val_2 := v_arr(v_place + 2);
      v_val_3 := v_arr(v_place + 3);

      dbms_output.put_line('----in loop----');
      dbms_output.put_line('v_val_0: '||v_val_0);
      dbms_output.put_line('v_val_1: '||v_val_1);
      dbms_output.put_line('v_val_2: '||v_val_2);
      dbms_output.put_line('v_val_3: '||v_val_3);
      dbms_output.put_line('v_place: '||v_place);
      v_val_0 := v_arr(v_place);
      if v_val_0 = 1 then
        v_total := v_val_1 + v_val_2;
        dbms_output.put_line('addition');
        v_arr(v_val_3) := v_total;
      elsif v_val_0 = 2 then
        v_total := v_val_1 * v_val_2;
        v_arr(v_val_3) := v_total;
      else
        null;
      end if;
      v_place := v_place + 4;
      v_val_0 := v_arr(v_place);
      dbms_output.put_line('----end loop----');
    end loop;
    dbms_output.put_line('----out of loop----');
    dbms_output.put_line('final array:');
    for i in 0..v_arr.count-1 loop
      dbms_output.put_line(v_arr(i));
    end loop;
    return v_arr;
  end intcode;

END cadvent;
/

declare
  v_arr cadvent.num_arr_typ;
begin
  v_arr := cadvent.intcode('1,9,10,3,2,3,11,0,99,30,40,50');
end;
/

create or replace package body ut_cadvent
is
  -- Original number test:
  procedure test (
    i_desc                                       varchar2
   ,i_exp                                         pls_integer
   ,i_act                                         pls_integer
  )
  is
  begin
    if i_exp = i_act then
      dbms_output.put_line('SUCCESS: ' || i_desc);
    else
      dbms_output.put_line('FAILURE: ' || i_desc || ' - expected ' || nvl('' || i_exp, 'null') || ', but received ' || nvl('' || i_act, 'null'));
    end if;
  end test;

/*************************************************************************************
  Checks two num_arr_typs are the same
*************************************************************************************/
  FUNCTION is_equal(
    arr1 cadvent.num_arr_typ,
    arr2 cadvent.num_arr_typ
  ) RETURN BOOLEAN
  IS
    i VARCHAR2(10);
  BEGIN
    i := arr1.FIRST;
    WHILE i IS NOT NULL LOOP
      -- Check if the keys in the first array do not exists in the
      -- second array or if the values are different.
      IF    ( NOT arr2.EXISTS( i ) )
         OR ( arr1(i) <> arr2(i) )
         OR ( arr1(i) IS NULL AND arr2(i) IS NOT NULL )
         OR ( arr1(i) IS NOT NULL AND arr2(i) IS NULL )
      THEN
        RETURN FALSE;
      END IF;
      i := arr1.NEXT(i);
    END LOOP;

    i := arr2.FIRST;
    WHILE i IS NOT NULL LOOP
      -- Check if there are any keys in the second array that do not
      -- exists in the first array.
      IF    ( NOT arr1.EXISTS( i ) )
      THEN
        RETURN FALSE;
      END IF;
      i := arr2.NEXT(i);
    END LOOP;

    RETURN TRUE;
  END is_equal;

  -- Test for num_arr_typ
  PROCEDURE test (
    i_desc                                        VARCHAR2
   ,i_exp                                         cadvent.num_arr_typ
   ,i_act                                         cadvent.num_arr_typ
  )
  IS
  BEGIN
    IF is_equal(i_exp, i_act) THEN
      dbms_output.put_line('SUCCESS: ' || i_desc);
    ELSE
      dbms_output.put_line('FAILURE: ' || i_desc || ' - expected ');
      FOR i in 0..i_exp.count-1 LOOP
        dbms_output.put_line(to_char(i) || ': ' || i_exp(i));
      END LOOP;
      dbms_output.put_line('But received ');
      FOR i in 0..i_act.count-1 LOOP
        dbms_output.put_line(to_char(i) || ': ' || i_act(i));
      END LOOP;
    END IF;
  END TEST;

  procedure run
  is
  begin
    test(i_desc => 'test_fuel_for_mass_12_is_2',
         i_exp  => 2,
         i_act  => cadvent.get_fuel_requirement(12)
    );
    test(i_desc => 'test_fuel_for_mass_14_is_2',
         i_exp  => 2,
         i_act  => cadvent.get_fuel_requirement(14)
    );
    test(i_desc => 'test_fuel_for_mass_1969_is_654',
         i_exp  => 654,
         i_act  => cadvent.get_fuel_requirement(1969)
    );
    test(i_desc => 'test_fuel_for_mass_100756_is_33583',
         i_exp  => 33583,
         i_act  => cadvent.get_fuel_requirement(100756)
    );
    test(i_desc => 'test_fuel_recursion_14_is_2',
         i_exp  => 2,
         i_act  => cadvent.get_fuel_requirement_rec(14)
    );
    test(i_desc => 'test_fuel_recursion_1969_is_966',
         i_exp  => 966,
         i_act  => cadvent.get_fuel_requirement_rec(1969)
    );
    test(i_desc => 'test_fuel_recursion_100756_is_50346',
         i_exp  => 50346,
         i_act  => cadvent.get_fuel_requirement_rec(100756)
    );
    test(i_desc => 'test_csv_to_num_arr_type_1',
         i_exp  => 1,
         i_act  => cadvent.csv_to_num_arr('1, 2, 3, 4')(0)
    );
    test(i_desc => 'test_csv_to_num_arr_type_2',
         i_exp  => 3,
         i_act  => cadvent.csv_to_num_arr('1, 2, 3, 4')(2)
    );
    test(i_desc => 'test_csv_to_num_arr_type_3',
         i_exp  => 12,
         i_act  => cadvent.csv_to_num_arr('1, 2, 3, 4,5,7,12')(6)
    );
    test(i_desc => 'test_csv_to_num_arr_type_4',
         i_exp  => 312,
         i_act  => cadvent.csv_to_num_arr('1,2,312,4')(2)
    );
    -- Test num_arr_typ test
    test(i_desc => 'test_array_with_first_5_fib_numbers',
         i_exp  => cadvent.num_arr_typ(0 => 1, 1 => 2, 2 => 3, 3 => 5, 4 => 8, 5 => 13, 6 => 21, 7 => 34),
         i_act  => cadvent.csv_to_num_arr('1, 2, 3  ,5,8,13, 21, 34')
    );
    -- Test f_intcode function
    test(i_desc => 'intcode_example_1',
         i_exp  => cadvent.num_arr_typ(0 => 3500, 1 => 9, 2 => 10, 3 => 70, 4 => 2, 5 => 3, 6 => 11, 7 => 0, 
                                         8 => 99, 9 => 30, 10 => 40, 11 => 50),
         i_act  => cadvent.intcode('1,9,10,3,2,3,11,0,99,30,40,50')
    );
  end run;
end ut_cadvent;
/

begin
  ut_cadvent.run;
end;
/

