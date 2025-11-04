module spi_slave (
    input  wire       sclk,      // SPI clock from master
    input  wire       cs,        // Active low chip select
    input  wire       mosi,      // Master → Slave
    output reg        miso,      // Slave → Master
    input  wire       reset,
    input  wire [7:0] data_in,   // Data to send (preloaded)
    output reg [7:0]  data_out   // Data received from master
);

    reg [7:0] shift_in;
    reg [7:0] shift_out;
    reg [3:0] bitcount;

    //------------------------------------------
    // Load data when CS goes low (start of frame)
    //------------------------------------------
    always @(negedge cs or posedge reset) begin
        if (reset) begin
            bitcount  <= 0;
            shift_out <= 8'h00;
            shift_in  <= 8'h00;
            miso      <= 1'b0;
        end else begin
            bitcount  <= 0;
            shift_out <= data_in; // preload for transmission
            shift_in  <= 0;
        end
    end

    //------------------------------------------
    // Mode-1: Sample MOSI on falling edge (CPHA=1)
    //------------------------------------------
    always @(negedge sclk) begin
        if (!cs) begin
            shift_in  <= {shift_in[6:0], mosi};
            bitcount  <= bitcount + 1;
        end
    end

    //------------------------------------------
    // Mode-1: Drive MISO on rising edge
    //------------------------------------------
    always @(posedge sclk) begin
        if (!cs) begin
            miso      <= shift_out[7];                // drive next bit
            shift_out <= {shift_out[6:0], 1'b0};      // shift left
        end
    end

    //------------------------------------------
    // Latch received byte when CS deasserts
    //------------------------------------------
    always @(posedge cs or posedge reset) begin
        if (reset)
            data_out <= 8'h00;
        else
            data_out <= shift_in;
    end

endmodule
