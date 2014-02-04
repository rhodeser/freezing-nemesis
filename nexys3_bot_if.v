`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author:			Bhavana & Erik
//  
// Create Date:    01/21/2014 
// Module Name:    nexys3_bot_if 
// Project Name: 	Rojobot world
//
// Description: 
//	This is interface module between bot, kcpsm6, debounce and 7-segment modules.
//	This modules has registers which can be written or read by kcpsm6
//
//////////////////////////////////////////////////////////////////////////////////
module nexys3_bot_if
(
input clk, reset,
input [7:0] locX, locY, 
input [7:0] botinfo, 
input [7:0] sensors, 
input [7:0] lmdist, rmdist, 
input [7:0] db_sw,
input [4:1] db_btns,
input [7:0] port_id, 
input [7:0] out_port, 
input write_strobe, k_write_strobe, 
input read_strobe,  
input interrupt_ack, upd_sysregs, 

output reg  interrupt,
output reg [7:0] led,
output reg [3:0] dp,
output reg [4:0] dig3, dig2, dig1, dig0, 
output reg [7:0] in_port, 
output reg [7:0] motctl
);
 
  always @ (posedge clk)
  begin // read interface between bot, debounce and kcpsm6 modules

      case (port_id)  
      
        // Read db_btns at port address 00 hex
        8'h00: in_port <= {db_btns[4],db_btns[3],db_btns[2],db_btns[1]};

        // Read db_sw at port address 01 hex
        8'h01 : in_port <= db_sw;

        // Read locX at port address 0A hex
        8'h0A : in_port <= locX;

        // Read locY at port address 0B hex
        8'h0B : in_port <= locY;
		
		 // Read botinfo at port address 0C hex
        8'h0C : in_port <= botinfo ;
		
		 // Read sensors at port address 0D hex
        8'h0D : in_port <= sensors ;
		
		 // Read lmdist at port address 0E hex
        8'h0E : in_port <= lmdist ;
		
		 // Read rmdist at port address 0F hex
        8'h0F : in_port <= rmdist;

        default : in_port <= 8'bXXXXXXXX ;  

      endcase

  end


  always @ (posedge clk)
  begin // write interface between kcpsm6 and nexys3_bot_if registers

      if (write_strobe == 1'b1 || k_write_strobe == 1'b1) begin

        // Write to led at port address 02 hex
        if (port_id  == 8'h2) begin
          led <= out_port;
        end

        // Write to dig3 at port address 03 hex
        if (port_id == 8'h3) begin
          dig3 <= out_port[4:0];
        end

        // Write to dig2 at port address 04 hex
        if (port_id == 8'h4) begin
          dig2  <= out_port[4:0];
        end

        // Write to dig1 at port address 05 hex
        if (port_id == 8'h5) begin
          dig1  <= out_port[4:0];
        end
		
		// Write to dig0 at port address 06 hex
        if (port_id == 8'h6) begin
          dig0  <= out_port[4:0];
        end
		
			// Write to dp at port address 07 hex
        if (port_id == 8'h7) begin
          dp  <= out_port[3:0];
        end
		
		// Write to motctl at port address 09 hex
        if (port_id == 8'h09) begin
          motctl  <= out_port;
        end

      end

  end

  always @ (posedge clk)
  begin	//interrupt assertion and de-assertion logic
	if (reset) begin
		interrupt <= 1'b0;
	end
	else begin
      if (interrupt_ack == 1'b1) begin
         interrupt <= 1'b0;
      end
      else if (upd_sysregs == 1'b1) begin
          interrupt <= 1'b1;
      end
      else begin
          interrupt <= interrupt;
      end
	end
  end

endmodule
