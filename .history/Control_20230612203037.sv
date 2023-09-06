// control decoder
module Control #(parameter opwidth = 4, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  input logic[7:0] datA, datB,
  output logic RegDst, Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite,
  output logic[3:0] regA, regB, wr_addr,
  output logic[7:0] dat_in,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  Mov       = 'b0;   // 1: for a mov type instruction
  ALUOp	    =   'b1111; // y = a+0;
  opcode    = instr[8:6];
  funct = instr[5:4];
  wr_addr = instr[3:0];
  // sample values only -- use what you need
  case(opcode)    // override defaults with exceptions
    'b000:  begin
      regA = 4'b0;
      regB = 4'b1;

      case(funct)
        'b00: ALUOp = 0;
        'b01: ALUOp = 1;
        'b10: MemToReg = 'b1;
        'b11: RegWrite = 'b0;
      endcase
    end
    // I type instructions
    'b001:  MemtoReg = 'b1;
    'b010:  RegWrite = 'b0;
    'b011: ALUSrc = 'b1;
    'b100: Branch = 'b1;  // Branch
    'b101: begin
      reg_a = instr[1:4]
      wr_addr = {3'b0, instr[5]}
      Move = 'b1;   // Move
    end
    // More R type instructions
    'b110: begin
      regA = 4'b0;
      regB = 4'b1;

      case(funct)
        'b00: ALUOp = 2;  // LSL
        'b01: ALUOp = 3;  // ASR
        'b10: ALUOp = 4;  // LSR
        'b11: ALUOp = 5;  // not
      endcase
    end
    'b111: begin
      regA = 4'b0;
      regB = 4'b1;

      case(funct)
        'b00: ALUOp = 6;  // and
        'b01: ALUOp = 7;  // or
        'b10: ALUOp = 8;  // mul
      endcase
    end
  // ...
  endcase

end
	
endmodule