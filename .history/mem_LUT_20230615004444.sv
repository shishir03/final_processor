module mem_LUT (
  input [4:0] address,
  output logic [7:0] data
);

 logic [7:0] lut [0:31];

  initial begin
    lut[0] = 60;
    lut[1] = 61;
    lut[2] = 62;
    lut[3] = 63;
    lut[4] = 64;
  end

  always_comb begin
    data = lut[address];
  end

endmodule
