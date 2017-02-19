module alu (
   input [ 31 : 0 ] srca,
   input [ 31 : 0 ] srcb,
   input [  2 : 0 ] alu_control,
   output zero,
   output [ 31 : 0 ] alu_result
);
   assign zero = (alu_result == 0);
   assign alu_result = alu_body( srca, srcb, alu_control);

   function [ 31 : 0 ] alu_body;
      input [ 31 : 0 ] srca;
      input [ 31 : 0 ] srcb;
      input [  2 : 0 ] alu_control;
      begin
         if ( alu_control == 3'b010 )
            alu_body = srca + srcb;
         else
            alu_body = 0; //T.B.D.
      end
   endfunction //alu_body
   
endmodule//alu
