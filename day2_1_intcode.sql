declare
/*************************************************************************************
1,0,0,0,99 becomes 2,0,0,0,99 (1 + 1 = 2).
2,3,0,3,99 becomes 2,3,0,6,99 (3 * 2 = 6).
2,4,4,5,99,0 becomes 2,4,4,5,99,9801 (99 * 99 = 9801).
1,1,1,4,99,5,6,0,99 becomes 30,1,1,4,2,5,6,0,99.
*************************************************************************************/
  p_str varchar2(4000) := '1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,2,19,6,23,2,13,23,27,1,9,27,31,2,31,9,
                           35,1,6,35,39,2,10,39,43,1,5,43,47,1,5,47,51,2,51,6,55,2,10,55,59,1,59,9,63,2,13,
                           63,67,1,10,67,71,1,71,5,75,1,75,6,79,1,10,79,83,1,5,83,87,1,5,87,91,2,91,6,95,2,
                           6,95,99,2,10,99,103,1,103,5,107,1,2,107,111,1,6,111,0,99,2,14,0,0';
  type num_arr_typ is table of number index by pls_integer;
  v_arr num_arr_typ;
  v_str varchar2(4000);
  
  -- turn list into cursor that can iterate over each
  cursor my_cursor
  is
  select to_number(regexp_substr(replace(replace(p_str, ' ', ''), chr(10), ''), '[^,]+', 1, level)) input,
         level
    from   dual
    connect by regexp_substr(replace(p_str, ' ', ''), '[^,]+', 1, level) is not null
    order by level;
  
    -- variables:
    v_type varchar2(4000);
    x_pos number;
    y_pos number;
    x number;
    y number;
    z number;
    res number;
    z_pos number;
    n number := 0;
begin
-- 
  -- transfer the cursor to an array (could I maybe do without this?)

  for i in my_cursor loop
   v_arr(i.level-1) := i.input;
  end loop;
--  dbms_output.put_line('len: '||v_arr.last);
  
--  dbms_output.put_line('----------- INITIAL ARRAY');
--  for i in v_arr.first..v_arr.last loop
--   dbms_output.put_line(i||': ' || v_arr(i));
--  end loop;
  
  
  
  -- loop start
  while v_arr(n) != 99 loop
    select decode(v_arr(n), 1, 'add', 2, 'multiply', 'error')
    into v_type
    from dual;
--    dbms_output.put_line(v_type);
  
    -- the positions of the numbers to be added together 
    x_pos := v_arr(n+1);
    y_pos := v_arr(n+2);
--    dbms_output.put_line('x_pos: '||x_pos||'     y_pos: '||y_pos);
    
    -- The numbers that are at those positions 
    x := v_arr(x_pos);
    y := v_arr(y_pos);
--    dbms_output.put_line('x: '||x||'     y: '||y);
    
    if v_type = 'add' then
      res := x+y;
    elsif v_type = 'multiply' then
      res := x*y;
    else
      dbms_output.put_line('input not 1 or 2');
    end if;
    -- where does the result go?
    z_pos := n+3;
    z := v_arr(z_pos);
    --
    v_arr(z) := res;
    n := n+4;
  end loop;
  
  dbms_output.put_line('--------- FINAL ARRAY:');
  for i in v_arr.first..v_arr.last loop
    dbms_output.put_line(i||': '||v_arr(i));
  end loop;

end;

/
-- wrong answer: 29891