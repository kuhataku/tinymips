typedef struct packed{
  logic mem2reg;
  logic memwrite;
  logic branch;
  logic [ 2 : 0 ] alu_control;
  logic alu_src;
  logic regdst;
  logic regwrite;
} control_sig_t;
