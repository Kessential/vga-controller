`timescale 1ns/1ps

module vga_timing #(
    parameter H_ACTIVE = 1024,
    parameter H_FP     = 24,
    parameter H_SYNC   = 136,
    parameter H_BP     = 160,
    parameter V_ACTIVE = 768,
    parameter V_FP     = 3,
    parameter V_SYNC   = 6,
    parameter V_BP     = 29
) (
    input  wire        clk,
    input  wire        reset_n,
    output reg         hsync,
    output reg         vsync,
    output reg         active_video,
    output reg [10:0]  pixel_x,
    output reg [9:0]   pixel_y
);

    localparam H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;
    localparam V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;

    reg [10:0] h_count;
    reg [9:0]  v_count;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            h_count <= 11'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 11'd0;
                if (v_count == V_TOTAL - 1) begin
                    v_count <= 10'd0;
                end else begin
                    v_count <= v_count + 1'b1;
                end
            end else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    always @(*) begin
        pixel_x = h_count;
        pixel_y = v_count;
        active_video = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);
        hsync = ~((h_count >= (H_ACTIVE + H_FP)) &&
                  (h_count <  (H_ACTIVE + H_FP + H_SYNC)));
        vsync = ~((v_count >= (V_ACTIVE + V_FP)) &&
                  (v_count <  (V_ACTIVE + V_FP + V_SYNC)));
    end

endmodule
