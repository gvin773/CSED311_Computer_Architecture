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
  wire pc_enable;
  wire [31:0] next_pc;
  wire [31:0] current_pc;

  //for memory
  wire [31:0] Address;
  wire [31:0] MemData;

  //for RegisterFile
  wire [31:0] WriteData;
  wire [31:0] A_new;
  wire [31:0] B_new;

  //for ImmediateGenerator
  wire [31:0] imm_gen_out;

  //for ALUControlUnit
  wire [3:0] part_of_inst_alu_control;
  wire [3:0] alu_op;

  //for ALU
  wire [31:0] alu_in_1;
  wire [31:0] alu_in_2;
  wire [31:0] alu_result;
  wire alu_bcond;

  //for control unit
  wire PCWriteCond;
  wire PCWrite;
  wire IorD;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire IRWrite;
  wire PCSource;
  wire [6:0] ALUOp;
  wire [1:0] ALUSrcB;
  wire ALUSrcA;
  wire RegWrite;
  wire is_ecall;

  //for halting
  wire [4:0] rs1;
  reg halt;

  /***** Register declarations *****/
  wire [31:0] IR; // instruction register
  wire [31:0] MDR; // memory data register
  wire [31:0] A; // Read 1 data register
  wire [31:0] B; // Read 2 data register
  wire [31:0] ALUOut; // ALU output register
  // Do not modify and use registers declared above.

  MUX2 ALUResult_and_aluout(
    .mux_in_1(alu_result),
    .mux_in_2(ALUOut),
    .select_in(PCSource),
    .mux_result(next_pc)
  );

  assign pc_enable = (PCWriteCond & alu_bcond) | PCWrite;
  // ---------- Update program counter ----------
  // PC must be updated on the rising edge (positive edge) of the clock.
  PC pc(
    .reset(reset),       // input (Use reset to initialize PC. Initial value must be 0)
    .clk(clk),         // input
    .pc_enable(pc_enable),     // input - gyubin
    .next_pc(next_pc),     // input
    .current_pc(current_pc)   // output
  );

  MUX2 pc_and_aluout(
    .mux_in_1(current_pc),
    .mux_in_2(ALUOut),
    .select_in(IorD),
    .mux_result(Address)
  );

  MUX2 aluout_and_MDR(
    .mux_in_1(ALUOut),
    .mux_in_2(MDR),
    .select_in(MemtoReg),
    .mux_result(WriteData)
  );

  assign rs1 = (is_ecall) ? 17 : IR[19:15];
  // ---------- Register File ----------
  RegisterFile reg_file(
    .reset(reset),        // input
    .clk(clk),          // input
    .rs1(rs1),          // input
    .rs2(IR[24:20]),          // input
    .rd(IR[11:7]),           // input
    .rd_din(WriteData),       // input
    .write_enable(RegWrite),    // input
    .rs1_dout(A_new),     // output
    .rs2_dout(B_new)      // output
  );

  //reg A, B - gyubin
  UpdateRegistersAB update_A_and_B(
    .reset(reset),
    .clk(clk),
    .A_new(A_new),
    .B_new(B_new),
    .A(A),
    .B(B)
  );

  //ecall_halt_or_nop - gyubin
  always @(*) begin
    if(is_ecall && A_new == 10) halt = 1;
    else halt = 0;
  end
  assign is_halted = halt;

  // ---------- Memory ----------
  Memory memory(
    .reset(reset),        // input
    .clk(clk),          // input
    .addr(Address),         // input
    .din(B),          // input
    .mem_read(MemRead),     // input
    .mem_write(MemWrite),    // input
    .dout(MemData)          // output
  );

  //inst reg - gyubin
  InstructionRegister inst_reg(
    .reset(reset),
    .clk(clk),
    .IRWrite(IRWrite),
    .mem_data(MemData),
    .IR(IR)
  );

  //mem reg - gyubin
  MemoryDataRegister mem_reg(
    .reset(reset),
    .clk(clk),
    .mem_data(MemData),
    .MDR(MDR)
  );

  // ---------- Control Unit ----------
  ControlUnit ctrl_unit(
    .reset(reset),
    .clk(clk),
    .part_of_inst(IR[6:0]),
    .PCWriteCond(PCWriteCond),
    .PCWrite(PCWrite),
    .IorD(IorD),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .MemtoReg(MemtoReg),
    .IRWrite(IRWrite),
    .PCSource(PCSource),
    .ALUOp(ALUOp),
    .ALUSrcB(ALUSrcB),
    .ALUSrcA(ALUSrcA),
    .RegWrite(RegWrite),
    .is_ecall(is_ecall)
  );

  // ---------- Immediate Generator ----------
  ImmediateGenerator imm_gen(
    .part_of_inst(IR),  // input
    .imm_gen_out(imm_gen_out)    // output
  );

  assign part_of_inst_alu_control[3] = IR[30];
  assign part_of_inst_alu_control[2:0] = IR[14:12];
  // ---------- ALU Control Unit ----------
  ALUControlUnit alu_ctrl_unit(
    .part_of_inst(part_of_inst_alu_control),  // input
    .Opcode(ALUOp),        // input - gyubin
    .alu_op(alu_op)         // output
  );

  MUX2 pc_and_A(
    .mux_in_1(current_pc),
    .mux_in_2(A),
    .select_in(ALUSrcA),
    .mux_result(alu_in_1)
  );

  MUX4 B_and_4_and_ImmOut(
    .mux_in_1(B),
    .mux_in_2(4),
    .mux_in_3(imm_gen_out),
    .mux_in_4(0),
    .select_in(ALUSrcB),
    .mux_result(alu_in_2)
  );

  // ---------- ALU ----------
  ALU alu(
    .alu_op(alu_op),      // input
    .alu_in_1(alu_in_1),    // input  
    .alu_in_2(alu_in_2),    // input
    .alu_result(alu_result),  // output
    .alu_bcond(alu_bcond)     // output
  );

  UpdateALUOut update_aluout(
    .reset(reset),
    .clk(clk),
    .alu_result(alu_result),
    .ALUOut(ALUOut)
  );

endmodule
