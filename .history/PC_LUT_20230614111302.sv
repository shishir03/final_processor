module PC_LUT #(parameter D=12)(
  input       [3:0] addr,	   
  output logic [D-1:0] target);

  logic [D-1:0] lut [0:15];

  initial begin
    lut[0] = 12'b000000000000;
    lut[1] = 12'b000000000001;
    // ...
    lut[15] = 12'b111111111111;
  end

  always_comb begin
    target = lut[address];
  end

endmodule

/*

	   pc = 4    0000_0000_0100	  4
	             1111_1111_1111	 -1

                 0000_0000_0011   3

				 (a+b)%(2**12)


   	  1111_1111_1011      -5
      0000_0001_0100     +20
	  1111_1111_1111      -1
	  0000_0000_0000     + 0


  */
