
/*----------------------------------------------------------------
//           test swp                                           //
----------------------------------------------------------------*/
	.text
	.global	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	movs r0, #var1
	movs r8, #data
	str r0, [r8]
	ldr r9, [r8]
	movs r1, #0x38
	swp r1, r1, [r0]
	cmp r1, #var1
	beq _good

_bad :
	nop
	nop
_good :
	nop
	nop

var1 : .word 0x12
data:  .word 0x44332211

AdrStack:  .word 0x80000000
