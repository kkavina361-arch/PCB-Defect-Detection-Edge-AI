module sliding_window #(
    parameter DATA_WIDTH = 8
)
(
    input clock,
    input rst,
    input enable,

    // Pixel position counters
    input [10:0] row_count,
    input [10:0] pixel_count,


    // Input from line buffer
    input signed [DATA_WIDTH-1:0] row_prev2,
    input signed [DATA_WIDTH-1:0] row_prev1,
    input signed [DATA_WIDTH-1:0] row_curr,


    // 3x3 window output

    output reg signed [DATA_WIDTH-1:0] p0,
    output reg signed [DATA_WIDTH-1:0] p1,
    output reg signed [DATA_WIDTH-1:0] p2,

    output reg signed [DATA_WIDTH-1:0] p3,
    output reg signed [DATA_WIDTH-1:0] p4,
    output reg signed [DATA_WIDTH-1:0] p5,

    output reg signed [DATA_WIDTH-1:0] p6,
    output reg signed [DATA_WIDTH-1:0] p7,
    output reg signed [DATA_WIDTH-1:0] p8,


    // valid signal for convolution

    output reg window_valid

);



//////////////////////////////////////////////////////
// Horizontal delay registers
//////////////////////////////////////////////////////


// Previous previous row delay

reg signed [DATA_WIDTH-1:0] row2_d1;
reg signed [DATA_WIDTH-1:0] row2_d2;


// Previous row delay

reg signed [DATA_WIDTH-1:0] row1_d1;
reg signed [DATA_WIDTH-1:0] row1_d2;


// Current row delay

reg signed [DATA_WIDTH-1:0] curr_d1;
reg signed [DATA_WIDTH-1:0] curr_d2;



//////////////////////////////////////////////////////
// Sequential Logic
//////////////////////////////////////////////////////

always @(posedge clock)
begin

    if(rst)
    begin

        row2_d1 <= 0;
        row2_d2 <= 0;

        row1_d1 <= 0;
        row1_d2 <= 0;

        curr_d1 <= 0;
        curr_d2 <= 0;


        p0 <= 0;
        p1 <= 0;
        p2 <= 0;

        p3 <= 0;
        p4 <= 0;
        p5 <= 0;

        p6 <= 0;
        p7 <= 0;
        p8 <= 0;


        window_valid <= 0;

    end


    else if(enable)
    begin


        ////////////////////////////////////////////
        // Shift row 2 pixels
        ////////////////////////////////////////////

        row2_d2 <= row2_d1;
        row2_d1 <= row_prev2;



        ////////////////////////////////////////////
        // Shift row 1 pixels
        ////////////////////////////////////////////

        row1_d2 <= row1_d1;
        row1_d1 <= row_prev1;



        ////////////////////////////////////////////
        // Shift current row pixels
        ////////////////////////////////////////////

        curr_d2 <= curr_d1;
        curr_d1 <= row_curr;



        ////////////////////////////////////////////
        // Generate 3x3 window
        ////////////////////////////////////////////

        /*
        
        Example:

        p0 p1 p2
        p3 p4 p5
        p6 p7 p8

        */


        p0 <= row2_d2;
        p1 <= row2_d1;
        p2 <= row_prev2;



        p3 <= row1_d2;
        p4 <= row1_d1;
        p5 <= row_prev1;



        p6 <= curr_d2;
        p7 <= curr_d1;
        p8 <= row_curr;




        ////////////////////////////////////////////
        // Window valid generation
        ////////////////////////////////////////////

        if((row_count >= 2) && (pixel_count >= 2))
        begin

            window_valid <= 1'b1;

        end

        else
        begin

            window_valid <= 1'b0;

        end



    end

end


endmodule