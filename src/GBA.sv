`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.06.2022 11:43:38
// Design Name: 
// Module Name: GBA
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


module GBA (
	input CLK_50,
	output[31:0] a
);
    var[31:0] address;
    var[31:0] data;

    var[15:0] romLSB, romMSB;
    
    ROM rom (
        .addra(address),
        .clka(CLK_50),
        .douta(romLSB),
        .addrb(address + 1),
        .clkb(CLK_50),
        .doutb(romMSB)
    );
    
    assign data = { romMSB[7:0], romMSB[15:8], romLSB[7:0], romLSB[15:8] };

    ARM7Core arm7core (
        .CLK(CLK_50),
        .address(address),
        .data(data),
        .aluBusOut(aluBus)
    );
    
    assign a = aluBus;
    
endmodule
