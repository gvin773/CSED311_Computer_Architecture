// Submit this file with other files you created.
// Do not touch port declarations of the module 'CPU'.

// Guidelines
// 1. It is highly recommened to `define opcodes and something useful.
// 2. You can modify the module.
// (e.g., port declarations, remove modules, define new modules, ...)
// 3. You might need to describe combinational logics to drive them into the module (e.g., mux, and, or, ...)
// 4. `include files if required

module CPU(input reset,       // positive reset signal
           input clk,         // clock signal
           output is_halted); // Whehther to finish simulation
  /***** Wire declarations *****/
  //for pc
  wire [31:0] next_pc;
  wire [31:0] current_pc;

  wire [31:0] pc_add4;

  //for InstMemory
  wire [31:0] Instr;

  //for ALU
  wire [31:0] alu_result;
  wire alu_bcond;
  wire [31:0] alu_input2;

  //for ControlUnit
  wire is_jal;
  wire is_jalr;
  wire branch;
  wire mem_read;
  wire mem_to_reg;
  wire mem_write;
  wire alu_src;
  wire write_enable;
  wire pc_to_reg;
  wire is_ecall;

  //for RegisterFile
  wire [31:0] rs1_dout;
  wire [31:0] rs2_dout;
  wire [31:0] register_write_data;

  //for ALUControlUnit
  wire [10:0] part_of_inst_alu_control;
  wire [3:0] alu_op;

  //for ImmediateGenerator
  wire [31:0] imm_gen_out;

  //for DataMemory
  wire [31:0] data_memory_out;

  /***** Register declarations *****/

  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  adder add4(
    .in_address(current_pc),
    .k(4),
    .out_address(pc_add4);
  );

  assign next_pc <= pc_add4;
  
  // ---------- Instruction Memory ----------
  InstMemory imem(
    .reset(reset),   // input
    .clk(clk),     // input
    .addr(current_pc),    // input
    .dout(Instr)     // output
  );

  MUX mux_alu_result_and_data_out (
    .mux_in_1(alu_result),
    .mux_in_2(data_memory_out),
    .select_in(mem_to_reg),
    .mux_result(register_write_data)
  );

  // ---------- Register File ----------
  RegisterFile reg_file (
    .reset (reset),        // input
    .clk (clk),          // input
    .rs1 (Instr[19:15]),          // input
    .rs2 (Instr[24:20]),          // input
    .rd (Instr[11:7]),           // input
    .rd_din (register_write_data),       // input
    .write_enable (write_enable),    // input
    .rs1_dout (rs1_dout),     // output
    .rs2_dout (rs2_dout)      // output
  );


  // ---------- Control Unit ----------
  ControlUnit ctrl_unit (
    .part_of_inst(Instr[6:0]),  // input
    .is_jal(is_jal),        // output
    .is_jalr(is_jalr),       // output
    .branch(branch),        // output
    .mem_read(mem_read),      // output
    .mem_to_reg(mem_to_reg),    // output
    .mem_write(mem_write),     // output
    .alu_src(alu_src),       // output
    .write_enable(write_enable),     // output
    .pc_to_reg(pc_to_reg),     // output
    .is_ecall(is_ecall)       // output (ecall inst)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(Instr),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  assign part_of_inst_alu_control[10] <= Instr[30]; //funct7
  assign part_of_inst_alu_control[9:7] <= Instr[14:12]; //funct3
  assign part_of_inst_alu_control[6:0] <= Instr[6:0]; //opcode

  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit (
    .part_of_inst(part_of_inst_alu_control),  // input
    .alu_op(alu_op)         // output
  );

  MUX mux_rs2_dout_and_imm (
    .mux_in_1(rs2_dout),
    .mux_in_2(imm_gen_out),
    .select_in(alu_src),
    .mux_result(alu_input2)
  );

  // ---------- ALU ----------
  ALU alu (
    .alu_op(alu_op),      // input
    .alu_in_1(rs1_dout),    // input  
    .alu_in_2(alu_input2),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output
  );

  // ---------- Data Memory ----------
  DataMemory dmem(
    .reset (reset),      // input
    .clk (clk),        // input
    .addr (alu_result),       // input
    .din (rs2_dout),        // input
    .mem_read (mem_read),   // input
    .mem_write (mem_write),  // input
    .dout (data_memory_out)        // output
  );
endmodule
