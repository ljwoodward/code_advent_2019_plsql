-------------------------------------------------------------------------------------------------------------------------------- - DAY 3 FUNCTION
create or replace function f_day_3(p_input varchar2)
return number
is
  t_wire1 varchar2(4000);
  t_wire2 varchar2(4000);
  v_direction varchar2(1);
  v_magnitude number;
  t_instructions1 apex_t_varchar2;
  t_instructions2 apex_t_varchar2;
  t_plot1 coordinate_arr_nt := coordinate_arr_nt (coordinate_va (0, 0));
  t_plot2 coordinate_arr_nt := coordinate_arr_nt (coordinate_va (0, 0));
  t_cur_coord coordinate_va := coordinate_va (0, 0);
  t_new_coord coordinate_va := coordinate_va (0, 0);
  c_l coordinate_va := coordinate_va (-1, 0);
  c_r coordinate_va := coordinate_va (1, 0);
  c_u coordinate_va := coordinate_va (0, 1);
  c_d coordinate_va := coordinate_va (0, -1);
  t_matches coordinate_arr_nt := coordinate_arr_nt();
  n_shortest_distance number := 999999999;
  n_distance number;
  t_distances num_nt := num_nt();
  
  function f_add_coords (p_coord1 coordinate_va, p_coord2 coordinate_va)
  return coordinate_va
  is
    t_new_coord coordinate_va := coordinate_va(p_coord1(1) + p_coord2(1), p_coord1(2) + p_coord2(2));
  begin
--    t_new_coord(1) := p_coord1(1) + p_coord2(1);
--    t_new_coord(2) := p_coord1(2) + p_coord2(2);
    return t_new_coord;
  end;
begin
  t_wire1 := f_split(p_input, chr(10))(1);
  t_wire2 := f_split(p_input, chr(10))(2);
  -- list of instructions 1
  t_instructions1 := f_split(t_wire1, ',');
  -- 
  for i in 1..t_instructions1.last loop
    v_direction := substr(t_instructions1(i), 1, 1);
    v_magnitude := to_number(substr(t_instructions1(i), 2));
    for j in 1..v_magnitude loop
      case v_direction
        when 'R' then
          t_new_coord := f_add_coords(t_cur_coord, c_r);
        when 'L' then
          t_new_coord := f_add_coords(t_cur_coord, c_l);
        when 'U' then
          t_new_coord := f_add_coords(t_cur_coord, c_u);
        when 'D' then
          t_new_coord := f_add_coords(t_cur_coord, c_d);
      end case;
      t_plot1.extend;
      t_plot1(t_plot1.last) := t_new_coord;
      t_cur_coord := t_new_coord;
    end loop;
  end loop;
  -- copy and paste above for instructions 2
  -- list of instructions 2
  t_instructions2 := f_split(t_wire2, ',');
  -- reset t_cur_coord
  t_cur_coord := coordinate_va (0, 0);
  for i in 1..t_instructions2.last loop
--    dbms_output.put_line(t_instructions2(i));
    v_direction := substr(t_instructions2(i), 1, 1);
    v_magnitude := to_number(substr(t_instructions2(i), 2));
--    dbms_output.put_line(v_direction);
--    dbms_output.put_line(v_magnitude);
    for j in 1..v_magnitude loop
      case v_direction
        when 'R' then
          t_new_coord := f_add_coords(t_cur_coord, c_r);
        when 'L' then
          t_new_coord := f_add_coords(t_cur_coord, c_l);
        when 'U' then
          t_new_coord := f_add_coords(t_cur_coord, c_u);
        when 'D' then
          t_new_coord := f_add_coords(t_cur_coord, c_d);
      end case;
--      t_plot2.extend;
--      t_plot2(t_plot2.last) := t_new_coord;
--      for i in 2..t_plot1.last loop
--      if f_coord_in_arr(t_new_coord, t_plot1) then
--        t_distances.extend;
--        t_distances(t_distances.last) := abs(t_new_coord(1)) + abs(t_new_coord(2));
--      end if;
--      end loop;
      t_cur_coord := t_new_coord;
    end loop;
  end loop;
--  dbms_output.put_line(t_plot1.last);
----  for i in t_plot2.first..t_plot2.last loop
----    dbms_output.put_line(i||' ('||t_plot2(i)(1)||', '||t_plot2(i)(2)||')');
----  end loop;
----  for i in 2..t_plot1.last loop
----    for j in 2..t_plot2.last loop
----      if t_plot1(i)(1) = t_plot2(j)(1) and t_plot1(i)(2) = t_plot2(j)(2) then
----        t_matches.extend;
----        t_matches(t_matches.last) := t_plot1(i);
----      end if;
----    end loop;
----  end loop;
----  t_matches := t_plot1 multiset intersect t_plot2;
--  for i in 1..t_distances.last loop
----    dbms_output.put_line(t_distances(i));
--    if t_distances(i) < n_shortest_distance then
--      n_shortest_distance := t_distances(i);
--    end if;
--  end loop;
--  return n_shortest_distance;
--  dbms_output.put_line('t_instructions1');
--  for i in t_instructions1.first..t_instructions1.last loop
--    dbms_output.put_line(t_instructions1(i));
--  end loop;
--  dbms_output.put_line('t_instructions2');
--  for i in t_instructions2.first..t_instructions2.last loop
--    dbms_output.put_line(t_instructions2(i));
--  end loop;
  
  return 12;
