module Display_Top(
    input wire clk,
    input wire rst,
    
    input wire [8:0] map,
    input wire [3:0] score,

    output wire [3:0] DIGIT,
    output wire [6:0] DISPLAY,
    output wire hsync,
    output wire vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);
	parameter WAIT_ONE = 3125000;

	wire clk_25MHz;
	clock_divider #(.n(2)) m2( .clk(clk), .clk_div(clk_25MHz));

	wire valid;
	wire [9:0] h_cnt;
	wire [9:0] v_cnt;
	reg [11:0] pixel;
	// assign {vgaRed, vgaGreen, vgaBlue} = (valid) ? 12'hfff : 12'h0;
	assign {vgaRed, vgaGreen, vgaBlue} = (valid) ? pixel : 12'h0;

    wire [3:0] score_ten = score / 10;
    wire [3:0] score_one = score >= 10 ? score - 10 : score;
    SevenSegment SevenSegment_inst(
        .clk(clk),
        .rst(rst),
        .nums({8'b0, score_ten, score_one}),
        .digit(DIGIT),
        .display(DISPLAY)
    );

	vga_controller vga_controller_inst(
		.pclk(clk_25MHz),
		.reset(rst),
		.hsync(hsync),
		.vsync(vsync),
		.valid(valid),
		.h_cnt(h_cnt),
		.v_cnt(v_cnt)
	);

	wire draw_hole, draw_mole;
	reg [16:0] pixel_addr;
	reg [14:0] grass_addr;
	wire [11:0] pixel_grass;
	wire [11:0] pixel_mole;
	reg [3:0] block_num;
	reg [4:0] frame_cnt;

	// background grass
	blk_mem_gen_0 blk_mem_gen_0_inst( .clka(clk_25MHz), .dina(dina), .wea(0), .addra(grass_addr), .douta(pixel_grass));
	// moles
	blk_mem_gen_1 blk_mem_gen_1_inst( .clka(clk_25MHz), .dina(dina), .wea(0), .addra(pixel_addr), .douta(pixel_mole));

	assign draw_hole = block_num != 4'hf;
	assign draw_mole = (block_num != 4'hf) ? map[block_num] : 0;

	always @(*) begin
		if(draw_hole) begin
			pixel = (pixel_mole == 12'h481 || pixel_mole == 12'h381 || 
					pixel_mole == 12'h380 || pixel_mole == 12'h480) ? pixel_grass : pixel_mole;
		end
		else begin
			pixel = pixel_grass;
		end
	end

	// PIXEL ADDR
	always @(*) begin
		pixel_addr = 0;
		if(draw_hole) begin
			if(draw_mole) begin
				case(block_num)
					4'd0: pixel_addr = ((h_cnt-63) & 63) + (((v_cnt-48) & 63) << 6) + 64*64*frame_cnt;
					4'd1: pixel_addr = ((h_cnt-319) & 63) + (((v_cnt-48) & 63) << 6) + 64*64*frame_cnt;
					4'd2: pixel_addr = ((h_cnt-189) & 63) + (((v_cnt-144) & 63) << 6) + 64*64*frame_cnt;
					4'd3: pixel_addr = ((h_cnt-447) & 63) + (((v_cnt-144) & 63) << 6) + 64*64*frame_cnt;
					4'd4: pixel_addr = ((h_cnt-95) & 63) + (((v_cnt-234) & 63) << 6) + 64*64*frame_cnt;
					4'd5: pixel_addr = ((h_cnt-351) & 63) + (((v_cnt-234) & 63) << 6) + 64*64*frame_cnt;
					4'd6: pixel_addr = ((h_cnt-223) & 63) + (((v_cnt-325) & 63) << 6) + 64*64*frame_cnt;
					4'd7: pixel_addr = ((h_cnt-479) & 63) + (((v_cnt-325) & 63) << 6) + 64*64*frame_cnt;
					4'd8: pixel_addr = ((h_cnt-351) & 63) + (((v_cnt-388) & 63) << 6) + 64*64*frame_cnt;
					default: pixel_addr = 0;
				endcase 
			end
			else begin
				case(block_num)
					4'd0: pixel_addr = ((h_cnt-63) & 63) + (((v_cnt-48) & 63) << 6);
					4'd1: pixel_addr = ((h_cnt-319) & 63) + (((v_cnt-48) & 63) << 6);
					4'd2: pixel_addr = ((h_cnt-189) & 63) + (((v_cnt-144) & 63) << 6);
					4'd3: pixel_addr = ((h_cnt-447) & 63) + (((v_cnt-144) & 63) << 6);
					4'd4: pixel_addr = ((h_cnt-95) & 63) + (((v_cnt-234) & 63) << 6);
					4'd5: pixel_addr = ((h_cnt-351) & 63) + (((v_cnt-234) & 63) << 6);
					4'd6: pixel_addr = ((h_cnt-223) & 63) + (((v_cnt-325) & 63) << 6);
					4'd7: pixel_addr = ((h_cnt-479) & 63) + (((v_cnt-325) & 63) << 6);
					4'd8: pixel_addr = ((h_cnt-351) & 63) + (((v_cnt-388) & 63) << 6);
					default: pixel_addr = 0;
				endcase
			end
		end
	end
	always @(*) begin
		grass_addr = h_cnt%80 + (v_cnt%60)*80;
	end
	// block num
	always @(*) begin
		block_num = 4'hf;
		if(h_cnt >= 63 && h_cnt < 63+64 && v_cnt >= 48 && v_cnt < 48+64) begin
			block_num = 4'd0;
		end
		else if(h_cnt >= 319 && h_cnt < 319+64 && v_cnt >= 48 && v_cnt < 48+64) begin
			block_num = 4'd1;
		end
		else if(h_cnt >= 189 && h_cnt < 189+64 && v_cnt >= 144 && v_cnt < 144+64) begin
			block_num = 4'd2;
		end
		else if(h_cnt >= 447 && h_cnt < 447+64 && v_cnt >= 144 && v_cnt < 144+64) begin
			block_num = 4'd3;
		end 
		else if(h_cnt >= 95 && h_cnt < 95+64 && v_cnt >= 234 && v_cnt < 234+64) begin
			block_num = 4'd4;
		end 
		else if(h_cnt >= 351 && h_cnt < 351+64 && v_cnt >= 234 && v_cnt < 234+64) begin
			block_num = 4'd5;
		end 
		else if(h_cnt >= 223 && h_cnt < 223+64 && v_cnt >= 325 && v_cnt < 325+64) begin
			block_num = 4'd6;
		end 
		else if(h_cnt >= 479 && h_cnt < 479+64 && v_cnt >= 325 && v_cnt < 325+64) begin
			block_num = 4'd7;
		end 
		else if(h_cnt >= 351 && h_cnt < 351+64 && v_cnt >= 388 && v_cnt < 388+64) begin
			block_num = 4'd8;
		end
	end

	reg [27:0] one_sec_cnt;
	always @(posedge clk) begin
		if(rst) begin
			one_sec_cnt <= 0;
		end
		else begin
			if(one_sec_cnt == 150_000_000) begin
				one_sec_cnt <= 0;
			end
			else begin
				one_sec_cnt <= one_sec_cnt + 1;
			end
		end
	end

	always @(*) begin
		if(one_sec_cnt > 0 && one_sec_cnt < WAIT_ONE) begin
			frame_cnt = 1;
		end
		else if(one_sec_cnt < WAIT_ONE*2) begin
			frame_cnt = 2;
		end
		else if(one_sec_cnt < WAIT_ONE*3) begin
			frame_cnt = 3;
		end
		else if(one_sec_cnt < WAIT_ONE*4) begin
			frame_cnt = 4;
		end
		else if(one_sec_cnt < WAIT_ONE*5) begin
			frame_cnt = 5;
		end
		else if(one_sec_cnt < WAIT_ONE*6) begin
			frame_cnt = 6;
		end
		else if(one_sec_cnt < WAIT_ONE*7) begin
			frame_cnt = 7;
		end
		else if(one_sec_cnt < WAIT_ONE*8) begin
			frame_cnt = 8;
		end
		else if(one_sec_cnt < WAIT_ONE*9) begin
			frame_cnt = 9;
		end
		else if(one_sec_cnt < WAIT_ONE*10) begin
			frame_cnt = 10;
		end
		else if(one_sec_cnt < WAIT_ONE*11) begin
			frame_cnt = 11;
		end
		else if(one_sec_cnt < WAIT_ONE*12) begin
			frame_cnt = 12;
		end
		else if(one_sec_cnt < WAIT_ONE*13) begin
			frame_cnt = 13;
		end
		else if(one_sec_cnt < WAIT_ONE*14) begin
			frame_cnt = 14;
		end
		else if(one_sec_cnt < WAIT_ONE*15) begin
			frame_cnt = 15;
		end
		else if(one_sec_cnt < WAIT_ONE*31) begin
			frame_cnt = 16;
		end
		else if(one_sec_cnt < WAIT_ONE*32) begin
			frame_cnt = 15;
		end
		else if(one_sec_cnt < WAIT_ONE*33) begin
			frame_cnt = 14;
		end
		else if(one_sec_cnt < WAIT_ONE*34) begin
			frame_cnt = 13;
		end
		else if(one_sec_cnt < WAIT_ONE*35) begin
			frame_cnt = 12;
		end
		else if(one_sec_cnt < WAIT_ONE*36) begin
			frame_cnt = 11;
		end
		else if(one_sec_cnt < WAIT_ONE*37) begin
			frame_cnt = 10;
		end
		else if(one_sec_cnt < WAIT_ONE*38) begin
			frame_cnt = 9;
		end
		else if(one_sec_cnt < WAIT_ONE*39) begin
			frame_cnt = 8;
		end
		else if(one_sec_cnt < WAIT_ONE*40) begin
			frame_cnt = 7;
		end
		else if(one_sec_cnt < WAIT_ONE*41) begin
			frame_cnt = 6;
		end
		else if(one_sec_cnt < WAIT_ONE*42) begin
			frame_cnt = 5;
		end
		else if(one_sec_cnt < WAIT_ONE*43) begin
			frame_cnt = 4;
		end
		else if(one_sec_cnt < WAIT_ONE*44) begin
			frame_cnt = 3;
		end
		else if(one_sec_cnt < WAIT_ONE*45) begin
			frame_cnt = 2;
		end
		else if(one_sec_cnt < WAIT_ONE*46) begin
			frame_cnt = 1;
		end
		else begin
			frame_cnt = 0;
		end
	end

endmodule