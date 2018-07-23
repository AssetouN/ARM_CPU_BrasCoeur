/*----------------------------------------------------------------
//           Test mvn                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mvn r0, #0
	adds r0, r0, #1
	beq	_good

_bad :
	nop
	nop
_good :
	nop
	nop
