module SoundEffect_Gen(
    input wire clk,
    input wire rst, 
    input wire hit, // one pulse signal
    
    output wire [21:0] SFX_note_div_left,
    output wire [21:0] SFX_note_div_right,
    output wire [15:0] bgm_amplitude
);

    localparam IDLE = 0;
    localparam PLAYING = 1;

    localparam SFX_LEN = 50_000_000; // 0.5 sec

    reg [25:0] time_cnt, time_cnt_next;

    reg cur_state, next_state;

    always@(posedge clk) begin
        if(rst) begin
            cur_state <= IDLE;
        end
        else begin
            cur_state <= next_state;
        end
    end

    always@* begin
        next_state = cur_state;
        if(cur_state == IDLE && hit) begin
            next_state = PLAYING;
        end
        else if(cur_state == PLAYING && time_cnt == SFX_LEN) begin
            next_state = IDLE;
        end
    end

    always@* begin
        time_cnt_next = time_cnt;
        if(cur_state == IDLE) begin
            time_cnt_next = 0;
        end
        else begin
            time_cnt_next = time_cnt + 1;
        end
    end

endmodule
