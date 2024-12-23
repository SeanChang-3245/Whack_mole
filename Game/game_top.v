module Game_Control(
    input wire clk,
    input wire rst,
    input wire start_game,
    input wire [3:0] one_pulse_pos,

    output reg [3:0] cur_score,
    output reg [2:0] cur_state,
    output reg [8:0] map
);

    localparam IDLE = 0;
    localparam GAME = 1;
    localparam FIN = 2;

    localparam PLACE_DURATION = 500_000_000; // 0.5 sec
    localparam GAME_LEN = 30 * 100_000_000;  // 30 sec
    localparam WIN_SCORE = 10;

    reg [31:0] time_cnt, time_cnt_next;
    reg [31:0] place_cnt, place_cnt_next;

    reg [3:0] next_score;
    reg [8:0] map_next;

    wire [8:0] random_number;
    

    reg [2:0] next_state;

    always@(posedge clk) begin
        if(rst) begin
            cur_state <= IDLE;
            time_cnt <= 0;
            place_cnt <= 0;
            cur_score <= 0;
            map <= 0;
        end
        else begin
            cur_state <= next_state;
            time_cnt <= time_cnt_next;
            place_cnt <= place_cnt_next;
            cur_score <= next_score;
            map <= map_next;
        end
    end

    always@* begin
        next_state = cur_state;
        if(cur_state == IDLE && start_game) begin
            next_state = GAME;
        end
        if(cur_state == GAME) begin
            if(time_cnt == GAME_LEN) begin
                next_state = FIN;
            end
            else if (cur_score == WIN_SCORE)begin
                next_state = FIN;
            end
        end
        else if(cur_state == FIN && start_game) begin
            next_state = IDLE;
        end
    end

    always@* begin
        map_next = map;
        if(cur_state == IDLE) begin
            map_next = 0;
        end
        else if(cur_state == GAME) begin
            if(one_pulse_pos != 15 && map[one_pulse_pos] == 1) begin
                map_next[one_pulse_pos] = 0;
            end
            else if(place_cnt == PLACE_DURATION) begin
                map_next = random_number;
            end
        end
        else if(cur_state == FIN) begin
            map_next = 0;
        end
    end

    always@* begin
        time_cnt_next = time_cnt;
        if(cur_state == IDLE) begin
            time_cnt_next = 0;
        end
        else if(cur_state == GAME) begin
            time_cnt_next = time_cnt + 1;
        end
    end

    always@* begin
        place_cnt_next = place_cnt;
        if(cur_state == IDLE) begin
            place_cnt_next = 0;
        end
        else if(cur_state == GAME) begin
            if(place_cnt < PLACE_DURATION) begin
                place_cnt_next = place_cnt + 1;
            end
            else begin
                place_cnt_next = 0;
            end
        end
    end

    always @(*) begin
        next_score = cur_score;
        if(cur_state == IDLE) begin
            next_score = 0;
        end
        else if(cur_state == GAME && one_pulse_pos != 15 && map[one_pulse_pos] == 1) begin
            next_score = 1;
        end
    end

    LFSR LFSR_inst(.clk(clk), .rst(rst), .rnd(random_number));

endmodule

module LFSR(
    input wire clk,
    input wire rst,
    output reg [8:0] rnd
);

    always@(posedge clk) begin
        if(rst) begin
            rnd <= 9'b1_101_0010;
        end
        else begin
            rnd <= {rnd[0], rnd[8], rnd[7]^rnd[0], rnd[6:5], rnd[4]^rnd[0], rnd[3]^rnd[0], rnd[2:1]};
        end
    end
endmodule