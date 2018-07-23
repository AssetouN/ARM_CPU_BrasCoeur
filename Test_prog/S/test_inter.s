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
	mov r0, #0x00
	mov r0, #0x00
	mov r0, #0x00
	mov r0, #0x00	
	b	_good



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

	ldrb r10, [r9 , #-16]
	cmp r10, #0
	bne _bad

	ldrb r10, [r9, #-12]
	cmp r10, #1
	bne _bad

	ldrb r10, [r9, #-8]
	cmp r10, #2
	bne _bad

	ldrb r10, [r9, #-4]
	cmp r10, #3
	bne _bad

	ldmdb r9!, {r4, r6, r11}



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
       .word 0xf

interruption :
	b _good