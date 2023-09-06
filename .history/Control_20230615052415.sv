// control decoder
module Control #(parameter opwidth = 4, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  input logic[7:0] datA, datB, mem_out, mem_lut_out, alu_rslt,
  output logic Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite, MemSrc, done,
  output logic[3:0] regA, regB, wr_addr,
  output logic[4:0] immed,
  output logic[3:0] pc_immed,
  output logic[7:0] dat_in, mem_in, mem_addr,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations
  
logic [2:0] opcode;
logic [1:0] funct;

always_comb begin
// defaults
  dat_in    =   8'b0;
  pc_immed  =   instr[3:0];
  mem_addr  =   8'b0;
  mem_in		=   8'b0;
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  MemSrc  = 'b0;   // 1: immediate  0: read / write from R0
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  done      = 'b0;
  ALUOp	    =   'b1111; // y = a+0;
  regA      = 4'b0;
  regB      = 4'b1;
  opcode    = instr[8:6];
  funct     = instr[5:4];
  wr_addr   = instr[3:0];
  immed     = instr[5:1];
  // sample values only -- use what you need
  case(opcode)    // override defaults with exceptions
    'b000:  begin
      dat_in = alu_rslt;

      case(funct)
        'b00: ALUOp = 0;
        'b01: ALUOp = 1;
        'b10: begin
          mem_addr = datA;
          dat_in   = mem_out;
          MemtoReg = 'b1;
        end
        'b11: begin
          regB     = wr_addr;
          mem_addr = datA;
          mem_in   = datB;
          RegWrite = 'b0;
        end
      endcase
    end
    // I type instructions
    'b001: begin         // lb
      mem_addr = mem_lut_out;
      dat_in = mem_out;
      wr_addr = {3'b0, instr[0]};
      MemSrc = 'b1;
      MemtoReg = 'b1;
    end
    'b010: begin         // subi
      ALUOp = 1;
      dat_in = alu_rslt;
      wr_addr = 4'b1;
      ALUSrc = 'b1;
    end
    'b011: begin         // addi
      ALUOp = 0;
      dat_in = alu_rslt;
      wr_addr = 4'b1;
      ALUSrc = 'b1;
    end
    // B type instructions
    'b100: begin
      case(funct)
        'b00: if(datA == datB) Branch = 'b1;      // beq
        'b01: if(datA != datB) Branch = 'b1;      // bne
        'b10: if(datA < datB)  Branch = 'b1;      // blt
        'b11: if(datA <= datB) Branch = 'b1;      // ble
      endcase
    end
    // Move
    'b101: begin
      case(instr[5])
        'b0: begin
          regA = instr[3:0];
          wr_addr = {3'b0, instr[4]};
        end
        'b1: begin
          regA = {3'b0, instr[0]};
          wr_addr = instr[4:1];
        end
      endcase
      
      dat_in = datA;
    end
    // More R type instructions
    'b110: begin
      dat_in = alu_rslt;

      case(funct)
        'b00: ALUOp = 2;  // LSL
        'b01: ALUOp = 3;  // ASR
        'b10: ALUOp = 4;  // LSR
        'b11: ALUOp = 5;  // not
      endcase
    end
    'b111: begin
      dat_in = alu_rslt;

      case(funct)
        'b00: ALUOp = 6;  // and
        'b01: ALUOp = 7;  // xor
        'b10: ALUOp = 8;  // rxor
        'b11: done = 'b1; // exit
      endcase
    end
  endcase

end
	
endmodule