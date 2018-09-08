-- Jake Fulton
-- 51804736

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity control is 
   port(
        clk   	    : IN STD_LOGIC; 
        reset_N	    : IN STD_LOGIC; 
        
        opcode_in   : IN opcode;     -- declare type for the 6 most significant bits of IR
        funct       : IN opcode;     -- declare type for the 6 least significant bits of IR 
     	zero        : IN STD_LOGIC;
        
     	PCUpdate    : OUT STD_LOGIC; -- this signal controls whether PC is updated or not
     	IorD        : OUT STD_LOGIC;
     	MemRead     : OUT STD_LOGIC;
     	MemWrite    : OUT STD_LOGIC;

     	IRWrite     : OUT STD_LOGIC;
     	MemtoReg    : OUT STD_LOGIC_VECTOR (1 downto 0); -- the extra bit is for JAL
     	RegDst      : OUT STD_LOGIC_VECTOR (1 downto 0); -- the extra bit is for JAL
     	RegWrite    : OUT STD_LOGIC;
     	ALUSrcA     : OUT STD_LOGIC;
     	ALUSrcB     : OUT STD_LOGIC_VECTOR (1 downto 0);
     	ALUcontrol  : OUT ALU_opcode;
     	PCSource    : OUT STD_LOGIC_VECTOR (1 downto 0)
	);
end control;

architecture control_arch of control is

--Create different states for FSM
type T_State is (   ifetch, decode,
                    r_ex, r_wb,
                    imm_ex, i_wb,
                    addr_comp, lw_mem, sw_mem, lw_wb,
                    beq, bne,
                    jump );
signal cur_state, nxtstate: T_State;

--Create buffer values
signal PCUpdate_buf    : STD_LOGIC;
signal IorD_buf        : STD_LOGIC;
signal MemRead_buf     : STD_LOGIC;
signal MemWrite_buf    : STD_LOGIC;
signal IRWrite_buf     : STD_LOGIC;
signal MemtoReg_buf    : STD_LOGIC_VECTOR (1 downto 0);
signal RegDst_buf      : STD_LOGIC_VECTOR (1 downto 0);
signal RegWrite_buf    : STD_LOGIC;
signal ALUSrcA_buf     : STD_LOGIC;
signal ALUSrcB_buf     : STD_LOGIC_VECTOR (1 downto 0);
signal ALUcontrol_buf  : ALU_opcode;
signal PCSource_buf    : STD_LOGIC_VECTOR (1 downto 0);
signal ALUop           : std_logic_vector (2 downto 0);

begin

--Assign buffer signals to output
    PCUpdate <= PCUpdate_buf;
    IorD <= IorD_buf;
    MemRead <= MemRead_buf;
    MemWrite <= MemWrite_buf;
    IRWrite <= IRWrite_buf;
    MemtoReg <= MemtoReg_buf;
    RegDst <= RegDst_buf;
    RegWrite <= RegWrite_buf;
    ALUSrcA <= ALUSrcA_buf;
    ALUSrcB <= ALUSrcB_buf;
    ALUcontrol <= ALUcontrol_buf;
    PCSource <= PCSource_buf;

--Update Current state every clock cycle or when reset
    process(clk, reset_N)
    begin
        if reset_N = '0' then
            cur_state <= ifetch;
        end if;
        if clk'event and clk = '1' and reset_N <= '1' then
                cur_state <= nxtstate;
        end if;
    end process;
    
--ALU Control: determines what operation ALU does
    --ALUcontrol <= f(ALUop, funct)
    ALUcontrol_buf(2) <= ( ( not(ALUop(2)) and ALUop(1) and not(ALUop(0)) ) and ( funct(2)
            or funct(0) ) ) or ( ALUop(2) and not(ALUop(1)) and ALUop(0) )
            or ( ALUop(2) and ALUop(1) and not(ALUop(0)) );
    ALUControl_buf(1) <= ( ( not(ALUop(2)) and ALUop(1) and not(ALUop(0)) ) and ( not(funct(5)) ) );
    ALUControl_buf(0) <= ( (( not(ALUop(2)) and ALUop(1) and not(ALUop(0)) ) and 
            ( funct(0) or funct(1) ) ) or ( not(ALUop(2)) and ALUop(1) and ALUop(0) )
            or ( ALUop(2) and ALUop(1) and not(ALUop(0)) ) or ( not(ALUop(2)) and not(ALUop(1))
            and ALUop(0) ) );

