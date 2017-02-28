module tb_top (
   output reg CLK,
   output reg RST
);

`define TOP_LEVEL test_top.dut_top.DUT
localparam add_funct = 6'd32;
localparam sub_funct = 6'd34;

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

   task resetall;
      #0;
      RST = 1;
      #5;
      RST = 0;
   endtask

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

   function [ 31 : 0 ] r_op;
      input [ 4 : 0  ] rs;
      input [ 4 : 0  ] rt;
      input [ 4 : 0  ] rd;
      input [ 4 : 0  ] shamt;
      input [ 5 : 0  ] funct;
      begin
         r_op = ( rs << 21 ) | ( rt << 16 ) | ( rd << 11 ) | ( shamt << 6 ) | funct;
      end
   endfunction

   function [ 31 : 0 ] i_op;
      input [ 5 : 0 ] op;
      input [ 4 : 0 ] rs;
      input [ 4 : 0 ] rt;
      input [ 15 : 0 ] imm;
      begin
         i_op = ( op << 26) | ( rs << 21 ) | ( rt << 16 ) | imm;
      end
   endfunction
   
   task test_lw;
      for (int i = 0; i < 5; i = i + 1) begin
         force `TOP_LEVEL.instr = lw_op(i,i,i); @(posedge CLK);
         $display("Load memory[%x] to register[%x]", `TOP_LEVEL.rf.A1, `TOP_LEVEL.rf.A3);
      end
      for (int i = 0; i < 5; i = i + 1) begin
         if( `TOP_LEVEL.rf.regfile[i] !== `TOP_LEVEL.dmem.memory[i] ) begin
            $error("LW operation is invalid.");
         end
      end
      release `TOP_LEVEL.instr;
   endtask

   task test_sw;
      for (int i = 0; i < 5; i = i + 1) begin
         force `TOP_LEVEL.instr = sw_op(i + 5, 4 - i, i); @(posedge CLK);
         $display("Store register[%x] to memory[%x]", `TOP_LEVEL.rf.A2, `TOP_LEVEL.dmem.A);
      end
      @(posedge CLK)
      $display("%x",`TOP_LEVEL.dmem.memory[32'd4]);
      for (int i = 0; i < 5; i = i + 1) begin
         if( `TOP_LEVEL.rf.regfile[4 - i] !== `TOP_LEVEL.dmem.memory[i] ) begin
            $error("SW operation is invalid.");
            $writememh("reg.out.h", `TOP_LEVEL.rf.regfile);
            $writememh("mem.out.h", `TOP_LEVEL.dmem.memory);
         end
      end
      release `TOP_LEVEL.instr;
   endtask

   task test_r_irs;
      $readmemh("reg_r_test.h", `TOP_LEVEL.rf.regfile);
      force `TOP_LEVEL.instr = r_op(0,1,2,0,add_funct); @(posedge CLK);
      if( `TOP_LEVEL.rf.WD3 !== 'd8 ) begin $error("Add operation is invalid."); end
      force `TOP_LEVEL.instr = r_op(0,1,2,0,sub_funct); @(posedge CLK);
      if( `TOP_LEVEL.rf.WD3 !== 'd2 ) begin $error("Sub operation is invalid."); end
      force `TOP_LEVEL.instr = i_op(32'b000_1000,0,2,10); @(posedge CLK);
      if( `TOP_LEVEL.rf.WD3 !== 'd15 ) begin $error("Addi operation is invalid."); end
   endtask
 
   initial begin
      resetall();
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
      resetall();
      test_r_irs();
      #10;
      $finish;
      // $writememh("reg.out.h", `TOP_LEVEL.rf.regfile);
      // $writememh("mem.out.h", `TOP_LEVEL.dmem.memory);
   end

   initial begin
      string vcdname;
      if ( $value$plusargs("VCDNAME=%s", vcdname) ) begin
         $dumpfile("mips.vcd");
         $dumpvars(0, test_top);
      end
   end
   
endmodule//tb
