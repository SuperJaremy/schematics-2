`timescale 1ns / 1ps

module cbr_tb;

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

wire[7:0] sum_a;
wire[7:0] sum_b;
wire[8:0] sum_res;

sum sum_1(
    .a(sum_a),
    .b(sum_b),
    .res(sum_res)
);

reg[7:0] cbrt_x;
reg cbrt_start_i;
wire cbrt_busy_o;
wire[2:0] cbrt_y_bo;

cbrt cbrt_1(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .x(cbrt_x),
    .start_i(cbrt_start_i),
    .sum_a(sum_a),
    .sum_b(sum_b),
    .sum_res(sum_res),
    .mul_a(mul_a),
    .mul_b(mul_b),
    .mul_start_i(mul_start_i),
    .mul_busy_o(mul_busy_o),
    .mul_y_bo(mul_y_bo),
    .busy_o(cbrt_busy_o),
    .y_bo(cbrt_y_bo)
);    

integer x_test[2:0];
integer res_test[2:0];

integer i;

initial begin

    clk_i = 0;
    x_test[0] = 0;
    x_test[1] = 255;
    x_test[2] = 64;
    
    res_test[0] = 0;
    res_test[1] = 6;
    res_test[2] = 4;
    
    rst_i <= 1;
    #10;
    rst_i <= 0;
    
    for(i=0; i < 3; i = i + 1) begin
        cbrt_x <= x_test[i];
        cbrt_start_i <= 1;
        #10
        cbrt_start_i <= 0;
        #1000
        if(cbrt_y_bo == res_test[i] && cbrt_x == x_test[i])
            $display("Correct! x=%d, res=%d", cbrt_x, cbrt_y_bo);
        else
            $display("Incorrect! x=%d, res=%d", cbrt_x, cbrt_y_bo);
        #10;
    end
end

always begin
    #5;
    clk_i=!clk_i;
end

endmodule
