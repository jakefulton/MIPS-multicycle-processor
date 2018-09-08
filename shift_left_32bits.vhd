-- Jake Fulton
-- 51804736

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity shiftleft32bits is 
  port( d_in       : in word;
        d_out      : out word
  );
end shiftleft32bits;

architecture shiftleft32bits_arch of shiftleft32bits is
begin
    process(d_in)
        begin
            d_out(31 downto 2) <= d_in(29 downto 0);
            d_out(1 downto 0) <= "00";
    end process;
end shiftleft32bits_arch;
