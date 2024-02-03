// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

// 三態元件(Z) 與 總線(Bus) : 單向連接
module Uni_dir_bus ( data_to_bus, bus_enable);
    input           bus_enable;
    output  [31: 0]	data_to_bus;
    reg     [31: 0] ckt_to_bus;
   
    assign data_to_bus = (bus_enabled) ? ckt_to_bus : 32'bz;
    //核心電路產生ckt_to_bus 省略
endmodule

// 三態元件(Z) 與 總線(Bus) : 雙向連接
module Bi_dir_bus (data_to_from_bus, send_data, rcv_data);
    inout   [31: 0] data_to_from_bus; //雙向用inout
    input           send_data, rcv_data;
    wire    [31: 0] ckt_to_bus;
    wire    [31: 0] data_to_from_bus, data_from_bus;   

    assign data_from_bus = (rcv_data) ? data_to_from_bus : 'bz;
    assign data_to_from_bus = (send_data) ? reg_to_bus : data_to_from_bus;
    //核心電路產生ckt_to_bus 省略
    //電路使用data_from_bus 省略
endmodule