library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Glob_dcls.all;

entity IR is 
  port( IRWrite, clk     : in std_logic;
        instruction      : in word;
        op               : out opcode;
        rs, rt, rd       : out reg_addr;
        func             : out opcode;
        i_type           : out offset;
        j_type           : out target;
        shamt            : out reg_addr
       
  );
end IR;

architecture IR_arch of IR is
    signal op_buf: opcode;
    signal rs_buf, rt_buf, rd_buf: reg_addr;
    signal func_buf: std_logic_vector(5 downto 0);
    signal i_type_buf: offset;
    signal j_type_buf: target;
    signal shamt_buf: std_logic_vector(4 downto 0);
    
    begin
        op <= op_buf;
        rs <= rs_buf;
        rt <= rt_buf;
        rd <= rd_buf;
        func <= func_buf;
        i_type <= i_type_buf;
        j_type <= j_type_buf;
        shamt <= shamt_buf;

        process(clk)
        begin
        if (IRWrite = '1' and clk = '1' and clk'event) then
            op_buf <= instruction(31 downto 26);
            rs_buf <= instruction(25 downto 21);
            rt_buf <= instruction(20 downto 16);
            rd_buf <= instruction(15 downto 11);
            func_buf <= instruction(5 downto 0);
            shamt_buf <= instruction(10 downto 6);
            i_type_buf <= instruction(15 downto 0);
            j_type_buf <= instruction(25 downto 0);
        end if;
        end process;
end IR_arch;
