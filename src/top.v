module top#(
    parameter WDATA = 8,
    parameter WADDR = 8
)(
    input i_PCLK,
    input i_PRESETn, //Active low reset
    input i_TRANSACTION,    //To enable a transfer for APB Master
    
    //Input signals to be given from testbench for checking functionality of the design
    input [WADDR-1 : 0] i_SLV_ADDR, //Address of slave to be selected
    input i_RW, //Input signal to specify whether to do a read/write transaction, 0 for READ and 1 for WRITE transaction
    input [WDATA-1 : 0] i_SLV_WDATA, //PWDATA which is to be written into slave by te master during WRITE transaction 

    output o_PSLVERR,
    output [WDATA-1 : 0] o_PRDATA
);

wire w_PREADY;
wire w_PSELx;
wire w_PENABLE;
wire w_PWRITE;
wire [WDATA-1 : 0] w_PRDATA;    //APB master reads this data from APB slave
wire [WADDR-1 : 0] w_PADDR;
wire [WDATA-1 : 0] w_PWDATA;    //APB master writes this data into APB slave


//APB Master Module
apb_master#(
    .WDATA(WDATA),
    .WADDR(WADDR)
)master1(
    .i_PCLK(i_PCLK),
    .i_PRESETn(i_PRESETn),    //Active low reset
    .i_TRANSACTION(i_TRANSACTION), //If 1, indicates initialization of a transaction
    .i_PREADY(w_PREADY), //Input READY signal coming from the slave to indicate completion of a transaction
    .i_PRDATA(w_PRDATA),   //Read data coming from the slave during READ transaction

    //Following set of inputs are to be given from testbench for checking the functionality of thid design
    .i_SLV_ADDR(i_SLV_ADDR), //Address of slave to be selected
    .i_RW(i_RW), //Input signal to specify whether to do a read/write transaction, 0 for READ and 1 for WRITE transaction
    .i_SLV_WDATA(i_SLV_WDATA), //PWDATA which is to be written into slave by te master during WRITE transaction 

    .o_PSELx(w_PSELx),
    .o_PENABLE(w_PENABLE),
    .o_PWRITE(w_PWRITE),
    .o_PWDATA(w_PWDATA),
    .o_PADDR(w_PADDR),

    .o_SLV_RDATA(o_PRDATA)    //Data received by master from the slave in READ Transaction
);

//APB Slave Module
apb_slave#(
    .WDATA(WDATA),
    .WADDR(WADDR)
)slave1(
    .i_PCLK(i_PCLK),
    .i_PRESETn(i_PRESETn),    //Active low reset
    .i_PSELx(w_PSELx),
    .i_PENABLE(w_PENABLE),
    .i_PWRITE(w_PWRITE), //If 1, indicates a WRITE transaction, else READ transaction
    .i_PADDR(w_PADDR),
    .i_PWDATA(w_PWDATA), //Data coming from APB master during it's WRITE Transaction

    .o_PREADY(w_PREADY),
    .o_PSLVERR(o_PSLVERR),
    .o_PRDATA(w_PRDATA)   //Data which is being read by APB master from APB slave during Master's READ Transaction
);

endmodule