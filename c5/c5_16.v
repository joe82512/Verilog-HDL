// 5.16
module shiftreg_PA (E, A, B, C, D, clk, rst);
    output A;
    input E;
    input clk, rst;
    reg	A, B, C, D;
    always @ (posedge clk or posedge rst) begin
        if (reset) begin
            A = 0; B = 0; C = 0; D = 0;
        end
        else begin //非同步執行
            A = B;
            B = C;
            C = D;
            D = E;
        end	
    end
endmodule

module shiftreg_PA_rev (A, E, clk, rst);
    output A;
    input E;
    input clk, rst;
    reg	A, B, C, D;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            A = 0; B = 0; C = 0; D = 0;
        end
        else begin //順序導致結果不同
            D = E; 
            C = D;
            B = C;
            A = B;
        end
  end
endmodule

// 5.17
module shiftreg_nb (A, E, clk, rst);
    output A;
    input E;
    input clk, rst;
    reg	A, B, C, D;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            A <= 0; B <= 0; C <= 0; D <= 0;
        end
        else begin //同步執行
            A <= B;     //	D <= E;
            B <= C;	    //	C <= D;
            C <= D;	    //	B <= D;
            D <= E;	    //	A <= B;
        end
    end
endmodule


