`timescale 1ns/1ps

module weight_bram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 9
)
(
    input clock,
    input rst,


   

    input we,

    input [ADDR_WIDTH-1:0] wr_addr,

    input signed [DATA_WIDTH-1:0] wr_data,


  

    input [ADDR_WIDTH-1:0] rd_addr,

    output reg signed [DATA_WIDTH-1:0] rd_data

);




reg signed [DATA_WIDTH-1:0] memory 
[0:(1<<ADDR_WIDTH)-1];





always @(posedge clock)
begin


    if(rst)
    begin

        rd_data <= 0;

    end


    else
    begin


       

        if(we)
        begin

            memory[wr_addr] <= wr_data;

        end



       

        rd_data <= memory[rd_addr];


    end


end


endmodule