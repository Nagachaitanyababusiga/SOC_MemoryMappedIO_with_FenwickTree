`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2025 11:21:44
// Design Name: 
// Module Name: Soc_based_fenwick_tree
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


module Soc_based_fenwick_tree#(parameter data_size=32,parameter arr_size=100)
( input clk,rst,wen,
  input[1:0] cmd,addr,
  input[$clog2(arr_size)+1:0] uindex,ql,qr,
  input[data_size-1:0] uvalue,ivalue,
  output reg[data_size-1:0] out
);

    wire [data_size-1:0] wired_out;

    fenwickTree #(data_size,arr_size) ft(clk,rst,cmd,uindex,ql,qr,uvalue,ivalue,wired_out);
    
    localparam [1:0] addr0=2'b00,addr1=2'b01,addr2=2'b10,addr3=2'b11;
    
    reg[data_size-1:0] reg0,reg1,reg2,reg3;
    
    //write
    always @(posedge clk) begin
        if(rst) begin
            reg0=0;reg1=0;reg2=0;reg3=0;
            out=0;
        end
        else if(wen) begin
            case(addr) 
                addr0: begin
                    reg0=wired_out;
                end
                addr1: begin
                    reg1=wired_out;
                end
                addr2: begin
                    reg2=wired_out;
                end
                addr3: begin
                    reg3=wired_out;
                end
                default: begin
                    reg0=wired_out;
                end
            endcase
        end
    end
    
    //read
    always @(posedge clk) begin
        if(rst) begin
            out=0;
        end
        else if(~wen) begin
            case(addr) 
                addr0: begin
                    out=reg0;
                end
                addr1: begin
                    out=reg1;
                end
                addr2: begin
                    out=reg2;
                end
                addr3: begin
                    out=reg3;
                end
                default: begin
                    out=reg0;
                end
            endcase
            $display("Reading data from addr: %0d, value stored is: %0d",addr,out);
        end
    end
    
endmodule

module fenwickTree #(parameter data_size=32,parameter arr_size=100)
( input clk,rst,
  input[1:0] cmd,
  input[$clog2(arr_size)+1:0] uindex,ql,qr,
  input[data_size-1:0] uvalue,ivalue,
  output reg[data_size-1:0] out
);

    //stages
    localparam [1:0] build=2'b00,query=2'b01,update=2'b10;
    
    //memory and storage
    reg[data_size-1:0] arr[0:arr_size-1];
    reg[data_size-1:0] ft[0:arr_size];
    
    //pointer
    reg[$clog2(arr_size)+1:0] pointer;
    
    //temporary storage helpers
    reg[data_size-1:0] diff,sum0,sum1;
    
    integer i;
    always @(*) begin
        if(rst) begin
            for(i=0;i<arr_size;i=i+1) begin
                arr[i]=0;
                ft[i]=0;ft[i+1]=0;
            end
            pointer=0;
        end
    end
    
    always @(posedge clk) begin
        case(cmd) 
            build: begin
                if(pointer==arr_size)begin
                    $display("The array is already filled, if you want to change any value, please go to update state or reset the entire array");
                end
                else begin
                    arr[pointer]=ivalue;
                    for(i=pointer+1;i<=arr_size;) begin
                        ft[i]=ft[i]+ivalue;
                        i=i+(i&(-i));
                    end
                    pointer=pointer+1;
                    $display("building the fenwick tree; In normal array setting value at index: %0d to %0d",pointer-1,ivalue);
                end
            end
            update: begin
                if(uindex>=arr_size) begin
                    $display("The update index is out of bounds");
                end
                else begin
                    diff=uvalue-arr[uindex];
                    arr[uindex]=uvalue;
                    for(i=uindex+1;i<=arr_size;)begin
                        ft[i]=ft[i]+diff;
                        i=i+(i&(-i));
                    end
                end
                $display("Update the element at index: %0d to %0d ",uindex,uvalue);
            end
            query: begin
                if(ql<0|qr>=arr_size) begin
                    $display("The query range is out of bounds");
                end
                else begin
                    sum0=0;sum1=0;
                    for(i=ql;i>0;)begin
                        sum0=sum0+(ft[i]);
                        i=i-(i&(-i));
                    end
                    for(i=qr+1;i>0;)begin
                        sum1=sum1+(ft[i]);
                        i=i-(i&(-i));
                    end
                    out=sum1-sum0;
                    $display("The sum of elements in the query range (%0d,%0d) is %0d",ql,qr,out);
                end
            end
            default: begin
                $display("A default state is encountered");
            end
        endcase
    end

endmodule