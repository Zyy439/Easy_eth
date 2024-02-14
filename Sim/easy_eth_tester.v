//
// Verilog Module easy_tester_lib.easy_eth_tester
//
// Created:
//          by - Administrator.UNKNOWN (WIN-P4J5GE79P21)
//          at - 15:35:30 2023/12/31
//
// using Mentor Graphics HDL Designer(TM) 2021.1 Built on 14 Jan 2021 at 15:11:42
//

`resetall
`timescale 1ns/10ps
module easy_eth_tester #
(
	parameter		FRAME_LENGTH	=	10	,
	parameter		FRAME_GAP		=	3	
)
(
	//clock and reset
	output	reg					wClk				,
	output	reg					wRst				,
	
	//Axi-stream ethernet data output 
	output	reg					wAxis_eth_valid		,
	input						wAxis_eth_ready		,
	output	reg	[127:0]			bAxis_eth_data		,
	output 	reg	[15:0]			bAxis_eth_keep		,
	output	reg					wAxis_eth_last		
	
);


//------------------------------------------------------------------
//generate a 100MHz clock
always #5 wClk	<=	~wClk	;

//==================================================================
//				TEST SOURCE IN AXI STREAM INTERFACE
//==================================================================
//------------------------------------------------------------------
//signal define
reg	[31:0]		bFrame_counter	= 0	;
reg	[31:0]		bGap_counter	= 0	;
reg				wSend_en		= 0	;

//------------------------------------------------------------------
//signal define
//`define  _NO_FRAME_GAP

//output ethernet frame data when send enable signal is asserted
`ifdef 	 _NO_FRAME_GAP
always @(posedge wClk)begin
	if(wRst)begin
		wSend_en	<=	1'b0	;
	end
	else begin
		wSend_en	<=	1'b1	;
	end
end
`else
always @(posedge wClk)begin
	if(wRst)begin
		wSend_en	<=	1'b0		;
	end
	else if((bGap_counter >= FRAME_GAP-1) && (!wSend_en))begin
		wSend_en	<=	1'b1		;
	end
	else if((bFrame_counter >= FRAME_LENGTH-1) && (wSend_en))begin
		wSend_en	<=	1'b0		;
	end
end
`endif

always @(posedge wClk)begin
	if(wRst)begin
		bFrame_counter	<=	'd0			;
	end
	else if((bFrame_counter >= FRAME_LENGTH-1) && (wSend_en))begin
		bFrame_counter	<=	'd0			;
	end
	//else if(wSend_en)begin
	else if(wAxis_eth_valid & wAxis_eth_ready)begin
		bFrame_counter	<=	bFrame_counter + 1	;
	end
end	

always @(posedge wClk)begin
	if(wRst)begin
		bGap_counter	<=	'd0			;
	end
	else if((bGap_counter >= FRAME_GAP-1) && (!wSend_en))begin
		bGap_counter	<=	'd0			;
	end
	else if(!wSend_en)begin
		bGap_counter	<=	bGap_counter + 1	;
	end
end	

always @* begin
	if(wRst)begin
		wAxis_eth_valid	=	0			;
	end
	else begin
		wAxis_eth_valid	=	wSend_en	;
	end
end

//data output
/*
always @(posedge wClk)begin
	if(wRst)begin
		bAxis_eth_data	<=	'd0	;
	end
	else if(wAxis_eth_valid	& wAxis_eth_ready & wAxis_eth_last)begin
		bAxis_eth_data	<=	'd0	;
	end
	else if(wAxis_eth_valid	& wAxis_eth_ready)begin
		bAxis_eth_data	<=	bAxis_eth_data + 1;
	end
end	
*/

always @(posedge wClk)begin
	if(wRst)begin
		bAxis_eth_data	<=	'd0	;
	end
	else if(wAxis_eth_valid	& wAxis_eth_ready & wAxis_eth_last)begin
		bAxis_eth_data	<=	'h0	;
	end
	else if(wAxis_eth_valid	& wAxis_eth_ready)begin
		case(bFrame_counter+1)
			32'h1: 	bAxis_eth_data	<=	'h1111_1111_1111_1111_1111_1111_1111_1111	;
			32'h2:	bAxis_eth_data	<=	'h2222_2222_2222_2222_2222_2222_2222_2222	;
			32'h3:	bAxis_eth_data	<=	'h3333_3333_3333_3333_3333_3333_3333_3333	;
			32'h4:	bAxis_eth_data	<=	'h4444_4444_4444_4444_4444_4444_4444_4444	;
			32'h5:	bAxis_eth_data	<=	'h5555_5555_5555_5555_5555_5555_5555_5555	;
			32'h6:	bAxis_eth_data	<=	'h6666_6666_6666_6666_6666_6666_6666_6666	;
			32'h7:	bAxis_eth_data	<=	'h7777_7777_7777_7777_7777_7777_7777_7777	;
			32'h8:	bAxis_eth_data	<=	'h8888_8888_8888_8888_8888_8888_8888_8888	;
			32'h9:	bAxis_eth_data	<=	'h9999_9999_9999_9999_9999_9999_9999_9999	;
			32'ha:	bAxis_eth_data	<=	'hAAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA_AAAA	;
			32'hb:	bAxis_eth_data	<=	'hBBBB_BBBB_BBBB_BBBB_BBBB_BBBB_BBBB_BBBB	;
			32'hc:	bAxis_eth_data	<=	'hCCCC_CCCC_CCCC_CCCC_CCCC_CCCC_CCCC_CCCC	;
			32'hd:	bAxis_eth_data	<=	'hDDDD_DDDD_DDDD_DDDD_DDDD_DDDD_DDDD_DDDD	;
			32'he:	bAxis_eth_data	<=	'hEEEE_EEEE_EEEE_EEEE_EEEE_EEEE_EEEE_EEEE	;
			32'hf:	bAxis_eth_data	<=	'hFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF	;
			
		default:begin
			bAxis_eth_data	<=	'h0	;
			//bAxis_eth_data	<=	'h1111_2222_3333_4444_5555_6666_7777_8888	;
		end
		endcase
	end
end	

//the last signal of shall be set high in the last valid clock cycle of a frame
//we can decide if ther is full keep signal at this time or not
always @(*)begin
	if(wRst)begin
		wAxis_eth_last	=	1'b0		;
		bAxis_eth_keep	=	16'hFFFF	;
	end
	else if((bFrame_counter >= FRAME_LENGTH-1) && wSend_en)begin
		wAxis_eth_last	=	1'b1		;
		bAxis_eth_keep	=	16'h7FFF	;
	end
	else begin
		wAxis_eth_last	=	1'b0		;
		bAxis_eth_keep	=	16'hFFFF	;
	end
end

//==================================================================
//					START TESTER ENGINE
//==================================================================
initial begin
	wClk	<=	1'b1	;
	wRst	<=	1'b1	;
	
	#100
	wRst	<=	1'b0	;
end


endmodule
