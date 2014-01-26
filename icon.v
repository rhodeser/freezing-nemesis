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
integer i,j;

always @(*) begin
	for (i=0; i<=15; i=i+1) begin
		for (j=0; j<=15; j=j+1) begin
			bitmap_bot_1[i][j] = 2'b11;	// Icon color
		end
	end
end

always @ (posedge clock) begin
	if (rst) begin
		icon <= 2'b00;
	end
	else begin
		if ((Pixel_row >= ({LocX_reg,2'b00})) && (Pixel_row <= (({LocX_reg,2'b00}) + 4'hF)) && (Pixel_column >= ({LocY_reg,2'b00})) && (Pixel_column <= (({LocY_reg,2'b00}) + 4'hF)) ) begin
			icon <= bitmap_bot_1 [Pixel_row - ({LocX_reg,2'b00})] [Pixel_column - ({LocY_reg,2'b00})];	
		end
		else begin
			icon <= 2'b00; // transparent
		end
	end
end

endmodule

