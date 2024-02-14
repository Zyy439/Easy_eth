`timescale 1ns/1ns
module tb_top;


///Àý»¯Ä£¿é

reg     [127:0] bData_in_data_in;
reg     [15:0] bData_in_keep_in;
reg  wClk;
reg  wData_Hdr_out_ready_out;
reg  wData_in_last_in;
reg  wData_in_valid_in;
reg  wData_out_ready_out;
reg  wRst;
wire     [31:0] bBadCheckSum_packet_cnt_IP;
wire     [15:0] bData_Hdr_out_IPCheckSum_out;
wire     [5:0] bData_Hdr_out_IPDscp_out;
wire     [31:0] bData_Hdr_out_IPDstIpAddr_out;
wire     [1:0] bData_Hdr_out_IPEcn_out;
wire     [2:0] bData_Hdr_out_IPFlag_out;
wire     [12:0] bData_Hdr_out_IPFragOffset_out;
wire     [15:0] bData_Hdr_out_IPIdentification_out;
wire     [3:0] bData_Hdr_out_IPIhl_out;
wire     [15:0] bData_Hdr_out_IPLength_out;
wire     [7:0] bData_Hdr_out_IPProtocol_out;
wire     [31:0] bData_Hdr_out_IPSrcIpAddr_out;
wire     [7:0] bData_Hdr_out_IPTimeToLive_out;
wire     [3:0] bData_Hdr_out_IPVersion_out;
wire     [47:0] bData_Hdr_out_MacDstMacAddr_out;
wire     [15:0] bData_Hdr_out_MacFrameType_out;
wire     [47:0] bData_Hdr_out_MacSrcMacAddr_out;
wire     [15:0] bData_Hdr_out_UDPCheckSum_out;
wire     [15:0] bData_Hdr_out_UDPDstPort_out;
wire     [15:0] bData_Hdr_out_UDPLength_out;
wire     [15:0] bData_Hdr_out_UDPSrcPort_out;
wire     [127:0] bData_out_data_out;
wire     [15:0] bData_out_keep_out;
wire     [31:0] bEarlyTerminate_packet_cnt_IP;
wire     [31:0] bEarlyTerminate_packet_cnt_UDP;
wire     [31:0] bUnsupportIpType_cnt_IP;
wire  wData_Hdr_out_valid_out;
wire  wData_in_ready_in;
wire  wData_out_last_out;
wire  wData_out_valid_out;

Rx_top  Rx_top_inst (
  .bData_in_data_in(bData_in_data_in),
  .bData_in_keep_in(bData_in_keep_in),
  .wClk(wClk),
  .wData_Hdr_out_ready_out(wData_Hdr_out_ready_out),
  .wData_in_last_in(wData_in_last_in),
  .wData_in_valid_in(wData_in_valid_in),
  .wData_out_ready_out(wData_out_ready_out),
  .wRst(wRst),
  .bBadCheckSum_packet_cnt_IP(bBadCheckSum_packet_cnt_IP),
  .bData_Hdr_out_IPCheckSum_out(bData_Hdr_out_IPCheckSum_out),
  .bData_Hdr_out_IPDscp_out(bData_Hdr_out_IPDscp_out),
  .bData_Hdr_out_IPDstIpAddr_out(bData_Hdr_out_IPDstIpAddr_out),
  .bData_Hdr_out_IPEcn_out(bData_Hdr_out_IPEcn_out),
  .bData_Hdr_out_IPFlag_out(bData_Hdr_out_IPFlag_out),
  .bData_Hdr_out_IPFragOffset_out(bData_Hdr_out_IPFragOffset_out),
  .bData_Hdr_out_IPIdentification_out(bData_Hdr_out_IPIdentification_out),
  .bData_Hdr_out_IPIhl_out(bData_Hdr_out_IPIhl_out),
  .bData_Hdr_out_IPLength_out(bData_Hdr_out_IPLength_out),
  .bData_Hdr_out_IPProtocol_out(bData_Hdr_out_IPProtocol_out),
  .bData_Hdr_out_IPSrcIpAddr_out(bData_Hdr_out_IPSrcIpAddr_out),
  .bData_Hdr_out_IPTimeToLive_out(bData_Hdr_out_IPTimeToLive_out),
  .bData_Hdr_out_IPVersion_out(bData_Hdr_out_IPVersion_out),
  .bData_Hdr_out_MacDstMacAddr_out(bData_Hdr_out_MacDstMacAddr_out),
  .bData_Hdr_out_MacFrameType_out(bData_Hdr_out_MacFrameType_out),
  .bData_Hdr_out_MacSrcMacAddr_out(bData_Hdr_out_MacSrcMacAddr_out),
  .bData_Hdr_out_UDPCheckSum_out(bData_Hdr_out_UDPCheckSum_out),
  .bData_Hdr_out_UDPDstPort_out(bData_Hdr_out_UDPDstPort_out),
  .bData_Hdr_out_UDPLength_out(bData_Hdr_out_UDPLength_out),
  .bData_Hdr_out_UDPSrcPort_out(bData_Hdr_out_UDPSrcPort_out),
  .bData_out_data_out(bData_out_data_out),
  .bData_out_keep_out(bData_out_keep_out),
  .bEarlyTerminate_packet_cnt_IP(bEarlyTerminate_packet_cnt_IP),
  .bEarlyTerminate_packet_cnt_UDP(bEarlyTerminate_packet_cnt_UDP),
  .bUnsupportIpType_cnt_IP(bUnsupportIpType_cnt_IP),
  .wData_Hdr_out_valid_out(wData_Hdr_out_valid_out),
  .wData_in_ready_in(wData_in_ready_in),
  .wData_out_last_out(wData_out_last_out),
  .wData_out_valid_out(wData_out_valid_out)
);



  

initial begin
    wClk = 1;
    wRst = 1;
    wData_in_valid_in = 0;
    wData_in_last_in = 0;
    bData_in_keep_in = 16'h0;
    wData_Hdr_out_ready_out = 0;
    wData_out_ready_out = 0;
    bData_in_data_in = 0;
    #100; 
    wRst = 0;
    wData_Hdr_out_ready_out = 1;
    wData_out_ready_out = 1;
end

always #5  wClk =  !wClk;
initial begin
  #150;
  gen_data;
  #500;
  $stop;
end

task gen_data;
begin
    @(posedge wClk);
    wData_in_valid_in = 1;
    bData_in_keep_in = 16'hffff;
    bData_in_data_in = {32{4'hf}};
    @(posedge wClk);
    bData_in_keep_in = 16'hffff;
    bData_in_data_in = {32{4'he}};
    @(posedge wClk);
    bData_in_keep_in = 16'hffff;
    bData_in_data_in = {32{4'hd}};
    wData_in_last_in = 1;
    @(posedge wClk);
    wData_in_last_in = 0;
    bData_in_keep_in = 16'h0;
    wData_in_valid_in = 0;
    bData_in_data_in = 0;
end
endtask




































endmodule
