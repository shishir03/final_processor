# hamming-9bit-processor

This is a 9-bit processor I designed and built for the spring 2023 quarter of CSE 141L at UCSD. It is optimized for Hamming code error correction. The general design was inspired by [this 9-bit processor](https://github.com/yehzhang/x9).

## Instruction Set

Instruction | Type | What it does | Usage | Opcode | Funct | Notes
----------- | ---- | ------------ | ----- | ------ | ----- | -----
add | R | {sc<sub>o</sub>, R[rd]} = R[0] + R[1] + sc<sub>i</sub> | add rd | 000 | 00 | Clears parity bit
sub | R | {sc<sub>o</sub>, R[rd]} = R[0] - R[1] + sc<sub>i</sub> | sub rd | 000 | 01 | Clears parity bit
lbr | R | R[rd] = Mem[R[0]] | lbr rd | 000 | 10
sbr | R | Mem[R[0]] = R[rd] | sbr rd | 000 | 11
lb | I | R[rt] = Mem[mem_lut[imm]] | lb rt, imm | 001 | - | rt can be either r0 or r1
subi | I | {sc<sub>o</sub>, R[rt]} = R[0] - Mem[alu_lut[imm]] + sc<sub>i</sub> | subi rt, imm | 010 | - | rt can be either r0 or r1; clears parity bit
addi | I | {sc<sub>o</sub>, R[rt]} = R[0] - Mem[alu_lut[imm]] + sc<sub>i</sub> | addi rt, imm | 011 | - | rt can be either r0 or r1; clears parity bit
beq | B | if (R[0] == R[1]) pc = PC_lut[imm] | beq imm | 100 | 00
bne | B | if (R[0] != R[1]) pc = PC_lut[imm] | bne imm | 100 | 01
blt | B | if (R[0] < R[1]) pc = PC_lut[imm]  | blt imm | 100 | 10
ble | B | if (R[0] <= R[1]) pc = PC_lut[imm] | bne imm | 100 | 11
mov | M | R[rt] = R[rs] | mov rt, rs | 101 | 0 | rt can be either r0 or r1, while rs can be any register
mov | M | R[rs] = R[rt] | mov rt, rs | 101 | 1 | rt can be either r0 or r1, while rs can be any register
lsl | R | {sc<sub>o</sub>, R[rd]} = {R[0], sc<sub>i</sub>} | lsl rd | 110 | 00 | Clears parity bit
asr | R | {R[rd], sc<sub>o</sub>} = {R[0][7], R[0]} | asr rd | 110 | 01 | Clears parity bit
lsr | R | {R[rd], sc<sub>o</sub>} = {sc<sub>i</sub>, R[0]} | lsr rd | 110 | 10 | Clears parity bit
not | R | R[rd] = !R[0] | not rd | 110 | 11 | Clears carry bit
and | R | R[rd] = R[0] & R[1] | and rd | 111 | 00 | Clears carry bit
xor | R | R[rd] = R[0] ^ R[1] | xor rd | 111 | 01 | Clears carry bit
rxor | R | R[rd] = ^R[0] ^ pari | rxor rd | 111 | 10 | Modifies parity bit
or | R | R[rd] = R[0] \| R[1] | or rd | 111 | 11 | Clears carry bit