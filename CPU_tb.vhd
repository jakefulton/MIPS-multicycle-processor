-- Jake Fulton
-- 51804736

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity CPU_tb is
end CPU_tb;

architecture CPU_test of CPU_tb is
    
    component CPU
        port(
            clk     : in std_logic;
            reset_N : in std_logic );
    end component;

signal clk: std_logic:= '0';
signal reset_N: std_logic:= '1';

for u0: CPU use entity work.CPU (CPU_arch);

begin
    clk <= not clk after CLK_PERIOD/2;
    u0: CPU PORT MAP (clk, reset_N);

    process begin
        wait for 21 ns;
        reset_N <= '0';
        wait for 20 ns;
        reset_N <= '1';
        wait;
    end process;

end CPU_test;
