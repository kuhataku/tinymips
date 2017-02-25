`include "mips_def.svh"

module top (
   input CLK,
   input RST
);
   `include "mips_param.svh"

   typedef struct packed{
      logic pc;
      logic plus4;
      logic branch;
   } pc_sig_t;

   reg [ DATA_WIDTH - 1 : 0 ] pc;
   wire [ DATA_WIDTH - 1 : 0 ] pc_plus4;
   wire [ DATA_WIDTH - 1 : 0 ] pc_branch;
   always@(posedge CLK) begin
      if(RST) begin
         pc <= 0;
      end else begin
         pc <= pc_next;
      end
   end

   control_sig_t control_sig;
   wire [ DATA_WIDTH - 1 : 0 ] instr;
   wire [ DATA_WIDTH - 1 : 0 ] sign_imm;
   wire [ DATA_WIDTH - 1 : 0 ] alu_result;
   wire zero;
   wire [ DATA_WIDTH - 1 : 0 ] rf_rd1;
   wire [ DATA_WIDTH - 1 : 0 ] rf_rd2;
   wire [ DATA_WIDTH - 1 : 0 ] srcb;
   wire [ DATA_WIDTH - 1 : 0] writedata;
   wire [ DATA_WIDTH - 1 : 0] readdata;
   wire [ 2 : 0 ] alu_control;
   wire [ REG_ADDR_WIDTH - 1 : 0 ] rf_a1;
   wire [ REG_ADDR_WIDTH - 1 : 0 ] rf_a2;
   wire [ REG_ADDR_WIDTH - 1 : 0 ] rf_a3;
   wire alu_src;
   wire mem2reg;
   wire regdst;
   wire branch;
   wire pc_src;
   wire [ 5 : 0 ] op;
   wire [ 5 : 0 ] funct;

   assign op = instr[DATA_WIDTH-1:26];
   assign funct = instr[5:0];
   assign rf_a1 = instr[25:21];
   assign rf_a2 = instr[20:16];
   assign rf_a3 = regdst ? instr[15:11] : instr[20:16];
   assign srcb =  alu_src ? sign_imm : rf_rd2;
   assign result = mem2reg ?  readdata : alu_result;
   assign pc_plus4 = pc + 4;
   assign pc_branch = ( sign_imm << 2 ) + pc_plus4;
   assign pc_src = zero & branch;
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
      .WD3(readdata),
      .WE3(control_sig.regwrite),
      .RD1(rf_rd1),
      .RD2(rf_rd2)
   );

   ram dmem(
      .CLK(CLK),
      .A(alu_result),
      .WD(rf_rd2),
      .WE(control_sig.memwrite),
      .RD(readdata)
   );

   sign_extend se(
      .extend_in(instr[15:0]),
      .extend_out(sign_imm)
   );

   alu alu(
      .srca(rf_rd1),
      .srcb(sign_imm),
      .alu_control(alu_control),
      .zero(zero),
      .alu_result(alu_result)
   );

   controller controller(
      .OP(op),
      .Funct(funct),
      .control_sig(control_sig)
   );

endmodule//top
