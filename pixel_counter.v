module pixel_counter #(
    parameter IMG_WIDTH  = 416,
    parameter IMG_HEIGHT = 416
)
(
    input clock,
    input rst,
    input enable,

    output reg [8:0] pixel_count,
    output reg [8:0] row_count,

    output reg frame_done
);


always @(posedge clock)
begin

    if(rst)
    begin
        pixel_count <= 0;
        row_count   <= 0;
        frame_done  <= 0;
    end


    else if(enable)
    begin

        frame_done <= 0;


        // End of column
        if(pixel_count == IMG_WIDTH-1)
        begin

            pixel_count <= 0;


            // End of image
            if(row_count == IMG_HEIGHT-1)
            begin

                row_count  <= 0;
                frame_done <= 1;

            end


            else
            begin

                row_count <= row_count + 1;

            end

        end


        else
        begin

            pixel_count <= pixel_count + 1;

        end

    end

end


endmodule