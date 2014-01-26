// colorizer Module for Rojobot World Video Controller
//
//	Author:			Bhavana & Erik
//	Last Modified:	25-Jan-2014
//	
//	 Revision History
//	 ----------------
//	 25-Jan-14		Added the colorizer Module
//	 
//
//	Description:
//	------------
//	 This circuit provides 8-bit output - 3 bits red, green and 2 bits blue. 
//	 This takes the 2-bit pixel inputs from the Bot and Icon modules.
//	
//	 Inputs:
//			clock           - 25MHz Clock
//			rst             - Active-high synchronous reset
//			video_on        - 1 = in active video area; 0 = blanking;
//			world_pixel     -  pixel (location) value
//			icon			-  pixel showing bot location and orientation
//	 Outputs:
//			red				-	All 3 bits 1's gives red color output
//			green			-	All 3 bits 1's gives green color output
//			blue			-	All 2 bits 1's gives blue color output
//			
//////////
module colorizer (
input clock, rst,
input video_on,
input [1:0] world_pixel,
input [1:0] icon,
output reg [2:0] red,
output reg [2:0] green,
output reg [1:0] blue
);

reg [7:0] out_color;

always @ (*) begin
	red = out_color[7:5];
	green = out_color[4:2];
	blue = out_color[1:0];
end

always @ (posedge clock) begin
	if (rst) begin
		out_color <= 8'h0;
	end
	else begin
		if (video_on == 0) begin
			out_color <= 8'h0;			
		end
		else begin
			case ({world_pixel,icon})
				4'b0000 : out_color <= 111_111_11;		// white back ground
				4'b0100 : out_color <= 000_000_00;		// Black line
				4'b1000 : out_color <= 111_000_00;		// Dark Red color for Obstruction
				4'b1100 : out_color <= 100_100_10;		// Grey for Reserved Area
				4'bxx01	: out_color <= 100_000_00;		// Maroon Color for Icon color 1
				4'bxx10 : out_color <= 000_111_11;		// Cyan color for Icon color 2
				4'bxx11 : out_color <= 111_000_11;		// Magenta color for Icon color 3
				default : out_color <= 000_000_00;
			endcase
		end
	end
end

endmodule


		



