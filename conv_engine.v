module conv_engine #(
   parameter DATA_WIDTH = 8,
   parameter PRODUCT_WIDTH =16,
   parameter OUTPUT_WIDTH =32
)(
    input clock,
	input rst,
	input enable,
	
	input signed {DATA_WIDTH_1:0}p0,
	input signed {DATA_WIDTH_1:0}p1,
	input signed {DATA_WIDTH_1:0}p2,
	input signed {DATA_WIDTH_1:0}p3,
	input signed {DATA_WIDTH_1:0}p4,
	input signed {DATA_WIDTH_1:0}p5,
	input signed {DATA_WIDTH_1:0}p6,
	input signed {DATA_WIDTH_1:0}p7,
	input signed {DATA_WIDTH_1:0}p8,
	
	input signed [DATA_WIDTH-1:0] w0,
	input signed [DATA_WIDTH-1:0] w1,
	input signed [DATA_WIDTH-1:0] w2,
	input signed [DATA_WIDTH-1:0] w3,
	input signed [DATA_WIDTH-1:0] w4,
	input signed [DATA_WIDTH-1:0] w5,
	input signed [DATA_WIDTH-1:0] w7,
	input signed [DATA_WIDTH-1:0] w8,
	
	input signed[OUTPUT_WIDTH_1:0]bias,
	output signed [15:0]feature_out
	
	)
	wire signed [OUTPUT_WIDTH-1:0]conv_out;
	wire signed [OUTPUT_WIDTH-1:0]bias_out;
	
	conv3x3 CONV  
	(
	    .clock(clock),
		.rst(rst),
		.enable(enable),
		.p0(p0),
		.p1(p1),
		.p2(p2),
		.p3(p3),
		.p4(p4),
		.p5(p5),
		.p6(p6),
		.p7(p7),
		.p8(p8),
		.w0(w0),
		.w1(w1),
		.w2(w2),
		.w3(w3),
		.w4(w4),
		.w5(w5),
		.w6(w6),
		.w7(w7),
		.w8(w8),
		.conv_out(conv_out)
		
		)
    bias_add bias
	(
	  .clock(clock),
	  .rst(rst),
	  .enable(enable),
	  .conv_out(conv_out),
	  .bias(bias),
	  .bias_out(bias_out)
	  );
	silu ACT
	( 
	  .din(bias_out[15:0]),
	  .dout(feature_out)
	  );
	  endmodule 