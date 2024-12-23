module Display_Top(
    input wire clk,
    input wire rst,
    
    input wire [8:0] map,
    input wire [3:0] score,

    output wire [3:0] DIGIT,
    output wire [6:0] DISPLAY,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);



    wire [3:0] score_ten = score / 10;
    wire [3:0] score_one = score >= 10 ? score - 10 : score;
    SevenSegment SevenSegment_inst(
        .clk(clk),
        .rst(rst),
        .nums({8'b0, score_ten, score_one}),
        .digit(DIGIT),
        .display(DISPLAY)
    );


endmodule