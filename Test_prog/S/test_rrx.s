/*----------------------------------------------------------------
//           test rrx                                           //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r0, #0x66
	mov r1, #0xCC

	lsrs r0, #1
	movs r1, r1, rrx
	movs r0, r0, rrx
	movs r1, r1, rrx
	movs r0, r0, rrx
	movs r1, r1, rrx
	movs r0, r0, rrx
	movs r1, r1, rrx
	movs r0, r0, rrx
	movs r1, r1, rrx
	movs r0, r0, rrx
	movs r1, r1, rrx
	movs r0, r0, rrx
	movs r1, r1, rrx
	movs r0, r0, rrx
	movs r1, r1, rrx
	movs r0, r0, rrx

	cmp r0, #0xCC000000
	bne _bad
	cmp r1, #0x66000000
	beq _good

_bad :
	nop
	nop
_good :
	nop
	nop
AdrStack:  .word 0x80000000
