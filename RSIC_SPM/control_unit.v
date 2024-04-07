module Control_Unit (
    Load_R0, Load_R1, 
    Load_R2, Load_R3, 
    Load_PC, Inc_PC, 
    Sel_Bus_1_Mux, Sel_Bus_2_Mux,
    Load_IR, Load_Add_R, Load_Reg_Y, Load_Reg_Z, 
    write, instruction, zero, clk, rst
);
    
    parameter word_size = 8, op_size = 4, state_size = 4;
    parameter src_size = 2, dest_size = 2, Sel1_size = 3, Sel2_size = 2;
    // 狀態機: State Codes
    parameter S_idle = 0, S_fet1 = 1, S_fet2 = 2, S_dec = 3;
    parameter S_ex1 = 4, S_rd1 = 5, S_rd2 = 6;  
    parameter S_wr1 = 7, S_wr2 = 8, S_br1 = 9, S_br2 = 10, S_halt = 11;  
    // 解碼: Opcodes
    parameter NOP = 0, ADD = 1, SUB = 2, AND = 3, NOT = 4;
    parameter RD  = 5, WR =  6,  BR =  7, BRZ = 8;  
    // reg: Source and Destination Codes, 給Mux_1  
    parameter R0 = 0, R1 = 1, R2 = 2, R3 = 3;  
    
    // Signal Output
    output Load_R0, Load_R1, Load_R2, Load_R3;
    output Load_PC, Inc_PC;
    output [Sel1_size-1:0] Sel_Bus_1_Mux;
    output Load_IR, Load_Add_R;
    output Load_Reg_Y, Load_Reg_Z;
    output [Sel2_size-1: 0] Sel_Bus_2_Mux;
    output write;
    // Signal Input
    input [word_size-1: 0] instruction; // 8-bits = [opcode(4), src(2), dest(2)]
    input zero;
    input clk, rst;
    
    reg [state_size-1: 0] state, next_state; // not output
    reg Load_R0, Load_R1, Load_R2, Load_R3, Load_PC, Inc_PC;
    reg Load_IR, Load_Add_R, Load_Reg_Y;
    reg Sel_ALU, Sel_Bus_1, Sel_Mem; // not output
    reg Sel_R0, Sel_R1, Sel_R2, Sel_R3, Sel_PC; // not output
    reg Load_Reg_Z, write;
    reg err_flag; // not output

    //opcode
    wire [op_size-1:0]   opcode = instruction[word_size-1: word_size - op_size];
    //source: Load->[R0-R3]
    wire [src_size-1: 0] src    = instruction[src_size + dest_size -1: dest_size];
    //destination: Bus_2->[R0-R3]
    wire [dest_size-1:0] dest   = instruction[dest_size -1:0];
    
    // Mux selectors
    //Mux_1: 選擇 R[0-3], PC 五擇一灌入 Bus_1
    assign  Sel_Bus_1_Mux[Sel1_size-1:0] =  Sel_R0 ? 0:
                                            Sel_R1 ? 1:
                                            Sel_R2 ? 2:
                                            Sel_R3 ? 3:
                                            Sel_PC ? 4: 3'bx;  //3-bits, 5mux

    //Mux_2: 選擇 ALU, Bus_1, Mem 三擇一灌入 Bus_2
    assign  Sel_Bus_2_Mux[Sel2_size-1:0] =  Sel_ALU ? 0:
                                            Sel_Bus_1 ? 1:
                                            Sel_Mem ? 2: 2'bx; //2-bits, 3mux

    // 狀態機起始狀態
    always @ (posedge clk or negedge rst) begin: State_transitions
        if (rst == 0) state <= S_idle;
        else state <= next_state;
    end

    /* 錯誤寫法: 沒有把OPcode變化納入
        always @ (state or instruction or zero) begin: Output_and_next_state
    */ 

    always @ (state or opcode or zero) begin: Output_and_next_state 
        Sel_R0 = 0;     Sel_R1 = 0;     Sel_R2 = 0;     Sel_R3 = 0;     Sel_PC = 0;
        Load_R0 = 0;    Load_R1 = 0;    Load_R2 = 0;    Load_R3 = 0;    Load_PC = 0;
        
        Load_IR = 0;    Load_Add_R = 0; Load_Reg_Y = 0; Load_Reg_Z = 0;
        
        Inc_PC = 0;     // Program Counter
        Sel_Bus_1 = 0;  // Mux_2 切 Bus_1
        Sel_ALU = 0;    // Mux_2 切 ALU
        Sel_Mem = 0;    // Mux_2 切 Mem
        write = 0;      // Bus_1 寫入 reg
        err_flag = 0;   // Used for de-bug in simulation		
        next_state = state;

        case  (state) //狀態轉移
            /* ------------ 初始狀態 ------------ */
            S_idle: begin //0
                next_state = S_fet1; // clk+1
            end      
            
            /* ------------ 取 address ------------ */
            S_fet1: begin //1
                next_state = S_fet2; // clk+1
                Sel_PC = 1;     //MUX_1 切 PC (=Bus_1)
                Sel_Bus_1 = 1;  //Mux_2 切 Bus_1, Bus2: PC->Memory
                Load_Add_R = 1; //讀取 地址reg (PC address->PC內容)
            end

            S_fet2: begin //2	
                next_state = S_dec; // clk+1
                Sel_Mem = 1;    //Mux_2 切 Mem, Bus_2: PC內容
                Load_IR = 1;    //讀取 指令reg (PC內容->指令reg)
                Inc_PC = 1;     //PC+1
            end

            /* ------------ 解 OPcode ------------ */
            S_dec: begin //3
                case (opcode) 
                    NOP: begin //total clk=3
                        next_state = S_fet1; //FSM
                    end // NOP
                    
                    ADD, SUB, AND: begin //total clk=4
                        next_state = S_ex1; //FSM
                        Sel_Bus_1 = 1;  //Mux_2 切 Bus_1
                        Load_Reg_Y = 1; //Bus2 -> RegY
                        case  (src)     //取得source, 2^2=4=[R3:R0], 四選一
                            R0: Sel_R0 = 1;
                            R1: Sel_R1 = 1;
                            R2: Sel_R2 = 1;
                            R3: Sel_R3 = 1;
                            default: err_flag = 1;
                        endcase   
                    end // ADD, SUB, AND

                    NOT: begin //total clk=3
                        next_state = S_fet1; //FSM
                        Load_Reg_Z = 1; //ALU output -> RegZ
                        // Sel_Bus_1 = 1;
                        Sel_ALU = 1;    //Mux_2 切 ALU (ALU優先)
                        case  (src)     //取得source
                            R0: Sel_R0 = 1;
                            R1: Sel_R1 = 1;
                            R2: Sel_R2 = 1;   
                            R3: Sel_R3 = 1; 
                            default: err_flag = 1;
                        endcase   
                        case  (dest)    //取得destination
                            R0: Load_R0 = 1;
                            R1: Load_R1 = 1;
                            R2: Load_R2 = 1;
                            R3: Load_R3 = 1;    
                            default: err_flag = 1;
                        endcase   
                    end // NOT
                    
                    RD: begin //total clk=5
                        next_state = S_rd1; //FSM
                        Sel_PC = 1;     //MUX_1 切 PC (same as S_fet1)
                        Sel_Bus_1 = 1;  //Mux_2 切 Bus_1
                        Load_Add_R = 1; //讀取 地址reg
                    end // RD

                    WR: begin //total clk=5
                        next_state = S_wr1; //FSM
                        Sel_PC = 1;     //(same as S_fet1)
                        Sel_Bus_1 = 1;
                        Load_Add_R = 1; 
                    end // WR

                    BR: begin //total clk=5
                        next_state = S_br1; //FSM
                        Sel_PC = 1;;     //(same as S_fet1)
                        Sel_Bus_1 = 1;
                        Load_Add_R = 1; 
                    end  // BR
        
                    BRZ: //total clk=5
                        if (zero == 1) begin
                            next_state = S_br1; //FSM
                            Sel_PC = 1;;    //(same as S_fet1)
                            Sel_Bus_1 = 1;
                            Load_Add_R = 1; 
                        end // BRZ
                        else begin 
                            next_state = S_fet1; //FSM
                            Inc_PC = 1; //PC+1
                        end
                        default:
                            next_state = S_halt; //FSM
                    endcase  // (opcode)
            end //S_dec

            /* ------------ 執行指令碼 ------------ */
            // add, sub, and 
            S_ex1: begin //4
                next_state = S_fet1; //FSM
                Load_Reg_Z = 1; //ALU output -> RegZ
                Sel_ALU = 1; 
                case  (dest)    //取得destination
                    R0: begin Sel_R0 = 1; Load_R0 = 1; end
                    R1: begin Sel_R1 = 1; Load_R1 = 1; end
                    R2: begin Sel_R2 = 1; Load_R2 = 1; end
                    R3: begin Sel_R3 = 1; Load_R3 = 1; end
                    default: err_flag = 1; 
                endcase  
                end

            // read
            S_rd1: begin //5
                next_state = S_rd2; //FSM
                Sel_Mem = 1;    //Mux_2 切 Memory
                Load_Add_R = 1; //讀取 地址reg 
                Inc_PC = 1;     //PC+1
            end

            S_rd2: begin //6
                next_state = S_fet1; //FSM
                Sel_Mem = 1;    //Mux_2 切 Memory, 同read
                case  (dest)    //取得destination
                    R0: Load_R0 = 1; 
                    R1: Load_R1 = 1; 
                    R2: Load_R2 = 1; 
                    R3: Load_R3 = 1; 
                    default: err_flag = 1;
                endcase  
            end

            // write
            S_wr1: begin //7
                next_state = S_wr2; //FSM
                Sel_Mem = 1;
                Load_Add_R = 1; 
                Inc_PC = 1;
            end 

            S_wr2: begin //8
                next_state = S_fet1; //FSM
                write = 1;  //memory轉write
                case  (src)
                    R0: Sel_R0 = 1;		 	    
                    R1: Sel_R1 = 1;		 	    
                    R2: Sel_R2 = 1; 		 	    
                    R3: Sel_R3 = 1;			    
                    default: err_flag = 1;
                endcase
                end

            // branch
            S_br1: begin //9
                next_state = S_br2; //FSM
                Sel_Mem = 1;
                Load_Add_R = 1;
            end
            
            S_br2: begin //10(A)
                next_state = S_fet1; //FSM
                Sel_Mem = 1;
                Load_PC = 1;
            end
            
            S_halt: begin //11(B)
                next_state = S_halt; //FSM
            end

            default: next_state = S_idle; //FSM

        endcase//狀態轉移

    end // (Output_and_next_state)
endmodule