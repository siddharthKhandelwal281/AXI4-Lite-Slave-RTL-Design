module axi4_lite_slave#(
parameter ADDR_WIDTH=4,
parameter DATA_WIDTH=32
)(
input ACLK,
input ARESETn,

// aw channel 
input [ADDR_WIDTH-1:0] AWADDR,
input AWVALID,
output reg AWREADY,


// w channel
input [DATA_WIDTH-1:0] WDATA,
input WVALID,
output reg WREADY,

// b channel 
input BREADY,
output reg [1:0] BRESP,
output reg BVALID,


// AR CHANNEL
input [ADDR_WIDTH-1:0] ARADDR,
input ARVALID,
output reg ARREADY,

// r channel
input RREADY,
output reg [1:0] RRESP,
output reg [DATA_WIDTH-1:0] RDATA,
output reg RVALID
);
 
// internal registers 

reg [DATA_WIDTH-1:0] reg0;
reg [DATA_WIDTH-1:0] reg1;
reg [DATA_WIDTH-1:0] reg2;
reg [DATA_WIDTH-1:0] reg3;

reg aw_done,w_done;
reg [ADDR_WIDTH-1:0] awaddr_reg,araddr_reg;
reg [DATA_WIDTH-1:0] wdata_reg;
reg read_pending;

always@(posedge ACLK or negedge ARESETn) begin
   if(!ARESETn) begin
      AWREADY<=1'b0;
      WREADY<=1'b0;
      BRESP<=2'b0;
      BVALID<=1'b0;
      ARREADY<=1'b0;
      RRESP<=2'b0;
      RVALID<=1'b0;
      RDATA<=32'b0;
      
      reg0<=32'b0;
      reg1<=32'b0;
      reg2<=32'b0;
      reg3<=32'b0;
      
      aw_done<=1'b0;
      w_done<=1'b0;
      
        awaddr_reg <= 0;
        araddr_reg <= 0;
        read_pending<=1'b0;
   end
   else begin
   

 
 // AW CHANNEL
if (!aw_done)
    AWREADY <= 1;
else
    AWREADY <= 0;

if (AWVALID && AWREADY)
begin
    aw_done    <= 1;
    awaddr_reg <= AWADDR;
end

// W CHANNEL
if (!w_done)
    WREADY <= 1;
else
    WREADY <= 0;

if (WVALID && WREADY)
begin
    w_done   <= 1;
    wdata_reg <= WDATA;
end
   
//  write execution 
if(aw_done && w_done && !BVALID) begin

  if(awaddr_reg[1:0]!=2'b00) begin
      // slave error 
      BRESP<=2'b10;
      BVALID<=1'b1;
  end
  else begin 
  case(awaddr_reg[3:2]) 
    2'b00: reg0<=wdata_reg;
    2'b01: reg1<=wdata_reg;
    2'b10: reg2<=wdata_reg;
    2'b11: reg3<=wdata_reg;
    endcase
    
    BRESP<=2'b00;
    BVALID<=1'b1;
    end
end

// b channel
if (BVALID && BREADY) begin
   BVALID<=1'b0;
   aw_done<=1'b0;
   w_done<=1'b0;
end




// AR READY generation
if (!read_pending && !RVALID)
    ARREADY <= 1;
else
    ARREADY <= 0;

// Handshake detection
if (ARVALID && ARREADY) begin
    araddr_reg  <= ARADDR;
    read_pending <= 1;
end

// Read execution (1-cycle latency)
if (read_pending) begin
    case (araddr_reg[3:2])
        2'b00: RDATA <= reg0;
        2'b01: RDATA <= reg1;
        2'b10: RDATA <= reg2;
        2'b11: RDATA <= reg3;
    endcase

    RRESP        <= 2'b00;
    RVALID       <= 1'b1;
    read_pending <= 0;
end

// Clear RVALID
if (RVALID && RREADY)
    RVALID <= 0;

end
end 


endmodule 