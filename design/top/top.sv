module top (
   input CLK,
   input RST
);

   reg [ 31 : 0 ] PC;
   wire [ 31 : 0 ] PCPLUS4;
   wire [ 31 : 0 ] NextPC;
   wire [ 31 : 0 ] PCBranch;
   wire [ 31 : 0 ] instr;
   wire [ 31 : 0 ] sign_imm;
   wire regwrite;
   wire memwrite;
   wire [ 15 : 0 ] imm;
   wire [ 31 : 0 ] result;
   wire [ 31 : 0 ] alu_result;
   wire zero;
   wire [ 31 : 0 ] rf_rd1;
   wire [ 31 : 0 ] rf_rd2;
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
   wire [ 5 : 0 ] op;
   wire [ 5 : 0 ] funct;

   assign op = instr[31:26];
   assign funct = instr[5:0];
   assign rf_a1 = instr[25:21];
   assign rf_a2 = instr[20:16];
   assign rf_a3 = regdst ? instr[15:11] : instr[20:16];
   assign srcb =  alu_src ? sign_imm : rf_rd2;
   assign result = mem2reg ?  readdata : alu_result;
   assign imm = instr[15:0];
   assign PCPLUS4 = PC + 4;
   assign PCBranch = ( sign_imm << 2 ) + PCPLUS4;
   assign PCSrc = zero & branch;
   assign NextPC = PCSrc ? PCBranch : PCPLUS4;


   rom imem(
     .A(PC[31:2]), 
     .RD(instr)
   );

   regfile32x32 rf(
     .CLK(CLK), 
     .A1(rf_a1), 
     .A2(rf_a2), 
     .A3(rf_a3), 
     .WD3(result), 
     .WE3(regwrite), 
     .RD1(rf_rd1), 
     .RD2(rf_rd2)
   );

   ram dmem(
     .CLK(CLK), 
     .A(alu_result), 
     .WD(rf_rd2), 
     .WE(memwrite),
     .RD(readdata)
   );

   sign_extend se(
     .extend_in(imm),
     .extend_out(sign_imm)
   );

   alu alu(
     .srca(rf_rd1),
     .srcb(srcb),
     .alu_control(alu_control),
     .zero(zero),
     .alu_result(alu_result)
   );

   controller controller(
     .OP(op),
     .Funct(funct),
     .Mem2Reg(mem2reg),
     .MemWrite(memwrite),
     .Branch(branch),
     .ALUControl(alu_control),
     .ALUSrc(alu_src),
     .RegDst(regdst),
     .RegWrite(regwrite)
   );


   always@(posedge CLK or posedge RST) begin
      if(RST) begin
         PC <= 0;
      end else begin
         PC <= NextPC;
      end
   end

endmodule//top
