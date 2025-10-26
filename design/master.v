module spi_master (
    input  wire clk,          // System clock
    input  wire reset,
    input  wire start,        // Start transmission
    input  wire [7:0] data_in,
    input  wire miso,         // Master In (from slave)
    output reg  mosi,         // Master Out
    output reg  sclk,         // SPI clock
    output reg  ss,           // Slave Select (active low)
    output reg  done
);