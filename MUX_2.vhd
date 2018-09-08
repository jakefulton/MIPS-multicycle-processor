library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity MUX_2 is 
  port( sel     : in std_logic;
        A, B    : in word;
        D       : out word
  );
end MUX_2;

architecture MUX_arch of MUX_2 is
begin
    D <= A when (sel = '1') else B;
end MUX_arch;
