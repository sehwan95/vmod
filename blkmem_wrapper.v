`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/08/08 14:56:34
// Design Name: 
// Module Name: blkmem_wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module blkmem_wrapper #(
    parameter READ_LATENCY =3
)
(
    input  clk,
    input  rstn,
    input ext_en,
    input [1:0] read_latency,
    output reg en,
    output reg valid
);

    
localparam IDLE=2'd0,
           WAIT=2'd1,
           READ=2'd2;
               
reg [1:0] cstate;
reg [1:0] nstate;
reg [1:0] wait_counter;


//FSM
always @(posedge clk) begin
    if(!rstn) 
        cstate <= IDLE;
    else 
        cstate <= nstate;
end
   
always @(*) begin
    case(cstate)
    IDLE: begin
        if(ext_en == 1'b1 && read_latency > 2'd1) begin
            nstate = WAIT;
            en = 1'd1;
            valid = 1'd0;  
        end
        else if(ext_en == 1'b1 && read_latency == 2'd1) begin
            nstate = READ;
            en = 1'd1;
            valid = 1'd0;
        end
        else begin
            nstate = IDLE;
            en = 1'd0;
            valid = 1'd0;
        end
    end
    
    WAIT: begin
        if(read_latency == wait_counter) begin
            nstate = READ;
            en = 1'd1;
            valid = 1'd0;
        end
        else begin
            nstate = WAIT;
            en = 1'd1;
            valid = 1'd0;
        end
    end
    
    READ: begin
        nstate = IDLE;
        en = 1'd0;
        valid = 1'd1;
    end
    
    default: begin
        nstate = IDLE;
        en = 1'd0;
        valid = 1'd0;
    end
    endcase 
end

//wait counter
always@ (posedge clk) begin
    if(!rstn)
        wait_counter <= 2'd1;
    else if(nstate == WAIT)
        wait_counter <= wait_counter + 1'd1;
    else
        wait_counter <= 2'd1;
end

endmodule