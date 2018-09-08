--Jake Fulton
--51804736

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity datapath is
  
  port (
    clk        : in  std_logic;
    reset_N    : in  std_logic;
    
    PCUpdate   : in  std_logic;         -- write_enable of PC

    IorD       : in  std_logic;         -- Address selection for memory (PC vs. store address)
    MemRead    : in  std_logic;		-- read_enable for memory
    MemWrite   : in  std_logic;		-- write_enable for memory

    IRWrite    : in  std_logic;         -- write_enable for Instruction Register
    MemtoReg   : in  std_logic_vector(1 downto 0);  -- selects ALU or MEMORY or PC to write to register file.
    RegDst     : in  std_logic_vector(1 downto 0);  -- selects rt, rd, or "31" as destination of operation
    RegWrite   : in  std_logic;         -- Register File write-enable
    ALUSrcA    : in  std_logic;         -- selects source of A port of ALU
    ALUSrcB    : in  std_logic_vector(1 downto 0);  -- selects source of B port of ALU
    
    ALUControl : in  ALU_opcode;	-- receives ALU opcode from the controller
    PCSource   : in  std_logic_vector(1 downto 0);  -- selects source of PC

    opcode_out : out opcode;		-- send opcode to controller
    func_out   : out opcode;		-- send func field to controller
    zero       : out std_logic);	-- send zero to controller (cond. branch)

end datapath;


architecture datapath_arch of datapath is

-- component declaration
component RegFile
    port(
        clk         : in std_logic;
        wr_en       : in std_logic;
        rd_addr_1   : in REG_addr;
        rd_addr_2   : in REG_addr;
        wr_addr     : in REG_addr;
        d_in        : in word;
        d_out_1     : out word;
        d_out_2     : out word);
end component;

component ALU
    port(   op_code     : in ALU_opcode;
            in0, in1    : in word;
            C           : in std_logic_vector(4 downto 0);
            ALUout      : out word;
            Zero        : out std_logic
    );
end component;

component mem
    port(
        MemRead     : in std_logic;
        MemWrite    : in std_logic;
        d_in        : in word;
        address     : in word;
        d_out       : out word);
end component;
                                        
component IR
    port(   IRWrite, clk        : in std_logic;
            instruction         : in word;
            op                  : out opcode;
            rs, rt, rd          : out reg_addr;
            func                : out std_logic_vector(5 downto 0);
            i_type              : out offset;
            j_type              : out target;
            shamt               : out reg_addr
    );
end component;

component Reg32
    port(
        clk         : in std_logic;
        d_in        : in word;
        d_out       : out word);
end component;

component PC
    port(
        wr_en       : in std_logic;
        clk         : in std_logic;
        reset_N     : in std_logic;
        addr_in     : in word;
        addr_out    : out word);
end component;

component MUX_2
    port(
        sel         : in std_logic;
        A           : in word;
        B           : in word;
        D           : out word);
end component;

component MUX_4
    port(
        sel         : in std_logic_vector(1 downto 0);
        A           : in word;
        B           : in word;
        C           : in word;
        D           : in word;
        E           : out word);
end component;


component sign_extend
    port(
        d_in        : in offset;
        d_out       : out word);
end component;

component shiftleft26bits
    port(
        d_in        : in target;
        d_out       : out std_logic_vector(27 downto 0));
end component;

component shiftleft32bits
    port(
        d_in        : in word;
        d_out       : out word);
end component;

component MUX_4b
    port(
        sel         : in std_logic_vector(1 downto 0);
        A,B,C,D     : in reg_addr;
        E           : out reg_addr);
end component;

for PCunit: PC use entity work.PC (PC_arch);
for MUX1, MUX4: MUX_2 use entity work.MUX_2 (MUX_arch);
for MemUnit: mem use entity work.mem (mem_arch);
for MDR, ALUregister: Reg32 use entity work.Reg32 (Reg32_arch);
for InstReg: IR use entity work.IR (IR_arch);
for MUX2: MUX_4b use entity work.MUX_4b (MUX_arch);
for MUX3, MUX5, MUX6: MUX_4 use entity work.MUX_4 (MUX_arch);
for Registers: RegFile use entity work.RegFile (RF_arch);
for SignExt: sign_extend use entity work.sign_extend (sign_extend_arch);
for Shift_r1: shiftleft32bits use entity work.shiftleft32bits (shiftleft32bits_arch);
for ALUunit: ALU use entity work.ALU (ALU_arch);
for Shift_r2: shiftleft26bits use entity work.shiftleft26bits (shiftleft26bits_arch);

-- signal declaration
signal PCout: word;
signal PCin: word;
signal ALUout: word;
signal Mem_addr: word;
signal Memout: word;
signal Memdata: word;
signal opcode_temp: opcode;
signal func_temp: opcode;
signal rs, rt, rd: reg_addr;
signal i_inst: offset;
signal j_inst: target;
signal wr_addr: reg_addr;
signal wr_data: word;
signal reg_outA: word;
signal reg_outB: word;
signal zero_temp: std_logic;
signal ALU_in0: word;
signal ALU_in1: word;
signal imm_ext: word;
signal i_offset: word;
signal C: std_logic_vector(4 downto 0):= "00000";
signal ALUreg: word;
signal j_shift: std_logic_vector(27 downto 0);
signal j_jump: word;
signal shamt: reg_addr;

begin
    opcode_out <= opcode_temp;
    func_out <= func_temp;
    zero <= zero_temp;

    j_jump(27 downto 0) <= j_shift(27 downto 0);
    j_jump(31 downto 28) <= PCout(31 downto 28);

    PCunit: PC port map(PCUpdate, clk, reset_N, PCin, PCout);
    MUX1: MUX_2 port map(IorD, ALUreg, PCout, Mem_addr);
    MemUnit: mem port map(MemRead, MemWrite, reg_outB, Mem_addr, Memout);
    MDR: Reg32 port map(clk, Memout, Memdata);
    InstReg: IR port map(IRWrite, clk, Memout, opcode_temp, rs,rt, rd, func_temp, i_inst, j_inst,shamt);
    MUX2: MUX_4b port map(RegDst, rt, rd, "11111", "00000", wr_addr);
    MUX3: MUX_4 port map(MemtoReg, ALUreg, Memdata, PCout, x"00000000", wr_data);
    Registers: RegFile port map(clk, RegWrite, rs, rt, wr_addr, wr_data, reg_outA, reg_outB);
    MUX4: MUX_2 port map(ALUsrcA, reg_outA, PCout, ALU_in0);
    SignExt: sign_extend port map(i_inst, imm_ext);
    Shift_r1: shiftleft32bits port map(imm_ext, i_offset);
    MUX5: MUX_4 port map(ALUSrcB, reg_outB, x"00000004", imm_ext, i_offset, ALU_in1);
    ALUunit: ALU port map(ALUControl, ALU_in0, ALU_in1, shamt, ALUout, zero_temp);
    ALUregister: Reg32 port map(clk, ALUout, ALUreg);
    Shift_r2: shiftleft26bits port map(j_inst, j_shift);
    MUX6: MUX_4 port map(PCSource, ALUout, ALUreg, j_jump, x"00000000", PCin);

end datapath_arch;
