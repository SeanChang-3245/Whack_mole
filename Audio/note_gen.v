module buzzer_control(
    input clk, // clock from crystal
    input rst, // active high reset
    input [2:0] volume, 
    input [15:0] amplitude,
    input [21:0] note_div_left, // div for note generation
    input [21:0] note_div_right,
    output [15:0] audio_left,
    output [15:0] audio_right
);

    // Declare internal signals
    reg [21:0] clk_cnt_next, clk_cnt;
    reg [21:0] clk_cnt_next_2, clk_cnt_2;
    reg b_clk, b_clk_next;
    reg c_clk, c_clk_next;
    reg signed [15:0] volume_out;

    // Note frequency generation
    // clk_cnt, clk_cnt_2, b_clk, c_clk
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1) begin
            clk_cnt <= 22'd0;
            clk_cnt_2 <= 22'd0;
            b_clk <= 1'b0;
            c_clk <= 1'b0;
        end
        else begin
            clk_cnt <= clk_cnt_next;
            clk_cnt_2 <= clk_cnt_next_2;
            b_clk <= b_clk_next;
            c_clk <= c_clk_next;
        end
    end    

    // clk_cnt_next, b_clk_next
    always @* begin
        if (clk_cnt == note_div_left) begin
            clk_cnt_next = 22'd0;
            b_clk_next = ~b_clk;
        end
        else begin
            clk_cnt_next = clk_cnt + 1'b1;
            b_clk_next = b_clk;
        end
    end

    // clk_cnt_next_2, c_clk_next
    always @* begin
        if (clk_cnt_2 == note_div_right) begin
            clk_cnt_next_2 = 22'd0;
            c_clk_next = ~c_clk;
        end
        else begin
            clk_cnt_next_2 = clk_cnt_2 + 1'b1;
            c_clk_next = c_clk;
        end
    end

    always@(*) begin
        volume_out = amplitude;
    end

    // always @* begin
    //     case (volume)
    //         3'd1   : volume_out =  16'h0200;
    //         3'd2   : volume_out =  16'h0400;
    //         3'd3   : volume_out =  16'h0800;
    //         3'd4   : volume_out =  16'h1000;
    //         3'd5   : volume_out =  16'h2000;
    //         default: volume_out =  16'h0000; 
    //     endcase
    // end

    // Assign the amplitude of the note
    // Volume is controlled here
    assign audio_left = (note_div_left == 22'd1) ? 16'h0000 :      // silence
                                (b_clk == 1'b0) ? volume_out : -volume_out;
    assign audio_right = (note_div_right == 22'd1) ? 16'h0000 :    // silence
                                (c_clk == 1'b0) ? volume_out : -volume_out;
endmodule