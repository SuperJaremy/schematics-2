`timescale 1ns / 1ps

module sum(
input wire[7:0] a,
input wire[7:0] b,
output wire[8:0] res
    );
    
    assign res = a + b;
    
endmodule
