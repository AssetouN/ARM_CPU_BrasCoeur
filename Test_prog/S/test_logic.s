/*----------------------------------------------------------------
//           test logic                                         //
----------------------------------------------------------------*/
	.text
	.globl	_start 
_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

startup:
	mov r4, #0x41
	orr r4, r4, #0x4200
	orr r4, r4, #0x430000
	orr r4, r4, #0x44000000
	eor r4, r4, #0x00F00000
	mvn r5, #0x0000F000
	and r6, R4, r5
	ldr r7, res
	cmp r6, r7
	bne _bad
	b _good

_bad :
	nop
	nop
_good :
	nop
	nop
res:  .word 0x44B30241
