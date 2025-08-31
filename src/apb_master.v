module apb_master#(
    parameter WDATA = 8,
    parameter WADDR = 8
)(
    input i_PCLK,
    input i_PRESETn,    //Active low reset
    input i_TRANSACTION, //If 1, indicates initialization of a transaction
    input i_PREADY, //Input READY signal coming from the slave to indicate completion of a transaction
    input [WDATA-1 : 0] i_PRDATA,   //Read data coming from the slave during READ transaction

    //Following set of inputs are to be given from testbench for checking the functionality of thid design
    input [WADDR-1 : 0] i_SLV_ADDR, //Address of slave to be selected
    input i_RW, //Input signal to specify whether to do a read/write transaction, 0 for READ and 1 for WRITE transaction
    input [WDATA-1 : 0] i_SLV_WDATA, //PWDATA which is to be written into slave by te master during WRITE transaction 

    output reg o_PSELx,
    output reg o_PENABLE,
    output reg o_PWRITE,
    output reg [WDATA-1 : 0] o_PWDATA,
    output reg [WADDR-1 : 0] o_PADDR,

    output reg [WDATA-1 : 0] o_SLV_RDATA    //Data received by master from the slave in READ Transaction
);
localparam  IDLE = 2'b00,
            SETUP = 2'b01,
            ACCESS = 2'b10;

reg [1:0] state = 0;

always@(posedge i_PCLK)begin
    if(~i_PRESETn)begin
        state <= 0;
        o_PSELx <= 0;
        o_PENABLE <= 0;
        o_PWRITE <= 0;
        o_PWDATA <= 0;
        o_PADDR <= 0;
        o_SLV_RDATA <= 0;
    end
    else begin
        case(state)
            IDLE: begin
                o_PSELx <= 0;
                o_PENABLE <= 0;
                o_PWRITE <= 0;
                o_PWDATA <= 0;
                o_PADDR <= 0;
                o_SLV_RDATA <= 0;

                if(i_TRANSACTION)begin
                    state <= SETUP;
                end
                else begin
                    state <= IDLE;
                end
            end

            SETUP: begin
                o_PSELx <= 1'b1;
                o_PADDR <= i_SLV_ADDR;
                o_PWRITE <= i_RW;
                o_PENABLE <= 0; //Retrive previous value of enable, and we don't really care about what value it holds
                if(i_RW)begin
                    //WRITE TRANSACTION
                    o_PWDATA <= i_SLV_WDATA;
                    o_SLV_RDATA <= o_SLV_RDATA;
                    // state <= ACCESS;    //Stays in SETUP state only for 1 clock cycle
                end
                else begin
                    //READ TRANSACTION
                    o_PWDATA <= o_PWDATA; //Master do not send any data in READ Transaction
                    o_SLV_RDATA <= i_PRDATA;
                    // state <= ACCESS;    //Stays in SETUP state only for 1 clock cycle
                end
                state <= ACCESS;
            end

            ACCESS: begin
                o_PENABLE <= 1;
                o_PSELx <= 1;
                o_PADDR <= i_SLV_ADDR;
                o_PWRITE <= i_RW;

                //READ TRANSACTION
                if(~i_RW)begin
                    o_SLV_RDATA <= i_PRDATA;
                    o_PWDATA <= o_PWDATA;
                end
                //WRITE TRANSACTION
                else begin
                    o_PWDATA <= i_SLV_WDATA;
                    o_SLV_RDATA <= o_SLV_RDATA;
                end

                if(i_PREADY && i_TRANSACTION)begin
                    state <= SETUP;
                end
                else if(i_PREADY && ~i_TRANSACTION)begin
                    state <= IDLE;
                end
                else begin
                    state <= ACCESS;
                end
            end

            default: begin
                state <= IDLE;
            end

        endcase
    end
end

endmodule