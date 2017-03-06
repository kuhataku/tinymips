module mult_controller(
  input CLK,
  input RST,
  input [ 5 : 0 ] OP,
  input [ 5 : 0 ] FUNCT,
  output IDMEM2RF,
  output IS_DST_RF,
  output IS_DATA_ADDR,
  output PC_SRC,
  output [ 1 : 0 ] ALU_SRCB_SEL,
  output ALU_SRCA_SEL,
  output IR_WE,
  output IDMEM_WE,
  output PC_WE,
  output PC_BRANCH,
  output RF_WE,
  output [ 2 : 0 ] ALUCONTROL
);

  reg [ 2 : 0 ] state;
  `define FETCH          'd0
  `define DECODE         'd1
  `define MEM_ADR        'd2
  `define MEM_READ       'd3
  `define MEM_WRITE      'd4
  `define MEM_WRITE_BACK 'd5
  `define EXECUTE        'd6
  `define ALU_WRITE_BACK 'd7
  `define BRANCH         'd8

  `define LW 6'b000000
  `define SW 6'b000000
  `define TYPE_R 6'b000000
  `define BEQ 6'b000000

  wire [ 1 : 0 ] aluop;

  assign {IDMEM2RF, IS_DST_RF, IS_DATA_ADDR, PC_SRC, ALU_SRCB_SEL, ALU_SRCA_SEL} = 
     main_decoder_mux_sel(state);
  assign {IR_WE, IDMEM_WE, PC_WE, PC_BRANCH, RF_WE} = 
     main_decoder_en(state);
  assign aluop = main_decoder_op(state);
  assign ALUCONTROL = alu_decoder(aluop, FUNCT);


  function [ 6 : 0 ] main_decoder_mux_sel;
    input [ 3 : 0 ] state;
    begin
      casex (state)
         //IDMEM2RF, IS_DST_RF, IS_DATA_ADDR, PC_SRC, ALU_SRCB_SEL, ALU_SRCA_SEL
        `FETCH         : main_decoder_mux_sel = 'bx_x_x_0_01_0;
        `DECODE        : main_decoder_mux_sel = 'bx_x_x_x_xx_x;
        `MEM_ADR       : main_decoder_mux_sel = 'bx_x_x_x_10_1;
        `MEM_READ      : main_decoder_mux_sel = 'bx_x_x_1_xx_x;
        `MEM_WRITE_BACK: main_decoder_mux_sel = 'b1_0_x_x_xx_x;
        `MEM_WRITE     : main_decoder_mux_sel = 'bx_x_x_1_xx_x;
        `EXECUTE       : main_decoder_mux_sel = 'bx_x_x_x_00_1;
        `ALU_WRITE_BACK: main_decoder_mux_sel = 'b0_1_x_x_xx_x;
        `BRANCH        : main_decoder_mux_sel = 'bx_x_x_1_00_1;
        default : main_decoder_mux_sel = 'bxxxxxxxx;
      endcase
    end
  endfunction

  function [ 4 : 0 ] main_decoder_en;
    input [ 3 : 0 ] state;
    begin
      casex (state)
         //IR_WE, IDMEM_WE, PC_WE, PC_BRANCH, RF_WE
        `FETCH         : main_decoder_en = 'b1_0_1_0_1;
        `DECODE        : main_decoder_en = 'b0_0_0_0_0;
        `MEM_ADR       : main_decoder_en = 'b0_0_0_0_0;
        `MEM_READ      : main_decoder_en = 'b0_0_0_0_0;
        `MEM_WRITE_BACK: main_decoder_en = 'b0_0_0_0_1;
        `MEM_WRITE     : main_decoder_en = 'b0_1_0_0_0;
        `EXECUTE       : main_decoder_en = 'b0_0_0_0_0;
        `ALU_WRITE_BACK: main_decoder_en = 'b0_0_0_0_1;
        `BRANCH        : main_decoder_en = 'b0_0_0_1_0;
        default : main_decoder_en = 'bxxxxxxxx;
      endcase
    end
  endfunction


  function [ 1 : 0 ] main_decoder_op;
      input [ 3 : 0 ] state;
      begin
         casex (state)
            `FETCH         : main_decoder_op = 'b00;
            `DECODE        : main_decoder_op = 'bxx;
            `MEM_ADR       : main_decoder_op = 'b00;
            `MEM_READ      : main_decoder_op = 'bxx;
            `MEM_WRITE_BACK: main_decoder_op = 'bxx;
            `MEM_WRITE     : main_decoder_op = 'bxx;
            `EXECUTE       : main_decoder_op = 'b10;
            `ALU_WRITE_BACK: main_decoder_op = 'bxx;
            `BRANCH        : main_decoder_op = 'b01;
            default        : main_decoder_op = 'bxx;
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

  always@(posedge CLK or posedge RST) begin
     if ( RST ) begin
        state <= `FETCH;
     end else begin
        case(state)
           `FETCH: 
              state <= `DECODE;
           `DECODE: begin
              case(OP)
                 `LW, `SW:
                    state <= `MEM_ADR;
                 `TYPE_R:
                    state <= `EXECUTE;
                 `BEQ:
                    state <= `BRANCH;
                 default:
                    state <= 'bx;
              endcase //(OP)
           end
           `MEM_ADR: begin
              case(OP)
                 `LW:
                    state <= `MEM_READ;
                 `SW:
                    state <= `MEM_WRITE;
                 default:
                    state <= 'bx;
              endcase //(OP)
           end
           `MEM_READ:
              state <= `MEM_WRITE_BACK;
           `EXECUTE:
              state <= `ALU_WRITE_BACK;
           `MEM_WRITE, `MEM_WRITE_BACK, `ALU_WRITE_BACK, `BRANCH:
              state <= `FETCH;
           default:
              state <= 'dx;
        endcase //(state)
         
     end
  end
endmodule

