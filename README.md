# MIPS-multicycle-processor

MIPS multi-cycle 32-bit VHDL implementation.

Implements a subset of MIPS architecture.

One memory is responsible for holding both data and instruction memory.

## Instruction Format:
3 instruction formats: R-Type, I-Type, and J-Type.
<table>
  <tr>
    <td>Type</td>
    <td>31-26</td>
    <td>25-21</td>
    <td>20-16</td>
    <td>15-11</td>
    <td>10-06</td>
    <td>05-00</td>
  </tr>
  <tr>
    <td>R-Type</td>
    <td>opcode</td>
    <td>rs</td>
    <td>rt</td>
    <td>rd</td>
    <td>shamt</td>
    <td>funct</td>
  </tr>
  <tr>
    <td>I-Type</td>
    <td>opcode</td>
    <td>rs</td>
    <td>rt</td>
    <td colspan="3">imm</td>
  <tr>
    <td>J-Type</td>
    <td>opcode</td>
    <td colspan="5">address</td>
  </tr>
</table>

## Supported Instructions:
#### R-type Instructions:
  | Instruction | RTL |
  |-------------|-----|
  | add | R[rd] <- R[rs] + R[rt] |
  | sub | R[rd] <- R[rs] - R[rt] |
  | and | R[rd] <- R[rs] & R[rt] |
  | or | R[rd] <- R[rs] | R[rt] |
  | sll | R[rd] <- R[rt] << shamt |
  | srl | R[rd] <- R[rt] >> shamt |
#### I-Type Instructions:
  | Instruction | RTL |
  |-------------|-----|
  | beq | if (R[rs] = R[rt])<br/>PC <- PC + 4 + SignExt({imm,00}) |
  | bne | if (R[rs] != R[rt])<br/>PC <- PC + 4 + SignExt({imm,00}) |
  | addi | R[rt] <- R[rs] + SignExt(imm) |
  | andi | R[rt] <- R[rs] & {0x16,imm} |
  | ori | R[rt] <- R[rs] | {0x16,imm} |
  | lw | R[rt] <= Mem(R[rs] + SignExt(imm)) |
  | sw | Mem(R[rs] + SignExt(imm)) <- R[rt] |
#### J-Type Instructions:
  | Instruction | RTL |
  |-------------|-----|
  | j | PC <- {(PC + 4)[31:28], address, 00} |

## Modelsim

Modelsim was used for simulation.
```
module load altera/modelsim/15.1
cd ["work" directory]
vsim
```
When in Modelsim
1. Create a new project (or open an existing one)
2. Import design files (if creating a new project)
3. Compile design files
4. Load simulation
5. Add variables which you want to track to wave
6. Run simulation

