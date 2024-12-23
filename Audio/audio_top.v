module Audio_top (
    input wire clk,
    input wire rst,
    input wire hit,
    input wire en_music,

    output wire audio_mclk, // master clock
    output wire audio_lrck, // left-right clock
    output wire audio_sck,  // serial clock
    output wire audio_sdin // serial audio data input
);
    
    // wire [21:0] bgm_note_div_left, bgm_note_div_right;
    // wire [15:0] bgm_amplitude;

    wire signed [15:0] music_waveform;
    wire signed [15:0] sfx_waveform;
    reg signed [15:0] output_waveform;

    always @(*) begin
        if(sfx_waveform == 0)
            output_waveform = music_waveform;
        else
            output_waveform = sfx_waveform*2 + music_waveform/4;
    end

    Music_from_waveform Music_from_waveform_inst(
        .clk(clk),
        .rst(rst),
        .en(en_music), 

        .waveform_amplitude(music_waveform)
    );

    SoundEffect_Gen SoundEffect_Gen_inst(
        .clk(clk),
        .rst(rst),
        .hit(hit),

        .sfx_waveform(sfx_waveform)
    );

    speaker_control speaker_control_inst(
        .clk(clk),
        .rst(rst),
        .audio_in_left(output_waveform),
        .audio_in_right(output_waveform),
        .audio_mclk(audio_mclk),
        .audio_lrck(audio_lrck),
        .audio_sck(audio_sck),
        .audio_sdin(audio_sdin)
    );

endmodule