/*----------------------------------------------------------------
//           test add flags                                     //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #0x7F000000
	mov r1, #0x01000000
	adds r2, r0, r1
	bcs _bad
	bvc _bad
	bpl _bad
	beq _bad
	cmp r2, #0x80000000
	bne _bad
	adds r2, r2, r2
	bcc _bad
	bvc _bad
	bmi _bad
	bne _bad
	b _good

_bad :
	nop
	nop
_good :
	nop
	nop
AdrStack:  .word 0x80000000
