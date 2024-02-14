`timescale 1ns/1ns
module IP_rx_process_tb;

parameter   MAC_ADDR    = 48'h01_23_45_67_89_ab,
            SRC_ADDR    = 48'h11_22_33_44_55_66,
            FRAMR_TYPE  = 16'h9876,

            VERSION     = 4'h4,
            IHL         = 4'h5,
            DSCP        = 6'h0,
            ECN         = 2'b0,
            LEN         = 16'd0048,   //32 byte
            ID          = 16'h0,
            FLAG        = 3'h2,
            OFFSET      = 13'h0,
            TTL         = 8'h40,
            PRO         = 8'h11,
            CHECK       = 16'hb689,
            SRC_IP      = 48'hc0_a8_01_7b,
            DES_IP      = 48'hc0_a8_01_66;

            
  //Ports
  reg  wClk;
  reg  wRst;
  reg  wData_Hdr_in_valid;
  wire  wData_Hdr_in_ready;
  reg [47:0] bData_Hdr_in_DstMacAddr;
  reg [47:0] bData_Hdr_in_SrcMacAddr;
  reg [15:0] bData_Hdr_in_FrameType;
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
  wire  wData_out_valid;
  reg  wData_out_ready;
  wire [127:0] bData_out_data;
  wire [15:0] bData_out_keep;
  wire  wData_out_last;
  wire [31:0] bEarlyTerminate_packet_cnt;
  wire [31:0] bUnsupportIpType_cnt;
  wire [31:0] bBadCheckSum_packet_cnt;

  reg [127:0] mem ;



  initial begin
    wRst = 1;
    wClk = 1;
    #100;
    wRst = 0;
    #50;

    @(posedge wClk);
    wData_in_valid = 1;
    bData_in_data = mem;
    bData_in_keep = 16'hffff;
    @(posedge wClk);
    wData_in_valid = 1;
    bData_in_data = 1;
    bData_in_keep = 16'hffff;
    @(posedge wClk);
    wData_in_valid = 1;
    bData_in_data = 2;
    bData_in_keep = 16'hffff;
    wData_in_last = 1;

    @(posedge wClk);
    wData_in_last = 0;


#500;
$stop;

  end
  always #5  wClk = ! wClk ;

initial begin
  wData_Hdr_in_valid = 0;
  bData_Hdr_in_DstMacAddr = MAC_ADDR;
  bData_Hdr_in_SrcMacAddr = SRC_ADDR;
  bData_Hdr_in_FrameType  = FRAMR_TYPE;
  wData_Hdr_out_ready = 1;

  wData_out_ready = 1;

  wData_in_valid = 0;
  bData_in_data = 0;
  bData_in_keep = 0;
  wData_in_last = 0;

  #110;
  @(posedge wClk)
  wData_Hdr_in_valid = 1;
  @(posedge wClk)
  wData_Hdr_in_valid = 0;
end

integer i;

initial begin
   mem = {DES_IP,SRC_IP,CHECK,PRO,TTL,OFFSET,FLAG,ID,LEN,ECN,DSCP,IHL,VERSION};

end


IP_rx_process  IP_rx_process_inst (
  .wClk(wClk),
  .wRst(wRst),
  .wData_Hdr_in_valid(wData_Hdr_in_valid),
  .wData_Hdr_in_ready(wData_Hdr_in_ready),
  .bData_Hdr_in_DstMacAddr(bData_Hdr_in_DstMacAddr),
  .bData_Hdr_in_SrcMacAddr(bData_Hdr_in_SrcMacAddr),
  .bData_Hdr_in_FrameType(bData_Hdr_in_FrameType),
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
  .wData_out_valid(wData_out_valid),
  .wData_out_ready(wData_out_ready),
  .bData_out_data(bData_out_data),
  .bData_out_keep(bData_out_keep),
  .wData_out_last(wData_out_last),
  .bEarlyTerminate_packet_cnt(bEarlyTerminate_packet_cnt),
  .bUnsupportIpType_cnt(bUnsupportIpType_cnt),
  .bBadCheckSum_packet_cnt(bBadCheckSum_packet_cnt)
);
endmodule