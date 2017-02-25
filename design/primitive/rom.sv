module rom #(
   parameter ADDR_WIDTH = 32,
   parameter DATA_WIDTH = 32,
   parameter DATA_DEPTH = 4096
)(
   input [ ADDR_WIDTH - 1 : 0 ] A,
   output [ DATA_WIDTH - 1 : 0 ] RD
);
   reg [ DATA_WIDTH - 1 : 0 ] memory [ 0 : DATA_DEPTH - 1 ];

   assign RD = memory[A];

endmodule//rom
