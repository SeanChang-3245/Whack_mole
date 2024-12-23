module Top(
    input wire clk,
    input wire rst,
    input wire btnR,

    inout wire PS2_CLK,
    inout wire PS2_DATA,

    output wire [3:0] DIGIT,
    output wire [6:0] DISPLAY,
    output wire [15:0] LED,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

    wire start_game;
    button_preprocess bp(.clk(clk), .signal_in(btnR), .signal_out(start_game));

    // output of game
    wire [3:0] score;
    wire [2:0] cur_state;
    wire [8:0] map;

    // output of keyboard
    wire [3:0] one_pulse_pos;


    Keyboard_Interface Keyboard_Interface_inst(
        .clk(clk),
        .rst(rst),

        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),

        .one_pulse_pos(one_pulse_pos)
    );

    Game_Control Game_Control_inst(
        .clk(clk),
        .rst(rst),
        .start_game(start_game),
        .one_pulse_pos(one_pulse_pos),

        .cur_score(score),
        .cur_state(cur_state),
        .map(map)
    );

    Display_Top Display_Top_inst(
        .clk(clk),
        .rst(rst),

        .map(map),
        .score(score),

        .DIGIT(DIGIT),
        .DISPLAY(DISPLAY),
        .hsync(hsync),
        .vsync(vsync),
        .vgaRed(vgaRed),
        .vgaGreen(vgaGreen),
        .vgaBlue(vgaBlue)
    );

    assign LED = {cur_state, 4'b0, map};
    assign {hsync, vsync, vgaRed, vgaBlue, vgaGreen} = 0;

endmodule