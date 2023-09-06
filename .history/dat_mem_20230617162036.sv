// 8-bit wide, 256-word (byte) deep memory array
module dat_mem (
  input[7:0] dat_in,
  input      clk,
  input      wr_en,	          // write enable
  input[7:0] addr,		      // address pointer
  output logic[7:0] dat_out);

  logic[7:0] core[256];       // 2-dim array  8 wide  256 deep

  initial begin
    // bit masks
    core[60] = 8'b00010000;
    core[61] = 8'b11100000;
    core[62] = 8'b11110000;
    core[63] = 8'b11001100;
    core[64] = 8'b10101010;
    core[65] = 30;
    core[66] = 8'b10000000;
    core[67] = 16;
    core[68] = 0;
    core[69] = 8'b11111111; // nice
    core[70] = 8'b00001000;
    core[71] = 8'b01000000;
    core[72] = 8'b11111000;
    core[73] = 8'b00000001;
    core[74] = 8;
    core[75] = 60;
    core[76] = 15;
  end

// reads are combinational; no enable or clock required
  assign dat_out = core[addr];

// writes are sequential (clocked) -- occur on stores or pushes 
  always @(posedge clk)
    if(wr_en)				  // wr_en usually = 0; = 1 		
      core[addr] <= dat_in; 

endmodule