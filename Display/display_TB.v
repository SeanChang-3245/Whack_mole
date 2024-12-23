module Display_TB(
	input wire clk,
	input wire rst,
	input wire change_pat,

	output wire [3:0] DIGIT,
    output wire [6:0] DISPLAY,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

	reg [8:0] map;
	reg [3:0] score;
	wire change_pattern;
	button_preprocess button_preprocess_inst(
		.clk(clk),
		.signal_in(change_pat),
		.signal_out(change_pattern)
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

	always @(posedge clk) begin
		if(rst) begin
			map <= 9'b0;
			score <= 4'b0;
		end
		else begin
			map <= map;
			score <= score;
			if(change_pattern) begin
				map <= map + 1;
				score <= score + 1;
			end
		end
	end
endmodule