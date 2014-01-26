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
	
	output 	wire		Vsync,				// Output from DTG
	output	wire		Hsync,				// Output from DTG
	
	output	wire [2:0]	vgaRed,					// Output from Colorizer
	output	wire [2:0]	vgaGreen,					// Output from Colorizer
	output 	wire [1:0]	vgaBlue					// Output from Colorizer
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
	
	//Internal signals to Video controller
	wire video_on;
	wire [9:0] vid_col, vid_row;
	wire [1:0] icon;
	wire [1:0] vid_pixel_out;
	wire            clkfb_in, clk0_buf;

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
		.clk(clkfb_in),	
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
		.clk(clkfb_in),
		.reset(sysreset),
		// ouput for simulation only
		.digits_out(digits_out)
	);

/******************************************************************/
/* CHANGE THIS DEFINITION FOR YOUR LAB 1                          */
/******************************************************************/							
			


// instantiate PicoBlaze CPU
	kcpsm6 PSM (
	.clk(clkfb_in),
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


	bot_ctrl bot_ctrl (
	.clk(clkfb_in),
	.address(address),
	.instruction(instruction),
	.enable(bram_enable),
	.rdl()
);


/*
	proj1demo proj1 (
	.clk(sysclk),
	.address(address),
	.instruction(instruction),
	.enable(bram_enable),
	.rdl()
);
*/
// instantiate interface
	nexys3_bot_if nex(
	.clk(clkfb_in),
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
	.clk(clkfb_in),
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

// colorizer
	colorizer colorizer1(
	.clock (clk25), 
	.rst (sysreset),
	.video_on (video_on),
	.world_pixel(vid_pixel_out),
	.icon(icon),
	.red(vgaRed),
	.green(vgaGreen),
	.blue(vgaBlue)
	);
	
//icon
	icon icon1(
	.clock (clk25), 
	.rst (sysreset),
	.LocX_reg(LocX_reg),				
	.LocY_reg(LocY_reg),	
	.BotInfo_reg(BotInfo_reg),
	.Pixel_row(vid_row),
	.Pixel_column(vid_col),
	.icon(icon)
	);
	
//dtg
	dtg dtg1 (
	.clock (clk25), 
	.rst (sysreset),
	.horiz_sync(Hsync), 
	.vert_sync(Vsync), 
	.video_on(video_on),		
	.pixel_row(vid_row), 
	.pixel_column(vid_col)
	);

//dcm
// insert this template into your top-level module to instantiate a DCM_SP and clock feedback buffer. 
// The DCM is configured to generate a divide-by-two clock output.

   
   // DCM clock feedback buffer
   BUFG CLK0_BUFG_INST (.I(clk0_buf), .O(clkfb_in));

// DCM_SP: Digital Clock Manager Circuit
// Spartan-3E/3A, Spartan-6
// Xilinx HDL Libraries Guide, version 11.2

DCM_SP #(
.CLKDV_DIVIDE(4.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
// 7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
.CLKFX_DIVIDE(1), // Can be any integer from 1 to 32
.CLKFX_MULTIPLY(4), // Can be any integer from 2 to 32
.CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
.CLKIN_PERIOD(10.0), // Specify period of input clock
.CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift of NONE, FIXED or VARIABLE
.CLK_FEEDBACK("1X"), // Specify clock feedback of NONE, 1X or 2X
.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or
// an integer from 0 to 15
.DLL_FREQUENCY_MODE("LOW"), // HIGH or LOW frequency mode for DLL
.DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
.PHASE_SHIFT(0), // Amount of fixed phase shift from -255 to 255
.STARTUP_WAIT("FALSE") // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) DCM_SP_inst (
.CLK0(clk0_buf), // 0 degree DCM CLK output
.CLK180(), // 180 degree DCM CLK output
.CLK270(), // 270 degree DCM CLK output
.CLK2X(), // 2X DCM CLK output
.CLK2X180(), // 2X, 180 degree DCM CLK out
.CLK90(), // 90 degree DCM CLK output
.CLKDV(clk25), // Divided DCM CLK out (CLKDV_DIVIDE)
.CLKFX(), // DCM CLK synthesis out (M/D)
.CLKFX180(), // 180 degree CLK synthesis out
.LOCKED(), // DCM LOCK status output
.PSDONE(), // Dynamic phase adjust done output
.STATUS(), // 8-bit DCM status bits output
.CLKFB(clkfb_in), // DCM clock feedback
.CLKIN(sysclk), // Clock input (from IBUFG, BUFG or DCM)
.PSCLK(1'b0), // Dynamic phase adjust clock input
.PSEN(1'b0), // Dynamic phase adjust enable input
.PSINCDEC(1'b0), // Dynamic phase adjust increment/decrement
.RST(1'b0) // DCM asynchronous reset input
);
// End of DCM_SP_inst instantiation

	
endmodule