module rom (
   input [ 29 : 0 ] A,
   output [ 31 : 0 ] RD
);
   reg [ 0 : 4095 ] memory [ 31 : 0 ];

   assign RD = memory[A];

endmodule//rom
