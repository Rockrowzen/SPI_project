module spi_slave_1(
    input  wire sclk,
    input  wire ss,          // Active low
    input  wire mosi,
    output reg  miso,
    output reg [7:0] data_out
);
module spi_slave_2(
    input  wire sclk,
    input  wire ss,          // Active low
    input  wire mosi,
    output reg  miso,
    output reg [7:0] data_out
);
module spi_slave_3(
    input  wire sclk,
    input  wire ss,          // Active low
    input  wire mosi,
    output reg  miso,
    output reg [7:0] data_out
);