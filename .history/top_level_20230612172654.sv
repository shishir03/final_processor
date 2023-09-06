// sample top level design
module top_level(
  input        clk, reset, req, 
  output logic done);
  parameter D = 12,             // program counter width
    A = 3;             		  // ALU command bit width
  wire[D-1:0] target, 			  // jump 
              prog_ctr;
  wire        RegWrite;
  wire[3:0]   regA,regB,wr_reg;
  wire[7:0]   datA,datB,		  // from RegFile
              muxB, 
			  rslt,               // alu output
        mem_out,
              immed;
  wire        mov;
  logic sc_in,   				  // shift/carry out from/to ALU
   		pariQ,              	  // registered parity flag from ALU
		zeroQ;                    // registered zero flag from ALU 
  wire  relj;                     // from control to PC; relative jump enable
  wire  pari,
        zero,
		sc_clr,
		sc_en,
        MemWrite,
        MemtoReg,
        ALUSrc;		              // immediate switch
  wire[A-1:0] alu_cmd;
  wire[8:0]   mach_code;          // machine code
  wire[2:0] rd_addrA, rd_adrB;    // address pointers to reg_file
// fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk              ,
		 .reljump_en (relj),
		 .absjump_en (absj),
		 .target           ,
		 .prog_ctr          );

// lookup table to facilitate jumps/branches
  PC_LUT #(.D(D))
    pl1 (.addr  (how_high),
         .target          );   

// contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

// control decoder
  Control #(.opwidth(4)) ctl1(.instr(mach_code),
  .Branch  (relj)  , 
  .MemWrite , 
  .ALUSrc   , 
  .RegWrite   ,     
  .regA,
  .regB,
  .dat_in,
  .wr_addr(wr_reg),
  .MemtoReg(MemtoReg),
  .Mov  (mov),
  .ALUOp(alu_cmd));

  // assign rd_addrA = mach_code[2:0];
  // assign rd_addrB = mach_code[5:3];
  // assign rd_addr_out = mach_code[3:0];
  assign muxMov = 0;
  assign muxB = ALUSrc ? immed : datB;

  alu alu1(.alu_cmd,
         .inA    (datA),
		 .inB    (muxB),
		 .sc_i   (sc),   // output from sc register
		 .rslt       ,
		 .sc_o   (sc_o), // input to sc register
		 .pari  );  

  dat_mem dm1(.dat_in(datB)  ,  // from reg_file
             .clk           ,
			 .wr_en  (MemWrite), // stores
			 .addr   (datA),
             .dat_out(mem_out));

  assign regfile_dat = MemtoReg ? mem_out : rslt;

  reg_file rf1(.dat_in(regfile_dat),	   
  .clk         ,
  .wr_en   (RegWrite),      // loads, most ops
  .rd_addrA(regA),
  .rd_addrB(regB),
  .wr_addr (wr_reg),      // in place operation
  .datA_out(datA),
  .datB_out(datB)); 

// registered flags from ALU
  always_ff @(posedge clk) begin
    pariQ <= pari;
	zeroQ <= zero;
    if(sc_clr)
	  sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_o;
  end

  assign done = prog_ctr == 128;
 
endmodule