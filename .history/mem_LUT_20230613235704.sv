module mem_LUT (
  input [4:0] address,
  output reg [7:0] data
);

  reg [7:0] lut [0:15];

  initial begin
    lut[0] = 8'b00000000;
    lut[1] = 8'b00000001;
    // ...
    lut[31] = 8'b11111111;
  end

  always_comb begin
    data = lut[address];
  end

endmodule
