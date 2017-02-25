`define I_INSTR
`define R_INSTR
`define J_INSTR

typedef struct packed{
  logic mem2reg;
  logic memwrite;
  logic branch;
  logic [ 2 : 0 ] alucontrol;
  logic alusrc;
  logic regdst;
  logic regwrite;
} control_sig_t;
