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

	/* 0x18 software Instruction Interrupt vector address */
	nop
	nop
	nop
	nop	
	b	interruption



startup:

	mov r0, #0x00
	mov r1, #0x01
	mov r2, #0x02
	mov r3, #0x03
	mov r4, #0x04
	mov r5, #0x05
	mov r6, #0x06
	mov r7, #0x07
	mov r8, #0x08

	mov r9, #data

	stmdb r9, {r0-r3}

	b	_good
	b	_good



_bad :
	nop
	nop
_good :
	nop
	nop

data:  .word 0xf
       .word 0xf
       .word 0xf
       .word 0xf
       .word 0xf
       .word 0xf
       .word 0xf
       .word 0xf
       .word 0xf
       .word 0xf-

interruption :
	MOVS pc, R14
