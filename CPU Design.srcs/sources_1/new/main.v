`timescale 1ns / 1ps
// CPU Design -- Dylan Burkholder



module main();    
endmodule

module datapath (input clk,

    output wire ewreg,
    output wire em2reg,
    output wire ewmem,
    output wire ealuimm,
    output wire [3:0] ealuc,
    output wire [4:0] edestReg,
    output wire [31:0] eqa,
    output wire [31:0] eqb,
    output wire [31:0] eimm32,
    output wire [31:0] dinstOut,
    output wire [31:0] pc,
    output wire mwreg,
    output wire mm2reg,
    output wire mwmem,
    output wire wwreg,
    output wire wm2reg,
    output wire [4:0] mdestReg,
    output wire [4:0] wdestReg,
    output wire [31:0] mr,
    output wire [31:0] mqb,
    output wire [31:0] wr,
    output wire [31:0] wdo, qa, qb,
    output wire [1:0] fwdB, fwdA,
    output wire [31:0] outfwda, outfwdb,
    output wire mrm, ern
);

wire  wreg;
wire  m2reg;
wire  wmem;
wire  aluimm;
wire  regrt;
wire  [3:0] aluc;
wire  [4:0] destReg;
wire  [31:0] imm32;
wire  [31:0] instOut;
wire  [31:0] nextPC;
wire [31:0] b;
wire [31:0] r;
wire [31:0] mdo;
wire [31:0] wbData;

controlUnit controlUnit(
    .op(dinstOut[31:26]),
    .func(dinstOut[5:0]),
    .rt(dinstOut[4:0]),
    .rs(dinstOut[4:0]),
    .mrm(mrm),
    .mm2reg(mm2reg),
    .mwreg(mwreg),
    .ern(ern),
    .em2reg(em2reg),
    .ewreg(ewreg),
    .wreg(wreg),
    .m2reg(m2reg),
    .wmem(wmem),
    .aluimm(aluimm),
    .regrt(regrt),
    .fwdA(fwdA),
    .fwdB(fwdB),
    .aluc(aluc) 
);

idexePipelineReg idexePipelineReg(
    .clk(clk),
    .wreg(wreg),
    .m2reg(m2reg),
    .wmem(wmem),
    .aluimm(aluimm),
    .aluc(aluc),
    .destReg(destReg),
    .qa(qa),
    .qb(qb),
    .imm32(imm32),

    .ewreg(ewreg),
    .em2reg(em2reg),
    .ewmem(ewmem),
    .ealuimm(ealuimm),
    .ealuc(ealuc),
    .edestReg(edestReg),
    .eqa(eqa),
    .eqb(eqb),
    .eimm32(eimm32)
);

ifidPipelineReg ifidPipelineReg(
    .clk(clk),
    .instOut(instOut),

    .dinstOut(dinstOut)
);

immExtender immExtender(
    .imm(dinstOut[15:0]),

    .imm32(imm32)
);

instructionMemory instructionMemory(
    .pc(pc),

    .instOut(instOut)
);

pcAdder pcAdder(
    .pc(pc),

    .nextPC(nextPC)
);

programCounter programCounter(
    .clk(clk),
    .nextPC(nextPC),

    .pc(pc)
);

regFile regFile(
    .rs(dinstOut[25:21]),
    .rt(dinstOut[20:16]),
    .wdestReg(wdestReg),
    .wbData(wbData),
    .wwreg(wwreg),
    .clk(clk),

    .qa(qa),
    .qb(qb)
);

regrtMultiplexer regrtMultiplexer(
    .regrt(regrt),
    .rt(dinstOut[20:16]),
    .rd(dinstOut[15:11]),

    .destReg(destReg)
);

aluMux aluMux(
    .eqb(eqb),
    .eimm32(eimm32),
    .ealuimm(ealuimm),
   
    .b(b)    
);


alu  alu(
    .eqa(outfwda),
    .b(outfwdb),
    .ealuc(ealuc),
   
    .r(r)
);  


exememPipelineReg exememPipelineReg(
    .ewreg(ewreg),
    .em2reg(em2reg),
    .ewmem(ewmem),
    .edestReg(edestReg),
    .r(r),
    .eqb(eqb),
    .clk(clk),

    .mwreg(mwreg),
    .mm2reg(mm2reg),
    .mwmem(mwmem),
    .mdestReg(mdestReg),
    .mr(mr),
    .mqb(mqb)
);

memwbPipelineRegister memwbPipelineRegister(
    .mwreg(mwreg),
    .mm2reg(mm2reg),
    .mdestReg(mdestReg),
    .mr(mr),
    .mdo(mdo),
    .clk(clk),

    .wwreg(wwreg),
    .wm2reg(wm2reg),
    .wdestReg(wdestReg),
    .wr(wr),
    .wdo(wdo)
);


dataMemory dataMemory(
    .mr(mr),
    .mqb(mqb),
    .mwmem(mwmem),
    .clk(clk),
    .mdo(mdo)

);

wbMux wbMux(
    .wr(wr),
    .wdo(wdo),
    .wm2reg(wm2reg),
    .wbData(wbData)
);
fwda fwda(
    .fwdA(fwdA),//input size 2 bits (4 cases: 0,1,2,3)
    .qa(qa),//0
    .r(r),//1 (alu output)
    .mr(mr),//2 (datamem input)
    .mdo(mdo),//3 (dataMem output)

    .outfwda(outfwda)
);

fwdb fwdb(
    .fwdB(fwdB),//input size 2 bits (4 cases: 0,1,2,3)
    .qb(qb),//0
    .r(r),//1 (alu output)
    .mr(mr),//2 (datamem input)
    .mdo(mdo),//3 (dataMem output)
    .outfwdb(outfwdb)
);
endmodule



module programCounter(input [31:0] nextPC, input clk, output reg[31:0] pc);
    initial begin
        pc = 32'h00000064;
    end
    always @(posedge clk) begin
        pc <= nextPC;     
    end        
endmodule



module pcAdder(input [31:0] pc, output reg[31:0] nextPC);
    always @(*) begin
        nextPC = pc + 32'h00000004;
        #1;
    end
endmodule

module ifidPipelineReg(input [31:0] instOut, input clk, output reg[31:0] dinstOut);
    always @(posedge clk) begin
        dinstOut = instOut;
    end    
endmodule

module controlUnit(
input [5:0] op, 
input [5:0] func,
input [4:0] rt,
input [4:0] rs,
input mrm,
input mm2reg,
input mwreg,
input ern,
input em2reg,
input ewreg,
output reg m2reg,
output reg wmem,
output reg aluimm,
output reg regrt,
output reg edestReg,
output reg wreg,
output reg destreg,
output reg fwdA,
output reg fwdB,
output reg [3:0] aluc
);
always @(op or func) begin
        case(op)
            6'b000000: begin // r-type
                case(func)
                    6'b100000: begin//ADD 
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        aluc = 4'b0010;
                    end
                    6'b100010: begin //SUB 
                        wreg = 1'b1;
                        m2reg = 1'b0;
                        wmem = 1'b0;
                        aluimm = 1'b0;
                        regrt = 1'b0;
                        aluc = 4'b0110;
                    end
                endcase
            end
            6'b100011: begin// LW
                wreg = 1'b1;
                m2reg = 1'b1;
                wmem = 1'b0;
                aluimm = 1'b1;
                regrt = 1'b1;
                aluc = 4'b0010;
            end
        endcase
        if (edestReg == rt && wreg == 1'b1 && destreg != 1'b0) begin
            fwdB = 2'b01;
        end
        else if (edestReg == rs && wreg == 1'b1 && destreg != 1'b0) begin
            fwdA = 2'b01;
        end
        else if (edestReg  == rt && m2reg ==1'b1 && destreg != 1'b0) begin
            fwdB = 2'b10;
        end
        else if(edestReg == rs && m2reg == 1'b1 && destreg != 1'b0) begin
            fwdA = 2'b10;
        end
        else begin
            fwdA = 2'b00;
            fwdB = 2'b00;
        end

    end
endmodule


module regrtMultiplexer(input [4:0] rt, input[4:0] rd, input regrt, output reg [4:0] destReg);
     always @(regrt or rt or rd) begin
        if (regrt == 1'b0) begin
            destReg = rd;
        end
        else begin
            destReg = rt;
        end
    end
endmodule


module regFile(
    input [4:0] rs,
    input [4:0] rt,
    input [4:0] wdestReg,
    input [31:0] wbData,
    input wwreg,
    input clk,
    output reg [31:0] qa,
    output reg [31:0] qb);
    reg [31:0] registers [0:31];
    integer i;

    initial
        begin
        for(i = 0; i < 32; i = i + 1)
        begin
            registers[i] = 0;
        end
    end
    always @(rs or rt)
        begin
            qa = registers[rs];
            qb = registers[rt];
        end
    always @ (negedge clk) begin
        if (wwreg == 1'b1) begin
            registers[wdestReg] = wbData;
        end
    end
endmodule



module immExtender(input [15:0] imm, output reg [31:0] imm32);
    always @(imm) begin
        imm32 = {{16{imm[15]}}, imm[15:0]};    
    end    
endmodule

module idexePipelineReg(clk, wreg, m2reg, wmem, aluimm, aluc, destReg, qa, qb, imm32, ewreg, em2reg, ewmem, ealuimm, ealuc, edestReg, eqa, eqb, eimm32);
    input clk, wreg, m2reg, wmem, aluimm;
    input [3:0] aluc;
    input [4:0] destReg;
    input [31:0] qa, qb, imm32;
    output reg ewreg, em2reg, ewmem, ealuimm;
    output reg [3:0] ealuc;
    output reg [4:0] edestReg;
    output reg [31:0] eqa, eqb, eimm32;
    always @(posedge clk) begin
        ewreg = wreg;
        em2reg = m2reg;
        ewmem = wmem;
        ealuimm = aluimm;
        ealuc = aluc;
        edestReg = destReg;
        eqa = qa;
        eqb = qb;
        eimm32 = imm32;
    end
endmodule

module alu (input [31:0] eqa, input [31:0] b, input [3:0] ealuc, output reg [31:0] r);
    always @ (eqa or b or ealuc)
        begin
            case (ealuc)
                4'b0000://and
                begin
                    r = eqa & b;
                end
                4'b0001://or
                begin
                    r = eqa || b;
                end
                4'b0010://add
                begin
                    r = eqa + b;
                end
                4'b0110://sub
                begin
                    r = eqa - b;
                end                
            endcase
        end
endmodule







module memwbPipelineRegister(
    input mwreg,
    input mm2reg,
    input [4:0] mdestReg,
    input [31:0] mr,
    input [31:0] mdo,
    input clk,
    output reg wwreg,
    output reg wm2reg,
    output reg [4:0] wdestReg,
    output reg [31:0] wr,
    output reg [31:0] wdo);
    
    always @(posedge clk) 
        begin
            wwreg = mwreg;
            wm2reg = mm2reg;
            wdestReg = mdestReg;
            wr = mr;
            wdo = mdo;
        end
endmodule
    
module aluMux (input [31:0] eqb, input [31:0] eimm32, input ealuimm, output reg [31:0] b);
    always @ (eqb or eimm32 or ealuimm)
        begin
          if (ealuimm == 1'b0) begin
            b = eqb;
          end
          
          else begin
            b = eimm32;
          end 
    end
endmodule



module exememPipelineReg(
    input ewreg,
    input em2reg,
    input ewmem, 
    input [4:0] edestReg,
    input [31:0] r,
    input [31:0] eqb,
    input clk,
    output reg mwreg, 
    output reg mm2reg, 
    output reg mwmem,
    output reg [4:0] mdestReg,
    output reg [31:0] mr,
    output reg [31:0] mqb);
    
    always @(posedge clk) 
        begin
            mwreg = ewreg;
            mm2reg = em2reg;
            mwmem = ewmem;
            mdestReg = edestReg;
            mr = r;
            mqb = eqb;
        end
endmodule





module dataMemory(input [31:0] mr, input [31:0] mqb, input mwmem, input clk, output reg [31:0] mdo);
    reg [31:0] memory [0:63];
    initial begin
        memory[0] = 32'hA00000AA;
        memory[1] = 32'h10000011;
        memory[2] = 32'h20000022;
        memory[3] = 32'h30000033;
        memory[4] = 32'h40000044;
        memory[5] = 32'h50000055;
        memory[6] = 32'h60000066;
        memory[7] = 32'h70000077;
        memory[8] = 32'h80000088;
        memory[9] = 32'h90000099;
    end
    always @ (mr or mqb or mwmem or clk)
        begin
            mdo = memory[mr[31:2]];
        end
   
    always @ (negedge clk)
        begin
            if (mwmem == 1'b1) begin
                memory[mr[31:2]] = mqb;
            end
        end
endmodule



module instructionMemory(input [31:0] pc, output reg [31:0] instOut);
    reg [31:0] memory [0:63];

initial
    begin
    memory[25] = {
        6'b100011,
        5'b00000,
        5'b00010,
        5'b00000,
        5'b00000,
        6'b000000
    };

    memory[26] = {
        6'b100011,
        5'b00000,
        5'b00011,
        5'b00000,
        5'b00000,
        6'b000100
    };
    memory[27] = {
        6'b100011,
        5'b00001,
        5'b00100,
        5'b00000,
        5'b00000,
        6'b001000
    };

    memory[28] = {
        6'b100011,
        5'b00001,
        5'b00101,
        5'b00000,
        5'b00000,
        6'b001100
    };
   
    memory[29] = {
        6'b000000,
        5'b00010,
        5'b01010,
        5'b00110,
        5'b00000,
        6'b100000
    };
end

always @(pc)
    begin
    instOut = memory[pc[7:2]];
    end
endmodule

module wbMux (input [31:0] wr, input [31:0] wdo, input wm2reg, output reg [31:0] wbData);
    always @ (wr or wdo or wm2reg)
        begin
            if (wm2reg == 1'b0) begin
            wbData = wr;
          end
         
          else begin
            wbData = wdo;
          end  
        end
endmodule

module fwda(
input fwdA,//input size 2 bits (4 cases: 0,1,2,3)
input qa,//0
input r,//1 (alu output)
input mr,//2 (datamem input)
input mdo,//3 (dataMem output)
output reg outfwda);
 
 always @(*) begin
 case (fwdA)
    2'b00: begin
    outfwda= qa;
    end

    2'b01: begin
    outfwda = r;
    end

    2'b10: begin
    outfwda = mr;
    end

    2'b11: begin
    outfwda = mdo;
    end
 endcase
 end
endmodule
    
module fwdb(
input fwdB,
input qb,
input r,
input mr,
input mdo,
output reg outfwdb);  

always @(*) begin
 case (fwdB)
    2'b00: begin
    outfwdb = qb;
    end

    2'b01: begin
    outfwdb = r;
    end

    2'b10: begin
    outfwdb = mr;
    end

    2'b11: begin
    outfwdb = mdo;
    end
 endcase
 end
endmodule

       


