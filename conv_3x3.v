module conv3x3 #(
    parameter DATA_WIDTH = 8,
    parameter PRODUCT_WIDTH = 16,
    parameter OUTPUT_WIDTH = 32
)(
input clock,
input rst,
input enable ,
//input pixels 
input signed [DATA_WIDTH-1:0] p0,
input signed [DATA_WIDTH-1:0] p1,
input signed [DATA_WIDTH-1:0] p2,
input signed [DATA_WIDTH-1:0] p3,
input signed [DATA_WIDTH-1:0] p4,
input signed [DATA_WIDTH-1:0] p5,
input signed [DATA_WIDTH-1:0] p6,
input signed [DATA_WIDTH-1:0] p7,
input signed [DATA_WIDTH-1:0] p8,
//input kernals
input signed [DATA_WIDTH-1:0] w0,
input signed [DATA_WIDTH-1:0] w1,
input signed [DATA_WIDTH-1:0] w2,
input signed [DATA_WIDTH-1:0] w3,
input signed [DATA_WIDTH-1:0] w4,
input signed [DATA_WIDTH-1:0] w5,
input signed [DATA_WIDTH-1:0] w6,
input signed [DATA_WIDTH-1:0] w7,
input signed [DATA_WIDTH-1:0] w8,


output reg signed [OUTPUT_WIDTH-1:0] conv_out
);
wire signed [PRODUCT_WIDTH-1:0]m0,m1,m2,m3,m4,m5,m6,m7,m8;
//instanisation
multiplier_unit M0(
    .pixel_in(p0),
    .weight_in(w0),
    .product_out(m0)
);
multiplier_unit M1(
    .pixel_in(p1),
    .weight_in(w1),
    .product_out(m1)
);
multiplier_unit M2(
    .pixel_in(p2),
    .weight_in(w2),
    .product_out(m2)
);
multiplier_unit M3(
    .pixel_in(p3),
    .weight_in(w3),
    .product_out(m3)
);
multiplier_unit M4(
    .pixel_in(p4),
    .weight_in(w4),
    .product_out(m4)
);
multiplier_unit M5(
    .pixel_in(p5),
    .weight_in(w5),
    .product_out(m5)
);
multiplier_unit M6(
    .pixel_in(p6),
    .weight_in(w6),
    .product_out(m6)
);
multiplier_unit M7(
    .pixel_in(p7),
    .weight_in(w7),
    .product_out(m7)
);
multiplier_unit M8(
    .pixel_in(p8),
    .weight_in(w8),
    .product_out(m8)
);
//adder tree 
wire signed [OUTPUT_WIDTH-1:0]s0,s1,s2,s3;
wire signed [OUTPUT_WIDTH-1:0]s4,s5;
wire signed [OUTPUT_WIDTH-1:0]conv_sum;

assign s0=m0+m1;
assign s1=m2+m3;
assign s2=m4+m5;
assign s3=m6+m7;

assign s4= s0+s1;
assign s5=s2+s3;

assign conv_sum=s4+s5+m8;

//output register
always@(posedge clock)
begin
if(rst)
begin
    conv_out <=0;
	end
else if(enable)
begin 
     conv_out<=conv_sum;
end
end
endmodule 
