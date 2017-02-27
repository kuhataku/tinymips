`include "mips_def.svh"

module top (
   input CLK,
   input RST
);
   `include "mips_param.svh"

   control_sig_t control_sig;
   logic [ DATA_WIDTH - 1 : 0 ] instr;
   logic [ DATA_WIDTH - 1 : 0 ] sign_imm;
   logic [ DATA_WIDTH - 1 : 0 ] alu_result;
   logic zero;
   logic [ DATA_WIDTH - 1 : 0 ] rf_rdata1;
   logic [ DATA_WIDTH - 1 : 0 ] rf_rdata2;
   logic [ REG_ADDR_WIDTH - 1 : 0 ] rf_addr1;
   logic [ REG_ADDR_WIDTH - 1 : 0 ] rf_addr2;
   logic [ REG_ADDR_WIDTH - 1 : 0 ] rf_addr3;
   logic [ DATA_WIDTH - 1 : 0 ] srcb;
   logic [ DATA_WIDTH - 1 : 0] dmem_rdata;
   logic pc_src;
   logic [ 5 : 0 ] op;
   logic [ 5 : 0 ] funct;
   logic [ DATA_WIDTH - 1 : 0 ] pc;
   logic [ DATA_WIDTH - 1 : 0 ] pc_plus4;
   logic [ DATA_WIDTH - 1 : 0 ] pc_branch;
   logic pc_next;

   always@(posedge CLK or posedge RST) begin
      if(RST) begin
         pc <= 0;
      end else begin
         pc <= pc_next;
      end
   end

   assign op = instr[DATA_WIDTH-1:26];
   assign funct = instr[5:0];
   assign rf_addr1 = instr[25:21];
   assign rf_addr2 = instr[20:16];
   assign rf_addr3 = control_sig.regdst ? instr[15:11] : instr[20:16];
   assign srcb =  control_sig.alu_src ? sign_imm : rf_rdata2;
   assign result = control_sig.mem2reg ?  dmem_rdata : alu_result;
   assign pc_plus4 = pc + 4;
   assign pc_branch = ( sign_imm << 2 ) + pc_plus4;
   assign pc_src = zero & control_sig.branch;
   assign pc_next = pc_src ? pc_branch : pc_plus4;

   rom #(
      .ADDR_WIDTH(DATA_WIDTH-2)
   ) imem(
      .A(pc[DATA_WIDTH-1:2]),
      .RD(instr)
   );
   regfile32x32 rf(
      .CLK(CLK),
      .A1(instr[25:21]),
      .A2(instr[20:16]),
      .A3(instr[20:16]),
      .WD3(dmem_rdata),
      .WE3(control_sig.regwrite),
      .RD1(rf_rdata1),
      .RD2(rf_rdata2)
   );

   ram dmem(
      .CLK(CLK),
      .A(alu_result),
      .WD(rf_rdata2),
      .WE(control_sig.memwrite),
      .RD(dmem_rdata)
   );

   sign_extend se(
      .extend_in(instr[15:0]),
      .extend_out(sign_imm)
   );

   alu alu(
      .srca(rf_rdata1),
      .srcb(sign_imm),
      .alu_control(control_sig.alu_control),
      .zero(zero),
      .alu_result(alu_result)
   );

   controller controller(
      .OP(op),
      .FUNCT(funct),
      .control_sig(control_sig)
   );

endmodule//top
