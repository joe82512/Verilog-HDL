// ==================== design.sv ====================
// Code your design here

//waveform: Icarus Verilog 0.9.7
//synthesis: Mentor Precision 2021.1+run.do

//組合邏輯綜合: 無反饋, 完整的case/if-else, 無時間控制# @ wait
module mux_logic(output y,
                input select, sig_G, sig_max, sig_a, sig_b);
    
    assign y = (select==1)||(sig_G==1)||(sig_max==0) ? sig_a : sig_b;

endmodule