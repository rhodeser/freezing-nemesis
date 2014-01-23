`timescale 1ns / 1ps
// nexys3fpga.v - Top level module for Nexys3 as used in the ECE 540 Getting Started project
//
// Modified from S3E Starter Board files by David Glover, 29-April-2012.
//
// Copyright Roy Kravitz, 2008, 2009, 2010, 2011, 2012
// 
// Created By:		Roy Kravitz
// Last Modified:	(RK) 17-Nov-2008
//
// Revision History:
// -----------------
// Nov-2008		RK		Created this module for the S3E Starter Board
// Apr-2012		DG		Modified for Nexys 3 board
// Dec-2014		RJ		Cleaned up formatting.  No functional changes
// Description:
// ------------
// Top level module for the ECE 540 Getting Started reference design
// on the Nexys3 FPGA Board (Xilinx XC6LX16-CS324)
//
// Use the pushbuttons to control the Rojobot wheels:
//	btnl	Left wheel forward
//	btnu	Left wheel reverse
//	btnr	Right wheel forward
//	btnd	Right wheel reverse
//  btns	System reset
//
//	Switches are not used. Compass heading and a turn indicator 
//	are shown on the seven segment dispay.  LED's display the chase segments.  
///////////////////////////////////////////////////////////////////////////

module Nexys3fpga (
	input 				clk100,          		// 100MHz clock from on-board oscillator
	input				btnl, btnr,				// pushbutton inputs - left and right
	input				btnu, btnd,				// pushbutton inputs - top and bottom
	input				btns,					// pushbutton inputs - center button
	input	[7:0]		sw,						// switch inputs
	
	output	[7:0]		led,  					// LED outputs	
	
	output 	[7:0]		seg,					// Seven segment display cathode pins
	output	[3:0]		an,						// Seven segment display anode pins	
	
	output	[3:0]		JA,						// JA Header
	
	input 	[9:0] 		vid_row , vid_col,		// inputs from Video Controller to bot.v
	output  [1:0]		vid_pixel_out			// output from bot.v to Video Controller
); 

	// internal variables
	wire 	[7:0]		db_sw;					// debounced switches
	wire 	[4:0]		db_btns;				// debounced buttons
	
	wire				sysclk;					// 100MHz clock from on-board oscillator	
	wire				sysreset;				// system reset signal - asserted high to force reset
	
	wire 	[4:0]		dig3, dig2, 
						dig1, dig0;				// display digits
	wire 	[3:0]		decpts;					// decimal points
	wire 	[7:0]		chase_segs;				// chase segments from Rojobot (debug)

/******************************************************************/
/* CHANGE THIS SECTION FOR YOUR LAB 1                             */
/******************************************************************/		
	wire	[7:0]		left_pos, right_pos;
	wire 	[31:0]		digits_out;				// ASCII digits (Only for Simulation)
	
	// 	Internal Signals
	wire 	[11:0]		address;
	wire	[17:0]		instruction;
	wire				bram_enable;
	wire	[7:0]		port_id, out_port, in_port;
	wire				write_strobe, k_write_strobe, read_strobe, interrupt, interrupt_ack;
	wire	[7:0]		MotCtl_in, LocX_reg, LocY_reg, BotInfo_reg, Sensors_reg, LMDist_reg, RMDist_reg;
	wire 				upd_sysregs;

	// set up the display and LEDs
	/*assign	dig3 = {1'b0,left_pos[7:4]};
	assign	dig2 = {1'b0,left_pos[3:0]};
	assign 	dig1 = {1'b0,right_pos[7:4]};
	assign	dig0 = {1'b0,right_pos[3:0]};
	assign	decpts = 4'b0100;					// d2 is on
	assign	led = db_sw;					// leds show the debounced switches
*/
/******************************************************************/
/* THIS SECTION SHOULDN'T HAVE TO CHANGE FOR LAB 1                */
/******************************************************************/			
	// global assigns
	assign	sysclk = clk100;
	assign 	sysreset = db_btns[0];
	assign	JA = {sysclk, sysreset, 2'b0};
	
//instantiate the debounce module
	debounce 	DB (
		.clk(sysclk),	
		.pbtn_in({btnl,btnu,btnr,btnd,btns}),
		.switch_in(sw),
		.pbtn_db(db_btns),
		.swtch_db(db_sw)
	);	
		
	// instantiate the 7-segment, 4-digit display
	sevensegment SSB (
		// inputs for control signals
		.d0(dig0),
		.d1(dig1),
 		.d2(dig2),
		.d3(dig3),
		.dp(decpts),
		// outputs to seven segment display
		.seg(seg),			
		.an(an),				
		// clock and reset signals (100 MHz clock, active high reset)
		.clk(sysclk),
		.reset(sysreset),
		// ouput for simulation only
		.digits_out(digits_out)
	);

/******************************************************************/
/* CHANGE THIS DEFINITION FOR YOUR LAB 1                          */
/******************************************************************/							
			


// instantiate PicoBlaze CPU
	kcpsm6 PSM (
	.clk(sysclk),
	.reset(sysreset),
	.address(address),
	.instruction(instruction),
	.bram_enable(bram_enable),
	.in_port(in_port),
	.out_port(out_port),
	.port_id(port_id),
	.write_strobe (write_strobe),
	.k_write_strobe(k_write_strobe), 
	.read_strobe(read_strobe), 
	.interrupt(interrupt), 
	.interrupt_ack(interrupt_ack), 
	.sleep(1'b0)
);

// instantiate bot_control instruction memory

	bot_control bot_ctr (
	.clk(sysclk),
	.address(address),
	.instruction(instruction),
	.enable(bram_enable),
	.rdl()
);

// instantiate interface
	nexys3_bot_if nex(
	.clk(sysclk),
	.reset(sysreset),
	.in_port(in_port),
	.out_port(out_port),
	.port_id(port_id),
	.write_strobe (write_strobe),
	.k_write_strobe(k_write_strobe), 
	.read_strobe(read_strobe), 
	.interrupt(interrupt), 
	.interrupt_ack(interrupt_ack), 
	.motctl(MotCtl_in),
	.locX(LocX_reg),
	.locY(LocY_reg),
	.botinfo(BotInfo_reg),
	.sensors(Sensors_reg),
	.lmdist(LMDist_reg),
	.rmdist(RMDist_reg),
	.upd_sysregs(upd_sysregs),
	.db_btns(db_btns[4:1]),
	.db_sw(db_sw),
	.dig3(dig3),
	.dig2(dig2),
	.dig1(dig1),
	.dig0(dig0),
	.dp(decpts),
	.led(led)

);
	//instantiate bot
	
	bot bot1 (
	.clk(sysclk),
	.reset(sysreset),
	.MotCtl_in(MotCtl_in),
	.LocX_reg(LocX_reg),
	.LocY_reg(LocY_reg),
	.BotInfo_reg(BotInfo_reg),
	.Sensors_reg(Sensors_reg),
	.LMDist_reg(LMDist_reg),
	.RMDist_reg(RMDist_reg),
	.upd_sysregs(upd_sysregs),
	.vid_col(vid_col),
	.vid_row(vid_row),
	.vid_pixel_out(vid_pixel_out)	
);
			
endmodule