`timescale 1ns/1ns
module UDP_rx_process_tb;

  // Parameters

  //Ports
  reg  wClk;
  reg  wRst;
  reg  wData_Hdr_in_valid;
  wire  wData_Hdr_in_ready;
  reg [47:0] bData_Hdr_in_MacDstMacAddr;
  reg [47:0] bData_Hdr_in_MacSrcMacAddr;
  reg [15:0] bData_Hdr_in_MacFrameType;
  reg [3:0] bData_Hdr_in_IPVersion;
  reg [3:0] bData_Hdr_in_IPIhl;
  reg [5:0] bData_Hdr_in_IPDscp;
  reg [1:0] bData_Hdr_in_IPEcn;
  reg [15:0] bData_Hdr_in_IPLength;
  reg [15:0] bData_Hdr_in_IPIdentification;
  reg [2:0] bData_Hdr_in_IPFlag;
  reg [12:0] bData_Hdr_in_IPFragOffset;
  reg [7:0] bData_Hdr_in_IPTimeToLive;
  reg [7:0] bData_Hdr_in_IPProtocol;
  reg [15:0] bData_Hdr_in_IPCheckSum;
  reg [31:0] bData_Hdr_in_IPSrcIpAddr;
  reg [31:0] bData_Hdr_in_IPDstIpAddr;
  reg  wData_in_valid;
  wire  wData_in_ready;
  reg [127:0] bData_in_data;
  reg [15:0] bData_in_keep;
  reg  wData_in_last;
  wire  wData_Hdr_out_valid;
  reg  wData_Hdr_out_ready;
  wire [47:0] bData_Hdr_out_MacDstMacAddr;
  wire [47:0] bData_Hdr_out_MacSrcMacAddr;
  wire [15:0] bData_Hdr_out_MacFrameType;
  wire [3:0] bData_Hdr_out_IPVersion;
  wire [3:0] bData_Hdr_out_IPIhl;
  wire [5:0] bData_Hdr_out_IPDscp;
  wire [1:0] bData_Hdr_out_IPEcn;
  wire [15:0] bData_Hdr_out_IPLength;
  wire [15:0] bData_Hdr_out_IPIdentification;
  wire [2:0] bData_Hdr_out_IPFlag;
  wire [12:0] bData_Hdr_out_IPFragOffset;
  wire [7:0] bData_Hdr_out_IPTimeToLive;
  wire [7:0] bData_Hdr_out_IPProtocol;
  wire [15:0] bData_Hdr_out_IPCheckSum;
  wire [31:0] bData_Hdr_out_IPSrcIpAddr;
  wire [31:0] bData_Hdr_out_IPDstIpAddr;
  wire [15:0] bData_Hdr_out_UDPSrcPort;
  wire [15:0] bData_Hdr_out_UDPDstPort;
  wire [15:0] bData_Hdr_out_UDPLength;
  wire [15:0] bData_Hdr_out_UDPCheckSum;
  wire  wData_out_valid;
  reg  wData_out_ready;
  wire [127:0] bData_out_data;
  wire [15:0] bData_out_keep;
  wire  wData_out_last;
  wire [31:0] bEarlyTerminate_packet_cnt;

  UDP_rx_process  UDP_rx_process_inst (
    .wClk(wClk),
    .wRst(wRst),
    .wData_Hdr_in_valid(wData_Hdr_in_valid),
    .wData_Hdr_in_ready(wData_Hdr_in_ready),
    .bData_Hdr_in_MacDstMacAddr(bData_Hdr_in_MacDstMacAddr),
    .bData_Hdr_in_MacSrcMacAddr(bData_Hdr_in_MacSrcMacAddr),
    .bData_Hdr_in_MacFrameType(bData_Hdr_in_MacFrameType),
    .bData_Hdr_in_IPVersion(bData_Hdr_in_IPVersion),
    .bData_Hdr_in_IPIhl(bData_Hdr_in_IPIhl),
    .bData_Hdr_in_IPDscp(bData_Hdr_in_IPDscp),
    .bData_Hdr_in_IPEcn(bData_Hdr_in_IPEcn),
    .bData_Hdr_in_IPLength(bData_Hdr_in_IPLength),
    .bData_Hdr_in_IPIdentification(bData_Hdr_in_IPIdentification),
    .bData_Hdr_in_IPFlag(bData_Hdr_in_IPFlag),
    .bData_Hdr_in_IPFragOffset(bData_Hdr_in_IPFragOffset),
    .bData_Hdr_in_IPTimeToLive(bData_Hdr_in_IPTimeToLive),
    .bData_Hdr_in_IPProtocol(bData_Hdr_in_IPProtocol),
    .bData_Hdr_in_IPCheckSum(bData_Hdr_in_IPCheckSum),
    .bData_Hdr_in_IPSrcIpAddr(bData_Hdr_in_IPSrcIpAddr),
    .bData_Hdr_in_IPDstIpAddr(bData_Hdr_in_IPDstIpAddr),
    .wData_in_valid(wData_in_valid),
    .wData_in_ready(wData_in_ready),
    .bData_in_data(bData_in_data),
    .bData_in_keep(bData_in_keep),
    .wData_in_last(wData_in_last),
    .wData_Hdr_out_valid(wData_Hdr_out_valid),
    .wData_Hdr_out_ready(wData_Hdr_out_ready),
    .bData_Hdr_out_MacDstMacAddr(bData_Hdr_out_MacDstMacAddr),
    .bData_Hdr_out_MacSrcMacAddr(bData_Hdr_out_MacSrcMacAddr),
    .bData_Hdr_out_MacFrameType(bData_Hdr_out_MacFrameType),
    .bData_Hdr_out_IPVersion(bData_Hdr_out_IPVersion),
    .bData_Hdr_out_IPIhl(bData_Hdr_out_IPIhl),
    .bData_Hdr_out_IPDscp(bData_Hdr_out_IPDscp),
    .bData_Hdr_out_IPEcn(bData_Hdr_out_IPEcn),
    .bData_Hdr_out_IPLength(bData_Hdr_out_IPLength),
    .bData_Hdr_out_IPIdentification(bData_Hdr_out_IPIdentification),
    .bData_Hdr_out_IPFlag(bData_Hdr_out_IPFlag),
    .bData_Hdr_out_IPFragOffset(bData_Hdr_out_IPFragOffset),
    .bData_Hdr_out_IPTimeToLive(bData_Hdr_out_IPTimeToLive),
    .bData_Hdr_out_IPProtocol(bData_Hdr_out_IPProtocol),
    .bData_Hdr_out_IPCheckSum(bData_Hdr_out_IPCheckSum),
    .bData_Hdr_out_IPSrcIpAddr(bData_Hdr_out_IPSrcIpAddr),
    .bData_Hdr_out_IPDstIpAddr(bData_Hdr_out_IPDstIpAddr),
    .bData_Hdr_out_UDPSrcPort(bData_Hdr_out_UDPSrcPort),
    .bData_Hdr_out_UDPDstPort(bData_Hdr_out_UDPDstPort),
    .bData_Hdr_out_UDPLength(bData_Hdr_out_UDPLength),
    .bData_Hdr_out_UDPCheckSum(bData_Hdr_out_UDPCheckSum),
    .wData_out_valid(wData_out_valid),
    .wData_out_ready(wData_out_ready),
    .bData_out_data(bData_out_data),
    .bData_out_keep(bData_out_keep),
    .wData_out_last(wData_out_last),
    .bEarlyTerminate_packet_cnt(bEarlyTerminate_packet_cnt)
  );

  //clk rst
  initial begin
    wRst = 1;
    wClk = 1;
    #100;
    wRst = 0;
  end
  always #5  wClk = ! wClk ;

  //ip frame header
initial begin
  wData_Hdr_in_valid            = 0;
  bData_Hdr_in_MacDstMacAddr    = 0;		
  bData_Hdr_in_MacSrcMacAddr    = 0;		
  bData_Hdr_in_MacFrameType	    = 0;
  bData_Hdr_in_IPVersion	      = 0;	
  bData_Hdr_in_IPIhl	          = 0;				
  bData_Hdr_in_IPDscp	          = 0;				
  bData_Hdr_in_IPEcn				    = 0;	
  bData_Hdr_in_IPLength			    = 0;	
  bData_Hdr_in_IPIdentification = 0;		
  bData_Hdr_in_IPFlag				    = 0;	
  bData_Hdr_in_IPFragOffset		  = 0;	
  bData_Hdr_in_IPTimeToLive		  = 0;	
  bData_Hdr_in_IPProtocol			  = 0;	
  bData_Hdr_in_IPCheckSum			  = 0;	
  bData_Hdr_in_IPSrcIpAddr		  = 0;	
  bData_Hdr_in_IPDstIpAddr		  = 0;	
end

//ip frame payload
initial begin
  wData_in_valid = 0;
  bData_in_data  = 0;
  bData_in_keep  = 0;
  wData_in_last  = 0;
end


initial begin
  wData_Hdr_out_ready = 1;

  wData_out_ready = 1;
end

task ip_her;
begin
  @(posedge wClk);
  wData_Hdr_in_valid            = 1;
  bData_Hdr_in_MacDstMacAddr    = 1;		
  bData_Hdr_in_MacSrcMacAddr    = 2;		
  bData_Hdr_in_MacFrameType	    = 3;
  bData_Hdr_in_IPVersion	      = 4;	
  bData_Hdr_in_IPIhl	          = 5;				
  bData_Hdr_in_IPDscp	          = 6;				
  bData_Hdr_in_IPEcn				    = 7;	
  bData_Hdr_in_IPLength			    = 8;	
  bData_Hdr_in_IPIdentification = 9;		
  bData_Hdr_in_IPFlag				    = 10;	
  bData_Hdr_in_IPFragOffset		  = 11;	
  bData_Hdr_in_IPTimeToLive		  = 12;	
  bData_Hdr_in_IPProtocol			  = 13;	
  bData_Hdr_in_IPCheckSum			  = 14;	
  bData_Hdr_in_IPSrcIpAddr		  = 15;	
  bData_Hdr_in_IPDstIpAddr		  = 16;

  @(posedge wClk);
  wData_Hdr_in_valid            = 0;
end

endtask


task ip_payload;
begin
  @(posedge wClk);
  wData_in_valid = 1;
  bData_in_data  = 128'h1234;
  bData_in_keep  = 16'hffff;
  wData_in_last  = 0;
  @(posedge wClk);
  wData_in_valid = 1;
  bData_in_data  = 128'h5678;
  bData_in_keep  = 16'hffff;
  @(posedge wClk);
  wData_in_valid = 1;
  bData_in_data  = 128'h9abc;
  bData_in_keep  = 16'hffff;
  @(posedge wClk);
  wData_in_valid = 1;
  bData_in_data  = 128'hdef0;
  bData_in_keep  = 16'hffff;
  wData_in_last  = 1;
  @(posedge wClk);
  wData_in_valid = 0;
  bData_in_data  = 128'h0;
  bData_in_keep  = 16'h0;
  wData_in_last  = 0;
end
endtask


initial begin
  #200;
  ip_her;
  #200;
  ip_payload;
  #300;
  $stop;
end
endmodule