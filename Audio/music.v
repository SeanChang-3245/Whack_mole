module Music_from_waveform (
    input wire clk,
    input wire rst,
    input wire en,

    output wire [15:0] waveform_amplitude
);

    localparam HOLD_TIME = 31_250; // number of 10ns in 1/3200 sec
    localparam MUSIC_LEN = 64000;

    wire clk_25MHz;
    clock_divider #(.n(2)) (.clk(clk), .clk_div(clk_25MHz));

    reg [31:0] time_cnt, time_cnt_next;
    reg [15:0] addr, addr_next;

    blk_mem_gen_5 blk_mem_gen_5_inst (.clka(clk_25MHz), .addra(addr), .dina(0), .douta(waveform_amplitude), .wea(0));

    always @(posedge clk) begin
        if(rst) begin
            time_cnt <= 0;
            addr <= 0;
        end
        else begin
            time_cnt <= time_cnt_next;
            addr <= addr_next;
        end
    end

    always@* begin
        addr_next = addr;
        if(en) begin
            if(time_cnt == HOLD_TIME-1) begin
                if(addr == MUSIC_LEN-1) begin
                    addr_next = 0;
                end
                else begin
                    addr_next = addr + 1;
                end
            end
        end
        else begin
            addr_next = 0;
        end
    end


    always@* begin
        time_cnt_next = time_cnt;
        if(en) begin
            if(time_cnt == HOLD_TIME-1) begin
                time_cnt_next = 0;
            end
            else begin
                time_cnt_next = time_cnt + 1;
            end
        end
        else begin
            time_cnt_next = 0;
        end
    end

    
endmodule