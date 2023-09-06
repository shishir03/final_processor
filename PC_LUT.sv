module PC_LUT #(parameter D=10)(
  input       [3:0] addr,	   
  output logic [D-1:0] target);

  logic [D-1:0] lut [0:15];

  initial begin
    lut[0] = 0;
    lut[1] = 11;
    lut[2] = 81;         // shift
    lut[3] = 69;        // correct
    lut[4] = 120;         // end
    lut[5] = 53;         // lsbshift
    lut[6] = 56;          // next
    lut[7] = 60;         // beginshiftloop
    lut[8] = 78;         // lsbxor
    lut[9] = 20;
    lut[10] = 1;         // start
    lut[11] = 44;        // corrections start
    lut[12] = 45;        // shift
    lut[13] = 13;        // inner loop
    lut[14] = 96;         // outer loop
    lut[15] = 77;        // second loop
  end

  always_comb begin
    target = lut[addr];
  end

endmodule