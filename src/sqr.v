`timescale 1ns / 1ps


module sqr(
    input clk_i,
    input rst_i,
    
    input [7:0] x,
    input start_i,
    
    output reg[7:0] mul_a,
    output reg[7:0] mul_b,
    output reg mul_start_i,
    input mul_busy_o,
    input [15:0] mul_y_bo,
    
    output busy_o,
    output reg[15:0] y_bo
    );
    
    localparam IDLE = 2'b0;
    localparam WORK = 2'b1;
    localparam WAIT1 = 2'b10;
    localparam WAIT2 = 2'b11;
    
    reg[7:0] x_bi;
    reg[1:0] state;
    
    assign busy_o = (state != IDLE);
    
    always @(posedge clk_i) begin
        if(rst_i) begin
            y_bo <= 0;
            state <= IDLE;
        end else begin
            case(state)
                IDLE:
                    if(start_i) begin
                        state <= WORK;
                        x_bi  <= x;
                    end
                WORK: begin
                    mul_a <= x_bi;
                    mul_b <= x_bi;
                    mul_start_i <= 1;
                    state <= WAIT1;
                end
                WAIT1: begin
                    mul_start_i <= 0;
                    state       <= WAIT2;
                    end
                WAIT2:
                    if(!mul_busy_o) begin
                        y_bo  <= mul_y_bo;
                        state <= IDLE;
                    end
            endcase
        end
    end   
endmodule
