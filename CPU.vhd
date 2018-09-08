-- Jake Fulton
-- 51804736

LIBRARY IEEE; 
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_unsigned.all;
USE work.Glob_dcls.all;

entity CPU is
  
  port (
    clk     : in std_logic;
    reset_N : in std_logic);            -- active-low signal for reset

end CPU;

architecture CPU_arch of CPU is

    component datapath
        port(
            clk         : in std_logic;
            reset_N     : in std_logic;
            PCUpdate    : in std_logic;
            IorD        : in std_logic;
            MemRead     : in std_logic;
            MemWrite    : in std_logic;
            IRWrite     : in std_logic;
            MemtoReg    : in std_logic_vector(1 downto 0);
            RegDst      : in std_logic_vector(1 downto 0);
            RegWrite    : in std_logic;
            ALUSrcA     : in std_logic;
            ALUSrcB     : in std_logic_vector(1 downto 0);
            ALUcontrol  : in ALU_opcode;
            PCSource    : in std_logic_vector(1 downto 0);
            opcode_out  : out opcode;
            func_out    : out opcode;
            zero        : out std_logic );
    end component;

    component control
        port(
            clk         : in std_logic;
            reset_N     : in std_logic;
            opcode_in   : in opcode;
            funct       : in opcode;
            zero        : in std_logic;
            PCUpdate    : out std_logic;
            IorD        : out std_logic;
            MemRead     : out std_logic;
            MemWrite    : out std_logic;
            IRWrite     : out std_logic;
            MemtoReg    : out std_logic_vector(1 downto 0);
            RegDst      : out std_logic_vector(1 downto 0);
            RegWrite    : out std_logic;
            ALUSrcA     : out std_logic;
            ALUSrcB     : out std_logic_vector(1 downto 0);
            ALUcontrol  : out ALU_opcode;
            PCSource    : out std_logic_vector(1 downto 0) );
    end component;

    for d_path: datapath use entity work.datapath (datapath_arch);
    for controller: control use entity work.control (control_arch);
    
    signal opcode_inst : opcode;
    signal funct       : opcode;
    signal zero        : std_logic;
    signal PCUpdate    : std_logic;
    signal IorD        : std_logic;
    signal MemRead     : std_logic;
    signal MemWrite    : std_logic;
    signal IRWrite     : std_logic;
    signal MemtoReg    : std_logic_vector(1 downto 0);
    signal RegDst      : std_logic_vector(1 downto 0);
    signal RegWrite    : std_logic;
    signal ALUSrcA     : std_logic;
    signal ALUSrcB     : std_logic_vector(1 downto 0);
    signal ALUcontrol  : ALU_opcode;
    signal PCSource    : std_logic_vector(1 downto 0);


begin
d_path: datapath port map (clk, reset_N, PCUpdate, IorD, MemRead, MemWrite,
                            IRWrite, MemtoReg, RegDst, RegWrite, ALUSrcA, ALUSrcB,
                            ALUControl, PCSource, opcode_inst, funct, zero);
controller: control port map (clk, reset_N, opcode_inst, funct, zero, PCUpdate, IorD, MemRead,
                            MemWrite, IRWrite, MemtoReg, RegDst, RegWrite, ALUSrcA,
                            ALUSrcB, ALUcontrol, PCSource);
end CPU_arch;
