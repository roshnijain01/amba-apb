module apb_slave#(
    parameter WDATA = 8,
    parameter WADDR = 8
)(
    input i_PCLK,
    input i_PRESETn,    //Active low reset
    input i_PSELx,
    input i_PENABLE,
    input i_PWRITE, //If 1, indicates a WRITE transaction, else READ transaction
    input [WADDR-1 : 0] i_PADDR,
    input [WDATA-1 : 0] i_PWDATA, //Data coming from APB master during it's WRITE Transaction

    output reg o_PREADY,
    output reg o_PSLVERR,
    output reg [WDATA-1 : 0] o_PRDATA   //Data which is being read by APB master from APB slave during Master's READ Transaction
);

reg [WDATA-1 : 0] mem [255:0];

always@(posedge i_PCLK)begin
    if(~i_PRESETn)begin
        o_PREADY <= 0;
        o_PSLVERR <= 0;
        o_PRDATA <= 0;
    end
    else begin
        if(i_PSELx)begin
            //Setup state
            if(i_PENABLE)begin
                o_PREADY <= 1; //Slave is ready to accept the transaction
                if(i_PWRITE)begin
                    //Write transaction- APB Master wants to write into the mentioned PADDR
                    o_PSLVERR <= 0; //No error in the transaction
                    o_PRDATA <= 0; //No data to be read in WRITE transaction
                    mem[i_PADDR] <= i_PWDATA;//write the data into the slave's internal registers
                end
                else begin
                    //Read transaction- APB Master wants to read from the mentioned PADDR
                    o_PSLVERR <= 0; //No error in the transaction
                    o_PRDATA <= mem[i_PADDR];//read the data from the slave's internal registers
                end
            end
            else begin
                o_PREADY <= 0; //Slave is not ready to accept the transaction
                o_PSLVERR <= 0;
            end

        end
        else begin
            o_PREADY <= 0;
            o_PSLVERR <= 0;
            o_PRDATA <= 0;
        end
    end
end

endmodule