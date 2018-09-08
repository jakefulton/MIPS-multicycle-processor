-- Jake Fulton
-- 51804736

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity PC is 
  port( wr_en, clk, reset_N: in std_logic;
        addr_in: in word;
        addr_out: out word
  );
end PC;

architecture PC_arch of PC is
    signal addr_buff: word;
    begin
        addr_out <= addr_buff;
        process(clk, reset_N)
        begin
            if reset_N = '0' then
                addr_buff <= x"00000000";
            elsif clk'event and clk = '1' and wr_en = '1' then
                addr_buff <= addr_in;
            end if;
        end process;
end PC_arch;
