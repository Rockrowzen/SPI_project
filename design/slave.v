// ===============================================================
// SPI SLAVE  (Mode-0 : CPOL = 0, CPHA = 0)
//   • Samples MOSI on rising edge of SCLK
//   • Drives MISO on falling edge of SCLK
//   • Latches received byte when CS goes HIGH
// ===============================================================
module spi_slave (
    input  wire       sclk,        // SPI clock from master
    input  wire       cs,          // Active-low chip-select
    input  wire       mosi,        // Master ? Slave
    output reg        miso,        // Slave ? Master
    input  wire       reset,
    input  wire [7:0] data_in,     // Data to send back
    output reg [7:0]  data_out     // Data received from master
);

    reg [7:0] shift_in;
    reg [7:0] shift_out;
    reg [3:0] bitcount;

    // -----------------------------------------------------------
    // Load data when CS goes low (begin transaction)
    // -----------------------------------------------------------
    always @(negedge cs or posedge reset) begin
        if (reset) begin
            bitcount  <= 0;
            shift_in  <= 8'h00;
            shift_out <= 8'h00;
            miso      <= 1'b0;
        end else begin
            bitcount  <= 0;
            shift_in  <= 8'h00;
            shift_out <= data_in;     // preload outgoing data
        end
    end

    // -----------------------------------------------------------
    // MODE-0 :  Sample MOSI on rising edge
    // -----------------------------------------------------------
    always @(posedge sclk) begin
        if (!cs) begin
            shift_in  <= {shift_in[6:0], mosi};
            bitcount  <= bitcount + 1;
        end
    end

    // -----------------------------------------------------------
    // MODE-0 :  Drive MISO on falling edge
    // -----------------------------------------------------------
    always @(negedge sclk) begin
        if (!cs) begin
            miso      <= shift_out[7];
            shift_out <= {shift_out[6:0], 1'b0};
        end
    end

    // -----------------------------------------------------------
    // Latch final received byte when CS de-asserts
    // -----------------------------------------------------------
    always @(posedge cs or posedge reset) begin
        if (reset)
            data_out <= 8'h00;
        else
            data_out <= shift_in;
    end

endmodule
