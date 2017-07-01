`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:09:45 05/15/2016 
// Design Name: 
// Module Name:    dmem_gcm 
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
`define idle    1'b0  
`define exec    1'b1  
// instruction macro define  
`define NOP 5'b00000  
`define HALT 5'b00001  
`define LOAD 5'b00010  
`define STORE 5'b00011  
`define SLL 5'b00100  
`define SLA 5'b00101  
`define SRL 5'b00110  
`define SRA 5'b00111  
`define ADD 5'b01000  
`define ADDI 5'b01001  
`define SUB 5'b01010  
`define SUBI 5'b01011  
`define CMP 5'b01100  
`define AND 5'b01101  
`define OR  5'b01110  
`define XOR 5'b01111  
`define LDIH 5'b10000  
`define ADDC 5'b10001  
`define SUBC 5'b10010  
`define JUMP 5'b11000  
`define JMPR 5'b11001  
`define BZ  5'b11010  
`define BNZ 5'b11011  
`define BN  5'b11100  
`define BNN 5'b11101  
`define BC  5'b11110  
`define BNC 5'b11111 
// general register  
`define gr0 3'b000  
`define gr1 3'b001  
`define gr2 3'b010  
`define gr3 3'b011  
`define gr4 3'b100  
`define gr5 3'b101  
`define gr6 3'b110  
`define gr7 3'b111

module total_test_dmem(reset,mem_clk,dwe,addr,wdata,rdata
    );

  input reset,mem_clk, dwe;
  input [7:0] addr;
  input [15:0] wdata;
  output reg[15:0] rdata;
  reg [15:0] d_mem[63:0];
  
  always @(posedge mem_clk or negedge reset)
  begin
    if(!reset)
    begin
    rdata <= 0;
  
    d_mem[0] <= 16'hfffd;
    d_mem[1] <= 16'h0004;
    d_mem[2] <= 16'h0005;
    d_mem[3] <= 16'hc369;
    d_mem[4] <= 16'h69c3;
    d_mem[5] <= 16'h0041;
    d_mem[6] <= 16'hffff;
    d_mem[7] <= 16'h0001;
    end
    else
    begin
      if(dwe) d_mem[addr] <= wdata;
	   else rdata <= d_mem[addr];
    end
  end


endmodule
