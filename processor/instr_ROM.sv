// lookup table
// deep 
// 9 bits wide; as deep as you wish
module instr_ROM #(parameter D=10)(
  input       [D-1:0] prog_ctr,    // prog_ctr	  address pointer
  output logic[ 8:0] mach_code);

  logic[8:0] core[2**D];
  initial begin							    // load the program
    // $readmemb("mach_code1.txt",core);
    // $readmemb("mach_code2.txt",core);
    $readmemb("../program_code/mach_code3.txt",core);
  end

  always_comb  mach_code = core[prog_ctr];

endmodule