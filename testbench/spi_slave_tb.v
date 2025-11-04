`timescale 1ns/1ps

module spi_slave_tb;
    reg sclk;
    reg cs;
    reg mosi;
    wire miso;
    reg reset;
    reg [7:0] data_in;
    wire [7:0] data_out;

    spi_slave uut (
        .sclk(sclk),
        .cs(cs),
        .mosi(mosi),
        .miso(miso),
        .reset(reset),
        .data_in(data_in),
        .data_out(data_out)
    );

    initial sclk = 0;
    always #50 sclk = ~sclk;  // 10 MHz clock

    reg [7:0] master_data = 8'hAC; // 1010_1100
    integer i;

    initial begin
        reset = 1; cs = 1; mosi = 0; data_in = 8'hA5;
        #200 reset = 0;
        #200;

        $display("[%0t] Starting SPI transaction", $time);
        cs = 0; // Active low
        #100;

        // --- Correct Mode-1 bit driving ---
        for (i = 7; i >= 0; i = i - 1) begin
            @(posedge sclk); // drive MOSI on rising edge
            mosi = master_data[i];
            @(negedge sclk); // wait for slave to sample it
        end

        @(negedge sclk);
        cs = 1; // end frame
        #200;

        $display("[%0t] Slave received data_out = %02h", $time, data_out);
        $stop;
    end
endmodule
