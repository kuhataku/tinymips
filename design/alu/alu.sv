module alu #(
   parameter DATA_WIDTH = 32
)(
   input [ DATA_WIDTH - 1 : 0 ] srca,
   input [ DATA_WIDTH - 1 : 0 ] srcb,
   input [  2 : 0 ] alu_control,
   output zero,
   output [ DATA_WIDTH - 1  : 0 ] alu_result
);
   assign zero = (alu_result == 0);
   assign alu_result = alu_body( srca, srcb, alu_control);

   function [ DATA_WIDTH - 1 : 0 ] alu_body;
      input [ DATA_WIDTH - 1 : 0 ] srca;
      input [ DATA_WIDTH - 1 : 0 ] srcb;
      input [  2 : 0 ] alu_control;
      begin
         casex(alu_control)
            3'b010: alu_body = srca + srcb;
            3'b110: alu_body = srca - srcb;
            3'b000: alu_body = srca & srcb;
            3'b001: alu_body = srca | srcb;
            3'b111: alu_body = 0; //T.B.D.
            default: alu_body = 3'bxxx;
         endcase //(alu_control)
      end
   endfunction //alu_body
   
endmodule//alu
