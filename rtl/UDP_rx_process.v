//
// Verilog Module UDP_layer_lib.UDP_rx_process
//
// Created:
//          by - Administrator.UNKNOWN (WIN-P4J5GE79P21)
//          at - 14:30:00 2024/01/29
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

//written by ZYY @2023/01/29
//Copyright belongs to ChangSha JiingJia micro Crop. 
//for personal learning scenario only

`resetall
`timescale 1ns/10ps

/*
`define UDP_DROP_EARLY_TERMINATE_FRAME
`define UDP_DROP_BAD_CHECKSUM
*/

module UDP_rx_process
(
	//clock & reset
	input								wClk							,
	input								wRst							,
		
	//incoming ip frame header	
	input								wData_Hdr_in_valid				,
	output	reg							wData_Hdr_in_ready				,
	input		[47:0]					bData_Hdr_in_MacDstMacAddr		,
	input		[47:0]					bData_Hdr_in_MacSrcMacAddr		,
	input		[15:0]					bData_Hdr_in_MacFrameType		,
	input		[3:0]					bData_Hdr_in_IPVersion			,
	input		[3:0]					bData_Hdr_in_IPIhl				,
	input		[5:0]					bData_Hdr_in_IPDscp				,
	input		[1:0]					bData_Hdr_in_IPEcn				,
	input		[15:0]					bData_Hdr_in_IPLength			,
	input		[15:0]					bData_Hdr_in_IPIdentification	,
	input		[2:0]					bData_Hdr_in_IPFlag				,
	input		[12:0]					bData_Hdr_in_IPFragOffset		,
	input		[7:0]					bData_Hdr_in_IPTimeToLive		,
	input		[7:0]					bData_Hdr_in_IPProtocol			,
	input		[15:0]					bData_Hdr_in_IPCheckSum			,
	input		[31:0]					bData_Hdr_in_IPSrcIpAddr		,
	input		[31:0]					bData_Hdr_in_IPDstIpAddr		,
		
	//incoming ip frame payload	
	input								wData_in_valid					,
	output	reg							wData_in_ready					,
	input		[127:0]					bData_in_data					,
	input		[15:0]					bData_in_keep					,
	input								wData_in_last					,
		
	//output UDP frame header	
	output	reg							wData_Hdr_out_valid				,
	input								wData_Hdr_out_ready				,
	output	reg	[47:0]					bData_Hdr_out_MacDstMacAddr		,
	output	reg	[47:0]					bData_Hdr_out_MacSrcMacAddr		,
	output	reg	[15:0]					bData_Hdr_out_MacFrameType		,
	output	reg	[3:0]					bData_Hdr_out_IPVersion			,
	output	reg	[3:0]					bData_Hdr_out_IPIhl				,
	output	reg	[5:0]					bData_Hdr_out_IPDscp			,
	output	reg	[1:0]					bData_Hdr_out_IPEcn				,
	output	reg	[15:0]					bData_Hdr_out_IPLength			,
	output	reg	[15:0]					bData_Hdr_out_IPIdentification	,
	output	reg	[2:0]					bData_Hdr_out_IPFlag			,
	output	reg	[12:0]					bData_Hdr_out_IPFragOffset		,
	output	reg	[7:0]					bData_Hdr_out_IPTimeToLive		,
	output	reg	[7:0]					bData_Hdr_out_IPProtocol		,
	output	reg	[15:0]					bData_Hdr_out_IPCheckSum		,
	output	reg	[31:0]					bData_Hdr_out_IPSrcIpAddr		,
	output	reg	[31:0]					bData_Hdr_out_IPDstIpAddr		,
	output	reg	[15:0]					bData_Hdr_out_UDPSrcPort		,
	output	reg	[15:0]					bData_Hdr_out_UDPDstPort		,
	output	reg	[15:0]					bData_Hdr_out_UDPLength			,
	output	reg	[15:0]					bData_Hdr_out_UDPCheckSum		,
	
	//output UDP frame payload	
	output	reg							wData_out_valid					,
	input 								wData_out_ready					,
	output	reg	[127:0]					bData_out_data					,
	output	reg	[15:0]					bData_out_keep					,
	output	reg							wData_out_last					,	
	
	//sideband signals
	output	reg	[31:0]					bEarlyTerminate_packet_cnt		
);

