module dut_top (
   input CLK,
   input [ 4 : 0 ]A1,
   input [ 4 : 0 ]A2,
   input [ 4 : 0 ]A3,
   input [ 31 : 0 ] WD3,
   input WE3,
   output [ 31 : 0 ] RD1,
   output [ 31 : 0 ] RD2
);
   regfile32x32 DUT(.*);

endmodule//dut_top
