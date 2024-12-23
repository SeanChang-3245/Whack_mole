module SoundEffect_Gen(
    input wire clk,
    input wire rst, 
    input wire hit, // one pulse signal
    
    output reg [15:0] sfx_waveform 
);

    localparam HOLD_TIME = 31_250;   // number of 10ns in 1/3200 sec
    localparam SFX_LEN = 16000; // number of int16 in 0.5 sec

    localparam IDLE = 0;
    localparam PLAYING = 1;

    wire clk_25MHz;
    clock_divider #(.n(2)) (.clk(clk), .clk_div(clk_25MHz));

    wire signed [15:0] amp;
    reg signed [15:0] prev_amp;

    reg [25:0] time_cnt, time_cnt_next;
    reg [15:0] addr, addr_next;

    reg cur_state, next_state;

    blk_mem_gen_6 blk_mem_gen_6_inst (.clka(clk_25MHz), .addra(addr), .dina(0), .douta(amp), .wea(0));


    always@(posedge clk) begin
        if(rst) begin
            cur_state <= IDLE;
            time_cnt <= 0;
            addr <= 0;
            prev_amp <= 0;
        end
        else begin
            cur_state <= next_state;
            time_cnt <= time_cnt_next;
            addr <= addr_next;
            if(time_cnt == HOLD_TIME-1)
                prev_amp <= amp;
            else 
                prev_amp <= prev_amp;
        end
    end

    integer i;
    always@* begin
        if(cur_state == PLAYING) begin
            for(i = 1; i <= 10; i = i + 1) begin
                if(time_cnt < 3125*i) begin 
                    sfx_waveform = prev_amp * (10-i) / 10 + amp * i / 10; 
                end
            end
        end
        else begin
            sfx_waveform = 0;
        end
    end

    always@* begin
        next_state = cur_state;
        if(cur_state == IDLE && hit) begin
            next_state = PLAYING;
        end
        else if(cur_state == PLAYING && time_cnt == SFX_LEN-1) begin
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

    always@* begin
        addr_next = addr;
        if(cur_state == PLAYING) begin
            if(time_cnt == HOLD_TIME-1) begin
                if(addr == SFX_LEN-1) begin
                    addr_next = 0;
                end
                else begin
                    addr_next = addr + 1;
                end
            end
        end
    end

endmodule
