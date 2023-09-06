module alu_LUT (
  input [4:0] address,
  output logic [7:0] data
);

  logic [7:0] lut [0:31];

  initial begin
    lut[0] = 1;
    lut[1] = 30;
    // ...
    lut[31] = 8'b11111111;
  end

  always_comb begin
    data = lut[address];
  end

endmodule
