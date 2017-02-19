module ram (
   input CLK,
   input [ 31 : 0 ] A,
   inout [ 31 : 0 ] WD,
   input WE,
   output [ 31 : 0 ] RD
);
   reg [ 31 : 0 ] memory [ 0 : 4095 ];

   assign RD = memory[A];

   always@(posedge CLK) begin
      if(WE) begin
      memory[A] <= WD;
      end
   end
   


endmodule//ram

