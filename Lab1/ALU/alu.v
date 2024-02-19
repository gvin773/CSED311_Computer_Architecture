`include "alu_func.v"

module ADD #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C,
	output OverflowFlag);

	assign C = A + B;
	assign OverflowFlag = ((A[data_width-1] == B[data_width-1]) && (A[data_width-1] != C[data_width-1]));

endmodule

module SUB #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C,
	output OverflowFlag);

	assign C = A - B;
	assign OverflowFlag = ((A[data_width-1] != B[data_width-1]) && (A[data_width-1] != C[data_width-1]));
	
endmodule

module ID #(parameter data_width = 16) (
	input [data_width-1:0] A,
	output [data_width-1:0] C);

	assign C = A;

endmodule

module NOT #(parameter data_width = 16) (
	input [data_width-1:0] A,
	output [data_width-1:0] C);

	assign C = ~A;
	
endmodule

module AND #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C);

	assign C = A & B;
	
endmodule

module OR #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C);

	assign C = A | B;
	
endmodule

module NAND #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C);

	assign C = ~(A & B);
	
endmodule

module NOR #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C);

	assign C = ~(A | B);
	
endmodule

module XOR #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C);

	assign C = A ^ B;
	
endmodule

module XNOR #(parameter data_width = 16) (
	input [data_width-1:0] A,
	input [data_width-1:0] B,
	output [data_width-1:0] C);

	assign C = ~(A ^ B);
	
endmodule

module LLS #(parameter data_width = 16) (
	input [data_width-1:0] A,
	output [data_width-1:0] C);

	assign C = A << 1;
	
endmodule

module LRS #(parameter data_width = 16) (
	input [data_width-1:0] A,
	output [data_width-1:0] C);

	assign C = A >> 1;
	
endmodule

module ALS #(parameter data_width = 16) (
	input signed [data_width-1:0] A,
	output signed [data_width-1:0] C);

	assign C = A <<< 1;
	
endmodule

module ARS #(parameter data_width = 16) (
	input signed [data_width-1:0] A,
	output signed [data_width-1:0] C);

	assign C = A >>> 1;
	
endmodule

module TCP #(parameter data_width = 16) (
	input [data_width-1:0] A,
	output [data_width-1:0] C);

	assign C = ~A + 1;
	
endmodule

module ZERO #(parameter data_width = 16) (
	output [data_width-1:0] C);

	assign C = 0;
	
endmodule

module ALU #(parameter data_width = 16) (
	input [data_width - 1 : 0] A, 
	input [data_width - 1 : 0] B, 
	input [3 : 0] FuncCode,
       	output reg [data_width - 1: 0] C,
       	output reg OverflowFlag);
// Do not use delay in your implementation.

// You can declare any variables as needed.
	wire [data_width-1:0] AddOut;
	wire AddFlag;
	wire [data_width-1:0] SubOut;
	wire SubFlag;
	wire [data_width-1:0] IdOut;
	wire [data_width-1:0] NotOut;
	wire [data_width-1:0] AndOut;
	wire [data_width-1:0] OrOut;
	wire [data_width-1:0] NandOut;
	wire [data_width-1:0] NorOut;
	wire [data_width-1:0] XorOut;
	wire [data_width-1:0] XnorOut;
	wire [data_width-1:0] LlsOut;
	wire [data_width-1:0] LrsOut;
	wire [data_width-1:0] AlsOut;
	wire [data_width-1:0] ArsOut;
	wire [data_width-1:0] TcpOut;
	wire [data_width-1:0] ZeroOut;

	ADD OP0(A, B, AddOut, AddFlag);
	SUB OP1(A, B, SubOut, SubFlag);
	ID OP2(A, IdOut);
	NOT OP3(A, NotOut);
	AND OP4(A, B, AndOut);
	OR OP5(A, B, OrOut);
	NAND OP6(A, B, NandOut);
	NOR OP7(A, B, NorOut);
	XOR OP8(A, B, XorOut);
	XNOR OP9(A, B, XnorOut);
	LLS OP10(A, LlsOut);
	LRS OP11(A, LrsOut);
	ALS OP12(A, AlsOut);
	ARS OP13(A, ArsOut);
	TCP OP14(A, TcpOut);
	ZERO OP15(ZeroOut);

initial begin
	C = 0;
	OverflowFlag = 0;
end   	

// TODO: You should implement the functionality of ALU!
// (HINT: Use 'always @(...) begin ... end')
always @(A or B or FuncCode) begin
	OverflowFlag = 0;
	case(FuncCode)
		`FUNC_ADD: begin
			C = AddOut;
			OverflowFlag = AddFlag;
		end

		`FUNC_SUB: begin
			C = SubOut;
			OverflowFlag = SubFlag;
		end

		`FUNC_ID: begin
			C = IdOut;
		end

		`FUNC_NOT: begin
			C = NotOut;
		end

		`FUNC_AND: begin
			C = AndOut;
		end

		`FUNC_OR: begin
			C = OrOut;
		end

		`FUNC_NAND: begin
			C = NandOut;
		end

		`FUNC_NOR: begin
			C = NorOut;
		end

		`FUNC_XOR: begin
			C = XorOut;
		end

		`FUNC_XNOR: begin
			C = XnorOut;
		end

		`FUNC_LLS: begin
			C = LlsOut;
		end

		`FUNC_LRS: begin
			C = LrsOut;
		end

		`FUNC_ALS: begin
			C = AlsOut;
		end

		`FUNC_ARS: begin
			C = ArsOut;
		end

		`FUNC_TCP: begin
			C = TcpOut;
		end

		`FUNC_ZERO: begin
			C = ZeroOut;
		end
	endcase
end

endmodule

