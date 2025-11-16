`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.11.2025 12:01:07
// Design Name: 
// Module Name: soc_tb
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


module soc_tb;

    parameter data_size=32 , arr_size=100;
    parameter [1:0] build=2'b00,query=2'b01,update=2'b10,nill=2'b11;
    
    parameter [1:0] addr0=2'b00,addr1=2'b01,addr2=2'b10,addr3=2'b11;
    
    reg clk,rst,wen;
    reg [$clog2(arr_size)+1:0] uindex,ql,qr;
    reg [data_size-1:0] uvalue,ivalue;
    reg [1:0] cmd,addr;
    wire [data_size-1:0] out;
    
    always #5 clk=~clk;
    
    Soc_based_fenwick_tree #(data_size,arr_size) dut(clk,rst,wen,cmd,addr,uindex,ql,qr,uvalue,ivalue,out);
    
    integer i;
    initial begin
        clk=1;rst=1;wen=1;
        // ivalue=0;cmd=build;
        ql=0;qr=0;uindex=0;uvalue=0;
        
        //build
        #10;rst=0;
        cmd=build;
        for(i=1;i<=101;i=i+1) begin
            ivalue=i;
            #10;
        end
        
        //query before update
        cmd=query;
        wen=1;
        ql=1;qr=25;
        #10; addr=addr0;
        
        
        //update
        cmd=update;
        uindex=2;
        uvalue=0;
        #10;
        
        //query after update
        cmd=query;
        ql=1;qr=25;
        #10; addr=addr1;
        
        
        //query after update
        cmd=query;
        ql=4;qr=25;
        #10;addr=addr2;
        
        
        //query after update
        cmd=query;
        ql=10;qr=35;
        #10;addr=addr3;
        
        #10;
  
        cmd=nill;
        wen=0;
        addr=addr0;
        #10;
        addr=addr1;
        #10;
        addr=addr2;
        #10;
        addr=addr3;
        
        #20; 
        $finish;
        
    end
    
endmodule
