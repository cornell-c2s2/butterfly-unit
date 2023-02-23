`ifndef PROJECT_BUTTERFLY_V
`define PROJECT_BUTTERFLY_V
`include "../../../fixedpt-iterative-complex-multiplier/sim/cmultiplier/FpcmultVRTL.v"
module ButterflyVRTL
#(
	parameter n = 32,
	parameter d = 16,
	parameter mult = 1 // 1 if we include the multiplication of w (saves area as w is usually 1)
) (clk, reset, recv_val, recv_rdy, send_val, send_rdy, ar, ac, br, bc, wr, wc, cr, cc, dr, dc);
	/* performs the butterfly operation, equivalent to doing
		| 1  w |   | a |   | c |
		| 1 -w | * | b | = | d |
	*/

	input logic clk, reset;
	input logic recv_val, send_rdy;
	input logic [n-1:0] ar, ac, br, bc, wr, wc;
	output logic send_val, recv_rdy;
	output logic [n-1:0] cr, cc, dr, dc;

	logic [n-1:0] ar_reg, ac_reg;

	logic mul_rdy;
	logic [n-1:0] tr, tc;


	FpcmultVRTL #(.n(n), .d(d)) mul ( // ar * br
        .clk(clk),
        .reset(reset),
        .ar(br),
        .ac(bc),
        .br(wr),
        .bc(wc),
        .cr(tr),
        .cc(tc),
        .recv_val(recv_val),
        .recv_rdy(recv_rdy),
        .send_val(send_val),
        .send_rdy(send_rdy)
            );

	always@(posedge clk) begin
		if(reset) begin
			ar_reg = 0;
			ac_reg = 0;
		end else if(recv_rdy) begin
			ar_reg = ar;
			ac_reg = ac;
		end else begin
			ar_reg = ar_reg;
			ac_reg = ac_reg;
		end
	end

	assign cr = ar_reg + tr;
	assign cc = ac_reg + tc;
	assign dr = ar_reg - tr;
	assign dc = ac_reg - tc;
endmodule
`endif
