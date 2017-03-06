`default_nettype none
module mult_top (
   input CLK,
   input RST
);
   parameter ADD=010;

   //pc
   reg [ 31 : 0 ] r_pc;
   wire [ 31 : 0 ] pc_plus4;
   wire pc_branch;
   wire pc_we;
   wire pc_src;
   wire pc_enable;

   //idmem
   wire ir_we;
   wire [ 31 : 0 ] idmem_rdata;
   wire [ 31 : 0 ] idmem_wdata;
   wire [ 31 : 0 ] idmem_addr;
   wire idmem_we;
   wire is_data_addr;
   wire idmem2rf;
   reg [ 31 : 0 ] r_ir;
   reg [ 31 : 0 ] r_data;

   //rf == register file
   wire [ 4 : 0 ] rf_a1;
   wire [ 4 : 0 ] rf_a2;
   wire [ 4 : 0 ] rf_a3;
   wire [ 31 : 0 ] rf_rd1;
   wire [ 31 : 0 ] rf_rd2;
   wire [ 31 : 0 ] rf_wd;
   reg  [ 31 : 0 ] r_rf_rd1;
   reg  [ 31 : 0 ] r_rf_rd2;
   wire rf_we;
   
   wire is_dst_rf;

   //sign_extend
   wire [ 15 : 0 ] imm;
   wire [ 31 : 0 ] sign_imm;

   //alu
   wire [ 31 : 0 ] alu_srca;
   wire [ 31 : 0 ] alu_srcb;
   wire [ 2 : 0 ] alu_control;
   reg [ 31 : 0 ] r_alu_result;
   wire [ 31 : 0 ] alu_result;
   wire zero;
   wire alu_srca_sel;
   wire [ 1 : 0 ] alu_srcb_sel;
   wire alu_src_is_imm;
   
   //controller
   wire [ 5 : 0 ] op;
   wire [ 5 : 0 ] funct;

   assign op = r_ir[31:26];
   assign funct = r_ir[5:0];

   assign imm = r_ir[15:0]; // For I-instruction
   assign rf_a1 = r_ir[25:21];
   assign rf_a2 = r_ir[20:16];
   assign rf_a3 = is_dst_rf ? r_ir[15:11] : r_ir[20:16];

   function [ 31 : 0 ] alu_srcb_mux;
      input [ 2 : 0 ] alu_srcb_sel;
      input [ 31 : 0 ] r_rf_rd2;
      input [ 31 : 0 ] sign_imm;
      begin
         case(alu_srcb_sel)
            2'b00:   alu_srcb_mux = r_rf_rd2;
            2'b01:   alu_srcb_mux = 'd4;
            2'b10:   alu_srcb_mux = sign_imm;
            2'b11:   alu_srcb_mux = sign_imm << 2;
            default: alu_srcb_mux = 'bx;
         endcase //(alu_srcb_sel)
      end
   endfunction //alu_srcb_mux
   

   assign alu_srca = alu_srca_sel ? r_rf_rd1 : r_pc;
   assign alu_srcb = alu_srcb_mux(alu_srcb_sel, r_rf_rd2, sign_imm);
   assign alu_control = alu_control ? ADD : 'd0;
   assign pc_plus4 = pc_src ? r_alu_result : alu_result;
   assign pc_enable = (zero & pc_branch) | pc_we;

   assign idmem_addr = is_data_addr ? r_alu_result : r_pc;
   assign rf_wd = idmem2rf ? r_data : r_alu_result;
   assign idmem_wdata = r_rf_rd2;

   ram idmem(
     .CLK(CLK), 
     .A(idmem_addr), 
     .WD(idmem_wdata), 
     .WE(idmem_we),
     .RD(idmem_rdata)
   );

   regfile32x32 rf(
     .CLK(CLK), 
     .A1(rf_a1), 
     .A2(rf_a2), 
     .A3(rf_a3), 
     .WD3(rf_wd), 
     .WE3(rf_we), 
     .RD1(rf_rd1), 
     .RD2(rf_rd2)
   );

   sign_extend se(
     .extend_in(imm),
     .extend_out(sign_imm)
   );

   alu alu(
     .srca(alu_srca),
     .srcb(alu_srcb),
     .alu_control(alu_control),
     .zero(zero),
     .alu_result(alu_result)
   );

   mult_controller mult_controller(
     .OP(op),
     .FUNCT(funct),
     .IDMEM2RF(idmem2rf),
     .IS_DST_RF(is_dst_rf),
     .IS_DATA_ADDR(is_data_addr),
     .PC_SRC(pc_src),
     .ALU_SRCA_SEL(alu_srca_sel),
     .ALU_SRCB_SEL(alu_srcb_sel),
     .IR_WE(ir_we),
     .IDMEM_WE(idmem_we),
     .PC_WE(pc_we),
     .PC_BRANCH(pc_branch),
     .RF_WE(rf_we),
     .ALUCONTROL(alu_control),
     .*
   );

   always@(posedge CLK or posedge RST) begin
      if ( RST ) begin
         r_ir <= 'd0;
      end else begin
         if ( ir_we ) begin
            r_ir <= idmem_rdata;
         end
      end
   end
   
   always@(posedge CLK or posedge RST) begin
      if ( RST ) begin
         r_data <= 'd0;
      end else begin
         if ( ! ir_we ) begin
            r_data <= idmem_rdata;
         end
      end
   end

   always@(posedge CLK or posedge RST) begin
      if ( RST ) begin
         r_pc <= 'd0;
      end else begin
         if ( pc_enable ) begin
            r_pc <= pc_plus4;
         end
      end
   end

   always@(posedge CLK or posedge RST) begin
      if ( RST ) begin
         r_alu_result = 'd0;
      end else begin
         r_alu_result = alu_result;
      end
   end

   always@(posedge CLK or posedge RST) begin
      if ( RST ) begin
         r_rf_rd1 <= 0;
         r_rf_rd2 <= 0;
      end else begin
         r_rf_rd1 <= rf_rd1;
         r_rf_rd2 <= rf_rd2;
      end
   end
   

endmodule//mult_top
