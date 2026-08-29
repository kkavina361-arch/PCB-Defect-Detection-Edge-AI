module line_buffer #(
    parameter DATA_WIDTH = 8,
    parameter IMG_WIDTH  = 640
)(
    input                              clock,
    input                              rst,
    input                              enable,     // asserted when pixel_in is valid this cycle
    input  signed [DATA_WIDTH-1:0]     pixel_in,   // current row, streaming pixel-by-pixel

    output signed [DATA_WIDTH-1:0]     row_curr,   // pixel_in delayed 1 cycle (column-aligned)
    output signed [DATA_WIDTH-1:0]     row_prev1,  // pixel from 1 row above, same column
    output signed [DATA_WIDTH-1:0]     row_prev2   // pixel from 2 rows above, same column
);

    localparam ADDR_WIDTH = $clog2(IMG_WIDTH);

    // circular row buffers — will infer as Block RAM
    reg signed [DATA_WIDTH-1:0] ram1 [0:IMG_WIDTH-1]; // holds "1 row ago"
    reg signed [DATA_WIDTH-1:0] ram2 [0:IMG_WIDTH-1]; // holds "2 rows ago"

    reg [ADDR_WIDTH-1:0] wr_ptr;

    reg signed [DATA_WIDTH-1:0] ram1_rd;
    reg signed [DATA_WIDTH-1:0] ram2_rd;
    reg signed [DATA_WIDTH-1:0] pixel_in_d;   // delay to match 1-cycle BRAM read latency

    always @(posedge clock) begin
        if (rst) begin
            wr_ptr     <= 0;
            ram1_rd    <= 0;
            ram2_rd    <= 0;
            pixel_in_d <= 0;
        end else if (enable) begin
            // read-before-write at the current column position
            ram1_rd <= ram1[wr_ptr];
            ram2_rd <= ram2[wr_ptr];

            // shift: row(-1) -> row(-2) buffer, incoming pixel -> row(-1) buffer
            ram2[wr_ptr] <= ram1[wr_ptr];
            ram1[wr_ptr] <= pixel_in;

            // delay pixel_in by one cycle so it lines up with ram1_rd/ram2_rd
            pixel_in_d <= pixel_in;

            // column pointer wraps at end of each image row
            if (wr_ptr == IMG_WIDTH - 1)
                wr_ptr <= 0;
            else
                wr_ptr <= wr_ptr + 1;
        end
    end

    assign row_curr  = pixel_in_d;
    assign row_prev1 = ram1_rd;
    assign row_prev2 = ram2_rd;

endmodule