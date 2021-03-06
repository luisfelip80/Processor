module uc (input logic clk, input logic[31:0] instruction,output logic PCWrite,
	output logic PCWriteCond,output logic BranchOp,output logic PCSrc,output logic [2:0] ALUFunct,
	output logic [1:0] ALUSrcB,output logic ALUSrcA,output logic LoadRegA,output logic LoadRegB,
	output logic LoadALUOut,output logic LoadMDR,output logic DMemWrite,output logic IMemWrite,output logic LoadIR,
	output logic [1:0] MemToReg,output logic WriteReg);

	reg [4:0]state;
	parameter init_state = 0; //estado 0
	parameter decod = 1;  // estado 1
	parameter cal_offset = 2; //
	parameter sum_reg = 3; //
	parameter sub_reg = 4; //
	parameter read_mem = 5;// 
	parameter write_mem = 6;//
	parameter lui = 7; //
	parameter beq_wpc = 8;//
	parameter bne_wpc = 9;//
	parameter ld_wreg = 10;//
	parameter add_wreg = 11;//

	always @(posedge clk) begin
		case(state)
			init_state: begin

				PCWrite <= 1;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b001;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b01;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				state <= decod;
				end
			decod: begin
				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b001;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b11;
				LoadRegA <= 1;
				LoadRegB <= 1;
				LoadALUOut <=1;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 1;


				case(instruction[6:0])
					7'b0110011: //type r
					begin
						case(instruction[31:24])
							7'b0000000: // add
							begin
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b001;
								LoadALUOut <= 1;
								state <= sum_reg; 	
							end
							7'b0100000: // sub
							begin 
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b010;
								LoadALUOut <= 1;
								state <= sub_reg; 	
							end
						endcase
					end
					7'b0100011: //type s
					begin
						ALUSrcA <= 2'b01;
						ALUSrcB <= 2'b10;
						ALUFunct <= 3'b001;
						LoadALUOut <= 1;
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0010011: //type i (ADDI)
					begin
						ALUSrcA <= 2'b01;
						ALUSrcB <= 2'b10;
						ALUFunct <= 3'b001;
						LoadALUOut <= 1;
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0000011: //type i (LD)
					begin
						ALUSrcA <= 2'b01;
						ALUSrcB <= 2'b10;
						ALUFunct <= 3'b001;
						LoadALUOut <= 1;
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0110111: //type u
					begin
						MemToReg = 2;
						WriteReg = 1;
						state <= lui; 
					end
					7'b1100111: //type sb
					begin
						case(instruction[10:7])
							3'b000: // BEQ
							begin 
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b010;
								PCWriteCond = 1;
								PCSrc = 2'b01;
								BranchOp = 0;
								state <= init_state; //volta pro começo 	
							end
							3'b001: // BNE
							begin 
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b010;
								PCWriteCond = 1;
								PCSrc = 2'b01;
								BranchOp = 1;
								state <= init_state; //volta pro começo 	
							end
						endcase
					end		
				endcase
				end
			cal_offset: begin
				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b001;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b10;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=1;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				case (instruction[6:0]) // sai de offset e vai para umas das funções
					7'b0100011: //type s
					begin
						state <= write_mem; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0010011: //type i (ADDI)
					begin
						state <= add_wreg; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0000011: //type i (LD)
					begin
						state <= read_mem; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					endcase
				end 
			sum_reg: begin
				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b001;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <= 1;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				state <= add_wreg;
				end	
			sub_reg: begin
				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b010;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=1;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				state <= add_wreg;
				end	
			read_mem: begin
				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 1;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				state <= ld_wreg;
				end
			write_mem: begin
				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 1;
				IMemWrite <= 0;
				LoadIR <= 0;
				state<=init_state;
				end
			lui: begin
				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 1;
				MemToReg <= 2'b10;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				state <=init_state;
				 end
		 	beq_wpc: begin
		 		PCWrite <= 0;
				PCWriteCond <= 1;
				PCSrc <= 1;
				ALUFunct <= 3'b010;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				BranchOp <= 0;
				state <= init_state;
		 			 end	 
		 	bne_wpc: begin
		 		PCWrite <= 0;
				PCWriteCond <= 1;
				PCSrc <= 1;
				ALUFunct <= 3'b010;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				BranchOp <= 1;
				state <= init_state;
		 			end
		 	ld_wreg: begin
		 		PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 1;
				MemToReg <= 1;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				BranchOp <= 0;
				state<= init_state;
		 			 end
		 	add_wreg: begin
		 		PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 1;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				BranchOp <= 0;
				state<= init_state;
		 			  end		 	
		endcase 
	end


endmodule // uc