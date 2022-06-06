`timescale 1ns / 1ps


module sq_tb;

reg clk_i;
reg rst_i;

wire[7:0] mul_a;
wire[7:0] mul_b;
wire mul_start_i;
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

reg[7:0] sqr_x;
reg sqr_start_i;
wire sqr_busy_o;
wire[15:0] sqr_y_bo;

sqr sqr_1(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .x(sqr_x),
    .start_i(sqr_start_i),
    .mul_a(mul_a),
    .mul_b(mul_b),
    .mul_start_i(mul_start_i),
    .mul_busy_o(mul_busy_o),
    .mul_y_bo(mul_y_bo),
    .busy_o(sqr_busy_o),
    .y_bo(sqr_y_bo)
);

integer x_test[2:0];
integer res_test[2:0];

integer i;

initial begin

    clk_i = 0;
    x_test[0] = 0;
    x_test[1] = 255;
    x_test[2] = 54;
    
    res_test[0] = 0;
    res_test[1] = 65025;
    res_test[2] = 2916;
    
    rst_i <= 1;
    #10;
    rst_i <= 0;
    
    for(i=0; i < 3; i = i + 1) begin
        sqr_x <= x_test[i];
        sqr_start_i <= 1;
        #10
        sqr_start_i <= 0;
        #150
        if(sqr_y_bo == res_test[i] && sqr_x == x_test[i])
            $display("Correct! x=%d, res=%d", sqr_x, sqr_y_bo);
        else
            $display("Incorrect! x=%d, res=%d", sqr_x, sqr_y_bo);
        #10;
    end
end

always begin
    #5;
    clk_i=!clk_i;
end
endmodule
