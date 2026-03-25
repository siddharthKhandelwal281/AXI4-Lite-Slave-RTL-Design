`timescale 1ns/1ps

module tb_axi4_lite_slave;

parameter ADDR_WIDTH=4;
parameter DATA_WIDTH=32;

reg ACLK,ARESETn;


// axi4 signals master driven signals as reg and slave output as wire 

// aw channel
reg [ADDR_WIDTH-1:0] AWADDR;
reg AWVALID;
wire AWREADY;

// w chabnnel 

reg [DATA_WIDTH-1:0] WDATA;
reg WVALID;
wire WREADY;

// B BHANNEL

reg BREADY;
wire [1:0] BRESP;
wire BVALID;

// AR channel 

reg [ADDR_WIDTH-1:0] ARADDR;
reg ARVALID;
wire ARREADY;

//  r channel

reg RREADY;
wire [1:0] RRESP;
wire RVALID;
wire [DATA_WIDTH-1:0] RDATA;

reg [DATA_WIDTH-1:0] expected_data;
integer error_count = 0;

// dut instiantiate
 
axi4_lite_slave dut(
.ACLK(ACLK),
.ARESETn(ARESETn),
.AWADDR(AWADDR),
.AWVALID(AWVALID),
.AWREADY(AWREADY),
.WDATA(WDATA),
.WREADY(WREADY),
.WVALID(WVALID),
.BRESP(BRESP),
.BREADY(BREADY),
.BVALID(BVALID),
.ARADDR(ARADDR),
.ARREADY(ARREADY),
.ARVALID(ARVALID),
.RRESP(RRESP),
.RVALID(RVALID),
.RDATA(RDATA),
.RREADY(RREADY)
);

initial begin
    AWADDR  = 0;
    AWVALID = 0;
    WDATA   = 0;
    WVALID  = 0;
    BREADY  = 0;
    ARADDR  = 0;
    ARVALID = 0;
    RREADY  = 0;
end

// CLOCK GENERATION

initial begin
  ACLK=0;
  ARESETn=0;
  
  #20;
  ARESETn = 1;
  end
  
always #5 ACLK=~ACLK;
  
  
initial begin
  wait(ARESETn);
  @(posedge ACLK);
 


// WRITE
AWADDR  = 4'h0;
WDATA   = 32'hED5684CA;
expected_data = 32'hED5684CA;

AWVALID = 1;
WVALID  = 1;

while (!AWREADY) @(posedge ACLK);
while (!WREADY)  @(posedge ACLK);
@(posedge ACLK);

AWVALID = 0;
WVALID  = 0;

BREADY = 1;
while (!BVALID) @(posedge ACLK);
@(posedge ACLK);
BREADY = 0;


// READ
ARADDR  = 4'h0;
ARVALID = 1;

while (!ARREADY) @(posedge ACLK);
@(posedge ACLK);
ARVALID = 0;

RREADY = 1;
while (!RVALID) @(posedge ACLK);

@(posedge ACLK);

// SELF CHECK
if (RDATA === expected_data) begin
    $display("PASS: Read Data = %h", RDATA);
end
else begin
    $display("FAIL: Expected %h, Got %h", expected_data, RDATA);
    error_count = error_count + 1;
end

RREADY = 0;

#20;

$display("=================================");

if (error_count == 0) begin
    $display(" ALL TESTS PASSED ");
end else begin
    $display(" TEST FAILED with %0d errors", error_count);
end

$display("=================================");

$finish;

end  // end of main initial block


endmodule 