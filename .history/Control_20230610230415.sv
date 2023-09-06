// control decoder
module Control #(parameter opwidth = 3, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  output logic RegDst, Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  RegDst 	=   'b0;   // 1: not in place  just leave 0
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    =   'b1111; // y = a+0;
  opcode    = instr[8:6];
  funct = instr[5:4];
// sample values only -- use what you need
case(opcode)    // override defaults with exceptions
  'b000:  begin					// store operation
    if(funct == 0) ALUOp = 0;  // add
    if(funct == 1) ALUOp = 1;  // sub
    else begin /* Loading / storing logic */ end
  end
  'b001:  begin
    // lb
  end
  'b010:  begin
    // sb
  end
  'b011: ALUSrc = 'b1;
  'b100: Branch = 'b0;
  'b101: // move
  'b110: begin
    case(funct)
      'b00: ALUOp = 2;  // LSL
      'b01: ALUOp = 3;  // ASR
      'b10: ALUOp = 4;  // LSR
      'b11: ALUOp = 5;  // not
    endcase
  end
  'b111: begin
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