//-------------------------------------------------------------------------------------------------------
//parameter define
localparam		HDR_SIZE 	= 	 8		;		
localparam		KEEP_WIDTH 	= 	 16		;
localparam		OFFSET 		= 	 HDR_SIZE % KEEP_WIDTH	;

localparam		STATE_IDLE			=	0		;
localparam		STATE_READ_HEADER	=	1		;
localparam		STATE_READ_PAYLOAD	=	2		;


//-------------------------------------------------------------------------------------------------------
//signal define
reg		[127:0]		bData_in_data_sync 			= 0				;
reg		[15:0]		bData_in_keep_sync			= 0				;
reg		[31:0]		bData_length_cnt			= 0				;
reg		[2:0]		bState_current				= STATE_IDLE	;
reg		[2:0]		bState_next									; //it's actually a wire
reg		[2:0]		bHeader_index				= 0				;
reg					wNeedExtra_cycle			= 0				;
reg					wData_Hdr_out_valid_temp	= 0				;
reg					wDrop_flag_EarlyTerminate	= 0 			;


wire 	[15:0]		bUDPLength_temp					;
wire				wEarlyHeadTerminate_packet_flag	;
wire				wEarlyPayloadTerminate_flag		;
wire				wDrop_flag						;

//-------------------------------------------------------------------------------------------------------
//									IP Frame Analyses
//-------------------------------------------------------------------------------------------------------
/*
 IP_V4 Frame

 Field                       Length
 Field                       Length
 Destination MAC address     6 octets
 Source MAC address          6 octets
 Ethertype (0x0800)          2 octets
 Version (4)                 4 bits
 IHL (5-15)                  4 bits
 DSCP (0)                    6 bits
 ECN (0)                     2 bits
 length                      2 octets
 identification (0?)         2 octets
 flags (010)                 3 bits
 fragment offset (0)         13 bits
 time to live (64?)          1 octet
 protocol                    1 octet
 header checksum             2 octets
 source IP                   4 octets
 destination IP              4 octets
 options                     (IHL-5)*4 octets
 source port				 2 octets
 destination port			 2 octets
 length						 2 octets
 checksum					 2 octets
 payload                     length octets
 
*/

/*
incoming data format(header shall always come one tap ahead)

HEADER
valid	____/--\_____________________________
ready	______/\_____________________________
info	XXXX____XXXXXXXXXXXXXXXXXXXXXXXXXXXXX

PAYLOAD
valid	________/-----------------------\____
ready	________/-----------------------\____
info	XXXXXXXX________________________XXXXX
*/

//-------------------------------------------------------------------------------------------------------
//state machine
always @(posedge wClk)begin
	if(wRst)begin
		bState_current	<=		STATE_IDLE		;
	end
	else begin
		bState_current	<=		bState_next		;
	end
end

always @(*)begin
	if(wRst)begin
		bState_next		=		STATE_IDLE		;
	end
	else begin
		case(bState_current)
		
			STATE_IDLE:begin
				if(wData_Hdr_in_valid & wData_Hdr_in_ready)begin
					bState_next	= STATE_READ_HEADER	;
				end
				else begin
					bState_next	= STATE_IDLE ;
				end
			end
			
			STATE_READ_HEADER:begin
				if(wData_in_ready && wData_in_valid && wEarlyHeadTerminate_packet_flag)begin
					bState_next	= STATE_IDLE ;
				end
				else if(wData_in_ready && wData_in_valid)begin
					bState_next	= STATE_READ_PAYLOAD ;
				end
				else begin
					bState_next	= STATE_READ_HEADER ;
				end
			end
			
			STATE_READ_PAYLOAD:begin
				if(wData_out_ready && (wData_out_valid | wDrop_flag) && wData_out_last)begin
					bState_next	= STATE_IDLE ;
				end
				else begin
					bState_next	= STATE_READ_PAYLOAD ;
				end
			end
			
			default:begin
				bState_next	= STATE_IDLE ;
			end
			
		endcase
	end
end

