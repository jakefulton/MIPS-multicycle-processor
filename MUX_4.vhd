library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity MUX_4 is 
  port( sel         : in std_logic_vector(1 downto 0);
        A, B, C, D  : in word;
        E           : out word
  );
end MUX_4;

architecture MUX_arch of MUX_4 is
begin
    E <=    A when (sel = "00") else
            B when (sel = "01") else
            C when (sel = "10") else
            D when (sel = "11") else A;
end MUX_arch;
