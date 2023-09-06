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
  ALUOp	    =   'b111; // y = a+0;
  opcode    = instr[8:6]
// sample values only -- use what you need
case(opcode)    // override defaults with exceptions
  'b000:  begin					// store operation
    if(instr[5:4] == 0) ALUOp = 0
    if(instr[5:4] == 1) ALUOp = 1
    else begin /* Loading / storing logic */ end
  end
  'b001:  begin
    ALUSrc = 'b1
  end
// ...
endcase

end
	
endmodule