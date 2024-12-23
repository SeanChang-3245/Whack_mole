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
    // output wire audio_mclk,
    // output wire audio_lrck,
    // output wire audio_sck,
    // output wire audio_sdin
);

    wire start_game;
    button_preprocess bp(.clk(clk), .signal_in(btnR), .signal_out(start_game));

    // output of game
    wire [3:0] score;
    wire [2:0] cur_state;
    wire [8:0] map;

    // output of keyboard
    wire [3:0] one_pulse_pos;
    wire hit;
    wire en_music;


    Keyboard_Interface Keyboard_Interface_inst(
        .clk(clk),
        .rst(rst),

        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),

        .one_pulse_pos(one_pulse_pos),
        .hit(hit)
    );

    Game_Control Game_Control_inst(
        .clk(clk),
        .rst(rst),
        .start_game(start_game),
        .one_pulse_pos(one_pulse_pos),
        .en_music(en_music),

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

    // Audio_top Audio_top_inst(
    //     .clk(clk),
    //     .rst(rst),
    //     .hit(hit),
    //     .en_music(en_music),
        
    //     .audio_mclk(audio_mclk),
    //     .audio_lrck(audio_lrck),
    //     .audio_sck(audio_sck),
    //     .audio_sdin(audio_sdin)
    // );

    assign LED = {cur_state, 4'b0, map};
    // assign {hsync, vsync, vgaRed, vgaBlue, vgaGreen} = 0;

endmodule