module tb_top (
   output reg CLK,
   output reg RST
);

`define TOP_LEVEL test_top.dut_top.DUT

   logic [31:0] data1;
   logic [31:0] data2;
   logic [4:0] addr1;
   logic [4:0] addr2;

   initial begin
      #0;
      CLK = 0;
      forever begin
         #2;
         CLK <= ~CLK;
      end
   end

   initial begin
      #0;
      RST = 1;
      #5;
      RST = 0;
   end

   function [ 31 : 0 ]lw_op;
      input [ 4 : 0 ] rs;
      input [ 4 : 0 ] rt;
      input [ 15 : 0 ] imm;
      begin
         lw_op = 32'h8C00_0000 | ( rs << 21 ) | ( rt << 16 ) | imm;
      end
   endfunction //lw_asm

   function [ 31 : 0 ]sw_op;
      input [ 4 : 0 ] rs;
      input [ 4 : 0 ] rt;
      input [ 15 : 0 ] imm;
      begin
         sw_op = 32'hAC00_0000 | ( rs << 21 ) | ( rt << 16 ) | imm;
      end
   endfunction //lw_asm
   
   task test_lw;
      force `TOP_LEVEL.alu_control = 3'b010;
      force `TOP_LEVEL.regwrite = 1'b1;
      force `TOP_LEVEL.memwrite = 1'b0;
      for (int i = 0; i < 5; i = i + 1) begin
         force `TOP_LEVEL.instr = lw_op(i,i,i); @(posedge CLK);
         $display("Load memory[%x] to register[%x]", `TOP_LEVEL.rf.A1, `TOP_LEVEL.rf.A3);
      end
      for (int i = 0; i < 5; i = i + 1) begin
         if( `TOP_LEVEL.rf.regfile[i] !== `TOP_LEVEL.dmem.memory[i] ) begin
            $error("LW operation is invalid.");
         end
      end
      release `TOP_LEVEL.alu_control;
      release `TOP_LEVEL.regwrite;
      release `TOP_LEVEL.memwrite;
      release `TOP_LEVEL.instr;
   endtask

   task test_sw;
      force `TOP_LEVEL.alu_control = 3'b010;
      force `TOP_LEVEL.regwrite = 1'b0;
      force `TOP_LEVEL.memwrite = 1'b1;
      force `TOP_LEVEL.mem2reg = 1'b0;
      for (int i = 0; i < 5; i = i + 1) begin
         force `TOP_LEVEL.instr = sw_op(i + 5, 4 - i, i); @(posedge CLK);
         $display("Store register[%x] to memory[%x]", `TOP_LEVEL.rf.A2, `TOP_LEVEL.dmem.A);
      end
      @(posedge CLK)
      $display("%x",`TOP_LEVEL.dmem.memory[32'd4]);
      for (int i = 0; i < 5; i = i + 1) begin
         $display("%x %x, %b %b",  `TOP_LEVEL.rf.regfile[4 - i] , `TOP_LEVEL.dmem.memory[i] , 4-i,i );
         if( `TOP_LEVEL.rf.regfile[4 - i] !== `TOP_LEVEL.dmem.memory[i] ) begin
            $error("SW operation is invalid.");
            $writememh("reg.out.h", `TOP_LEVEL.rf.regfile);
            $writememh("mem.out.h", `TOP_LEVEL.dmem.memory);
         end
      end
      release `TOP_LEVEL.alu_control;
      release `TOP_LEVEL.regwrite;
      release `TOP_LEVEL.memwrite;
      release `TOP_LEVEL.instr;
      release `TOP_LEVEL.mem2reg;
   endtask

   // initial begin
   //    if ( `TOP_LEVEL. )
   //
   // end
   //
   initial begin
      $readmemh("reg.h", `TOP_LEVEL.rf.regfile);
      // $readmemh("imem.h", `TOP_LEVEL.rf.regfile);
      for (int i = 0; i < $size(`TOP_LEVEL.dmem.memory); i = i + 1) begin
         `TOP_LEVEL.dmem.memory[i] = $urandom();
      end
      // $readmemh("dmem.h", `TOP_LEVEL.dmem.memory);
      // `TOP_LEVEL.rf.regfile[0] = $random;
      #10;
      test_lw();
      test_sw();
      #10;
      $writememh("reg.out.h", `TOP_LEVEL.rf.regfile);
      $writememh("mem.out.h", `TOP_LEVEL.dmem.memory);
      $finish;
   end

   initial begin
      string vcdname;
      if ( $value$plusargs("VCDNAME=%s", vcdname) ) begin
         $dumpfile("mips.vcd");
         $dumpvars(0, test_top);
      end
   end
   
endmodule//tb
