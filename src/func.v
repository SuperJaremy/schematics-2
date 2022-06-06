`timescale 1ns / 1ps


module func(
    input clk_i,
    input rst_i,

    input [7:0] a,
    input [7:0] b,
    input start_i,
    
    output busy_o,
    output reg[7:0] y_bo
    );
    
    
    localparam IDLE = 3'b000;
    localparam ST_1 = 3'b001;
    localparam ST_2 = 3'b010;
    localparam ST_3 = 3'b011;
    localparam ST_4 = 3'b100;
    
    reg[3:0] state;
    reg[7:0] a_bi;
    reg      a_ready;
    reg[7:0] b_bi;
    reg      b_ready;
    wire[7:0] sum_a_copy;
    wire[7:0] sum_b_copy;
    reg[7:0] sum_a_reg;
    reg[7:0] sum_b_reg;
    
    wire[7:0] sum_a;
    wire[7:0] sum_b;
    wire[8:0] sum_res;
    
    wire[7:0] mul1_a;
    wire[7:0] mul1_b;
    wire mul1_start_i;
    wire mul1_busy_o;
    wire[15:0] mul1_y_bo;
    
    wire[7:0] mul2_a;
    wire[7:0] mul2_b;
    wire mul2_start_i;
    wire mul2_busy_o;
    wire[15:0] mul2_y_bo;
    
    reg[7:0] sqr_x;
    reg sqr_start_i;
    wire sqr_busy_o;
    wire[8:0] sqr_y_bo;
    
    reg[7:0] cbrt_x;
    reg cbrt_start_i;
    wire cbrt_busy_o;
    wire[2:0] cbrt_y_bo;
    
    sum sum_1(
        .a(sum_a),
        .b(sum_b),
        .res(sum_res)
    );
    
    mult mul_1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a_bi(mul1_a),
        .b_bi(mul1_b),
        .start_i(mul1_start_i),
        .busy_o(mul1_busy_o),
        .y_bo(mul1_y_bo)
    );
    
    mult mul_2(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a_bi(mul2_a),
        .b_bi(mul2_b),
        .start_i(mul2_start_i),
        .busy_o(mul2_busy_o),
        .y_bo(mul2_y_bo)
    );
    
    sqr sqr_1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .x(sqr_x),
        .start_i(sqr_start_i),
        .mul_a(mul1_a),
        .mul_b(mul1_b),
        .mul_start_i(mul1_start_i),
        .mul_busy_o(mul1_busy_o),
        .mul_y_bo(mul1_y_bo),
        .busy_o(sqr_busy_o),
        .y_bo(sqr_y_bo)
    );
    
    cbrt cbrt_1(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .x(cbrt_x),
        .start_i(cbrt_start_i),
        .sum_a(sum_a_copy),
        .sum_b(sum_b_copy),
        .sum_res(sum_res),
        .mul_a(mul2_a),
        .mul_b(mul2_b),
        .mul_start_i(mul2_start_i),
        .mul_busy_o(mul2_busy_o),
        .mul_y_bo(mul2_y_bo),
        .busy_o(cbrt_busy_o),
        .y_bo(cbrt_y_bo)
    );
    
    wire[7:0] cbrt_res_compl;
    
    assign busy_o = (state != IDLE);
    assign sum_a = b_ready ? sum_a_reg : sum_a_copy;
    assign sum_b = b_ready ? sum_b_reg : sum_b_copy;
    assign cbrt_res_compl = {5'b0, cbrt_y_bo[2:0]};
    
    always @(posedge clk_i)
        if(rst_i) begin
            state <= IDLE;
            y_bo  <= 0;
        end else begin
            case(state)
                IDLE:
                    if(start_i) begin
                        a_bi    <= a;
                        a_ready <= 0;
                        b_bi    <= b;
                        b_ready <= 0;
                        state   <= ST_1;
                    end
                    
                ST_1: begin
                    sqr_x        <= a_bi;    
                    cbrt_x       <= b_bi;
                    sqr_start_i  <= 1;
                    cbrt_start_i <= 1;
                    state        <= ST_2;
                    end
                
                ST_2: begin
                    sqr_start_i <= 0;
                    cbrt_start_i <= 0;
                    a_bi  <= 0;
                    b_bi  <= 0;
                    state <= ST_3;
                    end
                
                ST_3: begin
                    if(!sqr_busy_o && !a_ready) begin
                        a_bi    <= sqr_y_bo;
                        a_ready <= 1;
                    end
                    if(!cbrt_busy_o && !b_ready) begin
                        b_bi    <= cbrt_res_compl;
                        b_ready <= 1;
                    end
                    if(a_ready && b_ready) begin
                        sum_a_reg <= a_bi;
                        sum_b_reg <= b_bi;
                        state <= ST_4;
                    end
                    end
                    
                ST_4: begin
                    y_bo <= sum_res;
                    state <= IDLE;
                end 
            endcase
        end
endmodule
