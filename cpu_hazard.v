`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:23:16 05/16/2016 
// Design Name: 
// Module Name:    cpu_test 
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

module cpu_hazard(input wire clk,
           input wire rst,
			  input wire enable,
			  input wire start,

			  output wire d_we,
			  
			  output wire [7:0]i_addr,
			  output wire [7:0]d_addr,
			  
			  output wire	[15:0]i_datain,
			  
			  output reg [7:0]pc,
			  
			  output wire [15:0]d_dataout,
			  
			  input wire [3:0]select,
			  
			  output reg[6:0]seg,
			  output reg[3:0]en
			  
    );
	 
	 wire [15:0] d_datain;
    
	 reg [3:0]count;
	 wire clock;
	 
	 //reg [7:0]pc;
	 	 
	 always@(posedge clk)
    begin
	   if(!rst) count <= 0;
		else count <= count + 1;
    end	 
		 
	assign clock = count[3];        //18fangzhen  28paoban
	assign i_addr = pc;	
		
	////////IP core////////
	
   //sort_imem sort_inmem(.clka(clk), .addra(pc), .douta(i_datain));
   //ort_dmem sort_damem(.clka(clk), .wea(d_we), .addra(d_addr), .dina(d_dataout), .douta(d_datain));

   //gcm_imem gcm_inmem(.clka(clk), .addra(pc), .douta(i_datain));
   //gcm_dmem gcm_damem(.clka(clk), .wea(d_we), .addra(d_addr), .dina(d_dataout), .douta(d_datain));	
	
	bubble_imem bubble_inmem(.clka(clk), .addra(pc), .douta(i_datain));
   bubble_dmem bubble_damem(.clka(clk), .wea(d_we), .addra(d_addr), .dina(d_dataout), .douta(d_datain));
	
	//b_imem b_inmem(.clka(clk), .addra(pc), .douta(i_datain));
	//b_dmem b_damem(.clka(clk), .wea(d_we), .addra(d_addr), .dina(d_dataout), .douta(d_datain));
	
	//////////////Function////////
	
   //total_test_imem imem(.mem_clk(clk), .addr(i_addr), .rdata(i_datain));
	//total_test_dmem dmem(.reset(rst), .mem_clk(clk), .dwe(d_we), .addr(d_addr), .wdata(d_dataout), .rdata(d_datain));
	
   /////////////cpu state control/////////////////////////////////////////////
	 reg state;
	 reg next_state;
	 reg [15:0]wb_ir;

	 always @(posedge clk or negedge rst)
	 begin
	 if(!rst) state <= `idle;
	 else state <= next_state; 
	 end
	 
	 
	 always @(*)
	 begin
	 
	 if(!rst) next_state <= 0;
	 
	 else 
	 begin
	 case(state)
	 `idle: if(enable == 1 && start == 1) next_state <= `exec;
	        else next_state <= `idle;
	 `exec: if(enable == 0 || wb_ir[15:11] == `HALT) next_state <= `idle;
	        else next_state <= `exec;
	 endcase
	 end
	 end
    ////end/////////////////////////////////////////////////////////////
	 
	 
	 
	 //////////IF///////////////////////////////////////////////////////////
	 reg [15:0]id_ir;
	 reg [15:0]reg_C;
	 
	 always @(posedge clock or negedge rst)
	 begin
	 if(!rst)
	   begin
	   id_ir <= 16'b0000_0000_0000_0000;
	   pc <= 8'b0000_0000;
	   end
	 else if(state == `exec)
	   begin
	 
	   if(((ex_ir[15:11] == `BZ) && (zf == 1)) || ((ex_ir[15:11] == `BN) && (nf == 1)) 
		|| ((ex_ir[15:11] == `BNZ) && (zf == 0))|| ((ex_ir[15:11] == `BNN) && (nf == 0))
		|| ((ex_ir[15:11] == `BC) && (cf == 1)) || ((ex_ir[15:11] == `BNC) && (cf == 0)) 
		||  ex_ir[15:11] == `JMPR)
		begin
	     pc <= ALUo[7:0];
		  id_ir <= 0;
		end
		  
	   else if(id_ir[15:11] == `JUMP)
		begin
	     pc <= id_ir[7:0];
		  id_ir <= 16'b0;
		end
		  
		  
	   else if(id_ir[15:11] == `LOAD &&(i_datain[15:11]!=`JUMP)&&(i_datain[15:11]!=`NOP)&&
		(i_datain[15:11]!=`HALT)&&(i_datain[15:11]!=`LOAD))
		begin
		  if((id_ir[10:8]==i_datain[2:0])&&((i_datain[15:11]==`ADD)||(i_datain[15:11]==`ADDC)
		   ||(i_datain[15:11]==`SUB)||(i_datain[15:11]==`SUBC)||(i_datain[15:11]==`CMP)
			||(i_datain[15:11]==`AND)||(i_datain[15:11]==`OR)||(i_datain[15:11]==`XOR)))
		  begin
		    pc <= pc;
			 id_ir <= 16'b0;
		  end
		  
		  else if((id_ir[10:8]==i_datain[6:4])&&((i_datain[15:11]==`STORE)||(i_datain[15:11]==`ADD)
		   ||(i_datain[15:11]==`ADDC)||(i_datain[15:11]==`SUB)|| (i_datain[15:11]==`LOAD)
			||(i_datain[15:11]==`SUBC)||(i_datain[15:11]==`AND)||(i_datain[15:11]==`OR)  
         ||(i_datain[15:11]==`XOR)||(i_datain[15:11]==`CMP)||(i_datain[15:11]==`SLL)
			||(i_datain[15:11]==`SRL)||(i_datain[15:11]==`SLA)||(i_datain[15:11]==`SRA)))
		  begin
		    pc <= pc;
			 id_ir <= 16'b0;
		  end
		  
		  else if((id_ir[10:8]==i_datain[10:8])&&((i_datain[15:11]==`LDIH)||(i_datain[15:11]==`SUBI)  
           ||(i_datain[15:11]==`JMPR)||(i_datain[15:11]==`BZ)||(i_datain[15:11]==`BNZ)
			  ||(i_datain[15:11]==`BN)  ||(i_datain[15:11]==`BNN)||(i_datain[15:11]==`BC)
			  ||(i_datain[15:11]==`BNC)||(i_datain[15:11]==`ADDI)))
		  begin
		    pc <= pc;
			 id_ir <= 16'b0;
		  end
		  else
		  begin
		    pc <= pc + 1;
			 id_ir <= i_datain;
		  end
		  
		end
		
		else
		begin
	     pc <= pc + 1;
		  id_ir <= i_datain;
		end
		end 
		
	 else if(state == `idle)
	   begin
		id_ir <= id_ir;
	   pc <= pc;
	   end
	 end
    ///////end///////////////////////////////////////////////////////////////////
	 
	 
	 ///////ID///////////////////////////////////////////////////////////////////
	 reg [15:0]ex_ir;
	 reg [15:0]reg_A;
	 reg [15:0]reg_B;
    reg [15:0]smdr;
	 reg [15:0]gr[0:7];
	 reg signed[15:0]reg_A1;
	 
	 always @(posedge clock or negedge rst)
	 begin
	 if(!rst) 
	   begin
	   ex_ir <= 0;
	   reg_A <= 0;
		reg_A1 <= 0;
	   reg_B <= 0;
	   smdr <= 0;
	   end
	 else if(state == `exec)
	   begin
	   ex_ir <= id_ir;
		
	 /////////reg_A/////////////////////////////
	 
	   if(((ex_ir[15:11] == `BZ) && (zf == 1)) || ((ex_ir[15:11] == `BN) && (nf == 1)) 
		|| ((ex_ir[15:11] == `BNZ) && (zf == 0))|| ((ex_ir[15:11] == `BNN) && (nf == 0))
		|| ((ex_ir[15:11] == `BC) && (cf == 1)) || ((ex_ir[15:11] == `BNC) && (cf == 0)) 
		||  ex_ir[15:11] == `JMPR)
		begin
	     reg_A <= 16'b0;
		  reg_A1 <= 16'b0;
		  ex_ir <= 16'b0;
		end
		
	   else if(id_ir[15:11] == `BN || id_ir[15:11] == `BZ || id_ir[15:11] == `BNZ 
		|| id_ir[15:11] == `BNN || id_ir[15:11] == `BC || id_ir[15:11] == `BNC 
		|| id_ir[15:11] == `JMPR || id_ir[15:11] == `ADDI || id_ir[15:11] == `SUBI 
		|| id_ir[15:11] == `LDIH)
		begin
		  if(ex_ir[10:8] == id_ir[10:8] && (ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`CMP)&&(ex_ir[15:11]!=`JUMP)
		  &&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`HALT)&&(ex_ir[15:11]!=`BNN)&&(ex_ir[15:11]!=`BN)&&(ex_ir[15:11]!=`BZ)
		  &&(ex_ir[15:11]!=`BNZ)&&(ex_ir[15:11]!=`BNC)&&(ex_ir[15:11]!=`BC))
		  begin
		    reg_A <= ALUo;
			 reg_A1 <= ALUo;
		  end
		  
		  else if(mem_ir[10:8] == id_ir[10:8] &&(mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`CMP)&&
		  (mem_ir[15:11]!=`JUMP)&&(mem_ir[15:11]!=`HALT)&&(mem_ir[15:11]!=`BNN)&&(mem_ir[15:11]!=`BN)&&(mem_ir[15:11]!=`BZ)
		  &&(mem_ir[15:11]!=`BNZ)&&(mem_ir[15:11]!=`BNC)&&(mem_ir[15:11]!=`BC))
		  begin
		    if(mem_ir[15:11] != `LOAD) begin reg_A <= reg_C; reg_A1 <= reg_C; end
	       else begin reg_A <= d_datain; reg_A1 <= d_datain; end
		  end
		  
		  else if((id_ir[10:8]== wb_ir[10:8])&&(wb_ir[15:11]!=`NOP)&&(wb_ir[15:11]!=`CMP)&&
		  (wb_ir[15:11]!=`JUMP)&&(wb_ir[15:11]!=`HALT)&&(wb_ir[15:11]!=`BNN)&&(wb_ir[15:11]!=`BN)&&(wb_ir[15:11]!=`BZ)
		  &&(wb_ir[15:11]!=`BNZ)&&(wb_ir[15:11]!=`BNC)&&(wb_ir[15:11]!=`BC)) 
		  begin
		    reg_A <= reg_C1;
			 reg_A1 <= reg_C1;
		  end
		  
		  else 
		  begin
		    reg_A <= gr[id_ir[10:8]];
			 reg_A1 <= gr[id_ir[10:8]];
		  end
		end
	   else if((id_ir[15:11] == `ADD)||(id_ir[15:11] == `LOAD)||(id_ir[15:11] == `STORE)
		||(id_ir[15:11] == `ADDC)||(id_ir[15:11] == `SUB)||(id_ir[15:11] == `SUBC)
		||(id_ir[15:11] == `CMP) ||(id_ir[15:11] == `AND)||(id_ir[15:11] == `OR)  
		||(id_ir[15:11] == `XOR) ||(id_ir[15:11] == `SLL)||(id_ir[15:11] == `SRL) 
		||(id_ir[15:11] == `SLA) ||(id_ir[15:11] == `SRA))
		begin
		  
		  if((id_ir[6:4] == ex_ir[10:8])&&(ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`CMP)&&(ex_ir[15:11]!=`JUMP)
		  &&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`HALT) && (ex_ir[15:11]!=`BZ)&& (ex_ir[15:11]!=`BNZ)&& (ex_ir[15:11]!=`BN)
		  && (ex_ir[15:11]!=`BNN)&& (ex_ir[15:11]!=`BC)&& (ex_ir[15:11]!=`BNC))
		  begin
		    reg_A <= ALUo;
			 reg_A1 <= ALUo;
		  end
		  
		   else if((id_ir[6:4] == mem_ir[10:8])&&(mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`CMP)
			&&(mem_ir[15:11]!=`JUMP)&&(mem_ir[15:11]!=`HALT)&& (mem_ir[15:11]!=`BZ)&& (mem_ir[15:11]!=`BNZ)&& 
			(mem_ir[15:11]!=`BN) && (mem_ir[15:11]!=`BNN)&& (mem_ir[15:11]!=`BC)&& (mem_ir[15:11]!=`BNC))
			begin
			if(mem_ir[15:11] == `LOAD)
			begin
			  reg_A <= d_datain;
			  reg_A1 <= d_datain;
			end
			else
			begin 
			  reg_A <= reg_C;
			  reg_A1 <= reg_C;
			end
			end
			
			else if((id_ir[6:4]== wb_ir[10:8])&&(wb_ir[15:11]!=`NOP)&&(wb_ir[15:11]!=`CMP)&&
			(wb_ir[15:11]!=`JUMP)&&(wb_ir[15:11]!=`HALT)&& (wb_ir[15:11]!=`BZ)&& (wb_ir[15:11]!=`BNZ)&& 
			(wb_ir[15:11]!=`BN) && (wb_ir[15:11]!=`BNN)&& (wb_ir[15:11]!=`BC)&& (wb_ir[15:11]!=`BNC))  
			begin
           reg_A <= reg_C1;  
			  reg_A1 <= reg_C1;
			end
         else 
         begin			
           reg_A <= gr[id_ir[6:4]];
			  reg_A1 <= gr[id_ir[6:4]];
			end
		 end	
       else;          	
	 
	 ////////reg_B/////////////////////////////
	   if(((ex_ir[15:11] == `BZ) && (zf == 1)) || ((ex_ir[15:11] == `BN) && (nf == 1)) 
		|| ((ex_ir[15:11] == `BNZ) && (zf == 0))|| ((ex_ir[15:11] == `BNN) && (nf == 0))
		|| ((ex_ir[15:11] == `BC) && (cf == 1)) || ((ex_ir[15:11] == `BNC) && (cf == 0)) 
		||  ex_ir[15:11] == `JMPR)
		begin
	     reg_B <= 16'b0;
		end
		
	   else if(id_ir[15:11] == `LOAD || id_ir[15:11] == `SLL || id_ir[15:11] == `SRL 
		|| id_ir[15:11] == `SLA || id_ir[15:11] == `SRA)
	     reg_B <= {12'b0000_0000_0000, id_ir[3:0]};
		  
	   else if(id_ir[15:11] == `STORE)
	   begin
	     reg_B <= {12'b0000_0000_0000, id_ir[3:0]};
		  		  
	   end
		
		else if(id_ir[15:11] == `LDIH)
		begin
		  reg_B <= {id_ir[7:0], 8'b0000_0000};
		end
		
		else if(id_ir[15:11] == `ADDI || id_ir[15:11] == `SUBI || id_ir[15:11] == `BN 
		|| id_ir[15:11] == `BZ || id_ir[15:11] == `BNZ || id_ir[15:11] == `BNN 
		|| id_ir[15:11] == `BC || id_ir[15:11] == `BNC || id_ir[15:11] == `JMPR)
		  reg_B <= {8'b0000_0000, id_ir[7:0]};
	 
	   else if ((id_ir[15:11] == `ADD)||(id_ir[15:11] == `ADDC)||(id_ir[15:11] == `SUB)
		||(id_ir[15:11] == `SUBC)||(id_ir[15:11] == `CMP)||(id_ir[15:11] == `AND) 
		||(id_ir[15:11] == `OR) ||(id_ir[15:11] == `XOR))
		begin
		  if((id_ir[2:0]==ex_ir[10:8])&&(ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`CMP)&&
		  (ex_ir[15:11]!=`JUMP)&&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`HALT)&& (ex_ir[15:11]!=`BZ)&& (ex_ir[15:11]!=`BNZ)&& 
		  (ex_ir[15:11]!=`BN) && (ex_ir[15:11]!=`BNN)&& (ex_ir[15:11]!=`BC)&& (ex_ir[15:11]!=`BNC))
		    reg_B <= ALUo;
			
		  else if((id_ir[2:0]==mem_ir[10:8])&&(mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`CMP)&&
		  (mem_ir[15:11]!=`JUMP)&&(mem_ir[15:11]!=`HALT)&& (mem_ir[15:11]!=`BZ)&& (mem_ir[15:11]!=`BNZ)&&
		  (mem_ir[15:11]!=`BN)&& (mem_ir[15:11]!=`BNN)&& (mem_ir[15:11]!=`BC)&& (mem_ir[15:11]!=`BNC))
		  begin
		    if(mem_ir[15:11] == `LOAD)
			 reg_B <= d_datain;
			 else 
			 reg_B <= reg_C;
		  end
		  
		  else if((id_ir[2:0]== wb_ir[10:8])&&(wb_ir[15:11]!=`NOP)&&(wb_ir[15:11]!=`CMP)
		  &&(wb_ir[15:11]!=`JUMP)&&(wb_ir[15:11]!=`HALT)&& (wb_ir[15:11]!=`BZ)&& (wb_ir[15:11]!=`BNZ)&& 
		  (wb_ir[15:11]!=`BN) && (wb_ir[15:11]!=`BNN)&& (wb_ir[15:11]!=`BC)&& (wb_ir[15:11]!=`BNC))  
          reg_B <= reg_C1;
		  else
		    reg_B <= gr[id_ir[2:0]];
		end
		  
      else; 
    
      if(id_ir[15:11] == `STORE)
      begin
		
		  if((id_ir[10:8]==ex_ir[10:8])&&(ex_ir[15:11]!=`NOP)&&(ex_ir[15:11]!=`CMP)
		  &&(ex_ir[15:11]!=`JUMP)&&(ex_ir[15:11]!=`LOAD)&&(ex_ir[15:11]!=`HALT))
		  begin
		    smdr <= ALUo;
		  end
		  
		  else if((id_ir[10:8]==mem_ir[10:8])&&(mem_ir[15:11]!=`NOP)&&(mem_ir[15:11]!=`CMP)
		  &&(mem_ir[15:11]!=`JUMP)&&(mem_ir[15:11]!=`HALT))                     
        begin  
          if(mem_ir ==`LOAD)  
            smdr <= d_datain;  
           else  
             smdr <= reg_C;                    
        end 
       
        else if((id_ir[10:8]== wb_ir[10:8])&&(wb_ir!=`NOP)&&(wb_ir!=`CMP)&&(wb_ir!=`JUMP)&&(wb_ir!=`HALT))  
          smdr <= reg_C1;

        else
          smdr <= gr[id_ir[10:8]];
      end		
		
	 end
	 
	 
    else if(state == `idle)
	 begin
	 reg_A <= reg_A;
	 reg_B <= reg_B;
	 ex_ir <= ex_ir;
	 smdr <= smdr;
	 end
	 end
	 /////////end////////////////////////////////////////////////////////////////
	 
	 //////////ALU////////////////////////////////////
	 reg [15:0]ALUo;
	 
	 reg cf, nf, zf;
	 always @(reg_A or reg_B or ex_ir[15:11])
	   begin
		
		if(!rst)
		begin
		  ALUo <= 16'b0000_0000_0000_0000;
		  cf <= 0;
		end
		  
	   case(ex_ir[15:11])
		`ADD:                                                
                     {cf,ALUo} <= reg_A + reg_B;                       //add  
      `ADDI:                                                
                     {cf,ALUo} <= reg_A + reg_B;                         //addi  
      `ADDC:                                                  
                     {cf,ALUo} <= reg_A + reg_B + cf;                   //addc  
      `SUB:                                        
                     {cf,ALUo} <= reg_A - reg_B;                         
      `SUBI:                                       
                     {cf,ALUo} <= reg_A - reg_B;                         //subi  
      `SUBC:                                      
                     {cf,ALUo} <= reg_A - reg_B - cf;                   //subc  
      `CMP:  
                     {cf,ALUo} <= reg_A - reg_B;                        //cmp 
      `LOAD:                                               
                          ALUo <= reg_A + reg_B;                         //load  
      `LDIH:                                               
                     {cf,ALUo} <= reg_A + reg_B; 
      `STORE:                                              
                          ALUo <= reg_A + reg_B; 							                                                       
      `AND:   
                          ALUo <= (reg_A & reg_B);                     //and   
      `OR:   
                          ALUo <= (reg_A | reg_B);                     //or                                        
      `XOR:   
                          ALUo <= (reg_A ^ reg_B);                     //xor  
      `SLL:   
                          ALUo <= (reg_A << reg_B[3:0]);               //ex_ir[3:0]);                 
		`SLA:                       
                          ALUo <= (reg_A1 <<< reg_B[3:0]);              //ex_ir[3:0]);              //sla  
      `SRL:   
                          ALUo <= (reg_A >> reg_B[3:0]);               //ex_ir[3:0]);               //srl           
      `SRA:       
                          ALUo <= (reg_A1 >>> reg_B[3:0]);              //ex_ir[3:0]);                //sra   
      `BZ:  
                          ALUo <= reg_A + reg_B;                         //bz  
      `BNZ:  
                          ALUo <= reg_A + reg_B;                         //bnz                   
      `BN:  
                          ALUo <= reg_A + reg_B;                         //bn  
      `BNN:  
                          ALUo <= reg_A + reg_B;                         //bnn  
      `BC:  
                          ALUo <= reg_A + reg_B;                         //bc  
      `BNC:  
                          ALUo <= reg_A + reg_B;                         //bnc  
      `JMPR:  
                          ALUo <= reg_A + reg_B;           
      
     endcase  
	   end
	 ///////end////////////////////////////////////////////////
	 
	 
	 /////////  EX  ////////////////////////////////////////////////////////////////
	 reg [15:0]mem_ir;
	 reg [15:0]smdr1;
	 reg dw;
	 
	 always @(posedge clock or negedge rst)
	 begin
	 if(!rst)
	 begin
	 mem_ir <= 0;
	 reg_C <= 0;
	 zf <= 0;
	 nf <= 0;
	 dw <= 0;
	 smdr1 <= 0;
	 end
	 else if(state == `exec)
	 begin
	 mem_ir <= ex_ir;
	 reg_C <= ALUo;
	 smdr1 <= smdr;
	 
	 if(ex_ir[15:11] == `CMP || ex_ir[15:11] == `ADD || ex_ir[15:11] == `ADDI|| ex_ir[15:11] == `ADDC|| ex_ir[15:11] == `SUB
	 || ex_ir[15:11] == `SUBI|| ex_ir[15:11] == `SUBC|| ex_ir[15:11] == `LDIH)
	 begin
	   if(ALUo == 0)
	   zf <= 1;
	   else 
	   zf <= 0;
	 
	   if(ALUo[15] == 1)
	   nf <= 1;
	   else
	   nf <= 0;
	 end
	 
		
	 if(ex_ir[15:11] == `STORE)  dw <= 1; 
	 else dw <= 0;
	 
	 end
	 else if(state == `idle)
	 begin
	 zf <= zf;
	 nf <= nf;
	 dw <= dw;
	 end
	 end
	 
	 
	 assign d_addr = reg_C;
	 assign d_dataout = smdr1;
	 assign d_we = dw;
	 /////end/////////////////////////////////////////////////////////////////////////////
	 
	 
	 /////MEM/////////////////////////////////////////////////////////////////////////////
	 reg [15:0]reg_C1;
	 
	 always @(posedge clock or negedge rst)
	 begin
	 if(!rst)
	 begin
	 wb_ir <= 0;
	 reg_C1 <= 0;
	 //d_dataout <= 0;
	 //d_we <= 0;
	 
	 end
	 else if(state == `exec)
	 begin
	 wb_ir <= mem_ir;
	 //d_dataout <= smdr1;
	 //d_we <= dw;
	 
	 
	 if(mem_ir[15:11] == `LOAD)
	 reg_C1 <= d_datain;
	 else
	 reg_C1 <= reg_C;
	 end
	 end
	 ///////end//////////////////////////////////////////////////////////////////////////
	 
	 ///////// WB /////////////////////////////////////////////////////////////////////////
	 always @(posedge clock or negedge rst) 
	 begin
	 if(!rst)
	   begin
	   gr[7] <= 16'b0000_0000_0000_0000;  
      gr[6] <= 16'b0000_0000_0000_0000;  
      gr[5] <= 16'b0000_0000_0000_0000;  
      gr[4] <= 16'b0000_0000_0000_0000;  
      gr[3] <= 16'b0000_0000_0000_0000;  
      gr[2] <= 16'b0000_0000_0000_0000;  
      gr[1] <= 16'b0000_0000_0000_0000;  
      gr[0] <= 16'b0000_0000_0000_0000; 
		end
	 else if(state == `exec)
	 begin
	 if((wb_ir[15:11] == `LOAD)|| (wb_ir[15:11] == `ADD) || (wb_ir[15:11] == `ADDC)  
    || (wb_ir[15:11] == `SUB) || (wb_ir[15:11] == `SUBC)|| (wb_ir[15:11] == `LDIH)  
    || (wb_ir[15:11] == `ADDI)|| (wb_ir[15:11] == `SUBI)|| (wb_ir[15:11] == `AND)   
    || (wb_ir[15:11] == `OR)  || (wb_ir[15:11] == `XOR) || (wb_ir[15:11] == `SLL)  
    || (wb_ir[15:11] == `SLA) || (wb_ir[15:11] == `SRL) || (wb_ir[15:11] == `SRA))
	 gr[wb_ir[10:8]] <= reg_C1;
	 else  
    gr[wb_ir[10:8]] <= gr[wb_ir[10:8]];
	 end
	 
	 end
    ////////end//////////////////////////////////////////////////////////////////////////	 
	 
	 ////////////display///////////////////
	 
	 reg [21:0]count1;
	 
	 always @(posedge clk or negedge rst)
	 if(!rst)
	 begin
	 count1 <= 1'b0;
	 end
	 else
	 begin
	 count1 <= count1 + 1'b1;
	 end
	 
	 always@(count1)
	 begin
	 
	 if(count1[18])
	 begin
	 en <= 4'b0111;
	 end
	 else if(count1[17])
	 begin
	 en <= 4'b1011;
	 end
	 else if(count1[16])
	 begin
	 en <= 4'b1101;
	 end
	 else 
	 en <= 4'b1110;
	 
	 end 
	 
	 reg [15:0]y;
	 always@(*)
	 begin
	   if(!rst)
	     y<=16'b0000_0000_0000_0000;
		else
		begin
	   case(select[3:0])
		4'b0000:  y<= {8'b0000_0000, pc};
	   4'b0001:  y<=id_ir;
		4'b0010:  y<=reg_A;
		4'b0011:  y<=reg_B;
		4'b0100:  y<=ALUo;
		4'b0101:  y<=reg_C;
		4'b0110:  y<=reg_C1;
		4'b0111:  y<=smdr1;
	   4'b1000:  y<=gr[0];
		4'b1001:  y<=gr[1];
		4'b1010:  y<=gr[1];
		4'b1011:  y<=gr[3];
		4'b1100:  y<=gr[4];
		4'b1101:  y<=gr[5];
		4'b1110:  y<=gr[6];
		4'b1111:  y<=gr[7];
		endcase
		end
	 end
	  
	 reg [3:0]num;
	 always @(*)
	 begin
	   case(en)
		4'b1110: num<=y[3:0];
		4'b1101: num<=y[7:4];
		4'b1011: num<=y[11:8];
		4'b0111: num<=y[15:12];
		default: num <= 0;
		endcase
	 end
	 
	 always@(*)
	 begin
	   if(!rst)
		  seg = 7'b000_0000;
		else
		begin
	   case(num)
		4'b0000: seg = 7'b0000001;
		4'b0001: seg = 7'b1001111;
		4'b0010: seg = 7'b0010010;
		4'b0011: seg = 7'b0000110;
		4'b0100: seg = 7'b1001100;
		4'b0101: seg = 7'b0100100;
		4'b0110: seg = 7'b0100000;
		4'b0111: seg = 7'b0001111;
		4'b1000: seg = 7'b0000000;
		4'b1001: seg = 7'b0000100;
		4'b1010: seg = 7'b0001000;
		4'b1011: seg = 7'b1100000;
		4'b1100: seg = 7'b0110001;
		4'b1101: seg = 7'b1000010;
		4'b1110: seg = 7'b0110000;
		4'b1111: seg = 7'b0111000;
		endcase
		end
	 end

endmodule

