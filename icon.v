// Icon Module for Rojobot World Video Controller
//
//	Author:			Bhavana & Erik
//	Last Modified:	25-Jan-2014
//	
//	 Revision History
//	 ----------------
//	 25-Jan-14		Added the Icon Module
//	 
//
//	Description:
//	------------
//	 This module stores the 16x16 image of the Rojobot.
//	
//	 Inputs:
//			clock           - 25MHz Clock
//			rst             - Active-high synchronous reset
//			LocX_reg		- X-coordinate of rojobot's location		
//			LocY_reg		- Y-coordinate of rojobot's location
//			BotInfo_reg		- Information about rojobot's activity
//			Pixel_row		- (10 bits) current pixel row address
//			Pixel_column	- (10 bits) current pixel column address
//			
//	 Outputs:
//			icon			-  pixel showing bot location and orientation
//			
//////////

module icon (
input clock, rst,
input [7:0] LocX_reg,				
input [7:0] LocY_reg,	
input [7:0]	BotInfo_reg,
input [9:0] Pixel_row,
input [9:0] Pixel_column,
output reg [1:0] icon
);

reg [1:0] bitmap_bot_1 [0:15] [0:15];
reg [1:0] bitmap_bot_2 [0:15] [0:15];
integer i,j;

always @(*) begin
	for (i=0; i<=15; i=i+1) begin
		for (j=0; j<=15; j=j+1) begin
		    //NORMAL IMAGE 
			if( (j==4 && i>=4 && i<=12) ||
			    (i+j == 8 && j<=4) ||
				(i-j == 8 && j<=4) ||
			    (i==8) ) begin
				bitmap_bot_1[i][j] = 2'b11;	// Icon color
			end
			else begin
			    bitmap_bot_1[i][j] = 2'b00;
			end
			//45 degree Tilted IMAGE 
			if( (j==0 && i>=12) ||
			    (i+j == 16) ||
				(i-j == 12) ||
			    (j<=4 && i==16) ) begin
				bitmap_bot_2[i][j] = 2'b11;	// Icon color
			end
			else begin
			    bitmap_bot_2[i][j] = 2'b00;
			end
		end
	end
end

always @ (posedge clock) begin
	if (rst) begin
		icon <= 2'b00;
	end
	else begin
		if ((Pixel_row >= ({LocY_reg,2'b00})) && (Pixel_row <= (({LocY_reg,2'b00}) + 4'hF)) && (Pixel_column >= ({LocX_reg,2'b00})) && (Pixel_column <= (({LocX_reg,2'b00}) + 4'hF)) ) begin
			case(BotInfo_reg[2:0])
				3'b000 : begin 
							icon <= bitmap_bot_1 [Pixel_row - ({LocY_reg,2'b00})] [Pixel_column - ({LocX_reg,2'b00})];	//0 Degree
						end	
				3'b001 : begin 
							icon <= bitmap_bot_2 [Pixel_row - ({LocY_reg,2'b00})] [Pixel_column - ({LocX_reg,2'b00})];	//45 Degree
						end	
				3'b010 : begin 
							icon <= bitmap_bot_1 [Pixel_column - ({LocX_reg,2'b00})] [({LocY_reg,2'b00}) + 4'hF - Pixel_row];	//90 Degree
						end	
				3'b011 : begin 
							icon <= bitmap_bot_2 [Pixel_column - ({LocX_reg,2'b00})] [({LocY_reg,2'b00}) + 4'hF - Pixel_row];	//135 Degree
						end	
				3'b100 : begin 
							icon <= bitmap_bot_1 [({LocY_reg,2'b00}) + 4'hF - Pixel_row] [({LocX_reg,2'b00}) + 4'hF - Pixel_column];	//180 Degree
						end	
				3'b101 : begin 
							icon <= bitmap_bot_2 [({LocY_reg,2'b00}) + 4'hF - Pixel_row] [({LocX_reg,2'b00}) + 4'hF - Pixel_column];	//225 Degree
						end	
				3'b110 : begin 
							icon <= bitmap_bot_1 [({LocX_reg,2'b00}) + 4'hF - Pixel_column] [Pixel_row - ({LocY_reg,2'b00})];	//270 Degree
						end	
				3'b111 : begin 
							icon <= bitmap_bot_2 [({LocX_reg,2'b00}) + 4'hF - Pixel_column] [Pixel_row - ({LocY_reg,2'b00})];	//315 Degree
						end			
		    endcase
		end
		else begin
			icon <= 2'b00; // transparent
		end
	end
end

endmodule

