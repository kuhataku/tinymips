module tb_ctrl (
   output reg CLK,
   output reg RST
);

   initial begin
      #0;
      CLK = 0;
      forever begin
         #2;
         CLK <= ~CLK;
      end
   end
   task resetall;
      #0;
      RST = 1;
      #5;
      RST = 0;
   endtask
endmodule//tb_ctrl
