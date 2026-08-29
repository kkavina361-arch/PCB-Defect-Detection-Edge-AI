module multiplier_unit #(
parameter DATA_WIDTH = 8,
parameter ACC_WIDTH = 32,
parameter PRODUCT_WIDTH=DATA_WIDTH+WEIGHT_WIDTH,
parameter WEIGHT_WIDTH=8)(
)
input clock,
input rst,
input signed [DATA_WIDTH-1:0]pixel_in,
input signed [WEIGHT_WIDTH-1:0]weight_in,
output  signed [PRODUCT_WIDTH-1:0]product;
);

assign product =pixel_in*weight_in;
endmodule 