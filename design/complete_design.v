//to get everything in one place for testbench
module spi_top (
    input  wire clk,             // System clock (e.g., 50 MHz)
    input  wire reset,           // Asynchronous reset
    input  wire start,           // Start SPI transaction
    input  wire [7:0] master_data, // Data to send from Master → Slave
    output wire [7:0] slave_data,  // Data received by Slave
    output wire [7:0] master_rx,   // Data received by Master (via MISO)
    output wire done               // Indicates transfer complete
);

//use master and slave modules(instantiate them)