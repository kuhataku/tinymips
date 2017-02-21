module top (
   input CLK,
   input RST
);

   reg [ 31 : 0 ] PC;
   wire [ 31 : 0 ] PCPLUS4;
   wire [ 31 : 0 ] PCBranch;
   wire [ 31 : 0 ] instr;
   wire [ 31 : 0 ] sign_imm;
   wire regwrite;
   wire memwrite;
   wire [ 31 : 0 ] alu_result;
   wire zero;
   wire [ 31 : 0 ] reg_rd1;
   wire [ 31 : 0 ] reg_rd2;
   wire [ 31 : 0 ] srcb;
   wire [ 31 : 0] writedata;
   wire [ 31 : 0] readdata;
   wire [ 2 : 0 ] alu_control;
   wire [ 4 : 0 ] rf_a1;
   wire [ 4 : 0 ] rf_a2;
   wire [ 4 : 0 ] rf_a3;
   wire alu_src;
   wire mem2reg;
   wire regdst;
   wire branch;
   wire PCSrc;

   assign rf_a1 = instr[25:21];
   assign rf_a2 = instr[20:16];
   assign rf_a3 = regdst ? instr[15:11] : instr[20:16];
   assign srcb =  alu_src ? sign_imm : reg_rd2;
   assign result = mem2reg ?  readdata : alu_result;
   assign PCPLUS4 = PC + 4;
   assign PCBranch = ( sign_imm << 2 ) + PCPLUS4;
   assign PCSrc = zero & branch;
   assign NextPC = PCSrc ? PCBranch : PCPLUS4;


   rom imem(.A(PC[31:2]), .RD(instr));
   regfile32x32 rf(.CLK(CLK), .A1(instr[25:21]), .A2(instr[20:16]), .A3(instr[20:16]), .WD3(readdata), .WE3(regwrite), .RD1(reg_rd1), .RD2(reg_rd2));
   ram dmem(.CLK(CLK), .A(alu_result), .WD(reg_rd2), .WE(memwrite), .RD(readdata));
   sign_extend se(.extend_in(instr[15:0]), .extend_out(sign_imm));
   alu alu(.srca(reg_rd1), .srcb(sign_imm), .alu_control(alu_control), .zero(zero), .alu_result(alu_result));

   always@(posedge CLK) begin
      if(RST) begin
         PC <= 0;
      end else begin
         PC <= NextPC;
      end
   end

endmodule//top
