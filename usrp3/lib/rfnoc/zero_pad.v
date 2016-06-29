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

reg [2:0] state;
localparam IDLE = 2'd0;
localparam PASSING = 2'd1;
localparam ZERO = 2'd2;
localparam LAST = 2'd3;

always @(posedge clk) begin
	if (reset) begin
		state <= IDLE;
	end else begin
		case(state)
			IDLE: begin
				sample_cnt <= 0;
				if(i_tvalid & o_tready) begin
					state <= PASSING;
				end
			end
			PASSING: begin
				if(i_tvalid & o_tready) begin
					sample_cnt <= sample_cnt + 1'd1;
					if(i_tlast) begin
						state <= ZERO;
					end
				end
			end
			ZERO: begin
				if(o_tready) begin
					sample_cnt <= sample_cnt + 1'd1;
					if(sample_cnt == (OUT_L - 1)) begin
						state <= LAST;
					end
				end

			end
			LAST: begin
				if(o_tready) begin
					state <= IDLE;
				end
			end

		endcase
	end
end

assign o_tdata  = (state==PASSING) ? i_tdata : 0;
//assign o_tdata = 32'hdeadbeef;
assign i_tready = (state==PASSING) ? o_tready : 0;
assign o_tlast  = (state==LAST);
assign o_tvalid = (state==PASSING) ? i_tvalid : ~(state==IDLE);

endmodule
