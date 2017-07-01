`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:59:42 03/23/2016
// Design Name:   cpu_hazard
// Module Name:   F:/learning/zhuxiaoning/cpu_hazard/cpu_board1.v
// Project Name:  cpu_hazard
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu_hazard
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cpu_board1;

	// Inputs
	reg clk;
	reg rst;
	reg enable;
	reg start;
	reg [3:0]select;

	// Outputs
	wire d_we;
	wire [7:0] i_addr;
	wire [15:0] d_addr;
	wire [15:0] i_datain;
	wire [7:0] pc;
	wire [15:0] d_dataout;
	wire [6:0] seg;
	wire [3:0] en;

	// Instantiate the Unit Under Test (UUT)
	cpu_hazard uut (
		.clk(clk), 
		.rst(rst), 
		.enable(enable),
		.start(start), 
		.d_we(d_we), 
		.i_addr(i_addr), 
		.d_addr(d_addr), 
		.i_datain(i_datain), 
		.pc(pc), 
		.d_dataout(d_dataout), 
		.select(select), 
		.seg(seg), 
		.en(en)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		enable = 0;
		start = 0;
		select = 0;

		// Wait 100 ns for global reset to finish
		#100;
      $display("LOAD,ADD,HALT,SUB,STORE");   
        $display("pc: id_ir:reg_A:reg_B:ALUo: reg_C: da: dd : w:reC1:gr0 :gr1 :gr2 :gr3 :gr4 :gr5 :gr6 :gr7 :exir:smdr:zf:cf:nf");  
        $monitor("%h: %h: %h :%h :%h :%h :%h:%h:%b:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h:%h: %b: %b: %b",   
            uut.pc, uut.id_ir, uut.reg_A, uut.reg_B, uut.ALUo,uut.reg_C,  
            uut.d_addr, uut.d_dataout, uut.d_we, uut.reg_C1, uut.gr[0],uut.gr[1], uut.gr[2], uut.gr[3], uut.gr[4], uut.gr[5], uut.gr[6], uut.gr[7],uut.ex_ir, 
uut.smdr,uut.zf, uut.cf, uut.nf);  
              
        enable <= 1; start <= 0;
		  
		  #10 rst  <= 0;
        #10 rst  <= 1;  
        #10 enable <= 1; 
        #10 select <= 4'b1000;		  
        #10 start  <= 1;  
        #10 start  <= 0;
        
		// Add stimulus here

	end
	always #1 clk = ~clk;
      
endmodule



