`timescale 1ns / 1ps


module sum_tb;

reg[7:0] sum_a;
reg[7:0] sum_b;

wire[8:0] sum_res;


sum sum_1(
    .a(sum_a),
    .b(sum_b),
    .res(sum_res)
);

integer test_a[4:0];

integer test_b[4:0];

integer test_res[4:0];

integer i;

initial begin
test_a[0] = 0;
test_a[1] = 255;
test_a[2] = 45;
test_a[3] = 103;
test_a[4] = 56;

test_b[0] = 0;
test_b[1] = 255;
test_b[2] = 37;
test_b[3] = 89;
test_b[4] = 12;

test_res[0] = 0;
test_res[1] = 510;
test_res[2] = 82;
test_res[3] = 192;
test_res[4] = 68;
    for(i = 0; i < 5; i = i+1) begin
        sum_a <= test_a[i];
        sum_b <= test_b[i];
        
        #5
        
        if(test_res[i] == sum_res && sum_a == test_a[i] && sum_b == test_b[i])
            $display("Correct! a=%d, b=%d, res=%d", sum_a, sum_b, sum_res);
        else
            $display("Incorrect! a=%d, b=%d, res=%d", sum_a, sum_b, sum_res);
    end
end

endmodule
