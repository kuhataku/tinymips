module tb_top (
   output reg CLK,
   output reg [ 4 : 0 ]A1,
   output reg [ 4 : 0 ]A2,
   output reg [ 4 : 0 ]A3,
   output reg [ 31 : 0 ] WD3,
   output reg WE3,
   input [ 31 : 0 ] RD1,
   input [ 31 : 0 ] RD2
);

   logic [31:0] data1;
   logic [31:0] data2;
   logic [4:0] addr1;
   logic [4:0] addr2;

   initial begin
      #0;
      CLK = 0;
      forever begin
         #1;
         CLK <= ~CLK;
      end
   end

   task test_regfile;
      data1 = 32'h5a5a5a5a;
      data2 = 32'h12345678;
      addr1 = 0;
      addr2 = 1;
      #10;
      WE3 = 1; A3 = addr1; WD3 = data1;
      #10;
      WE3 = 1; A3 = addr2; WD3 = data2;
      #10;
      A1 = addr1; A2 = addr2;
      if(RD1!=data1 || RD2!=data2) $error("Read data was mismatched with expecting value");
      $info("RD1 = %x, RD2 = %x", RD1, RD2);
      #10;
      WE3 = 1; A3 = addr1; WD3 = data2;
      #10;
      WE3 = 1; A3 = addr2; WD3 = data1;
      #10;
      A1 = addr1; A2 = addr2;
      if(RD1!=data2 || RD2!=data1) $error("Read data was mismatched with expecting value");
      $info("RD1 = %x, RD2 = %x", RD1, RD2);
   endtask

   initial begin
      test_regfile();
      $finish;
   end
endmodule//tb
