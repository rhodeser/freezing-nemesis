`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:05:50 01/18/2014 
// Design Name: 
// Module Name:    nexys3_bot_if 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module nexys3_bot_if
(
input [7:0] locX, locY, botinfo, sensors, lmdist, rmdist, 
input [7:0] db_sw,
input [4:1] db_btns,
input [7:0] port_id, 
input [7:0] out_port, 
input clk, reset,  write_strobe, k_write_strobe, read_strobe,  interrupt_ack, upd_sysregs, 
output reg  interrupt,
output reg [7:0] led,
output reg [3:0] dp,
output reg [4:0] dig3, dig2, dig1, dig0, 
output reg [7:0] in_port, 
output reg [7:0] motctl
);

//
// Some additional signals are required if your system also needs to reset KCPSM6. 
//

//wire			cpu_reset;
//wire			rdl;

//
// When interrupt is to be used then the recommended circuit included below requires 
// the following signal to represent the request made from your system.
//

//wire			int_request;

//
///////////////////////////////////////////////////////////////////////////////////////////
// Circuit Descriptions
///////////////////////////////////////////////////////////////////////////////////////////
//

  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // Instantiate KCPSM6 and connect to Program Memory
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // The KCPSM6 parameters can be defined as required but the default values are shown below
  // and these would be adequate for most designs.
  //

 /* kcpsm6 #(
	.interrupt_vector	(12'h3FF),
	.scratch_pad_memory_size(64),
	.hwbuild		(8'h00))
  processor (
	.address 		(address),
	.instruction 	(instruction),
	.bram_enable 	(bram_enable),
	.port_id 		(port_id),
	.write_strobe 	(write_strobe),
	.k_write_strobe 	(k_write_strobe),
	.out_port 		(out_port),
	.read_strobe 	(read_strobe),
	.in_port 		(in_port),
	.interrupt 		(interrupt),
	.interrupt_ack 	(interrupt_ack),
	.reset 		(kcpsm6_reset),
	.sleep		(kcpsm6_sleep),
	.clk 			(clk)); 
*/
  //
  // In many designs (especially your first) interrupt and sleep are not used.
  // Tie these inputs Low until you need them. 
  // 
/*
  assign kcpsm6_sleep = 1'b0;
  assign interrupt = 1'b0;
*/
  //
  // The default Program Memory recommended for development.
  // 
  // The generics should be set to define the family, program size and enable the JTAG
  // Loader. As described in the documentation the initial recommended values are.  
  //    'S6', '1' and '1' for a Spartan-6 design.
  //    'V6', '2' and '1' for a Virtex-6 design.
  // Note that all 12-bits of the address are connected regardless of the program size
  // specified by the generic. Within the program memory only the appropriate address bits
  // will be used (e.g. 10 bits for 1K memory). This means it that you only need to modify 
  // the generic when changing the size of your program.   
  //
  // When JTAG Loader updates the contents of the program memory KCPSM6 should be reset 
  // so that the new program executes from address zero. The Reset During Load port 'rdl' 
  // is therefore connected to the reset input of KCPSM6.
  //

  //
  // If your design also needs to be able to reset KCPSM6 the arrangement below should be 
  // used to 'OR' your signal with 'rdl' from the program memory.
  // 

//  assign kcpsm6_reset = cpu_reset | rdl;

  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // Example of General Purose I/O Ports.
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // The following code corresponds with the circuit diagram shown on page 72 of the 
  // KCPSM6 Guide and includes additional advice and recommendations.
  //
  //

  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // General Purpose Input Ports. 
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  //
  // The inputs connect via a pipelined multiplexer. For optimum implementation, the input
  // selection control of the multiplexer is limited to only those signals of 'port_id' 
  // that are necessary. In this case, only 2-bits are required to identify each of  
  // four input ports to be read by KCPSM6.
  //
  // Note that 'read_strobe' only needs to be used when whatever supplying information to
  // KPPSM6 needs to know when that information has been read. For example, when reading 
  // a FIFO a read signal would need to be generated when that port is read such that the 
  // FIFO would know to present the next oldest information.
  //

  always @ (posedge clk)
  begin

      case (port_id) 
      
        // Read db_btns at port address 00 hex
        8'h00: in_port <= db_btns;

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

        // To ensure minimum logic implementation when defining a multiplexer always
        // use don't care for any of the unused cases (although there are none in this 
        // example).

        default : in_port <= 8'bXXXXXXXX ;  

      endcase

  end

  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // General Purpose Output Ports 
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  //
  // Output ports must capture the value presented on the 'out_port' based on the value of 
  // 'port_id' when 'write_strobe' is High.
  //
  // For an optimum implementation the allocation of output ports should be made in a way 
  // that means that the decoding of 'port_id' is minimised. Whilst there is nothing 
  // logically wrong with decoding all 8-bits of 'port_id' it does result in a function 
  // that can not fit into a single 6-input look up table (LUT6) and requires all signals 
  // to be routed which impacts size, performance and power consumption of your design.
  // So unless you really have a lot of output ports it is best practice to use 'one-hot'
  // allocation of addresses as used below or to limit the number of 'port_id' bits to 
  // be decoded to the number required to cover the ports.
  // 
  // Code examples in which the port address is 04 hex. 
  //
  // Best practice in which one-hot allocation only requires a single bit to be tested.
  // Supports up to 8 output ports with each allocated a different bit of 'port_id'.
  //
  //   if (port_id[2] == 1'b1)  output_port_x <= out_port;  
  //
  //
  // Limited decode in which 5-bits of 'port_id' are used to identify up to 32 ports and 
  // the decode logic can still fit within a LUT6 (the 'write_strobe' requiring the 6th 
  // input to complete the decode).
  // 
  //   if (port_id[4:0] == 5'b00100) output_port_x <= out_port;
  // 
  //
  // The 'generic' code may be the easiest to write with the minimum of thought but will 
  // result in two LUT6 being used to implement each decoder. This will also impact
  // performance and power. This is not generally a problem and hence it is reasonable to 
  // consider this as over attention to detail but good design practice will often bring 
  // rewards in the long term. When a large design struggles to fit into a given device 
  // and/or meet timing closure then it is often the result of many small details rather 
  // that one big cause. PicoBlaze is extremely efficient so it would be a shame to 
  // spoil that efficiency with unnecessarily large and slow peripheral logic.
  //
  //   if port_id = X"04" then output_port_x <= out_port;  
  //

  always @ (posedge clk)
  begin

      // 'write_strobe' is used to qualify all writes to general output ports.
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






  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // Constant-Optimised Output Ports 
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  //
  // Implementation of the Constant-Optimised Output Ports should follow the same basic 
  // concepts as General Output Ports but remember that only the lower 4-bits of 'port_id'
  // are used and that 'k_write_strobe' is used as the qualifier.
  //
/*
  always @ (posedge clk)
  begin

      // 'k_write_strobe' is used to qualify all writes to constant output ports.
      if (k_write_strobe == 1'b1) begin

        // Write to output_port_k at port address 01 hex
        if (port_id[0] == 1'b1) begin
          output_port_k <= out_port;
        end

        // Write to output_port_c at port address 02 hex
        if (port_id[1] == 1'b1) begin
          output_port_c <= out_port;
        end

      end
  end
*/




  //
  /////////////////////////////////////////////////////////////////////////////////////////
  // Recommended 'closed loop' interrupt interface (when required).
  /////////////////////////////////////////////////////////////////////////////////////////
  //
  // Interrupt becomes active when 'int_request' is observed and then remains active until 
  // acknowledged by KCPSM6. Please see description and waveforms in documentation.
  //

  always @ (posedge clk)
  begin
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

  //
  /////////////////////////////////////////////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////
//
// END OF FILE kcpsm6_design_template.v
//
///////////////////////////////////////////////////////////////////////////////////////////

	
	



endmodule
