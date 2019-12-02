CREATE OR REPLACE PACKAGE cadvent AS
    function get_fuel_requirement(p_mass number) return number;
    function get_fuel_requirement_rec(p_mass number) return number;END cadvent;
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
END cadvent;
/

create or replace package body ut_cadvent
is
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
  end run;
end ut_cadvent;
/

begin
  ut_cadvent.run;
end;
/

declare
  cursor cur_mass
  is
  select mass
  from ca_masses;
  v_count number := 0;
begin
  for i in cur_mass loop
    v_count := v_count + cadvent.get_fuel_requirement_rec(i.mass);
  end loop;
  dbms_output.put_line(v_count);
end;