module spi_master(
    input  wire clk,          // System clock
    input  wire reset,
    input  wire start,        // Start transmission
    input  wire en,
    input  wire [7:0] data_in,// 8-bit data input 
    input  wire miso,         // Master In Slave out
    output reg  mosi,         // Master Out Slave in 
    output reg  cs0,cs1,cs2,
    output reg  sclk,         // SPI clock
    output reg  ss,           // Slave Select (active low)
    output reg  [7:0] data_out
);