//-------------------------------------------------------------------------------------------------------
//										Header Information Exrtract
//-------------------------------------------------------------------------------------------------------
//header ready signal
always @(*)begin
	if(wData_Hdr_in_valid && (bState_current == STATE_IDLE))begin
		wData_Hdr_in_ready	=	1'b1	;
	end
	else begin
		wData_Hdr_in_ready	=	1'b0	;
	end
end

//header index to indicate which segment we are loading at the moment
always @(posedge wClk)begin
	if(wRst)begin
		bHeader_index	<=	'd0	;
	end
	else if((wData_in_valid & wData_in_ready) && (bState_current==STATE_READ_HEADER))begin
		if(bHeader_index >= 1)begin
			bHeader_index	<=	'd0	;
		end
		else begin
			bHeader_index	<=	bHeader_index + 1	;
		end
	end
end

//loading incoming mac headder information
always @(posedge wClk)begin
	if(wData_Hdr_in_valid & wData_Hdr_in_ready)begin
		bData_Hdr_out_MacDstMacAddr		<=	bData_Hdr_in_MacDstMacAddr		;
		bData_Hdr_out_MacSrcMacAddr		<=	bData_Hdr_in_MacSrcMacAddr		;
		bData_Hdr_out_MacFrameType		<=	bData_Hdr_in_MacFrameType		;
		bData_Hdr_out_IPVersion			<=	bData_Hdr_in_IPVersion			;
		bData_Hdr_out_IPIhl				<=	bData_Hdr_in_IPIhl				;
		bData_Hdr_out_IPDscp			<=	bData_Hdr_in_IPDscp			    ;
		bData_Hdr_out_IPEcn				<=	bData_Hdr_in_IPEcn				;
		bData_Hdr_out_IPLength			<=	bData_Hdr_in_IPLength			;
		bData_Hdr_out_IPIdentification	<=	bData_Hdr_in_IPIdentification	;
		bData_Hdr_out_IPFlag			<=	bData_Hdr_in_IPFlag			    ;
		bData_Hdr_out_IPFragOffset		<=	bData_Hdr_in_IPFragOffset		;
		bData_Hdr_out_IPTimeToLive		<=	bData_Hdr_in_IPTimeToLive		;
		bData_Hdr_out_IPProtocol		<=	bData_Hdr_in_IPProtocol		    ;
		bData_Hdr_out_IPCheckSum		<=	bData_Hdr_in_IPCheckSum		    ;
		bData_Hdr_out_IPSrcIpAddr		<=	bData_Hdr_in_IPSrcIpAddr		;
	end
	else begin
		bData_Hdr_out_MacDstMacAddr		<=	bData_Hdr_out_MacDstMacAddr		;
		bData_Hdr_out_MacSrcMacAddr		<=	bData_Hdr_out_MacSrcMacAddr		;
		bData_Hdr_out_MacFrameType		<=	bData_Hdr_out_MacFrameType		;
		bData_Hdr_out_IPVersion			<=  bData_Hdr_out_IPVersion			;
		bData_Hdr_out_IPIhl				<=  bData_Hdr_out_IPIhl				;
		bData_Hdr_out_IPDscp			<=  bData_Hdr_out_IPDscp			;
		bData_Hdr_out_IPEcn				<=  bData_Hdr_out_IPEcn				;
		bData_Hdr_out_IPLength			<=  bData_Hdr_out_IPLength			;
		bData_Hdr_out_IPIdentification	<=  bData_Hdr_out_IPIdentification	;
		bData_Hdr_out_IPFlag			<=  bData_Hdr_out_IPFlag			;
		bData_Hdr_out_IPFragOffset		<=  bData_Hdr_out_IPFragOffset		;
		bData_Hdr_out_IPTimeToLive		<=  bData_Hdr_out_IPTimeToLive		;
		bData_Hdr_out_IPProtocol		<=  bData_Hdr_out_IPProtocol		;
		bData_Hdr_out_IPCheckSum		<=  bData_Hdr_out_IPCheckSum		;
		bData_Hdr_out_IPSrcIpAddr		<=  bData_Hdr_out_IPSrcIpAddr		;
	end
end

