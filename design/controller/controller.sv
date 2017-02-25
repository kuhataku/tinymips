module controller(
  input [ 5 : 0 ] OP,
  input [ 5 : 0 ] Funct,
  output control_sig_t control_sig
);

  wire [ 1 : 0 ] ALUOp;

  assign control_sig = main_decoder(OP);
  assign ALUControl = alu_decoder(ALUOp, Funct);


  function [ 7 : 0 ] main_decoder;
    input [ 5 : 0 ] opcode;
    begin
      case (opcode)
        6'b000000: main_decoder = 8'b11000010;
        6'b100011: main_decoder = 8'b10100100;
        6'b101011: main_decoder = 8'b0x101x00;
        6'b000100: main_decoder = 8'b0x010x01;
        default : main_decoder = 8'bxxxxxxxx;
      endcase
    end
  endfunction

  function [ 2 : 0 ] alu_decoder; 
    input [ 1 : 0 ] aluop;
    input [ 5 : 0 ] funct;
    begin
      case ({aluop,funct})
        {2'b00, 6'bxxxxxx}: alu_decoder = 3'b010;
        {2'b01, 6'bxxxxxx}: alu_decoder = 3'b110;
        {2'b1x, 6'b100000}: alu_decoder = 3'b110;
        {2'b1x, 6'b100010}: alu_decoder = 3'b110;
        {2'b1x, 6'b100100}: alu_decoder = 3'b110;
        {2'b1x, 6'b100101}: alu_decoder = 3'b110;
        {2'b1x, 6'b101010}: alu_decoder = 3'b110;
        default : alu_decoder = 3'bxxx;
      endcase
    end
  endfunction

endmodule
