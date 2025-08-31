module tb_apb_slave();
localparam WDATA = 8;
localparam WADDR = 8;

reg i_clk;
reg i_rstn;
reg i_psel;
reg i_penable;
reg i_rw;
reg [WADDR-1 : 0] i_paddr;
reg [WDATA-1 : 0] i_pwdata;
wire o_pready;
wire o_pslverr;
wire [WDATA-1 : 0] o_prdata;

apb_slave#(
    .WDATA(WDATA),
    .WADDR(WADDR)
)apb_slave1(
    .i_PCLK(i_clk),
    .i_PRESETn(i_rstn),    //Active low reset
    .i_PSELx(i_psel),
    .i_PENABLE(i_penable),
    .i_PWRITE(i_rw), //If 1, indicates a WRITE transaction, else READ transaction
    .i_PADDR(i_paddr),
    .i_PWDATA(i_pwdata), //Data coming from APB master during it's WRITE Transaction

    .o_PREADY(o_pready),
    .o_PSLVERR(o_pslverr),
    .o_PRDATA(o_prdata)   //Data which is being read by APB master from APB slave during Master's READ Transaction
);

always#5 i_clk <= ~i_clk;

initial begin
    $dumpfile("apbslave.vcd");
    $dumpvars;
    i_clk <= 0;
    i_rstn <= 0;
    #20 i_rstn <= 1;
    i_psel <= 0;
    i_penable <= 0;
    i_rw <= 0;
    i_paddr <= 0;
    i_pwdata <= 0;

    //1st write transaction
    #30 i_psel <= 1;
    i_rw <= 1;
    #10 i_penable <= 1;
    i_paddr <= 8'h04;   //input address from APB master
    i_pwdata <= 8'hbb;  //input write data from APB master
    #50 i_penable <= 0; //end of write transaction

    //2nd write transaction
    #50 i_penable <= 1;
    i_paddr <= 8'h05;
    i_pwdata <= 8'hcc;
    #60 i_penable <= 0;

    //3rd write transaction
    #50 i_penable <= 1;
    i_paddr <= 8'h06;
    i_pwdata <= 8'hdd;
    #60 i_penable <= 0;

    //1st read transaction
    #20 i_penable <= 1;
    i_paddr <= 8'h04; //read from address 4
    i_rw <= 0;

    #70 i_paddr <= 8'h05;   //read from address 5
    #50 i_paddr <= 8'h06;   //read from address 6

    
end

endmodule