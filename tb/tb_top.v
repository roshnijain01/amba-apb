module tb_top();

localparam WADDR = 8;
localparam WDATA = 8;

reg i_clk;
reg i_rstn;
reg i_start;
reg i_rw;
reg [WADDR-1 : 0] i_addr;
reg [WDATA-1 : 0] i_data;
wire [WDATA-1 : 0] o_data;

top#(
    .WDATA(WDATA),
    .WADDR(WADDR)
)dut(
    .i_PCLK(i_clk),
    .i_PRESETn(i_rstn), //Active low reset
    .i_TRANSACTION(i_start),    //To enable a transfer for APB Master
    
    //Input signals to be given from testbench for checking functionality of the design
    .i_SLV_ADDR(i_addr), //Address of slave to be selected
    .i_RW(i_rw), //Input signal to specify whether to do a read/write transaction, 0 for READ and 1 for WRITE transaction
    .i_SLV_WDATA(i_data), //PWDATA which is to be written into slave by te master during WRITE transaction 
    
    .o_PRDATA(o_data)
);

always #5 i_clk = ~ i_clk;

initial begin
    $dumpfile("tb.vcd");
    $dumpvars;
    i_clk <= 0;
    i_rstn <= 0;
    #20 i_rstn <= 1;
    i_start <= 1;
    
    //1st write transaction
    #10 i_rw <= 1;
    i_addr <= 8'haa;
    i_data <= 8'h18;

    //2nd write transaction
    #50 i_addr <= 8'hbb;
    i_data <= 8'h67;

    //1st read transaction
    #10 i_addr <= 8'haa;
    i_rw <= 0;

    //2nd read transaction
    #30 i_addr <= 8'hbb;
    i_rw <= 0;

    #90 i_rstn <= 0;
    i_start <= 0;
end

endmodule