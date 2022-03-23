//Control -hyunjun

`include "opcodes.v"

module control_unit (
    part_of_inst, is_jal, is_jalr, branch, mem_read,
    mem_to_reg, mem_write, alu_src, write_enable, pc_to_reg, is_ecall);

    input wire[6:0] part_of_inst;

    output reg is_jal;
    output reg is_jalr;
    output reg branch;
    output reg mem_read;
    output reg mem_to_reg;
    output reg mem_write;
    output reg alu_src;
    output reg write_enable;
    output reg pc_to_reg;
    output reg is_ecall;

    initial begin
        part_of_inst<=0;
        is_jal<=0;
        is_jalr<=0;
        branch<=0;
        mem_read<=0;
        mem_to_reg<=0;
        mem_write<=0;
        alu_src<=0;
        write_enable<=0;
        pc_to_reg<=0;
        is_ecall<=0;
    end

    always @(*) begin
        if(part_of_inst==`JAL) begin  //is_jal
            part_of_inst=0;
            is_jal=1;
            is_jalr=0;
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            mem_write=0;
            alu_src=0;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=0;       
        end 

        else if(part_of_inst==`JALR) begin  //is_jalr
            part_of_inst=0;
            is_jal=0;
            is_jalr=1;
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            mem_write=0;
            alu_src=0;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=0;       
        end 

        else if(part_of_inst==`BRANCH) begin  //branch
            part_of_inst=0;
            is_jal=0;
            is_jalr=0;
            branch=1;
            mem_read=0;
            mem_to_reg=0;
            mem_write=0;
            alu_src=0;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=0;       
        end 

        if((part_of_inst!=`STORE)&&(part_of_inst!=`BRANCH)) begin  //RegWrite
            is_jal=0;
            is_jalr=0;
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            mem_write=0;
            alu_src=0;
            write_enable=1;
            pc_to_reg=0;
            is_ecall=0;
        end

        else if ((part_of_inst!=`ARITHMETIC) && (part_of_inst!=`STORE)&&(part_of_inst!=`BRANCH)) begin  //ALLSrc
            part_of_inst=0;
            is_jal=0;
            is_jalr=0;
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            mem_write=0;
            alu_src=1;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=0;
        end

        else if (part_of_inst==`LOAD) begin  //MemRead
            is_jal=0;
            is_jalr=0;
            branch=0;
            mem_read=1;
            mem_to_reg=0;
            mem_write=0;
            alu_src=0;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=0;     
        end

        else if (part_of_inst==`STORE) begin  //MemWrite
            part_of_inst=0;
            is_jal=0;
            is_jalr=0;
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            mem_write=1;
            alu_src=0;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=0;               
        end

        else if (part_of_inst==`LOAD) begin  //MemtoReg
            part_of_inst=0;
            is_jal=0;
            is_jalr=0;
            branch=0;
            mem_read=0;
            mem_to_reg=1;
            mem_write=0;
            alu_src=0;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=0;            
        end 

        else if ((part_of_inst==`JAL) || (part_of_inst==`JALR)) begin  //PCtoReg
            part_of_inst=0;
            is_jal=0;
            is_jalr=0;
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            mem_write=0;
            alu_src=0;
            write_enable=0;
            pc_to_reg=1;
            is_ecall=0;   
        end
	else if (part_of_inst==`ECALL) begin  //isecall
            part_of_inst=0;
            is_jal=0;
            is_jalr=0;
            branch=0;
            mem_read=0;
            mem_to_reg=0;
            mem_write=0;
            alu_src=0;
            write_enable=0;
            pc_to_reg=0;
            is_ecall=1;   
        end
    end
endmodule
    