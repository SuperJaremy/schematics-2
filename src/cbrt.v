`timescale 1ns / 1ps


module cbrt(
    input clk_i,
    input rst_i,

    input [7:0] x,
    input start_i,
    
    output reg [7:0] sum_a,
    output reg [7:0] sum_b,
    input  [8:0] sum_res,
    
    output reg [7:0] mul_a,
    output reg [7:0] mul_b,
    output reg mul_start_i,
    input mul_busy_o,
    input[15:0] mul_y_bo,
    
    output busy_o,
    output reg[2:0] y_bo
    );
    
    localparam IDLE = 4'b0000;
    localparam ST_1 = 4'b0001;
    localparam ST_2 = 4'b0010;
    localparam ST_3 = 4'b0011;
    localparam ST_4 = 4'b0100;
    localparam ST_5 = 4'b0101;
    localparam ST_6 = 4'b0110;
    localparam ST_7 = 4'b0111;
    localparam ST_8 = 4'b1000;
    localparam ST_9 = 4'b1001;
    localparam ST_A = 4'b1010;
    
    reg [15:0] b;
    reg  [7:0] x_bi;
    reg signed [3:0] s;
    reg  [2:0] y;
    wire [2:0] shifted_y;
    wire [2:0] incremented_y;
    reg  [3:0] state;
    
    assign shifted_y = y << 1;
    assign incremented_y = y + 1;
    assign busy_o = (state != IDLE);
    
    always @(posedge clk_i) begin
        if(rst_i) begin
            b     <= 0;
            x_bi     <= 0;
            state <= IDLE;
            y_bo  <= 0;
         end else begin
            case(state)
                IDLE:
                    if(start_i) begin
                        state <= ST_1;
                        x_bi     <= x;
                        y     <= 0;
                        s     <= 6;
                    end
                    
                ST_1:
                    if(s > -3) begin
                        y     <= shifted_y;
                        state <= ST_2;
                    end else begin
                        y_bo  <= y;
                        state <= IDLE;
                    end
                    
                ST_2: begin
                    mul_a <= 3;
                    mul_b <= y;
                    mul_start_i <= 1;
                    state <= ST_3;
                    end
                    
                ST_3: begin
                    mul_start_i <= 0;
                    state <= ST_4;
                    end
                    
                ST_4:
                    if(!mul_busy_o) begin
                        b <= mul_y_bo;
                        state <= ST_5;
                    end  
                 
                ST_5: begin
                mul_a <= b;
                mul_b <= incremented_y;
                mul_start_i <= 1;
                state <= ST_6;
                end
                
                ST_6: begin
                    mul_start_i <= 0;
                    state <= ST_7;
                    end
                   
                ST_7:
                    if(!mul_busy_o) begin
                        b <= mul_y_bo;
                        state <= ST_8;
                    end
                    
                ST_8: begin
                    b <= (b + 1) << s;
                    state <= ST_9;
                    end
                    
                ST_9: begin
                    if(x_bi >= b) begin
                        sum_a <= x_bi;
                        sum_b <= -b;
                        state <= ST_A;
                    end
                    else begin
                        s <= (s - 3);
                        state <= ST_1;
                    end
                    end
                ST_A: begin
                    x_bi  <= sum_res;
                    y     <= incremented_y;
                    s     <= (s - 3);
                    state <= ST_1;
                end
            endcase        
         end  
    end              
endmodule
