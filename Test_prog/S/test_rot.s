/*----------------------------------------------------------------
//           test rot                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #0x00550000
	ror r0, #24
	ror r0, #24
	rors r0, #1
	bcc _bad
	rors r0, #1
	bcs _bad
	rors r0, #1
	bcc _bad
	rors r0, #1
	bcs _bad
	rors r0, #1
	bcc _bad
	rors r0, #1
	bcs _bad
	rors r0, #1
	bcc _bad
	rors r0, #1
	bcs _bad
	cmp r0, #0x55000000
	beq _good

_bad :
	nop
	nop
_good :
	nop
	nop
AdrStack:  .word 0x80000000
