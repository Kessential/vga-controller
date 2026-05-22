`timescale 1ns/1ps

module mem_interface #(
    parameter H_ACTIVE  = 1024,
    parameter V_ACTIVE  = 768,
    parameter ADDR_WIDTH = 20,
    parameter MEM_FILE  = "Code\\SourceImage.hex"
) (
    input  wire                   clk,
    input  wire                   reset_n,
    input  wire [10:0]            pixel_x,
    input  wire [9:0]             pixel_y,
    input  wire                   active_video,
    output reg  [23:0]            rgb_out,
    output reg                    rgb_valid
);

    localparam integer MEM_DEPTH = H_ACTIVE * V_ACTIVE;

    reg [23:0] mem [0:MEM_DEPTH-1];

    wire [ADDR_WIDTH-1:0] addr_next;
    assign addr_next = (pixel_y * H_ACTIVE) + pixel_x[9:0];

    integer i;
    initial begin
        for (i = 0; i < MEM_DEPTH; i = i + 1) begin
            mem[i] = 24'h000000;
        end
        $readmemh(MEM_FILE, mem);
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rgb_out   <= 24'h000000;
            rgb_valid <= 1'b0;
        end else begin
            if (active_video) begin
                rgb_out <= mem[addr_next];
                rgb_valid <= 1'b1;
            end else begin
                rgb_out <= 24'h000000;
                rgb_valid <= 1'b0;
            end
        end
    end

endmodule
