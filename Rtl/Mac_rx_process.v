//
// Verilog Module Mac_layer_lib.Mac_rx_process
//
// Created:
//          by - Administrator.UNKNOWN (WIN-P4J5GE79P21)
//          at - 17:52:00 2023/12/30
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

//written by ZYY @2023/12/30
//Copyright belongs to ChangSha JiingJia micro Crop. 
//for personal learning scenario only

`resetall
`timescale 1ns/10ps
module Mac_rx_process
(
	
	//clock & reset
	input								wClk						,
	input								wRst						,
	
	//AXI-stream ethernet data input  (frame filter is utilized in the front by defalut. user signal is therefore deleted)
	input								wData_in_valid				,
	output								wData_in_ready				,
	input		[127:0]					bData_in_data				,
	input		[15:0]					bData_in_keep				,
	input								wData_in_last				,
	
	//----------------------------------------------------------------
	//IP frame port
	//AXI-stream ethernet data output
	output	reg							wData_out_valid				,
	input 								wData_out_ready				,
	output	reg	[127:0]					bData_out_data				,
	output	reg	[15:0]					bData_out_keep				,
	output	reg							wData_out_last				,
	
	//output header signals
	output	reg							wData_Hdr_out_valid			,
	input								bData_Hdr_out_ready			,
	output	reg	[47:0]					bData_Hdr_out_DstMacAddr	,
	output	reg	[47:0]					bData_Hdr_out_SrcMacAddr	,
	output	reg	[15:0]					bData_Hdr_out_FrameType		
	
	
);

//-------------------------------------------------------------------------------------------------------
//parameter define
localparam		HDR_SIZE 	= 	 14		;		
localparam		KEEP_WIDTH 	= 	 16		;
localparam		OFFSET 		= 	 HDR_SIZE % KEEP_WIDTH	;

//-------------------------------------------------------------------------------------------------------
//signal define
reg				bMac_counter 		= 0		;
reg				wNeedExtra_cycle	= 0		;
reg	[127:0]		bData_in_data_sync 	= 0		;
reg	[15:0]		bData_in_keep_sync	= 0		;


//-------------------------------------------------------------------------------------------------------
//									Ethernet Frame Analyses
//-------------------------------------------------------------------------------------------------------
/*
 Ethernet Frame

 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype (0x0800)          2 octets
 payload                     length octets
*/
//mac info analysis
always @(posedge wClk)begin
	if(wRst)begin
		bMac_counter	<=		'd0		;
	end
	else if(wData_in_valid && wData_in_ready && wData_in_last)begin
		bMac_counter	<=		'd0		;
	end
	else if(wData_in_valid && wData_in_ready)begin
		bMac_counter	<=		'd1		;
	end
end

always @(posedge wClk)begin
	if(wRst)begin
		bData_Hdr_out_DstMacAddr	<=	'd0						;
		bData_Hdr_out_SrcMacAddr	<=	'd0						;
		bData_Hdr_out_FrameType		<=	'd0						;
	end
	else if((bMac_counter == 0) && wData_in_valid && wData_in_ready)begin
		bData_Hdr_out_DstMacAddr	<=	bData_in_data[47:0]		;
		bData_Hdr_out_SrcMacAddr	<=	bData_in_data[95:48]	;
		bData_Hdr_out_FrameType		<=	bData_in_data[111:96]	;
	end
end

//header info output
always @(posedge wClk)begin
	if(wRst)begin
		wData_Hdr_out_valid		<=	1'b0	;
	end	
	else if(wData_Hdr_out_valid & bData_Hdr_out_ready)begin
		wData_Hdr_out_valid		<=	1'b0	;
	end
	else if((bMac_counter == 0) && wData_in_valid)begin
		wData_Hdr_out_valid		<=	1'b1	;
	end
end

//-------------------------------------------------------------------------------------------------------
//										Payload Output
//-------------------------------------------------------------------------------------------------------
//send payload after header info being successfully sent
always @(posedge wClk)begin
	if(wRst)begin
		wData_out_valid		<=	1'd0	;
	end
	else if(wData_Hdr_out_valid & bData_Hdr_out_ready)begin
		wData_out_valid		<=	1'd1	;  
	end
	else if(wData_out_valid && wData_in_ready && wData_out_last)begin
		wData_out_valid		<=	1'd0	;
	end
end

//ready signal of the incoming axi-streaming interface shall be asserted when both output ports are ready
assign	wData_in_ready	=	wData_out_ready	& (bData_Hdr_out_ready | (!wData_Hdr_out_valid))	;

//synchronization of the incoming data , will be utilized in the offset shift stage
always @(posedge wClk)begin
	if(wRst)begin
		bData_in_data_sync	<=	'd0				;
		bData_in_keep_sync	<=	'd0				;
	end
	else if(wData_in_valid && wData_in_ready)begin
		bData_in_data_sync	<=	bData_in_data	;
		bData_in_keep_sync	<=	bData_in_keep	;
	end
end

//offset shift is needed as we do not want head info any more
always @(posedge wClk)begin
	if(wRst)begin
		bData_out_data	<=	'd0		;
	end
	else begin
		bData_out_data	<=	{bData_in_data,bData_in_data_sync} >> (OFFSET*8)	;
		
	end
end

//decide when to end an payload output
always @(posedge wClk)begin
	if(wRst)begin
		wData_out_last	<=	1'b0	;
	end
	else begin
		wData_out_last	<=	(wData_in_last && ((bData_in_keep & ({16{1'b1}} << OFFSET)) == 0))  || 	wNeedExtra_cycle;
	end
end

//sometimes we need extra clock cycle to complete the whole transfer of the entire frame
always @(posedge wClk)begin
	if(wRst)begin
		wNeedExtra_cycle	<=	1'b0	;
	end
	else begin
		wNeedExtra_cycle	<=	wData_in_last && ((bData_in_keep & ({16{1'b1}} << OFFSET)) != 0)	;
	end
end

//decide the keep signal accordingly (whether we need an extra cycle or not)
always @(posedge wClk)begin
	if(wRst)begin
		bData_out_keep	<=	'd0	;
	end
	else if(wNeedExtra_cycle)begin
		bData_out_keep	<=	{{16{1'b0}},bData_in_keep_sync} >> (OFFSET)	;
	end
	else begin
		bData_out_keep	<=	{bData_in_keep,bData_in_keep_sync} >> (OFFSET)		;
	end
end

endmodule
