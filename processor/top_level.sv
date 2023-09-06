`include "instr_ROM.sv"
`include "alu_LUT.sv"
`include "Control.sv"
`include "mem_LUT.sv"
`include "PC_LUT.sv"
`include "dat_mem.sv"
`include "alu.sv"
`include "reg_file.sv"
`include "PC.sv"

module top_level(
  input        clk, reset, 
  output logic done);
  parameter D = 10,             // program counter width
    A = 4;             		  // ALU command bit width
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire        RegWrite;
  wire[3:0]   regA,regB,wr_reg;
  wire[7:0]   datA,datB,dat_in,		  // from RegFile
              muxALU, mem_lut_out, alu_lut_out,
			  rslt,               // alu output
        mem_in,
        mem_out, mem_addr;
  wire[4:0] immed;
  wire[3:0] pc_immed;
  wire        mov;
  logic sc_in, sc_o,   				  // shift/carry out from/to ALU
   		pariQ;
	wire pari_clr, pari_en;              	  // registered parity flag from ALU
  // wire  relj;                     // from control to PC; relative jump enable
  wire absj;
  wire  pari,
		sc_clr,
		sc_en,
        MemWrite,
        MemtoReg,
        ALUSrc;		              // immediate switch
  wire[A-1:0] alu_cmd;
  wire[8:0]   mach_code;          // machine code
  
  initial begin
    sc_in = 'b0;
    pariQ = 'b0;
  end

  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk              ,
		 // .reljump_en (relj),
		 .absjump_en (absj),
		 .target           ,
		 .prog_ctr          );

     // contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

  PC_LUT #(.D(D)) pc_lut (
    .addr  (pc_immed),
    .target          
  );

     // control decoder
  Control #(.opwidth(4)) ctl1(
    .instr(mach_code),
    .datA,
    .datB,
    .mem_out,
    .mem_lut_out,
    .Branch  (absj)  , 
    .MemtoReg(MemtoReg),
    .MemWrite , 
    .ALUSrc   , 
    .RegWrite   ,
    .regA,
    .regB,
    .wr_addr(wr_reg),
    .dat_in,
    .mem_in,
    .mem_addr,
    .immed,
    .pc_immed,
    .alu_rslt(rslt),
    .ALUOp(alu_cmd)
  );
  
  reg_file rf1(
    .dat_in,	   
    .clk         ,
    .wr_en   (RegWrite),      // loads, most ops
    .rd_addrA(regA),
    .rd_addrB(regB),
    .wr_addr (wr_reg),
    .datA_out(datA),
    .datB_out(datB)
  ); 

  mem_LUT mem_lut(
    .address(immed),
    .data(mem_lut_out)
  );

  alu_LUT alu_lut(
    .address(immed),
    .data(alu_lut_out)
  );

  // assign rd_addrA = mach_code[2:0];
  // assign rd_addrB = mach_code[5:3];
  // assign rd_addr_out = mach_code[3:0];
  // assign muxMov = 0;
  assign muxALU = ALUSrc ? alu_lut_out : datB;
  // assign muxMem = MemSrc ? immed_mem : datA;

  alu alu1(
     .alu_cmd,
     .inA    (datA),
		 .inB    (muxALU),
		 .sc_i   (sc_in),   // output from sc register
     .pari_in(pariQ),
		 .rslt       ,
		 .sc_o, // input to sc register
     .sc_clr,
     .sc_en,
		 .pari,
     .pari_clr,
     .pari_en
  );  

  dat_mem dm1(.dat_in(mem_in)  ,  // from reg_file
    .clk           ,
    .wr_en  (MemWrite), // stores
    .addr   (mem_addr),
    .dat_out(mem_out)
  );

// registered flags from ALU
  always @(posedge clk) begin
    // if(prog_ctr == 42) $display("%d %d %d %d", prog_ctr, datA, muxALU, rslt);
    if(sc_clr)
	    sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_o;
    if(pari_clr)
      pariQ <= 'b0;
    else if(pari_en)
      pariQ <= pari;
  end

  // assign done = prog_ctr == 83;        // Program 1
  // assign done = prog_ctr == 131;       // Program 2
  assign done = prog_ctr == 113;       // Program 3
 
endmodule