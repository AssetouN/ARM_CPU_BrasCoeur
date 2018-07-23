/*----------------------------------------------------------------
//           test shift                                         //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #0x80000000
	lsls r0, #1
	bcc _bad
	orr r0, r0, #2
	lsls r0, #30
	bcs _bad
	lsls r0, #1
	bcc _bad
	bne _bad
	mov r0, #0x80000000
	mov r1, r0, asr #31
	adds r1, #1
	bne _bad
	mov r2, r0, lsr #31
	cmp r2, #1
	beq _good


_bad :
	nop
	nop
_good :
	nop
	nop
AdrStack:  .word 0x80000000
