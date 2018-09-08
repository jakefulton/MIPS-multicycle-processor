-- Jake Fulton
-- 51804736

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity Reg32 is 
  port( clk     : in std_logic;
        d_in    : in word;
        d_out   : out word
  );
end Reg32;

architecture Reg32_arch of Reg32 is
begin
    process(clk)
    begin
        if clk = '1' and clk'event then
            d_out <= d_in;
        end if;
    end process;
end Reg32_arch;