end;
/

-------------------------------------------------------------------------------------------------------------------------------- - TEST
declare
v_input varchar2(4000) := 'R1001,D915,R511,D336,L647,D844,R97,D579,L336,U536,L645,D448,R915,D473,L742,D470,R230,D558,R214,D463,L374,D450,R68,U625,L937,D135,L860,U406,L526,U555,R842,D988,R819,U995,R585,U218,L516,D756,L438,U921,R144,D62,R238,U144,R286,U934,L682,U13,L287,D588,L880,U630,L882,D892,R559,D696,L329,D872,L946,U219,R593,U536,R402,U946,L866,U690,L341,U729,R84,U997,L579,D609,R407,D846,R225,U953,R590,U79,R590,U725,L890,D384,L442,D364,R600,D114,R39,D962,R413,U698,R762,U520,L180,D557,R35,U902,L476,U95,R830,U858,L312,U879,L85,U620,R505,U248,L341,U81,L323,U296,L53,U532,R963,D30,L380,D60,L590,U699,R967,U88,L725,D730,R706,D337,L248,D46,R131,U541,L313,U508,R120,D719,R28,U342,R555,U780,R397,D523,L619,D820,R865,D4,L790,D544,L873,D249,L220,U343,R818,U803,R309,D576,R811,D717,L800,D171,R523,U630,L854,U265,R207,U147,R518,U237,R822,D672,L140,U580,R408,D739,L519,U759,R664,D61,R258,D313,R472,U437,R975,U828,L54,D892,L370,U509,L80,U593,L268,U856,L177,U950,L266,U29,R493,D228,L110,U390,L92,U8,L288,U732,R459,D422,R287,D359,R915,U295,R959,U215,R82,D357,L970,D782,L653,U399,L50,D720,R788,D396,L562,D560,R798,D196,R79,D732,R332,D957,L106,D199,R756,U379,R716,U282,R812,U346,R592,D416,L454,U612,L160,U884,R373,U306,R55,D492,R175,D233,L249,D616,L342,D650,L181,U868,L761,D170,L976,U711,R377,D113,L548,U39,R62,D99,R853,U249,L951,U617,R257,U457,R430,D355,L541,U595,L176,D987,R365,D77,L181,D192,L688,D942,R617,U484,R247,U180,R771,D392,R184,U597,L682,U454,R856,U616,R174,U629,L607,U41,L970,D602,R402,D208,R826
L994,U238,R605,U233,L509,U81,R907,U880,R666,D86,R6,U249,R345,D492,L912,U770,L827,D107,R988,D525,L471,U706,R31,U485,R835,D778,R419,D461,L937,D740,R559,U309,L379,U385,R828,D698,R276,U914,L911,U969,R282,D365,L43,D911,R256,D592,L451,U162,L829,D564,R349,U279,R19,D110,R259,D551,L172,D899,L924,D819,R532,U737,L794,U995,R168,D359,R847,U426,R224,U984,L929,D531,L797,U292,L332,D280,R317,D648,R776,D52,R916,U363,R919,U890,R583,U961,L89,D680,L894,D226,L83,U68,R551,U413,R259,D468,L702,U453,L128,U986,R238,U805,R431,U546,R944,D142,R677,D783,R336,D220,R40,U391,R5,D760,L963,D764,R653,U932,R473,U311,L189,D883,R216,U391,L634,U275,L691,U975,R130,D543,L163,U736,R964,U729,R752,D531,R90,D471,R687,D341,R441,U562,R570,U278,R570,U177,L232,U781,L874,U258,R180,D28,R916,D395,R96,U954,L222,U578,L394,U775,L851,D18,L681,D912,L761,U945,L866,D12,R420,D168,R490,U679,R521,D91,L782,U583,L823,U656,L365,D517,R319,U725,L824,D531,L747,U822,R893,D162,L11,D913,L295,D65,L393,D351,L432,U828,L131,D384,R311,U381,L26,D635,L180,D395,L576,D836,R548,D820,L219,U749,L64,D2,L992,U104,L501,U247,R693,D862,R16,U346,R332,U618,R387,U4,L206,U943,R734,D164,R771,U17,L511,D475,L75,U965,R116,D627,R243,D77,R765,D831,L51,U879,R207,D500,R289,U749,R206,D850,R832,U407,L985,U514,R290,U617,L697,U812,L633,U936,R214,D447,R509,D585,R787,D500,R305,D598,R866,U781,L771,D350,R558,U669,R284,D686,L231,U574,L539,D337,L135,D751,R315,D344,L694,D947,R118,U377,R50,U181,L96,U904,L776,D268,L283,U233,L757,U536,L161,D881,R724,D572,R322';
--  v_input varchar2(4000) := 'R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
--U98,R91,D20,R16,D67,R40,U7,R15,U6,R7';
  n_result number;
  t1 pls_integer;
begin
  t1 := dbms_utility.get_time;
  n_result := f_day_3(v_input);
  dbms_output.put_line('result: '||n_result );
  dbms_output.put_line((dbms_utility.get_time - t1)/100 || ' seconds');
end;
/
-------------------------------------------------------------------------------------------------------------------------------- - PLAYGROUND
--create type coordinate_va is varray(2) of number;
--/
--create type coordinate_arr_nt is table of coordinate_va
--/
--create type num_nt is table of number
--/
--create type varchar_nt is table of varchar2(32767)
--/