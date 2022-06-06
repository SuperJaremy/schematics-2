`timescale 1ns / 1ps


module func_tb;

    reg clk_i;
    reg rst_i;
    
    reg[7:0] func_a;
    reg[7:0] func_b;
    reg func_start_i;

    wire func_busy_o;
    wire[7:0] func_y_bo;
    
    func func_1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a(func_a),
        .b(func_b),
        .start_i(func_start_i),
        .busy_o(func_busy_o),
        .y_bo(func_y_bo)
    );
    
    integer a_test[2:0];
    integer b_test[2:0];
    integer res_test[2:0];

    integer i;

initial begin
    clk_i = 0;
    a_test[0] = 0;
    a_test[1] = 15;
    a_test[2] = 8;
    
    b_test[0] = 1;
    b_test[1] = 255;
    b_test[2] = 64;
    
    res_test[0] = 1;
    res_test[1] = 231;
    res_test[2] = 68;
    
    rst_i <= 1;
    #10;
    rst_i <= 0;
    
    for(i=0; i < 3; i = i + 1) begin
        func_a <= a_test[i];
        func_b <= b_test[i];
        func_start_i <= 1;
        #10
        func_start_i <= 0;
        @(negedge func_busy_o);
        if(func_y_bo == res_test[i] && func_a == a_test[i] && func_b == b_test[i])
            $display("Correct! a=%d, b=%d, res=%d", func_a, func_b, func_y_bo);
        else
            $display("Incorrect! a=%d, b=%d, res=%d", func_a, func_b, func_y_bo);
    end
end
    
    always begin
        clk_i = !clk_i;
        #5;
    end
    
    

endmodule
