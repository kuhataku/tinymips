module regfile32x32 #(
   parameter ADDR_WIDTH = 5,
   parameter DATA_WIDTH = 32
)(
   input CLK,
   input [ ADDR_WIDTH - 1 : 0 ] A1,
   input [ ADDR_WIDTH - 1 : 0 ] A2,
   input [ ADDR_WIDTH - 1 : 0 ] A3,
   input [ DATA_WIDTH - 1 : 0 ] WD3,
   input WE3,
   output [ DATA_WIDTH - 1 : 0 ] RD1,
   output [ DATA_WIDTH - 1 : 0 ] RD2
);

   parameter DLY=1;
   logic [ DATA_WIDTH - 1 : 0 ] regfile [ 0 : DATA_WIDTH - 1 ];
   assign RD1 = regfile[A1];
   assign RD2 = regfile[A2];

   always@(posedge CLK) begin
      if( WE3 ) begin
         regfile[A3] <= #DLY WD3;
      end
   end

endmodule//regfile32x32
