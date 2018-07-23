/*----------------------------------------------------------------
//           test transferts multiples                          //
----------------------------------------------------------------*/
	.text
	.globl	_start

_start:               
	/* 0x00 Reset Interrupt vector address */
	b	startup
	
	/* 0x04 Undefined Instruction Interrupt vector address */
	b	_bad

	/* 0x08 software Instruction Interrupt vector address */
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
	mov r9, #0x09
	mov r10, #0x0a
	mov r11, #0x0b
	mov r12, #0x0c
	mov r13, #0x0d
	mov r14, #0x0e

	SWI 0
	b	_good


interruption :
	mov r13, #0x0d
	MOVS pc, R14

_bad :
	nop
	nop
_good :
	nop
	nop
