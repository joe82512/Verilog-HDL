`define CPOL 0
`define CPHA 0
`define CLK_FREQ 50_000_000
`define SCLK_FREQ 5_000_000
`define DATA_WIDTH 8
`define CLK_CYCLE 20



module SPI_SLAVE (
    input clk, rst, mosi, sclk, start, ss_n,
    output [`DATA_WIDTH-1:0] data_out,
    output done
);
    // FSM
    parameter IDLE = 2'd0;
    parameter DATA = 2'd1;
    // parameter KEEP = 2'd2;
    parameter STOP = 2'd3;
    reg [1:0] state, next_state;

    // sclk edge
    reg sclk_delay;
    wire sclk_pos, sclk_neg;
    wire sample_edge;

    // counter data bit
    wire [3:0] cnt_data;
    reg [3:0] cnt_sclk_pos, cnt_sclk_neg;
    reg [`DATA_WIDTH-1:0] data_shift_pos, data_shift_neg; //ouput data
    
    // define sample edge & data
    assign sample_edge = (`CPOL==`CPHA) ? 1'b1 : 1'b0;
    assign cnt_data = sample_edge ? cnt_sclk_pos : cnt_sclk_neg;
    
    // ================== SCLK ==================
    // get SCLK edge
    always @(posedge clk, posedge rst) begin
        sclk_delay <= sclk;
    end
    assign sclk_pos = ( (sclk==1'b1)&&(sclk_delay==1'b0) ) ? 1'b1 : 1'b0;
    assign sclk_neg = ( (sclk==1'b0)&&(sclk_delay==1'b1) ) ? 1'b1 : 1'b0;
    // count SCLK edge
    always @(posedge clk, posedge rst) begin
        if ( (rst)||(state==STOP) ) begin
            cnt_sclk_pos <= 0;
            cnt_sclk_neg <= 0;
        end
        else if (sclk_pos) begin
            cnt_sclk_pos <= cnt_sclk_pos + 1;
            cnt_sclk_neg <= cnt_sclk_neg;
        end
        else if (sclk_neg) begin
            cnt_sclk_pos <= cnt_sclk_pos;
            cnt_sclk_neg <= cnt_sclk_neg + 1;
        end
        else begin
            cnt_sclk_pos <= cnt_sclk_pos;
            cnt_sclk_neg <= cnt_sclk_neg;
        end
    end

    // ================== FSM ==================
    // step 1. trans condition
    always @(*) begin
        case (state)
            IDLE:
                next_state = (start) ? DATA : IDLE;
            DATA: begin
                if ( (cnt_data==`DATA_WIDTH-1) && (!ss_n) && (sample_edge) && (sclk_pos) ) begin
                    next_state <= STOP;
                end
                else if ( (cnt_data==`DATA_WIDTH-1) && (!ss_n) && (~sample_edge) && (sclk_neg) ) begin
                    next_state <= STOP;
                end
                else begin
                    next_state <= DATA;
                end
            end
            STOP:
                next_state = IDLE;
            default:
                next_state = IDLE;
        endcase
    end

    // step 2. state trans
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // step 3. output
    // shift register for posedge or negedge
    always @(posedge clk, posedge rst) begin
        if ( (rst)||(state==STOP) ) begin
            data_shift_pos <= {`DATA_WIDTH{1'b0}};
            data_shift_neg <= {`DATA_WIDTH{1'b0}};
        end
        else if ( (state==DATA) && (sclk_pos) ) begin
            data_shift_pos <= {mosi, data_shift_pos[`DATA_WIDTH-1:1]};
            data_shift_neg <= data_shift_neg;
        end
        else if ( (state==DATA) && (sclk_neg) ) begin
            data_shift_pos <= data_shift_pos;
            data_shift_neg <= {mosi, data_shift_neg[`DATA_WIDTH-1:1]};
        end
        else begin
            data_shift_pos <= data_shift_pos;
            data_shift_neg <= data_shift_neg;
        end
    end
    // get data
    assign data_out = (state==STOP) ? (sample_edge ? data_shift_pos:data_shift_neg) : {`DATA_WIDTH{1'b0}};
    // finish flag
    assign done = (state==STOP);

endmodule



module SPI_MASTER (
    input clk, rst, miso, start,
    input [`DATA_WIDTH-1:0] data_in,
    output mosi, done,
    output reg sclk, ss_n
);
    // FSM
    parameter IDLE = 2'd0;
    parameter DATA = 2'd1;
    parameter KEEP = 2'd2;
    parameter STOP = 2'd3;
    reg [1:0] state, next_state;
    reg start_delay;

    // freq division
    parameter CNT_FREQ = `CLK_FREQ/`SCLK_FREQ - 1; //freq div
    wire sclk_flag; //sclk toggle
    reg [31:0] cnt_clk; //count clk for gen sclk 
    
    // sclk edge
    reg sclk_delay;
    wire sclk_pos, sclk_neg;
    wire sample_edge;

    // counter data bit
    wire [3:0] cnt_data;
    reg [3:0] cnt_sclk_pos, cnt_sclk_neg;
    
    // define sample edge & data
    assign sample_edge = (`CPOL==`CPHA) ? 1'b1 : 1'b0;
    assign cnt_data = sample_edge ? cnt_sclk_pos : cnt_sclk_neg;
    
    // ================== SCLK ==================
    // get SCLK edge
    always @(posedge clk, posedge rst) begin
        sclk_delay <= sclk;
        start_delay <= start;
    end
    assign sclk_pos = ( (sclk==1'b1)&&(sclk_delay==1'b0) ) ? 1'b1 : 1'b0;
    assign sclk_neg = ( (sclk==1'b0)&&(sclk_delay==1'b1) ) ? 1'b1 : 1'b0;
    // count SCLK edge
    always @(posedge clk, posedge rst) begin
        if ( (rst)||(state==STOP) ) begin
            cnt_sclk_pos <= 0;
            cnt_sclk_neg <= 0;
        end
        else if (sclk_pos) begin
            cnt_sclk_pos <= cnt_sclk_pos + 1;
            cnt_sclk_neg <= cnt_sclk_neg;
        end
        else if (sclk_neg) begin
            cnt_sclk_pos <= cnt_sclk_pos;
            cnt_sclk_neg <= cnt_sclk_neg + 1;
        end
        else begin
            cnt_sclk_pos <= cnt_sclk_pos;
            cnt_sclk_neg <= cnt_sclk_neg;
        end
    end

    // ================== FSM ==================
    // step 1. trans condition
    always @(*) begin
        case (state)
            IDLE:
                next_state = (start_delay) ? DATA : IDLE;
            DATA:
                next_state = (cnt_data==`DATA_WIDTH) ? (`CPHA==0) ? KEEP : STOP : DATA ;
            KEEP:
                next_state = (sclk_flag) ? STOP : KEEP;
            STOP:
                next_state = IDLE;
            default:
                next_state = IDLE;
        endcase
    end

    // step 2. state trans
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    // step 3. output
    // get cnt_clk for freq division
    always @(posedge clk, posedge rst) begin
        if ( (rst)||(cnt_clk==CNT_FREQ) ) begin
            cnt_clk <= 0;
        end
        else if ( (state==DATA)||(state==KEEP) ) begin
            cnt_clk <= cnt_clk + 1;
        end
        else begin
            cnt_clk <= 0;
        end
    end
    assign sclk_flag = (cnt_clk==CNT_FREQ);
    // gen SCLK
    always @(posedge clk, posedge rst) begin
        if ( (rst) || (next_state==IDLE) ) begin
            sclk <= (`CPOL) ? 1 : 0 ;
        end
        else if (start_delay) begin
            sclk <= ~sclk;
        end
        else if ( (state==DATA) && (sclk_flag) ) begin
            sclk <= ~sclk;
        end
        else begin
            sclk <= sclk;
        end
    end
    // gen SS
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            ss_n <= 1;
        end
        else if (start) begin
            ss_n <= 0;
        end
        else if (state==STOP) begin
            ss_n <= 1;
        end
        else begin
            ss_n <= ss_n;
        end
    end
    // gen MOSI
    assign mosi = (state==DATA) ? ( (cnt_data < `DATA_WIDTH) ? data_in[cnt_data] : data_in[`DATA_WIDTH-1] ) : data_in[0] ;
    // finish flag
    assign done = (state==STOP);

endmodule



// testbench
module top();
    reg clk, rst, start, miso;
    reg [`DATA_WIDTH-1:0] data_in;

    wire mosi, sclk, ss_n, master_done, slave_done;
    wire [`DATA_WIDTH-1:0] data_out;

    SPI_MASTER SM (
        .clk    (clk),
        .rst  (rst),
        .miso   (miso),
        .data_in(data_in),
        .start  (start), 
        .mosi   (mosi),
        .sclk   (sclk),
        .done   (master_done),
        .ss_n   (ss_n)
    );

    SPI_SLAVE SS (
        .clk    (clk),
        .rst  (rst),
        .mosi   (mosi),
        .sclk   (sclk),
        .start  (start), 
        .ss_n   (ss_n),
        .data_out(data_out),
        .done (slave_done)
    );

    initial begin
        clk = 0;
        rst = 1;
        start = 0;
        data_in = 8'h35;
        miso = 0;

        #30 rst = 0;
        #10;
        @(posedge clk); start = 1;
        @(posedge clk); start = 0;
        @(negedge master_done); data_in = 8'h44;
        repeat(2) @(posedge clk); start = 1;
        @(posedge clk); start = 0;

    end

    // clock
    always #(`CLK_CYCLE/2) clk=~clk;

    // EPWave: Icarus Verilog 0.9.7
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
        #7000 $finish;
    end

endmodule