--Datapath inputs are determined based upon the next state
    process(nxtstate,clk)
    begin
        case(nxtstate) is
            when ifetch =>
                MemRead_buf <= '1'; --Instruction to be read from Memory
                IorD_buf <= '0'; --Memory address comes from PC
                IRWrite_buf <= '1'; --IR reg to be updated with instruction
                ALUSrcA_buf <= '0'; --Sets ALUSrcA to PC
                ALUSrcB_buf <= "01"; --Sets ALUSrcB to 4
                ALUop <= "000"; --ALU operation is addition
                PCSource_buf <= "00"; --PC register input comes directly from ALU
                PCUpdate_buf <= '1'; --PC register is updated with PC+4
                RegWrite_buf <= '0';
            when decode =>
                ALUop <= "000"; --ALU operation is addition
                ALUSrcA_buf <= '0'; --ALUSrcA comes from PC
                ALUSrcB_buf <= "11"; --ALUSrcB is sign_extend(IR[15-0]) << 2
                PCUpdate_buf <= '0'; --PC register should not change
                IRWrite_buf <= '0'; --IR reg should not change until instruction is done
            when r_ex =>
                ALUSrcA_buf <= '1'; --ALUSrcA comes from RegFile[rs]
                ALUSrcB_buf <= "00"; --ALUSrcB comes from RegFile[rt]
                ALUop <= "010"; --ALUop is set for R-type operations
            when r_wb =>
                RegDst_buf <= "01"; --Regfile write address is rd
                RegWrite_buf <= '1'; --Allow Regfile update
                MemtoReg_buf <= "00"; --Regfile write data comes from ALUout register
                MemRead_buf <= '0';
            when imm_ex =>
                ALUSrcA_buf <= '1'; --ALUSrcA comes from RegFile[rs] 
                ALUSrcB_buf <= "10"; --ALUSrB comes from IR[15-0]
                ALUop(2) <= '1'; --ALU operation depends on type of i imm instruction
                ALUop(1) <= opcode_in(0);
                ALUop(0) <= opcode_in(2) and not(opcode_in(0));
            when i_wb =>
                RegDst_buf <= "00"; --Regfile write address is rt
                RegWrite_buf <= '1'; --Allows RegFile to be updated
                MemtoReg_buf <= "00"; --RegFile write data comes from ALUout register
                MemRead_buf <= '0';
            when addr_comp =>
                ALUSrcA_buf <= '1'; --ALUSrcA comes from RegFile[rs]
                ALUSrcB_buf <= "10"; --ALUSrcB is sign_extend(IR[15-0])
                ALUop <= "000"; --ALU operation is addition
                MemRead_buf <= '0';
                MemWrite_buf <= '0';
            when lw_mem =>
                IorD_buf <= '1'; --Memory address comes from ALUout
                MemRead_buf <= '1'; --Allows read from memory[ALUout]
            when sw_mem =>
                IorD_buf <= '1'; --Memory address comes from ALUout
                MemWrite_buf <= '1'; --Allows RegFile[rt] to be written to Memory[ALUout]
            when lw_wb =>
                MemtoReg_buf <= "01"; --Regfile write data comes from MDR register
                RegDst_buf <= "00"; --RegFile write address is rt
                RegWrite_buf <= '1'; --Allows RegFile to be updated
                MemRead_buf <= '0';
            when beq =>
                ALUSrcA_buf <= '1'; --ALUSrcA comes from Regfile[rs]
                ALUSrcB_buf <= "00"; --ALUSrcB comes from RegFile[rt]
                ALUop <= "001"; --Set ALU operation to subtraction
                PCSource_buf <= "01"; --PC register input comes from ALUout
                if (zero = '1') then
                    PCUpdate_buf <= '1'; --Allow PC update if ALU inputs are equal
                end if;
                MemRead_buf <= '0';
            when bne =>
                ALUSrcA_buf <= '1'; --ALUSrcA comes from RegFile[rs[
                ALUSrcB_buf <= "00"; --ALUSrB comes from RegFile[rt]
                ALUop <= "011";
                PCSource_buf <= "01"; --PC register input comes from ALUout
                if (zero = '0') then
                    PCUpdate_buf <= '1'; --Allow PC update if ALU inputs are not equal
                end if;
                MemRead_buf <= '0';
            when jump =>
                PCSource_buf <= "10"; --PC register input comes from PC[31-28] || (IR[25-0]<<2)
                PCUpdate_buf <= '1'; --Allows PC register update
                MemRead_buf <= '0';
        end case;
    end process;

--Next state is updated whenever the current state changes
    process(cur_state,clk)
    begin
        case(cur_state) is
            when ifetch =>
                if reset_N /= '0' then
                    nxtstate <= decode;
                else
                    nxtstate <= ifetch;
                end if;
            when decode =>
                if opcode_in = "000000" then
                    nxtstate <= r_ex;
                elsif opcode_in(5) = '1' then
                    nxtstate <= addr_comp;
                elsif opcode_in(3) = '1' and opcode_in(1) = '0' then
                    nxtstate <= imm_ex;
                elsif opcode_in = "000010" then
                    nxtstate <= jump;
                elsif opcode_in(2) = '1' and opcode_in(3) = '0' then
                    if opcode_in(0) = '1' then
                        nxtstate <= bne;
                    else
                        nxtstate <= beq;
                    end if;
                end if;
            when r_ex =>
                nxtstate <= r_wb;
            when r_wb =>
                nxtstate <= ifetch;
            when imm_ex =>
                nxtstate <= i_wb;
            when i_wb =>
                nxtstate <= ifetch;
            when addr_comp =>
                if opcode_in(3) = '1' then
                    nxtstate <= sw_mem;
                else
                    nxtstate <= lw_mem;
                end if;
            when sw_mem =>
                nxtstate <= ifetch;
            when lw_mem =>
                nxtstate <= lw_wb;
            when lw_wb =>
                nxtstate <= ifetch;
            when beq =>
                nxtstate <= ifetch;
            when bne =>
                nxtstate <= ifetch;
            when jump =>
                nxtstate <= ifetch;
        end case;
    end process;

end control_arch;



