`timescale 1ns/1ps

module tb_top_module;
    localparam H_ACTIVE = 1024;
    localparam H_FP     = 24;
    localparam H_SYNC   = 136;
    localparam H_BP     = 160;
    localparam V_ACTIVE = 768;
    localparam V_FP     = 3;
    localparam V_SYNC   = 6;
    localparam V_BP     = 29;
    localparam integer TOTAL_PIXELS = H_ACTIVE * V_ACTIVE;

    reg clk;
    reg reset_n;
    wire hsync;
    wire vsync;
    wire active_video;
    wire [23:0] rgb;

    top_module #(
        .H_ACTIVE(H_ACTIVE),
        .H_FP(H_FP),
        .H_SYNC(H_SYNC),
        .H_BP(H_BP),
        .V_ACTIVE(V_ACTIVE),
        .V_FP(V_FP),
        .V_SYNC(V_SYNC),
        .V_BP(V_BP),
        .MEM_FILE("Code\\SourceImage.hex")
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .hsync(hsync),
        .vsync(vsync),
        .active_video(active_video),
        .rgb(rgb)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    integer outfile;
    integer pixel_count;

    initial begin
        outfile = $fopen("Results\\ReconstructedImage.txt", "w");
        if (outfile == 0) begin
            $fatal(1, "Cannot open Results\\ReconstructedImage.txt for writing");
        end
    end

    always @(posedge clk) begin
        if (reset_n && active_video) begin
            $fwrite(outfile, "%06h\n", rgb);
            pixel_count = pixel_count + 1;
            if (pixel_count == TOTAL_PIXELS) begin
                $display("Captured %0d pixels", TOTAL_PIXELS);
                $fclose(outfile);
                $finish;
            end
        end
    end

    initial begin
        reset_n = 1'b0;
        pixel_count = 0;
        repeat (5) @(posedge clk);
        reset_n = 1'b1;
    end

endmodule
