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
         case(alu_control)
            3'b010: alu_body = srca + srcb;
            3'b110: alu_body = srca - srcb;
            3'b000: alu_body = srca & srcb;
            3'b001: alu_body = srca | srcb;
            3'b111: alu_body = srca < srcb;
            default: alu_body = 32'bx;
         endcase //(alu_control)
      end
   endfunction //alu_body
   
endmodule//alu
