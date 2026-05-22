`timescale 1ns/1ps

module tb_vga_timing;
    localparam H_ACTIVE = 1024;
    localparam H_FP     = 24;
    localparam H_SYNC   = 136;
    localparam H_BP     = 160;
    localparam V_ACTIVE = 768;
    localparam V_FP     = 3;
    localparam V_SYNC   = 6;
    localparam V_BP     = 29;
    localparam H_TOTAL  = H_ACTIVE + H_FP + H_SYNC + H_BP;
    localparam V_TOTAL  = V_ACTIVE + V_FP + V_SYNC + V_BP;

    reg clk;
    reg reset_n;
    wire hsync;
    wire vsync;
    wire active_video;
    wire [10:0] pixel_x;
    wire [9:0]  pixel_y;

    vga_timing #(
        .H_ACTIVE(H_ACTIVE),
        .H_FP(H_FP),
        .H_SYNC(H_SYNC),
        .H_BP(H_BP),
        .V_ACTIVE(V_ACTIVE),
        .V_FP(V_FP),
        .V_SYNC(V_SYNC),
        .V_BP(V_BP)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .hsync(hsync),
        .vsync(vsync),
        .active_video(active_video),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    integer h_count;
    integer v_count;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1) begin
                    v_count <= 0;
                end else begin
                    v_count <= v_count + 1;
                end
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    wire exp_active = (h_count < H_ACTIVE) && (v_count < V_ACTIVE);
    wire exp_hsync  = ~((h_count >= (H_ACTIVE + H_FP)) &&
                        (h_count <  (H_ACTIVE + H_FP + H_SYNC)));
    wire exp_vsync  = ~((v_count >= (V_ACTIVE + V_FP)) &&
                        (v_count <  (V_ACTIVE + V_FP + V_SYNC)));

    always @(posedge clk) begin
        if (reset_n) begin
            if (pixel_x !== h_count[10:0]) begin
                $fatal(1, "pixel_x mismatch: got %0d exp %0d", pixel_x, h_count);
            end
            if (pixel_y !== v_count[9:0]) begin
                $fatal(1, "pixel_y mismatch: got %0d exp %0d", pixel_y, v_count);
            end
            if (active_video !== exp_active) begin
                $fatal(1, "active_video mismatch at x=%0d y=%0d", h_count, v_count);
            end
            if (hsync !== exp_hsync) begin
                $fatal(1, "hsync mismatch at x=%0d y=%0d", h_count, v_count);
            end
            if (vsync !== exp_vsync) begin
                $fatal(1, "vsync mismatch at x=%0d y=%0d", h_count, v_count);
            end
        end
    end

    initial begin
        reset_n = 1'b0;
        repeat (5) @(posedge clk);
        reset_n = 1'b1;

        repeat (H_TOTAL * V_TOTAL * 2) @(posedge clk);
        $display("tb_vga_timing: PASS");
        $finish;
    end

endmodule
