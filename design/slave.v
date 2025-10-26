module spi_slave (
    input  wire sclk,
    input  wire ss,          // Active low
    input  wire mosi,
    output reg  miso,
    output reg [7:0] data_out
);