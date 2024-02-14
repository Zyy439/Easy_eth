`timescale 1ns/1ns
module Mac_rx_process_tb;

  reg  wClk;
  reg  wRst;
  reg  wData_in_valid;
  wire  wData_in_ready;
  reg [127:0] bData_in_data;
  reg [15:0] bData_in_keep;
  reg  wData_in_last;
  wire  wData_out_valid;
  reg  wData_out_ready;
  wire [127:0] bData_out_data;
  wire [15:0] bData_out_keep;
  wire  wData_out_last;
  wire  wData_Hdr_out_valid;
  reg  bData_Hdr_out_ready;
  wire [47:0] bData_Hdr_out_DstMacAddr;
  wire [47:0] bData_Hdr_out_SrcMacAddr;
  wire [15:0] bData_Hdr_out_FrameType;

  Mac_rx_process  Mac_rx_process_inst (
    .wClk(wClk),
    .wRst(wRst),
    .wData_in_valid(wData_in_valid),
    .wData_in_ready(wData_in_ready),
    .bData_in_data(bData_in_data),
    .bData_in_keep(bData_in_keep),
    .wData_in_last(wData_in_last),
    .wData_out_valid(wData_out_valid),
    .wData_out_ready(wData_out_ready),
    .bData_out_data(bData_out_data),
    .bData_out_keep(bData_out_keep),
    .wData_out_last(wData_out_last),
    .wData_Hdr_out_valid(wData_Hdr_out_valid),
    .bData_Hdr_out_ready(bData_Hdr_out_ready),
    .bData_Hdr_out_DstMacAddr(bData_Hdr_out_DstMacAddr),
    .bData_Hdr_out_SrcMacAddr(bData_Hdr_out_SrcMacAddr),
    .bData_Hdr_out_FrameType(bData_Hdr_out_FrameType)
  );


initial begin
  wRst = 1;
  wClk = 1;
  #100;
  wRst = 0;
end
always #5  wClk = ! wClk ;

initial begin
  wData_in_valid = 0;
  bData_in_data = 0;
  bData_in_keep = 0;
  wData_in_last = 0;
  bData_Hdr_out_ready = 1; 
  wData_out_ready = 0;

end


initial begin
  #200;
  rx_data;
  #500;
  rx_data;
  #500;
  $stop;
end

task rx_data;
integer i;
begin
  @(posedge wClk);
  wData_in_valid = 1;

  @(posedge wClk);
  wData_out_ready = 1;
  wData_in_valid = 1;
  bData_in_data = {16'h5a_a5,48'h0123456789,48'h9876543210};
  bData_in_keep = 16'hffff;


  @(posedge wClk);
  bData_in_data = {32{4'h1}};
  bData_in_keep = 16'hffff;

  for ( i=0 ;i<10 ; i=i+1) begin
    @(posedge wClk);
    bData_in_data = i;
  end
  @(posedge wClk);
  bData_in_data = {32{4'hf}};
  wData_in_last = 1;
  bData_in_keep = 16'h0fff;


  @(posedge wClk);
  bData_in_keep = 0;
  wData_in_last = 0;
  wData_out_ready =0;
  wData_in_valid = 0;


end
endtask


//1
// always  @(*)begin
//   if(wData_Hdr_out_valid)
//   bData_Hdr_out_ready = 1;
//   else
//   bData_Hdr_out_ready = 0;

// end

//2
// always  @(*)begin
//  if(wData_in_valid)
//     bData_Hdr_out_ready = 1;
//   else  if(bData_Hdr_out_ready)
//     bData_Hdr_out_ready = 0;
// end

endmodule