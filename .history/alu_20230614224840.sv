// combinational -- no clock
// sample -- change as desired
module alu(
  input[3:0] alu_cmd,    // ALU instructions
  input[7:0] inA, inB,	 // 8-bit wide data path
  input      sc_i,       // shift_carry in
  input		 pari_in,
  output logic[7:0] rslt,
  output logic sc_o,     // shift_carry out
			   sc_clr,
			   sc_en,
               pari,     // reduction XOR (output)
			   pari_en,
			   pari_clr,
);

always_comb begin 
 rslt = 8'b0;            
 sc_o = 'b0;
 pari = 'b0;
 sc_clr = 'b0;
 sc_en = 'b0;
 pari_en = 'b0;
 pari_clr = 'b1;
 case(alu_cmd)
	0: begin     // add 2 8-bit unsigned; automatically makes carry-out
	  sc_en = 'b1;
	  {sc_o, rslt} = inA + inB + sc_i;
	end
	1: begin    // sub (shanky)
	  sc_en = 'b1;
	  {sc_o, rslt} = inA - inB + sc_i;
	end
	2: begin   // left_shift
	  sc_en = 'b1;
	  {sc_o, rslt} = {inA, sc_i};
	end
	3: begin   // arithmetic right shift (alternative syntax -- works like left shift)
	  sc_en = 'b1;
	  {rslt, sc_o} = {inA[7], inA};
	end
	4: begin   // logical right shift
	  sc_en = 'b1;
	  {rslt, sc_o} = {sc_i, inA};
	end
	5: begin   // not
	  sc_clr = 'b1;
	  rslt = !inA;
	end
	6: begin   // bitwise AND
	  sc_clr = 'b1;
	  rslt = inA & inB;
	end
	7: begin   // bitwise XOR
	  sc_clr = 'b1;
	  rslt = inA ^ inB;
	end
	8: begin   // reduction xor
	  pari_clr = 'b0;
	  pari_en = 'b1;
	  sc_clr = 'b1;
	  pari = ^inA ^ pari_in;
	  rslt = {7'b0, pari};
	end
 endcase
end
   
endmodule