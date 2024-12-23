module Speaker_top(
    input wire clk,
    input wire rst,

    input wire hit,
    input wire en_music,

    output wire audio_mclk,
    output wire audio_lrck,
    output wire audio_sck,
    output wire audio_sdin
);
    wire hit_op;

    one_pulse op1(.clk(clk), .pb_db(hit), .pb_op(hit_op));


    Audio_top Audio_top_inst(
        .clk(clk),
        .rst(rst),
        .hit(hit_op),
        .en_music(en_music),
        
        .audio_mclk(audio_mclk),
        .audio_lrck(audio_lrck),
        .audio_sck(audio_sck),
        .audio_sdin(audio_sdin)
    );

endmodule