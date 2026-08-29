`timescale 1ns/1ps

module bias_add #(
    parameter ACC_WIDTH = 32
)(
    input clock,
    input rst,
    input enable,

    input signed [ACC_WIDTH-1:0] conv_out,
    input signed [ACC_WIDTH-1:0] bias,

    output reg signed [ACC_WIDTH-1:0] bias_out
);

always @(posedge clock)
begin
    if (rst)
    begin
        bias_out <= 0;
    end
    else if (enable)
    begin
        bias_out <= conv_out + bias;
    end
end

endmodule