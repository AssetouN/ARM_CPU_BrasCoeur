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
	mov r0, #7
	mov r1, #6
	bl mult
	cmp r0, #42
	bne _bad
	b _good

_bad :
	nop
	nop
	
_good :
	nop
	nop

mult :
	movs r3, r0
	moveq pc, r14
	mov r0, #0
	teq r1, #0
	moveq pc, r14

bwhile:
	movs r1, r1, LSR #1
	addcs r0, r0, r3
	mov r3, r3, LSL #1
	moveq pc, r14
	b bwhile
	nop
