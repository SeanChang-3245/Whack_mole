module BGM_gen(
    input wire clk,
    input wire rst,

    output wire [21:0] bgm_note_div_left,
    output wire [21:0] bgm_note_div_right,
    output wire [15:0] bgm_amplitude
);

    localparam HOLD_LENGTH = 2_500_000;
    localparam NOTE_CNT = 2274;

    integer counter, counter_next;
    reg [14:0] note_addr, note_addr_next;
    wire [31:0] note_freq;
    wire [15:0] note_ampl;
    wire clk_25MHz;

    clock_divider #(.n(2)) m2(.clk(clk), .clk_div(clk_25MHz));

    // blk_mem_gen_0 blk_mem_gen_0_inst(.addra(note_addr), .clka(clk_25MHz), .dina(0), .wea(0), .douta(note_freq)); // memory for frequency
    // blk_mem_gen_1 blk_mem_gen_1_inst(.addra(note_addr), .clka(clk_25MHz), .dina(0), .wea(0), .douta(note_ampl)); // memory for amplitude

    assign bgm_note_div_left = 50_000_000 / note_freq;
    assign bgm_note_div_right = 50_000_000 / note_freq;
    assign bgm_amplitude = note_ampl;

    wire [15:0] audio_left, audio_right;

    always@(posedge clk) begin
        if(rst) begin
            counter <= 0;
            note_addr <= 0;
        end
        else begin
            counter <= counter_next;
            note_addr <= note_addr_next;
        end
    end


    always@(*) begin
        counter_next = counter+1;
        if(counter == HOLD_LENGTH-1) begin // each note hold for 12.5ms
            counter_next = 0;
        end
    end

    always@* begin
        note_addr_next = note_addr;
        if(counter == HOLD_LENGTH-1) begin
            if(note_addr == NOTE_CNT-1) begin // 4472 note in total
                note_addr_next = 0;
            end
            else begin
                note_addr_next = note_addr + 1;
            end
        end
    end

endmodule