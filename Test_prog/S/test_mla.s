/*----------------------------------------------------------------
//           test mla                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #12
	mov r1, #11
	mov r2, #56
	mla r10, r1, r0, r2
	cmp r10, #188
	bne _bad
	b _good

_bad :
	nop
	nop
_good :
	nop
	nop
