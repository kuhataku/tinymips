module top (
   input CLK,
   input RST
);

   logic [ 31 : 0 ] PC;
   logic [ 31 : 0 ] PCPLUS4;
   logic [ 31 : 0 ] PCBranch;
   logic [ 31 : 0 ] instr;
   logic [ 31 : 0 ] sign_imm;
   logic regwrite;
   logic memwrite;
   logic [ 31 : 0 ] alu_result;
   logic zero;
   logic [ 31 : 0 ] rf_rd1;
   logic [ 31 : 0 ] rf_rd2;
   logic [ 31 : 0 ] srcb;
   logic [ 31 : 0] writedata;
   logic [ 31 : 0] readdata;
   logic [ 2 : 0 ] alu_control;
   logic [ 4 : 0 ] rf_a1;
   logic [ 4 : 0 ] rf_a2;
   logic [ 4 : 0 ] rf_a3;
   logic alu_src;
   logic mem2reg;
   logic regdst;
   logic branch;
   logic PCSrc;
   logic [ 5 : 0 ] op;
   logic [ 5 : 0 ] funct;

   assign op = instr[31:26];
   assign funct = instr[5:0];
   assign rf_a1 = instr[25:21];
   assign rf_a2 = instr[20:16];
   assign rf_a3 = regdst ? instr[15:11] : instr[20:16];
   assign srcb =  alu_src ? sign_imm : rf_rd2;
   assign result = mem2reg ?  readdata : alu_result;
   assign PCPLUS4 = PC + 4;
   assign PCBranch = ( sign_imm << 2 ) + PCPLUS4;
   assign PCSrc = zero & branch;
   assign NextPC = PCSrc ? PCBranch : PCPLUS4;


   rom imem(.A(PC[31:2]), .RD(instr));
   regfile32x32 rf(.CLK(CLK), .A1(instr[25:21]), .A2(instr[20:16]), .A3(instr[20:16]), .WD3(readdata), .WE3(regwrite), .RD1(rf_rd1), .RD2(rf_rd2));
   ram dmem(.CLK(CLK), .A(alu_result), .WD(rf_rd2), .WE(memwrite), .RD(readdata));
   sign_extend se(.extend_in(instr[15:0]), .extend_out(sign_imm));
   alu alu(.srca(rf_rd1), .srcb(sign_imm), .alu_control(alu_control), .zero(zero), .alu_result(alu_result));
   controller controller(.OP(op), .Funct(funct), .Mem2Reg(mem2reg), .MemWrite(memwrite), .Branch(branch), .ALUControl(alu_control), .ALUSrc(alu_src), .RegDst(regdst), .RegWrite(regwrite));


   always@(posedge CLK) begin
      if(RST) begin
         PC <= 0;
      end else begin
         PC <= NextPC;
      end
   end

endmodule//top
