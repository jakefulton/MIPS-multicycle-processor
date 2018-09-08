-- Jake Fulton
-- 51804736

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity RegFile is 
  port(
        clk, wr_en                    : in STD_LOGIC;
        rd_addr_1, rd_addr_2, wr_addr : in REG_addr;
        d_in                          : in word; 
        d_out_1, d_out_2              : out word
  );
end RegFile;

architecture RF_arch of RegFile is
    type temp is array(0 to 31) of word;
    signal reg: temp; --:= (others => X"00000000");

    begin

    process(clk)
    begin
        --Read1  (compiling w/ vhdl 2002 so no when/else statement)
        if rd_addr_1 = "00000" then
            d_out_1 <= x"00000000";
        else
            d_out_1 <= reg(to_integer(unsigned(rd_addr_1)));
        end if;
        --Read2
        if rd_addr_2 = "00000" then
            d_out_2 <= x"00000000";
        else
            d_out_2 <= reg(to_integer(unsigned(rd_addr_2)));
        end if;
        --Write
        if clk = '1' and clk'event then
            if (wr_en = '1' and wr_addr /= "00000") then
                reg(to_integer(unsigned(wr_addr))) <= d_in;
            end if;
        end if;
    end process;
end RF_arch;
