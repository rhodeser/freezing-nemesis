// Icon Module for Rojobot World Video Controller
//
//	Author:			Bhavana & Erik
//	Last Modified:	3-Feb-2014
//	
//	 Revision History
//	 ----------------
//	 25-Jan-14		Added the Icon Module
//	 27-Jan-2014	Modified the orientation equations
//	 3-Feb-2014		Added comments for better understanding.
//
//	Description:
//	------------
//	 This module stores the 16x16 image of the Rojobot 
//	 and outputs correct orientation of bot based on Botinfo_reg.
//	 The modules outputs bot icon only when the bot location matches with that of pixel address.
//
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

reg [1:0] bitmap_bot_1 [0:15] [0:15];	// normal image bitmap
reg [1:0] bitmap_bot_2 [0:15] [0:15];	//45 degree image bitmap
integer i,j;
reg [9:0] locX,locY;

always @(*) begin
	for (i=0; i<=15; i=i+1) begin
		for (j=0; j<=15; j=j+1) begin
		    //equations to store 0 degree bot image
			if( (j==4 && i>=4 && i<=12) ||
			    (i+j == 8 && j<=4) ||
				(i-j == 8 && j<=4) ||
			    (i==8) ) begin
				bitmap_bot_1[i][j] = 2'b11;	// Icon color
			end
			else begin
			    bitmap_bot_1[i][j] = 2'b00;
			end
			//equations to store 45 degree bot image
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
		locX = ({LocX_reg,2'b00} - 4'b1001);	//offset to allign correctly in the X-axis
		locY = ({LocY_reg,2'b00} - 3'b100);		//offset to allign correctly in the Y-axis
		
		if ((Pixel_row >= locY) && (Pixel_row <= (locY + 4'hF)) && (Pixel_column >= locX) && (Pixel_column <= (locX + 4'hF)) ) begin
			//condition to know whether pixel address matches with that of bot location
			
			case(BotInfo_reg[2:0])
				3'b110 : begin 
							icon <= bitmap_bot_1 [Pixel_row - locY] [Pixel_column - locX];	//0 Degree
						end	
				3'b101 : begin 
							icon <= bitmap_bot_2 [Pixel_row - locY] [Pixel_column - locX];	//45 Degree
						end	
				3'b100 : begin 
							icon <= bitmap_bot_1 [Pixel_column - locX] [locY + 4'hF - Pixel_row];	//90 Degree
						end	
				3'b011 : begin 
							icon <= bitmap_bot_2 [Pixel_column - locX] [locY + 4'hF - Pixel_row];	//135 Degree
						end	
				3'b010 : begin 
							icon <= bitmap_bot_1 [locY + 4'hF - Pixel_row] [locX + 4'hF - Pixel_column];	//180 Degree
						end	
				3'b001 : begin 
							icon <= bitmap_bot_2 [locY + 4'hF - Pixel_row] [locX + 4'hF - Pixel_column];	//225 Degree
						end	
				3'b000 : begin 
							icon <= bitmap_bot_1 [locX + 4'hF - Pixel_column] [Pixel_row - locY];	//270 Degree
						end	
				3'b111 : begin 
							icon <= bitmap_bot_2 [locX + 4'hF - Pixel_column] [Pixel_row - locY];	//315 Degree
						end			
		    endcase
		end
		else begin
			icon <= 2'b00; // transparent
		end
	end
end

endmodule

