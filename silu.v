`timescale 1ns/1ps

module silu #(
    parameter DATA_WIDTH = 16
)
(
    input signed [DATA_WIDTH-1:0] din,
    output reg signed [DATA_WIDTH-1:0] dout
);


always @(*)
begin

    case(din)

        -16'sd8 : dout = 0;
        -16'sd7 : dout = -1;
        -16'sd6 : dout = -1;
        -16'sd5 : dout = -2;
        -16'sd4 : dout = -2;
        -16'sd3 : dout = -1;
        -16'sd2 : dout = -1;
        -16'sd1 : dout = 0;

         16'sd0 : dout = 0;

         16'sd1 : dout = 1;
         16'sd2 : dout = 2;
         16'sd3 : dout = 3;
         16'sd4 : dout = 4;
         16'sd5 : dout = 5;
         16'sd6 : dout = 6;
         16'sd7 : dout = 7;
         16'sd8 : dout = 8;


        default:
        begin

            if(din > 16'sd8)
                dout = din;

            else
                dout = 0;

        end

    endcase

end

endmodule