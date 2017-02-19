module sign_extend (
   input [ 15 : 0 ] extend_in,
   output [ 31 : 0 ] extend_out
);
   
   assign extend_out = {{16{extend_in[15]}},extend_in[15:0]};

endmodule//sign_extend