//extract IP header information in the STATE_READ_HEADER state
always @(posedge wClk)begin
	if((bState_current==STATE_READ_HEADER) && wData_in_ready && wData_in_valid)begin
		bData_Hdr_out_UDPSrcPort		<=		bData_in_data[15:0]		;
		bData_Hdr_out_UDPDstPort		<=		bData_in_data[31:16]	;
		bData_Hdr_out_UDPLength			<=		bData_in_data[47:32]	;
		bData_Hdr_out_UDPCheckSum		<=		bData_in_data[63:48]	;
	end
end

//=======================================================================================================
//										Data output path
//=======================================================================================================
//-------------------------------------------HEADER------------------------------------------------------
//header output valid signal, it will be asserted high at the first tap of STATE_READ_PAYLOAD state
//this signal is still not the final output. we do not asser it if it is a bad frame
always @(posedge wClk)begin
	if(wRst)begin
		wData_Hdr_out_valid_temp	<=	1'b0	;
	end
	else if((wData_Hdr_out_valid_temp & wData_in_ready) || (bState_current == STATE_IDLE))begin
		wData_Hdr_out_valid_temp	<=	1'b0	;
	end
	//else if(wData_in_ready && wData_in_valid && (bState_current == STATE_READ_HEADER) && (bHeader_index >= 1))begin
	else if(wData_in_ready && wData_in_valid && (bState_current == STATE_READ_HEADER) && (bHeader_index >= 1))begin
		wData_Hdr_out_valid_temp	<=	1'b1	;
	end
end

//real data hdr out valid signal
always @(*)begin
	if(wRst)begin
		wData_Hdr_out_valid = 0	;
	end
	else begin
		wData_Hdr_out_valid = wData_Hdr_out_valid_temp & (!wDrop_flag)	;
	end
end


//-------------------------------------------PAYLOAD-----------------------------------------------------
//synchronization of the incoming data, it will be utilized in the offset shift stage
always @(posedge wClk)begin
	if(wRst)begin
		bData_in_data_sync	<=	'd0			;
		bData_in_keep_sync	<=	'd0			;
	end
	else if(wData_in_valid && wData_in_ready)begin
		bData_in_data_sync	<=	bData_in_data		;
		bData_in_keep_sync	<=	bData_in_keep		;
	end
end

