`timescale 1ns / 1ps
// CPU Design -- Dylan Burkholder


module testbench ();
    reg clk_tb;
 
    wire ewreg_tb;
    wire em2reg_tb;
    wire ewmem_tb;
    wire ealuimm_tb;
    wire [3:0] ealuc_tb;
    wire [4:0] edestReg_tb;
    wire [31:0] eqa_tb;
    wire [31:0] eqb_tb;
    wire [31:0] eimm32_tb;
    wire [31:0] dinstOut_tb;
    wire [31:0] pc_tb;
    wire mwreg_tb;
    wire mm2reg_tb;
    wire mwmem_tb;
    wire wwreg_tb;
    wire wm2reg_tb;
    wire [4:0] mdestReg_tb;
    wire [4:0] wdestReg_tb;
    wire [31:0] mr_tb;
    wire [31:0] mqb_tb;
    wire [31:0] wr_tb;
    wire [31:0] wdo_tb;
    initial begin
        clk_tb = 1'b0;
    end
    
    
    datapath datapath(
        .clk(clk_tb),
        .ewreg(ewreg_tb),
        .em2reg(em2reg_tb),
        .ewmem(ewmem_tb),
        .ealuimm(ealuimm_tb),
        .ealuc(ealuc_tb),
        .edestReg(edestReg_tb),
        .eqa(eqa_tb),
        .eqb(eqb_tb),
        .eimm32(eimm32_tb),
        .dinstOut(dinstOut_tb),
        .pc(pc_tb),
        .mwreg(mwreg_tb),
        .mm2reg(mm2reg_tb),
        .mwmem(mwmem_tb),
        .wwreg(wwreg_tb),
        .wm2reg(wm2reg_tb),
        .mdestReg(mdestReg_tb),
        .wdestReg(wdestReg_tb),
        .mr(mr_tb),
        .mqb(mqb_tb),
        .wr(wr_tb),
        .wdo(wdo_tb)
        );

    always begin
        #10;
        clk_tb = ~clk_tb;
    end
endmodule

    
    
