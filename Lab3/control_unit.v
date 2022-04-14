//written - gyubin
`include "opcodes.v"

module ControlUnit (
    input reset,
    input clk,
    input [6:0] part_of_inst,
    output reg PCWriteCond,
    output reg PCWrite,
    output reg IorD,
    output reg MemRead,
    output reg MemWrite,
    output reg MemtoReg,
    output reg IRWrite,
    output reg PCSource,
    output reg [6:0] ALUOp,
    output reg [1:0] ALUSrcB,
    output reg ALUSrcA,
    output reg RegWrite,
    output reg is_ecall);

    reg [3:0] state;

    always @(posedge clk) begin
        if(reset) state <= `IF;

        case(state)
            `IF : begin
                PCWriteCond <= 0;
                if(part_of_inst == `JAL || part_of_inst == `JALR) PCWrite <= 0;
                else PCWrite <= 1;
                IorD <= 0;
                MemRead <= 1;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 1;
                PCSource <= 0;
                ALUOp <= `PLUS;
                ALUSrcB <= 2'b01;
                ALUSrcA <= 0;
                RegWrite <= 0;
                is_ecall <= 0;

                state <= `ID;
            end

            `ID : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= `PLUS;
                if(part_of_inst == `JAL || part_of_inst == `JALR) ALUSrcB <= 2'b01;
                else ALUSrcB <= 2'b10;
                ALUSrcA <= 0;
                RegWrite <= 0;
                is_ecall <= 0;

                case(part_of_inst)
                    `ARITHMETIC : state <= `EX_R;
                    `ARITHMETIC_IMM : state <= `EX_R;
                    `LOAD : state <= `EX_L;
                    `STORE : state <= `EX_S;
                    `BRANCH : state <= `EX_B;
                    `JAL : state <= `EX_JAL1;
                    `JALR : state <= `EX_JALR1;
                    `ECALL : state <= `ECALL_HALT;
                    default : state <= `NULL_STATE;
                endcase
            end

            `EX_R : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                if(part_of_inst == `ARITHMETIC) ALUSrcB <= 2'b00; //B
                else ALUSrcB <= 2'b10; //Imm
                ALUSrcA <= 1;
                RegWrite <= 0;
                is_ecall <= 0;

                state <= `MEM_R;
            end

            `EX_L : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 1;///////
                MemRead <= 1; ////////
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b10;
                ALUSrcA <= 1;
                RegWrite <= 0;
                is_ecall <= 0;

                state <= `MEM_L;
            end

            `EX_S : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b10;
                ALUSrcA <= 1;
                RegWrite <= 0;
                is_ecall <= 0;

                state <= `MEM_S;
            end

            `EX_B : begin
                PCWriteCond <= 1;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 1;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b00;
                ALUSrcA <= 1;
                RegWrite <= 0;
                is_ecall <= 0;

                state <= `IF;
            end

            `EX_JAL1 : begin
                PCWriteCond <= 0;
                PCWrite <= 1;//////
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 1;/////
                ALUOp <= `PLUS;
                ALUSrcB <= 2'b01;/////
                ALUSrcA <= 0;
                RegWrite <= 0;/////
                is_ecall <= 0;

                state <= `EX_JAL2;
            end

            `EX_JAL2 : begin
                PCWriteCond <= 0;
                PCWrite <= 0;/////
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 1;
                ALUOp <= `PLUS;
                ALUSrcB <= 2'b00;
                ALUSrcA <= 0;
                RegWrite <= 1;/////
                is_ecall <= 0;

                state <= `IF;
            end

            `EX_JALR1 : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= `PLUS;
                ALUSrcB <= 2'b01;/////
                ALUSrcA <= 0;/////
                RegWrite <= 0;/////
                is_ecall <= 0;

                state <= `EX_JALR2;
            end

            `EX_JALR2 : begin
                PCWriteCond <= 0;
                PCWrite <= 1;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;/////
                ALUOp <= `PLUS;
                ALUSrcB <= 2'b10;/////
                ALUSrcA <= 1;/////
                RegWrite <= 1;/////
                is_ecall <= 0;

                state <= `IF;
            end

            `MEM_R : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b00;
                ALUSrcA <= 0;
                RegWrite <= 1;
                is_ecall <= 0;

                state <= `IF;
            end

            `MEM_L : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 1;
                MemRead <= 1;
                MemWrite <= 0;
                MemtoReg <= 1;/////
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b00;
                ALUSrcA <= 0;
                RegWrite <= 1;////
                is_ecall <= 0;

                state <= `WB;
            end

            `MEM_S : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 1;
                MemRead <= 0;
                MemWrite <= 1;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b00;
                ALUSrcA <= 0;
                RegWrite <= 0;
                is_ecall <= 0;

                state <= `IF;
            end

            `WB : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 1;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b00;
                ALUSrcA <= 0;
                RegWrite <= 0;////
                is_ecall <= 0;

                state <= `IF;
            end

            `ECALL_HALT : begin
                PCWriteCond <= 0;
                PCWrite <= 0;
                IorD <= 0;
                MemRead <= 0;
                MemWrite <= 0;
                MemtoReg <= 0;
                IRWrite <= 0;
                PCSource <= 0;
                ALUOp <= part_of_inst;
                ALUSrcB <= 2'b00;
                ALUSrcA <= 0;
                RegWrite <= 0;
                is_ecall <= 1;

                state <= `IF;
            end
        endcase
    end
endmodule
