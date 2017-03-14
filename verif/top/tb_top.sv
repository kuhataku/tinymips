module tb_top (
   output CLK,
   output RST
);


   tb_ctrl tb_ctrl(.*);

`define TOP_LEVEL test_top.dut_top.DUT
`define MULT_TOP_LEVEL test_top.dut_top.MULT_DUT
`define TB_TOP_LEVEL test_top.tb_top
localparam add_funct = 6'd32;
localparam sub_funct = 6'd34;

   logic [31:0] data1;
   logic [31:0] data2;
   logic [4:0] addr1;
   logic [4:0] addr2;

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
      force `TOP_LEVEL.instr = r_op(0,1,2,0,sub_funct); @(posedge CLK);
      force `TOP_LEVEL.instr = i_op(32'b000_1000,0,2,10);@(posedge CLK);
      release `TOP_LEVEL.instr;
   endtask
 
   task single_cycle;
      tb_ctrl.resetall();
      $monitor("instr:%x",`TOP_LEVEL.instr);
      $readmemh("reg.h", `TOP_LEVEL.rf.regfile);
      for (int i = 0; i < $size(`TOP_LEVEL.dmem.memory); i = i + 1) begin
         `TOP_LEVEL.dmem.memory[i] = $urandom();
      end
      #10;
      test_lw();
      test_sw();
      #10;
      tb_ctrl.resetall();
      test_r_irs();
      #10;
      $readmemh("imem.h", `TOP_LEVEL.imem.memory);
      $readmemh("dmem.h", `TOP_LEVEL.dmem.memory);
      $readmemh("reg.h", `TOP_LEVEL.rf.regfile);
      tb_ctrl.resetall();
      #50;
      $writememh("mem.out.h", `TOP_LEVEL.dmem.memory);
   endtask

   task multi_cycle;
      for (int i = 0; i < $size(`TOP_LEVEL.dmem.memory); i = i + 1) begin
         `TOP_LEVEL.dmem.memory[i] = $urandom();
      end
      $readmemh("imem.h", `MULT_TOP_LEVEL.idmem.memory);
      $readmemh("reg.h", `MULT_TOP_LEVEL.rf.regfile);
      tb_ctrl.resetall();
      #200;
      $writememh("mem.out.h", `MULT_TOP_LEVEL.idmem.memory);
   endtask

   initial begin
      // single_cycle();
      multi_cycle();
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
