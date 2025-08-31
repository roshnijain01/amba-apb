module tb_apb_master();
localparam WDATA = 16;
localparam WADDR = 16;
apb_master#(
    .WDATA(WDATA),
    .WADDR(WADDR)
)apb_master1(
    .i_PCLK(i_clk),
    .i_PRESETn(i_rstn),    //Active low reset
    .i_TRANSACTION(i_transaction), //If 1, indicates initialization of a transaction
    .i_PREADY(i_pready), //Input READY signal coming from the slave to indicate completion of a transaction
    .i_PRDATA(i_slv_rd_data),   //Read data coming from the slave during READ transaction

    //Following set of inputs are to be given from testbench for checking the functionality of thid design
    .i_SLV_ADDR(i_slv_addr), //Address of slave to be selected
    .i_RW(i_rw), //Input signal to specify whether to do a read/write transaction, 0 for READ and 1 for WRITE transaction
    .i_SLV_WDATA(i_slv_wr_data), //PWDATA which is to be written into slave by te master during WRITE transaction 

    .o_PSELx(o_psel),
    .o_PENABLE(o_penb),
    .o_PWRITE(o_pwr),
    .o_PWDATA(o_pwdata),
    .o_PADDR(o_paddr),

    .o_SLV_RDATA(o_data)    //Data received by master from the slave in READ Transaction
);

reg i_clk = 0;
reg i_rstn = 1;
reg i_transaction = 0;
reg i_pready = 0;
reg [WDATA-1:0] i_slv_rd_data = 0;
reg [WADDR-1:0] i_slv_addr = 0;
reg i_rw = 0;
reg [WDATA-1:0] i_slv_wr_data = 0;
wire o_psel;
wire o_penb;
wire o_pwr;
wire [WDATA-1:0] o_pwdata;
wire [WADDR-1:0] o_paddr;
wire [WDATA-1:0] o_data;

always #5 i_clk <= ~i_clk;

initial begin
    $dumpfile("apbmaster.vcd");
    $dumpvars;
    //1st
    i_rstn <= 0;
    #10 i_rstn <= 1;
    i_transaction <= 1;
    i_slv_addr <= 16'h a1a2; //Slave address
    i_rw <= 1;  //write transaction
    i_slv_wr_data <= 16'h1312;//WRITE DATA

    #20 i_pready <= 1;
    #10 i_transaction <= 0;
    #10 i_transaction <= 1;
    #50 i_rw <= 0;
    i_slv_addr <= 16'h a1a2;
    i_slv_rd_data <= o_pwdata;
    #10 i_pready <= 1;
    #60 i_transaction <= 0;
    #10 i_pready <= 0;

    //2nd
     i_rstn <= 0;
    #10 i_rstn <= 1;
    i_transaction <= 1;
    i_slv_addr <= 16'h10a5; //Slave address
    i_rw <= 1;  //write transaction
    i_slv_wr_data <= 16'h654e;//WRITE DATA

    #20 i_pready <= 1;
    #10 i_transaction <= 0;
    #10 i_transaction <= 1;
    #50 i_rw <= 0;
    i_slv_addr <= 16'h10a5;
    i_slv_rd_data <= o_pwdata;
    #10 i_pready <= 1;
    #60 i_transaction <= 0;
    #10 i_pready <= 0;

end

endmodule