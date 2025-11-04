`timescale 1ns/1ps

module spi_master_tb_mode1;

    // Inputs
    reg clk;
    reg reset;
    reg start;
    reg en;
    reg [1:0] slaveselect;
    reg [7:0] data_in;
    reg miso;

    // Outputs
    wire mosi;
    wire cs0, cs1, cs2;
    wire sclk;
    wire [7:0] data_out;

    // Instantiate DUT
    spi_master uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .en(en),
        .slaveselect(slaveselect),
        .data_in(data_in),
        .miso(miso),
        .mosi(mosi),
        .cs0(cs0),
        .cs1(cs1),
        .cs2(cs2),
        .sclk(sclk),
        .data_out(data_out)
    );

    // 100 MHz system clock
    always #5 clk = ~clk;

    //---------------------------------------------
    // Simple Mode-1 SPI Slave Model
    //---------------------------------------------
    reg [7:0] slave_shift;

    //  (1) Capture MOSI on falling edge  (CPHA = 1)
    always @(negedge sclk or posedge reset) begin
        if (reset)
            slave_shift <= 8'hA5;   // preload dummy data
        else
            slave_shift <= {slave_shift[6:0], mosi}; // sample MOSI
    end

    //  (2) Drive MISO on rising edge (so master samples it on falling)
    always @(posedge sclk or posedge reset) begin
        if (reset)
            miso <= 1'b0;
        else
            miso <= slave_shift[7]; // output MSB first
    end

    //---------------------------------------------
    // Test Sequence
    //---------------------------------------------
    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        start = 0;
        en = 1;
        slaveselect = 2'b00;
        data_in = 8'hAC;   // 1010_1100
        miso = 0;

        // Apply reset
        #50  reset = 0;
        #50;

        // Start transmission (hold long enough for sclk edge)
        $display("[%0t] Starting SPI transmission...", $time);
        start = 1;
        #300 start = 0;

        // Let transfer complete (8 bits × 200 ns ≈ 1.6 µs + margin)
        #3000;

        $display("[%0t] Data received by master = %02h", $time, data_out);
        $display("Simulation complete.");
        $stop;
    end

    //---------------------------------------------
    // Monitor key signals
    //---------------------------------------------
    initial begin
        $monitor("T=%0t | CS0=%b | SCLK=%b | MOSI=%b | MISO=%b | data_out=%h",
                  $time, cs0, sclk, mosi, miso, data_out);
    end

endmodule
