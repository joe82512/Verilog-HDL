// 5.36
module adder_task (c_out, sum, c_in, data_a, data_b, clk, reset,);
    output [3: 0]   sum;
    output          c_out;
    input  [3: 0]   data_a, data_b;
    input           clk, reset;
    input           c_in;
    reg             sum, c_out;

    always @  (posedge clk or posedge reset)
        if (reset)
            {c_out, sum} <= 0;
        else 
            add_values (c_out, sum, data_a, data_b, c_in);

    // task 可包含時序 , 但 event 無法被綜合
    task add_values;
        output [3: 0]   sum;
        output          c_out;
        input  [3: 0]   data_a, data_b;
        input           c_in;
    
        begin
            {c_out, sum} <= data_a + (data_b + c_in);
        end
    endtask
endmodule

// 5.37
module word_aligner (word_out, word_in);
    output [7: 0]   word_out;
    input  [7: 0]   word_in;

    assign word_out = aligned_word(word_in);

    // function 不能含有時序 , 計算/執行也不占用時間
    function [7: 0] aligned_word;
        input [7: 0] word_in; // 5-10-2004
        begin
            aligned_word = word_in;
            if (aligned_word != 0)
                while (aligned_word[7] == 0) aligned_word = aligned_word << 1;
        end
    endfunction
endmodule


// 5.38
module arithmetic_unit (result_1, result_2, operand_1, operand_2,);
    output [4: 0] result_1;
    output [3: 0] result_2;
    input  [3: 0] operand_1, operand_2;
  
    assign result_1 = sum_of_operands (operand_1, operand_2);
    assign result_2 = largest_operand (operand_1, operand_2);

    function [4: 0] sum_of_operands;
        input [3: 0] operand_1, operand_2;
        sum_of_operands = operand_1 + operand_2;
    endfunction

    function [3: 0] largest_operand;
        input [3: 0] operand_1, operand_2;
        largest_operand = (operand_1 >= operand_2) ? operand_1 : operand_2;
    endfunction
endmodule