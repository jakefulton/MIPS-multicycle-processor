library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity shiftleft26bits is 
  port( d_in       : in target;
        d_out      : out std_logic_vector(27 downto 0)
  );
end shiftleft26bits;

architecture shiftleft26bits_arch of shiftleft26bits is
begin
    process(d_in)
        begin
            d_out(27 downto 2) <= d_in(25 downto 0);
            d_out(1 downto 0) <= "00";
    end process;
end shiftleft26bits_arch;
