`timescale 1ns / 1ps


module mult_tb;

reg clk_i;
reg rst_i;
reg[7:0] mul_a;
reg[7:0] mul_b;
reg mul_start_i;

wire mul_busy_o;
wire[15:0] mul_y_bo;

mult mult_1(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .a_bi(mul_a),
    .b_bi(mul_b),
    .start_i(mul_start_i),
    .busy_o(mul_busy_o),
    .y_bo(mul_y_bo)
);

integer a_test[2:0];
integer b_test[2:0];
integer res_test[2:0];

integer i;

initial begin
    clk_i = 0;
    a_test[0] = 0;
    a_test[1] = 255;
    a_test[2] = 16;
    
    b_test[0] = 1;
    b_test[1] = 255;
    b_test[2] = 117;
    
    res_test[0] = 0;
    res_test[1] = 65025;
    res_test[2] = 1872;
    
    rst_i <= 1;
    #10;
    rst_i <= 0;
    
    for(i=0; i < 3; i = i + 1) begin
        mul_a <= a_test[i];
        mul_b <= b_test[i];
        mul_start_i <= 1;
        #10
        mul_start_i <= 0;
        #100
        if(mul_y_bo == res_test[i] && mul_a == a_test[i] && mul_b == b_test[i])
            $display("Correct! a=%d, b=%d, res=%d", mul_a, mul_b, mul_y_bo);
        else
            $display("Incorrect! a=%d, b=%d, res=%d", mul_a, mul_b, mul_y_bo);
        #10;
    end
end

always begin
    #5;
    clk_i = !clk_i;
end

endmodule
