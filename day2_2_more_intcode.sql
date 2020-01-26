/*************************************************************************************
--- Part Two ---
Intcode programs are given as a list of integers; these values are used as the initial state for the computer's memory. When you 
run an Intcode program, make sure to start by initializing memory to the program's values. A position in memory is called an address 
(for example, the first value in memory is at "address 0").

Opcodes (like 1, 2, or 99) mark the beginning of an instruction. The values used immediately after an opcode, if any, are called 
the instruction's parameters. For example, in the instruction 1,2,3,4, 1 is the opcode; 2, 3, and 4 are the parameters. The instruction 
99 contains only an opcode and has no parameters.

The address of the current instruction is called the instruction pointer; it starts at 0. After an instruction finishes, the 
instruction pointer increases by the number of values in the instruction; until you add more instructions to the computer, this is 
always 4 (1 opcode + 3 parameters) for the add and multiply instructions. (The halt instruction would increase the instruction pointer 
by 1, but it halts the program instead.)

"With terminology out of the way, we're ready to proceed. To complete the gravity assist, you need to determine what pair of inputs 
produces the output 19690720."

The inputs should still be provided to the program by replacing the values at addresses 1 and 2, just like before. In this program, 
the value placed in address 1 is called the noun, and the value placed in address 2 is called the verb. Each of the two input values 
will be between 0 and 99, inclusive.

Once the program has halted, its output is available at address 0, also just like before. Each time you try a pair of inputs, make 
sure you first reset the computer's memory to the values in the program (your puzzle input) - in other words, don't reuse memory 
from a previous attempt.

Find the input noun and verb that cause the program to produce the output 19690720. What is 100 * noun + verb? 
(For example, if noun=12 and verb=2, the answer would be 1202.)
*************************************************************************************/

-- instructions are opcodes plus parameters
-- n is opcode
-- n+1..n+p are parameters
-- instruction pointer is the address of current instruction (starts at 0) afterwards it increases by the length of the instruction
-- p_noun and p_verb are the inputs, they're between 0 and 99 inc.
  -- they replace positions 1 and 2
-- 19690720


-- DANGER! takes a long time
declare
  j number := 0;
begin
  for i in 0..99 loop
    for j in 0..99 loop
      if intcode(i, j) = 19690720 then
        dbms_output.put_line(100 * i + j);
        exit;
      end if;      
    end loop;
  end loop;
end;
/
begin dbms_output.put_line(intcode(12, 2)); end;
/
create or replace function intcode(p_noun number, p_verb number)
return number
is
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
    v_opcode number;
    x_pos number;
    y_pos number;
    x number;
    y number;
    z number;
    res number;
    z_pos number;
    n number := 0;
begin
  -- create the array:
  for i in my_cursor loop
   v_arr(i.level-1) := i.input;
  end loop;
  -- substitute the inputs:
  v_arr(1) := p_noun;
  v_arr(2) := p_verb;
  -- loop start
  while v_arr(n) != 99 loop
    v_opcode := v_arr(n);
  
    -- the positions of the numbers to be added together 
    x_pos := v_arr(n+1);
    y_pos := v_arr(n+2);
    x := v_arr(x_pos);
    y := v_arr(y_pos);
    
    -- 1 = add
    -- 2 = multiply
    if v_opcode = 1 then
      res := x+y;
    elsif v_opcode = 2 then
      res := x*y;
    else
      dbms_output.put_line('input not 1 or 2');
      return 0;
    end if;
    z_pos := n+3;
    z := v_arr(z_pos);
    --
    v_arr(z) := res;
    n := n+4;
    if v_arr(n) not in (1, 2, 99) then
      return 0;
    end if;
  end loop;
  -- return the first item in the array:
  return v_arr(0);

end;

/