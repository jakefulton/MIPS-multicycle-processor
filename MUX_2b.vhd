-- Jake Fulton
-- 51804736

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity MUX_4b is
    port(
        sel         : in std_logic_vector(1 downto 0);
        A           : in reg_addr;
        B           : in reg_addr;
        C           : in reg_addr;
        D           : in reg_addr;
        E           : out reg_addr);
end MUX_4b;

architecture MUX_arch of MUX_4b is
begin
    E <=       A when (sel = "00") else
               B when (sel = "01") else
               C when (sel = "10") else
               D when (sel = "11") else A;
end MUX_arch;
