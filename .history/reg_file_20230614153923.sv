// cache memory/register file
// default address pointer width = 4, for 16 registers
module reg_file #(parameter pw=4)(
  input[7:0] dat_in,
  input      clk,
  input      wr_en,           // write enable
  input[pw:0] wr_addr,		  // write address pointer
              rd_addrA,		  // read address pointers
			  rd_addrB,
  output logic[7:0] datA_out, // read data
                    datB_out);

  logic[7:0] core[2**pw];    // 2-dim array  8 wide  16 deep

  initial begin
	core[0] = 8'b0;
	core[1] = 8'b0;
	core[2] = 8'b0;
	core[3] = 8'b0;
	core[4] = 8'b0;
	core[5] = 8'b0;
	core[6] = 8'b0;
	core[7] = 8'b0;
	core[8] = 8'b0;
	core[9] = 8'b0;
	core[10] = 8'b0;
	core[11] = 8'b0;
	core[12] = 8'b0;
	core[13] = 8'b0;
	core[14] = 8'b0;
	core[15] = 8'b0;
  end

// reads are combinational
  assign datA_out = core[rd_addrA];
  assign datB_out = core[rd_addrB];

// writes are sequential (clocked)
  always_ff @(posedge clk)
    if(wr_en)				   // anything but stores or no ops
      core[wr_addr] <= dat_in; 

endmodule