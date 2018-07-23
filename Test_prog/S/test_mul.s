/*----------------------------------------------------------------
//           test mul                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #100
	mov r1, #20
	mul r10, r1, r0
	cmp r10, #2000
	bne _bad
	b _good

_bad :
	nop
	nop
_good :
	nop
	nop
