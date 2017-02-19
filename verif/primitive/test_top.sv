module test_top (
);
   wire CLK;
   wire [ 4 : 0 ]A1;
   wire [ 4 : 0 ]A2;
   wire [ 4 : 0 ]A3;
   wire [ 31 : 0 ] WD3;
   wire WE3;
   wire [ 31 : 0 ] RD1;
   wire [ 31 : 0 ] RD2;

   tb_top tb_top(.*);
   dut_top dut_top(.*);

endmodule//top
