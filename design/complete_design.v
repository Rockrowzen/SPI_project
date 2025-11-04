module spi_top (
    input  wire clk,
    input  wire reset,
    input  wire start,
    input  wire [1:0] slaveselect,
    input  wire [7:0] master_data,
    input  wire [7:0] slave0_data_in,
    input  wire [7:0] slave1_data_in,
    input  wire [7:0] slave2_data_in,
    output wire [7:0] slave0_data_out,
    output wire [7:0] slave1_data_out,
    output wire [7:0] slave2_data_out,
    output wire [7:0] master_rx,
    output wire done
);

    wire mosi;
    wire sclk;
    wire cs0, cs1, cs2;
    
    wire miso0, miso1, miso2;
    
    wire miso;
    assign miso = (!cs0) ? miso0 :
                  (!cs1) ? miso1 :
                  (!cs2) ? miso2 : 1'b0;
    
    wire en = 1'b1;
    
    assign done = cs0 & cs1 & cs2;
    
    spi_master master (
        .clk(clk),
        .reset(reset),
        .start(start),
        .en(en),
        .slaveselect(slaveselect),
        .data_in(master_data),
        .miso(miso),
        .mosi(mosi),
        .cs0(cs0),
        .cs1(cs1),
        .cs2(cs2),
        .sclk(sclk),
        .data_out(master_rx)
    );
    
    spi_slave slave0 (
        .sclk(sclk),
        .cs(cs0),
        .mosi(mosi),
        .miso(miso0),
        .reset(reset),
        .data_in(slave0_data_in),
        .data_out(slave0_data_out)
    );
    
    spi_slave slave1 (
        .sclk(sclk),
        .cs(cs1),
        .mosi(mosi),
        .miso(miso1),
        .reset(reset),
        .data_in(slave1_data_in),
        .data_out(slave1_data_out)
    );
    
    spi_slave slave2 (
        .sclk(sclk),
        .cs(cs2),
        .mosi(mosi),
        .miso(miso2),
        .reset(reset),
        .data_in(slave2_data_in),
        .data_out(slave2_data_out)
    );

endmodule