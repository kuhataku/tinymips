interface regfile_if(
   input CLK
);
   reg [ 4 : 0 ]A1;
   reg [ 4 : 0 ]A2;
   reg [ 4 : 0 ]A3;
   reg [ 31 : 0 ] WD3;
   reg WE3;
   wire [ 31 : 0 ] RD1;
   wire [ 31 : 0 ] RD2;

   modport mst(
      input RD1, RD2,
      output A1, A2, A3, WD3, WE3
   );

   modport slv(
      output RD1, RD2,
      input A1, A2, A3, WD3, WE3
   );

endinterface
