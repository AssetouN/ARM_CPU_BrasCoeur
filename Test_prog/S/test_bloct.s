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

	stmib r9, {r0-r3}

	ldrb r10, [r9 , #16]
	cmp r10, #3
	bne _bad

	ldrb r10, [r9, #4]
	cmp r10, #0
	bne _bad

	ldrb r10, [r9, #8]
	cmp r10, #1
	bne _bad

	ldrb r10, [r9, #12]
	cmp r10, #2
	bne _bad

	ldmib r9!, {r4, r6, r11}
	cmp r4, #0
	bne _bad
	cmp r6, #1
	bne _bad
	cmp r11, #2
	bne _bad


	b _good

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
