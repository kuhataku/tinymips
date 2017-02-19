module regfile32x32 (
   input CLK,
   input [ 4 : 0 ]A1,
   input [ 4 : 0 ]A2,
   input [ 4 : 0 ]A3,
   input [ 31 : 0 ] WD3,
   input WE3,
   output [ 31 : 0 ] RD1,
   output [ 31 : 0 ] RD2
);

   reg [ 31 : 0 ] regfile [ 0 : 31 ];
   assign RD1 = regfile[A1];
   assign RD2 = regfile[A2];

   always@(posedge CLK) begin
      if( WE3 ) begin
         regfile[A3] = WD3;
      end
   end

endmodule//regfile32x32
