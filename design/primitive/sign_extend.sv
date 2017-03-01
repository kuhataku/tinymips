module sign_extend (
   input [ 15 : 0 ] extend_in,
   output signed [ 31 : 0 ] extend_out
);
   
   assign extend_out = extend_in;

endmodule//sign_extend
