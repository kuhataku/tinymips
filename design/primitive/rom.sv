module rom (
   input [ 29 : 0 ] A,
   output [ 31 : 0 ] RD
);
   reg [ 31 : 0 ] memory [ 0 : 4095 ];

   assign RD = memory[A];

endmodule//rom
