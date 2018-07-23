/*----------------------------------------------------------------
//           test rsb                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r1, #3
	tst r1, #12
	bne _bad
	b _good

_bad :
	nop
	nop
_good :
	nop
	nop
AdrStack:  .word 0x80000000
