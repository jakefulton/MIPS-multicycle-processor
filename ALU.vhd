--Jake Fulton
--51804736


LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
use work.Glob_dcls.all;
use ieee.numeric_std.all;

entity ALU is 
  PORT( op_code  : in ALU_opcode;
        in0, in1 : in word;	
        C	 : in std_logic_vector(4 downto 0);  -- shift amount	
        ALUout   : out word;
        Zero     : out std_logic
  );
end ALU;

architecture ALU_arch of ALU is
-- signal declaration
signal res : word;

begin
    process(in0, in1, op_code)
    begin
        case(op_code) is when "000" => --Addition
            res <= in0 + in1;
        when "001" => --Subtraction
            res <= in0 - in1;
        when "010" => --Shift Left
            res <= std_logic_vector(unsigned(in1) sll to_integer(unsigned(C)));
        when "011" => --Shift Right
            res <= std_logic_vector(unsigned(in1) srl to_integer(unsigned(C)));
        when "100" => --AND
            res <= in0 AND in1;
        when "101" => --OR
            res <= in0 OR in1;
        when "110" => --XOR
            res <= in0 XOR in1;
        when "111" => --NOR
            res <= in0 NOR in1;
	when others =>
		res <= in0 + in1;
	end case;
    end process;

ALUout <= res;
Zero <= '1' when res = X"00000000" else '0';  --Zero Flag
end ALU_arch;
