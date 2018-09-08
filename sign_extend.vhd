-- Jake Fulton
-- 51804736

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity sign_extend is 
  port( d_in       : in offset;
        d_out      : out word
  );
end sign_extend;

architecture sign_extend_arch of sign_extend is
begin
    process(d_in)
        begin
            d_out(15 downto 0) <= d_in(15 downto 0);
            if( d_in(15) = '1' ) then
                d_out(31 downto 16) <= "1111111111111111";
            else
                d_out(31 downto 16) <= "0000000000000000";
            end if;
    end process;
end sign_extend_arch;
