module address_generator #(
  parameter IMG_WIDTH =416,
  parameter IMG_HEIGHT =416,
  parameter ADDR_WIDTH = 18
  )(
  input clock,
  input rst,
  input enable,
  output reg[ADDR_WIDTH_1:0] pixel_addr
  );
  localparam IMAGE_SIZE =IMAGE_WIDTH*IMAGE_HEIGHT;
  always @(posedge clock)
  begin
   if(rst)
   begin
     pixel_addr<=0;
	 end
	 
	 else if(enable)
	 begin
	 if(pixel_addr == IMAGE_SIZE-1)
	 begin
	    pixel_addr<=0;
	end
	
	else 
	begin
	  pixel_addr<= pixel_addr+1'b1;
	  end
	  end
	  end
	  endmodule 