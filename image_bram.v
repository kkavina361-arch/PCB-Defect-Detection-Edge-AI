module image_bram#(
  parameter DAT_WIDTH =8;
  parameter IMG_WWIDTH =416,
  parameter IMG_HEIGHT =416,
  parameter ADDR_WIDTH =18
  )(
   input clock,
   input rat,
   input enable,
   input [ADDR_WIDTH-1:0]pixel_addr,
   output reg [DATA_WIDTH-1:0]pixel_out
   );
   reg [DATA_WIDTH-1:0]image_mem[0:(IMG_WIDTH*IMG_HEIGHT)-1];
   inital 
   begin
      $readmemh("image.hex",image_mem);
   end
   
   always @(posedge clock)
   begin
     if(rst)
	 begin 
	    pixel_out<=0;
     end
	 else if(enable)
	  begin
	    pixel_out<=image_mem[pixel_addr];
		end
		end
		endmodule 