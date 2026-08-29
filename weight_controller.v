`timescale 1ns/1ps

module weight_controller #(
    parameter WEIGHT_COUNT = 9
)
(
    input clock,
    input rst,
    input enable,

    output reg [$clog2(WEIGHT_COUNT)-1:0] weight_addr,
    output reg weight_done
);


always @(posedge clock)
begin

    if(rst)
    begin
        weight_addr <= 0;
        weight_done <= 0;
    end


    else if(enable)
    begin

        if(weight_addr == WEIGHT_COUNT-1)
        begin

            weight_addr <= 0;
            weight_done <= 1;

        end

        else
        begin

            weight_addr <= weight_addr + 1;
            weight_done <= 0;

        end

    end

end


endmodule 