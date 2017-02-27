module ram #(
   parameter ADDR_WIDTH = 32,
   parameter DATA_WIDTH = 32,
   parameter DATA_DEPTH = 4096
)(
   input CLK,
   input [ ADDR_WIDTH - 1 : 0 ] A,
   input [ DATA_WIDTH - 1 : 0 ] WD,
   input WE,
   output [ DATA_WIDTH - 1 : 0 ] RD
);
   parameter DLY=1;
   reg [ DATA_WIDTH - 1 : 0 ] memory [ 0 : DATA_DEPTH - 1 ];

   assign RD = memory[A];

   always@(posedge CLK) begin
      if(WE) begin
         memory[A] <= #DLY WD;
      end
   end
   


endmodule//ram

