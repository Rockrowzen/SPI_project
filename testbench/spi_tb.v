`timescale 1ns/1ps

module spi_top_tb;

    // Clock and reset
    reg clk;
    reg reset;

    // Master control
    reg start;
    reg [1:0] slaveselect;
    reg [7:0] master_data;

    // Slave data inputs
    reg [7:0] slave0_data_in;
    reg [7:0] slave1_data_in;
    reg [7:0] slave2_data_in;

    // Outputs from top module
    wire [7:0] slave0_data_out;
    wire [7:0] slave1_data_out;
    wire [7:0] slave2_data_out;
    wire [7:0] master_rx;
    wire done;

    // SPI lines (now exposed from spi_top)
    wire mosi, miso, sclk, cs0, cs1, cs2;

    //-------------------------------------------------------
    // Instantiate the top-level SPI design
    //-------------------------------------------------------
    spi_top uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .slaveselect(slaveselect),
        .master_data(master_data),
        .slave0_data_in(slave0_data_in),
        .slave1_data_in(slave1_data_in),
        .slave2_data_in(slave2_data_in),
        .slave0_data_out(slave0_data_out),
        .slave1_data_out(slave1_data_out),
        .slave2_data_out(slave2_data_out),
        .master_rx(master_rx),
        .done(done),
        .mosi(mosi),
        .miso(miso),
        .sclk(sclk),
        .cs0(cs0),
        .cs1(cs1),
        .cs2(cs2)
    );

    //-------------------------------------------------------
    // Clock generation
    //-------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz system clock (10 ns period)

    //-------------------------------------------------------
    // Test sequence
    //-------------------------------------------------------
    initial begin
        // Initialize
        reset = 1;
        start = 0;
        slaveselect = 2'b00;
        master_data = 8'hAC;
        slave0_data_in = 8'hA5;
        slave1_data_in = 8'h5A;
        slave2_data_in = 8'h3C;

        #50;
        reset = 0;
        #50;

        $display("=== Starting SPI Communication ===");

        // --- Communicate with Slave 0 ---
        slaveselect = 2'b00;
        master_data = 8'hF0;
        start = 1;
        #300 start = 0;
        wait(done == 1);
        #1500;
        $display("[%0t] Slave 0 RX = %02h, Master RX = %02h", $time, slave0_data_out, master_rx);

        // --- Communicate with Slave 1 ---
        slaveselect = 2'b01;
        master_data = 8'hAA;
        start = 1;
        #300 start = 0;
        wait(done == 1);
        #1500;
        $display("[%0t] Slave 1 RX = %02h, Master RX = %02h", $time, slave1_data_out, master_rx);

        // --- Communicate with Slave 2 ---
        slaveselect = 2'b10;
        master_data = 8'h55;
        start = 1;
        #300 start = 0;
        wait(done == 1);
        #1500;
        $display("[%0t] Slave 2 RX = %02h, Master RX = %02h", $time, slave2_data_out, master_rx);

        $display("=== Simulation Complete ===");
        #200;
        $stop;
    end

    //-------------------------------------------------------
    // Monitor SPI lines for debug
    //-------------------------------------------------------
    initial begin
        $monitor("[%0t] | CS0=%b CS1=%b CS2=%b | MOSI=%b MISO=%b | SCLK=%b | Master_RX=%h",
                 $time, cs0, cs1, cs2, mosi, miso, sclk, master_rx);
    end

endmodule