//decide when to end an payload output
always @(posedge wClk)begin
	if(wRst)begin
		wData_out_last	<=	1'b0	;
	end
	else begin
		wData_out_last	<=	(wData_in_last && ((bData_in_keep & ({16{1'b1}} << OFFSET)) == 0)) || wNeedExtra_cycle;
	end
end

//sometimes we need extra clock cycle to complete the whole transfer of the entire frame
always @(posedge wClk)begin
	if(wRst)begin
		wNeedExtra_cycle	<=	1'b0	;
	end
	else begin
		wNeedExtra_cycle	<=	wData_in_last && ((bData_in_keep & ({16{1'b1}} << OFFSET)) != 0);
	end
end

//deciede the keep signal accordingly(whether we need an extra cycle or not)
always @(posedge wClk)begin
	if(wRst)begin
		bData_out_keep	<=	'd0	;
	end
	else if(wNeedExtra_cycle)begin
		bData_out_keep	<=	{{16{1'b1}},bData_in_keep_sync} >> (OFFSET);
	end
	else begin
		bData_out_keep	<=	{bData_in_keep,bData_in_keep_sync} >> (OFFSET);
	end
end

//offfset shift is needed as we do not want head info any more
always @(posedge wClk)begin
	if(wRst)begin
		bData_out_data	<=	1'b0	;
	end
	else begin
		bData_out_data	<=	{bData_in_data,bData_in_data_sync} >> (OFFSET*8);
		
	end
end

//payload data output valid signal, it shall be asserted only after a valid
//header is successfully sent
always @(posedge wClk)begin
	if(wRst)begin
		wData_out_valid	<=	1'b0	;
	end
	else if(wData_Hdr_out_valid & wData_Hdr_out_ready)begin
		wData_out_valid	<=	1'b1	;
	end
	else if(wData_out_last & wData_out_valid & wData_out_ready)begin
		wData_out_valid	<=	1'b0	;
	end
end

//data iun ready signal, it shall not be asserted the IDLE state
always @(*)begin
	wData_in_ready = (bState_current != STATE_IDLE) && wData_out_ready && (wData_Hdr_out_ready | (!wData_Hdr_out_valid));
end


//=======================================================================================================
//										Function Keep2Count
//=======================================================================================================
function [4:0]	keep2count;
	input [15:0] k;
	if(k[7]==1)begin
		keep2count = keep2count_sub(k[15:8]) + 8;
	end
	else begin
		keep2count = keep2count_sub(k[7:0]);
	end
endfunction

function [3:0]	keep2count_sub;
	input [7:0] k;
	casez(k)
		8'bzzzzzzz0: keep2count_sub = 4'd0;
		8'bzzzzzz01: keep2count_sub = 4'd1;
		8'bzzzzz011: keep2count_sub = 4'd2;
		8'bzzzz0111: keep2count_sub = 4'd3;
		8'bzzz01111: keep2count_sub = 4'd4;
		8'bzz011111: keep2count_sub = 4'd5;
		8'bz0111111: keep2count_sub = 4'd6;
		8'b01111111: keep2count_sub = 4'd7;
		8'b11111111: keep2count_sub = 4'd8;
	endcase
endfunction


//=======================================================================================================
//										Abnormal frame statistics 
//=======================================================================================================
//---------------------------------------EARLY HEADER TERMINATE------------------------------------------
//we need to discard those early terminate frames
assign	bUDPLength_temp = {bData_in_data[39:32],bData_in_data[47:40]}	; //save the UDP length at first, be noted that its in little endian
assign	wEarlyHeadTerminate_packet_flag = ((bUDPLength_temp - 8) != keep2count(bData_in_keep)) && wData_in_last;

//we shall asser the drop flag signal once we find a frame terminates too early at the header stage~ ,and
//thus we can drop them by not sending header valid signal, the payload wont be sent either if the header of the frame is not sent
always @(posedge wClk)begin
	if(wRst)begin
		wDrop_flag_EarlyTerminate	<=	0	;
	end
	else if(wDrop_flag_EarlyTerminate)begin
		wDrop_flag_EarlyTerminate	<=	0	;
	end
	else if((bState_current==STATE_READ_HEADER) && wData_in_ready && wData_in_valid && wEarlyHeadTerminate_packet_flag)begin
		wDrop_flag_EarlyTerminate	<=	1	;
	end
end

assign wDrop_flag = wDrop_flag_EarlyTerminate	;

//---------------------------------------EARLY PAYLOAD TERMINATE-----------------------------------------
//we can onlyl drop those frames terminate early in the header stage, for thouse frames
//terminate abnormally, since we have sent their data to next module, we can not do shit on them, just let it go
//however, we can still detect this and statistic~ report this to the registers and thus the processors will know

//firstly we count the amount of data sent
always @(posedge wClk)begin
	if(wRst)begin
		bData_length_cnt	<=	0	;
	end
	else if(wData_in_valid & wData_in_ready & wData_in_last)begin
		bData_length_cnt	<=	0	;
	end
	else if(wData_in_valid & wData_in_ready)begin
		bData_length_cnt	<=	bData_length_cnt + 16	;
	end
end

assign wEarlyPayloadTerminate_flag = wData_in_last & ((bData_length_cnt+keep2count(bData_in_keep)) != {bData_Hdr_out_UDPLength[7:0],bData_Hdr_out_UDPLength[15:8]});

//---------------------------------------EARLY TERMINATE STATISTIC--------------------------------------
//count the early terminate packet and then report it to the registers.(altogether with header early terminate)
always @(posedge wClk)begin
	if(wRst)begin
		bEarlyTerminate_packet_cnt	<=	'd0				;
	end
	else if(wEarlyHeadTerminate_packet_flag & (bState_current==STATE_READ_HEADER) & wData_in_ready & wData_in_valid)begin
		bEarlyTerminate_packet_cnt	<=	bEarlyTerminate_packet_cnt + 1	;
	end
	else if(wEarlyPayloadTerminate_flag & (bState_current==STATE_READ_PAYLOAD) & wData_in_ready & wData_in_valid)begin
		bEarlyTerminate_packet_cnt	<=	bEarlyTerminate_packet_cnt + 1	;	
	end
end

endmodule
