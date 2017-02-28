module controller(
  input [ 5 : 0 ] OP,
  input [ 5 : 0 ] Funct,
  output Mem2Reg,
  output MemWrite,
  output Branch,
  output [ 2 : 0 ]ALUControl,
  output ALUSrc,
  output RegDst,
  output RegWrite,
  output JUMP
);

  wire [ 1 : 0 ] ALUOp;

  assign {RegWrite, RegDst, ALUSrc, Branch, MemWrite, Mem2Reg, ALUOp, JUMP} = 
    main_decoder(OP);
  assign ALUControl = alu_decoder(ALUOp, Funct);


  function [ 8 : 0 ] main_decoder;
    input [ 5 : 0 ] opcode;
    begin
      casex (opcode)
        6'b000000: main_decoder = 9'b110000100;
        6'b100011: main_decoder = 9'b101001000;
        6'b101011: main_decoder = 9'b0x101x000;
        6'b000100: main_decoder = 9'b0x010x010;
        6'b001000: main_decoder = 9'b101000000;
        6'b000010: main_decoder = 9'b0xxx0xxx1;
        default : main_decoder = 9'bxxxxxxxxx;
      endcase
    end
  endfunction

  function [ 2 : 0 ] alu_decoder; 
    input [ 1 : 0 ] aluop;
    input [ 5 : 0 ] funct;
    begin
      casex ({aluop,funct})
        {2'b00, 6'bxxxxxx}: alu_decoder = 3'b010;
        {2'b01, 6'bxxxxxx}: alu_decoder = 3'b110;
        {2'b1x, 6'b100000}: alu_decoder = 3'b010;
        {2'b1x, 6'b100010}: alu_decoder = 3'b110;
        {2'b1x, 6'b100100}: alu_decoder = 3'b000;
        {2'b1x, 6'b100101}: alu_decoder = 3'b001;
        {2'b1x, 6'b101010}: alu_decoder = 3'b111;
        default : alu_decoder = 3'bxxx;
      endcase
    end
  endfunction

endmodule
