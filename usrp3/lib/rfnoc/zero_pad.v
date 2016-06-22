module zero_pad #(
  parameter WIDTH=32,
  parameter OUT_L=32
)(
  input clk, input reset,
//  input vector_mode,
//  input [$clog2(MAX_N+1)-1:0] n,
  input [WIDTH-1:0] i_tdata, input i_tlast, input i_tvalid, output i_tready,
  output [WIDTH-1:0] o_tdata, output o_tlast, output o_tvalid, input o_tready
);
  /* Simple Loopback */
/*	assign m_axis_data_tready = s_axis_data_tready;
  assign s_axis_data_tvalid = m_axis_data_tvalid;
  assign s_axis_data_tlast  = m_axis_data_tlast;
  assign s_axis_data_tdata  = m_axis_data_tdata;
*/
reg [WIDTH-1:0] sample_cnt;
reg zeropadding;
reg last;

always @(posedge clk) begin
	if (reset) begin
		sample_cnt <= 0;
		zeropadding <= 0;
		last <= 0;
	end else begin
		if (i_tvalid) begin
			sample_cnt <= sample_cnt + 1'd1;
		end
		if (i_tlast) begin
			zeropadding <= 1;
		end
		if (sample_cnt == (OUT_L-1)) begin
			zeropadding <= 0;
			last <= 1;
		end else begin
			last <= 0;
		end
	end
end

wire [WIDTH-1:0] scount;
assign o_tdata  = (~zeropadding) ? i_tdata : 0;
//assign o_tdata = 32'hdeadbeef;
assign i_tready = (o_tready & ~zeropadding);
assign o_tlast  = last;
assign o_tvalid = (~zeropadding) ? i_tvalid : 1;

endmodule
