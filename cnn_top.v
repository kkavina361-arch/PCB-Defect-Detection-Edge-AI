module cnn_top#(
 parameter IMG_WIDTH = 416,
 parameter IMG_HEIGHT= 416
 )(
   input clock,
   input rst,
   input enable,
    
	output signed [15:0] feature_out,
	output frame_done
	);
	wire [8:0]row_count;
	wire [8:0]pixel_count;
	
	pixel_counter #(
	 .IMG_WIDTH(IMG_WIDTH),
	 .IMG_HEIGHT(IMG_HEIGHT)
	 )
	 
    pixel_counter
	(
	  .clock(clock),
	  .rst(rst),
	  .enable(enable),
	  .pixel_count(pixel_count),
	  .row_count(row_count),
	  .frame_done(frame_done)
	  );
	  wire [17:0]pixel_addr;
	  address_generator add_gen_inst
	  (
	    .clock(clock),
		.rst(rst),
		.enable(enable),
		.pixel_addr(pixel_addr)
		)
		wire signed [7:0]pixel_data;
		image_bram image_mem_inst
		(
		.clock(clock),
		.addr9pixel_addr),
		.pixel_out(pixel_data)
		);
		wire signed [7:0]row_curr;
		wire signed [7:0]row_prev1;
		wire signed [7:0]row_prev2;
		
		line_buffer line_buffer_inst
		(
		   .clock(clock),
		   .rst(rst),
		   .enable(enable),
		   .pixel_in(pixel_data),
		    .row_curr(row_curr),
            .row_prev1(row_prev1),
            .row_prev2(row_prev2)
			);
		wire signed [7:0] p0,p1,p2;
		wire signed [7:0] p3,p4,p5;
		wire signed [7:0] p6,p7,p8;
		wire window_vaild;
		sliding_window window_inst
		(
		  .clock(clock),
		  .rst(rst),
		  .enable(enable),

    .row_count(row_count),
    .pixel_count(pixel_count),

    .row_prev2(row_prev2),
    .row_prev1(row_prev1),
    .row_curr(row_curr),


    .p0(p0),
    .p1(p1),
    .p2(p2),

    .p3(p3),
    .p4(p4),
    .p5(p5),

    .p6(p6),
    .p7(p7),
    .p8(p8),

    .window_valid(window_valid)
	);
	conv_engine conv_engine_inst
	(
	  .clock(clock),
    .rst(rst),

    .enable(window_valid),


    .p0(p0),
    .p1(p1),
    .p2(p2),

    .p3(p3),
    .p4(p4),
    .p5(p5),

    .p6(p6),
    .p7(p7),
    .p8(p8),


    .feature_out(feature_out)
	);
	endmodule 