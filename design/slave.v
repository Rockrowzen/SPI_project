module spi_slave (
    input  wire      sclk,     // SPI clock (from master)
    input  wire      cs,       // chip select active LOW
    input  wire      mosi,     // Master → Slave
    output reg       miso,     // Slave → Master
    input  wire      reset,
    input  wire [7:0] data_in, // Internal slave data to send
    output reg [7:0] data_out  // Data received from master
);

reg [7:0] shift_in;
reg [7:0] shift_out;
reg [3:0] bitcount;

always @(negedge cs or posedge reset) begin
    if(reset) begin
        bitcount <= 0;
        shift_out <= 0;
    end else begin
        bitcount   <= 0;
        shift_out  <= data_in;   // preload
    end
end

// MOSI sampled on rising edge
always @(posedge sclk) begin
    if(!cs) begin
        shift_in <= {shift_in[6:0], mosi};
        bitcount <= bitcount + 1;
    end
end

// MISO updates on falling edge
always @(negedge sclk) begin
    if(!cs) begin
        miso     <= shift_out[7];
        shift_out <= {shift_out[6:0], 1'b0};
    end
end

// Latch data
always @(posedge cs) begin
    data_out <= shift_in;
end

endmodule
