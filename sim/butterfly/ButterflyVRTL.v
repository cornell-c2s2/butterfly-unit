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

	logic mul_rdy;
	logic [n-1:0] tr, tc;

	if ( mult == 1 ) begin
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
			.recv_rdy(),
			.send_val(mul_rdy),
			.send_rdy(1'b1)
		);
	end else begin
		always @(posedge clk) begin
			if (reset) begin
				mul_rdy <= 0;
			end

			if (~mul_rdy & recv_val) begin
				mul_rdy <= 1;
				tr <= br;
				tc <= bc;
			end

			if (mul_rdy) begin
				mul_rdy <= 0;
			end
		end
	end

	always @(posedge clk) begin
		if (reset) begin
			send_val <= 0;
			recv_rdy <= 1;
		end else if (recv_val & recv_rdy) begin
			cr <= ar;
			cc <= ac;
			dr <= ar;
			dc <= ac;
			recv_rdy <= 0;
			send_val <= 0;
		end else if (~send_val & mul_rdy) begin // all multipliers are done!
			cr <= cr + tr;
			cc <= cc + tc;
			dr <= dr - tr;
			dc <= dc - tc;
			send_val <= 1;
		end else if (~recv_rdy & send_val & send_rdy) begin
			recv_rdy <= 1;
		end
	end
endmodule
`endif
