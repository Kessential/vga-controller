`timescale 1ns/1ps

module top_module #(
    parameter H_ACTIVE  = 1024,
    parameter H_FP      = 24,
    parameter H_SYNC    = 136,
    parameter H_BP      = 160,
    parameter V_ACTIVE  = 768,
    parameter V_FP      = 3,
    parameter V_SYNC    = 6,
    parameter V_BP      = 29,
    parameter MEM_FILE  = "Code\\SourceImage.hex"
) (
    input  wire        clk,
    input  wire        reset_n,
    output reg         hsync,
    output reg         vsync,
    output wire        active_video,
    output wire [23:0] rgb
);

    wire        hsync_i;
    wire        vsync_i;
    wire        active_video_i;
    wire [10:0] pixel_x;
    wire [9:0]  pixel_y;
    wire [23:0] rgb_i;
    wire        rgb_valid_i;

    vga_timing #(
        .H_ACTIVE(H_ACTIVE),
        .H_FP(H_FP),
        .H_SYNC(H_SYNC),
        .H_BP(H_BP),
        .V_ACTIVE(V_ACTIVE),
        .V_FP(V_FP),
        .V_SYNC(V_SYNC),
        .V_BP(V_BP)
    ) u_timing (
        .clk(clk),
        .reset_n(reset_n),
        .hsync(hsync_i),
        .vsync(vsync_i),
        .active_video(active_video_i),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    mem_interface #(
        .H_ACTIVE(H_ACTIVE),
        .V_ACTIVE(V_ACTIVE),
        .MEM_FILE(MEM_FILE)
    ) u_mem (
        .clk(clk),
        .reset_n(reset_n),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .active_video(active_video_i),
        .rgb_out(rgb_i),
        .rgb_valid(rgb_valid_i)
    );

    assign active_video = rgb_valid_i;
    assign rgb = rgb_i;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            hsync <= 1'b1;
            vsync <= 1'b1;
        end else begin
            hsync <= hsync_i;
            vsync <= vsync_i;
        end
    end

endmodule
