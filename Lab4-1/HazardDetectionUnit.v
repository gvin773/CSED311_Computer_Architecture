`include "opcodes.v"

module HazardDetectionUnit #(parameter data_width = 5) (
    input [31:0] Instruction,
    input [data_width - 1 : 0] EX_rd,
    input [data_width - 1 : 0] MEM_rd,
    input [data_width - 1 : 0] WB_rd,
    input EX_reg_write,
    input MEM_reg_write,
    input WB_reg_write,
        output stall);
    
    wire [4:0] ID_rs1;
	wire [4:0] ID_rs2;
    wire [6:0] op;
    wire use_rs1;
    wire use_rs2;
    wire u1, u2, u3, u4;
    wire t1, t2, t3, t4, t5, t6;

    assign ID_rs1 = Instruction[19:15];
    assign ID_rs2 = Instruction[24:20];
    assign op = Instruction[6:0];

    //R: rs1, rs2   R_IMM: rs1      Load: rs1     Store: rs1, rs2
    assign u1 = (op == `ARITHMETIC) || (op == `ARITHMETIC_IMM) || (op == `LOAD) || (op == `STORE);
    assign u2 = (ID_rs1 != 5'b00000);
    assign u3 = (op == `ARITHMETIC) || (op == `STORE);
    assign u4 = (ID_rs2 != 5'b00000);
    assign use_rs1 = u1 && u2;
    assign use_rs2 = u3 && u4;

    assign t1 = (ID_rs1 == EX_rd) && use_rs1 && EX_reg_write;
    assign t2 = ((ID_rs1 == MEM_rd) && use_rs1 && MEM_reg_write);
    assign t3 = ((ID_rs1 == WB_rd) && use_rs1 && WB_reg_write);

    assign t4 = ((ID_rs2 == EX_rd) && use_rs2 && EX_reg_write);
    assign t5 = ((ID_rs2 == MEM_rd) && use_rs2 && MEM_reg_write);
    assign t6 = ((ID_rs2 == WB_rd) && use_rs2 && WB_reg_write);

    assign stall = t1 || t2 || t3 || t4 || t5 || t6;

endmodule
