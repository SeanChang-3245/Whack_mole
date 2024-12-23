module Keyboard_Interface(
    input wire clk,
    input wire rst, 

    inout wire PS2_CLK,
    inout wire PS2_DATA,

    output reg [3:0] one_pulse_pos,
    output wire hit
);


    wire [511:0] key_down;
    wire [8:0] last_change;
    reg [3:0] key_pos;
    wire key_valid;

    assign hit = one_pulse_pos != 15;
    wire cur_holding = |(key_down);
    reg prev_holding;

    always @(posedge clk) begin
        if(rst) begin
            prev_holding <= 0;
        end
        else begin
            prev_holding <= cur_holding;
        end
    end

    always@* begin
        one_pulse_pos = 15;
        if(!prev_holding && key_valid) begin
            one_pulse_pos = last_change;
        end
    end

    always@* begin
        case (last_change) 
            9'h015: key_pos = 0; // Q
            9'h01d: key_pos = 1; // W
            9'h024: key_pos = 2; // E
            9'h01c: key_pos = 3; // A
            9'h01b: key_pos = 4; // S
            9'h023: key_pos = 5; // D
            9'h01a: key_pos = 6; // Z
            9'h022: key_pos = 7; // X
            9'h021: key_pos = 8; // C
            default: key_pos = 15;
        endcase
    end

    KeyboardDecoder KeyboardDecoder_inst(
        .clk(clk),
        .rst(rst),
        .PS2_CLK(PS2_CLK),
        .PS2_DATA(PS2_DATA),
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(key_valid)
    );


endmodule
