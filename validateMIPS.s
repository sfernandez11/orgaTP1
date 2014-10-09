	.file	1 "validate.c"
	.section .mdebug.abi32
	.previous
	.abicalls
	.text
	.align	2
	.globl	analizarTag
	.ent	analizarTag
analizarTag:
	.frame	$fp,64,$ra		# vars= 24, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,64
	.cprestore 16
	sw	$ra,56($sp)
	sw	$fp,52($sp)
	sw	$gp,48($sp)
	move	$fp,$sp
	sw	$a0,64($fp)
	sw	$a1,68($fp)
	sw	$a2,72($fp)
	sw	$a3,76($fp)
$L18:
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	bne	$v0,$zero,$L20
	b	$L19
$L20:
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,10			# 0xa
	bne	$v1,$v0,$L21
	lw	$v1,76($fp)
	lw	$v0,76($fp)
	lw	$v0,0($v0)
	addu	$v0,$v0,1
	sw	$v0,0($v1)
$L21:
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,60			# 0x3c
	bne	$v1,$v0,$L22
	lw	$v0,72($fp)
	addu	$v0,$v0,1
	sw	$v0,72($fp)
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,47			# 0x2f
	bne	$v1,$v0,$L23
	lw	$v0,72($fp)
	addu	$v0,$v0,1
	sw	$v0,72($fp)
	sw	$zero,24($fp)
$L24:
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,62			# 0x3e
	bne	$v1,$v0,$L26
	b	$L25
$L26:
	lw	$v1,68($fp)
	lw	$v0,24($fp)
	addu	$a0,$v1,$v0
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($a0)
	lb	$v0,0($v0)
	beq	$v1,$v0,$L27
	li	$v0,-2			# 0xfffffffffffffffe
	sw	$v0,40($fp)
	b	$L17
$L27:
	lw	$v0,24($fp)
	addu	$v0,$v0,1
	sw	$v0,24($fp)
	lw	$v0,72($fp)
	addu	$v0,$v0,1
	sw	$v0,72($fp)
	b	$L24
$L25:
	lw	$v0,72($fp)
	sw	$v0,40($fp)
	b	$L17
$L23:
	lw	$v0,72($fp)
	sw	$v0,24($fp)
$L29:
	lw	$v1,64($fp)
	lw	$v0,24($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,62			# 0x3e
	bne	$v1,$v0,$L31
	b	$L30
$L31:
	lw	$v0,24($fp)
	addu	$v0,$v0,1
	sw	$v0,24($fp)
	b	$L29
$L30:
	lw	$v1,24($fp)
	lw	$v0,72($fp)
	subu	$v0,$v1,$v0
	sw	$v0,24($fp)
	sw	$zero,28($fp)
	lw	$a0,24($fp)
	la	$t9,malloc
	jal	$ra,$t9
	sw	$v0,32($fp)
$L32:
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,62			# 0x3e
	bne	$v1,$v0,$L34
	b	$L33
$L34:
	lw	$v1,32($fp)
	lw	$v0,28($fp)
	addu	$a0,$v1,$v0
	lw	$v1,64($fp)
	lw	$v0,72($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	sb	$v0,0($a0)
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	lw	$v0,72($fp)
	addu	$v0,$v0,1
	sw	$v0,72($fp)
	b	$L32
$L33:
	lw	$v0,72($fp)
	addu	$v0,$v0,1
	sw	$v0,72($fp)
	lw	$a0,64($fp)
	lw	$a1,32($fp)
	lw	$a2,72($fp)
	lw	$a3,76($fp)
	la	$t9,analizarTag
	jal	$ra,$t9
	sw	$v0,36($fp)
	lw	$a0,32($fp)
	la	$t9,free
	jal	$ra,$t9
	lw	$v1,36($fp)
	sw	$v1,44($fp)
	li	$v0,-2			# 0xfffffffffffffffe
	lw	$v1,44($fp)
	beq	$v1,$v0,$L37
	li	$v0,-1			# 0xffffffffffffffff
	lw	$v1,44($fp)
	beq	$v1,$v0,$L36
	b	$L38
$L36:
	li	$v0,-1			# 0xffffffffffffffff
	sw	$v0,40($fp)
	b	$L17
$L37:
	li	$v1,-2			# 0xfffffffffffffffe
	sw	$v1,40($fp)
	b	$L17
$L38:
	lw	$v0,36($fp)
	sw	$v0,72($fp)
$L22:
	lw	$v0,72($fp)
	addu	$v0,$v0,1
	sw	$v0,72($fp)
	b	$L18
$L19:
	li	$v0,-1			# 0xffffffffffffffff
	sw	$v0,40($fp)
$L17:
	lw	$v0,40($fp)
	move	$sp,$fp
	lw	$ra,56($sp)
	lw	$fp,52($sp)
	addu	$sp,$sp,64
	j	$ra
	.end	analizarTag
	.size	analizarTag, .-analizarTag
	.rdata
	.align	2
$LC0:
	.ascii	"El tag abierto, no fue cerrado, en la linea: %d.\n\000"
	.align	2
$LC1:
	.ascii	"Tag mal anidado, el ultimo tag cerrado, no corresponde c"
	.ascii	"on el ultimo tag abierto, en la linea: %d.\n\000"
	.text
	.align	2
	.globl	validate
	.ent	validate
validate:
	.frame	$fp,72,$ra		# vars= 32, regs= 3/0, args= 16, extra= 8
	.mask	0xd0000000,-8
	.fmask	0x00000000,0
	.set	noreorder
	.cpload	$t9
	.set	reorder
	subu	$sp,$sp,72
	.cprestore 16
	sw	$ra,64($sp)
	sw	$fp,60($sp)
	sw	$gp,56($sp)
	move	$fp,$sp
	sw	$a0,72($fp)
	sw	$a1,76($fp)
	sw	$zero,28($fp)
	sw	$zero,32($fp)
$L41:
	lw	$v1,72($fp)
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lb	$v0,0($v0)
	bne	$v0,$zero,$L43
	b	$L42
$L43:
	lw	$v1,72($fp)
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,10			# 0xa
	bne	$v1,$v0,$L44
	lw	$v0,32($fp)
	addu	$v0,$v0,1
	sw	$v0,32($fp)
$L44:
	lw	$v1,72($fp)
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,60			# 0x3c
	bne	$v1,$v0,$L45
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	sw	$zero,36($fp)
$L46:
	lw	$v1,72($fp)
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lb	$v1,0($v0)
	li	$v0,62			# 0x3e
	bne	$v1,$v0,$L48
	b	$L47
$L48:
	lw	$v1,40($fp)
	lw	$v0,36($fp)
	addu	$a0,$v1,$v0
	lw	$v1,72($fp)
	lw	$v0,28($fp)
	addu	$v0,$v1,$v0
	lbu	$v0,0($v0)
	sb	$v0,0($a0)
	lw	$v0,36($fp)
	addu	$v0,$v0,1
	sw	$v0,36($fp)
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	b	$L46
$L47:
	addu	$v0,$fp,32
	lw	$a0,72($fp)
	lw	$a1,40($fp)
	lw	$a2,28($fp)
	move	$a3,$v0
	la	$t9,analizarTag
	jal	$ra,$t9
	sw	$v0,28($fp)
	lw	$v0,28($fp)
	sw	$v0,48($fp)
	li	$v0,-2			# 0xfffffffffffffffe
	lw	$v1,48($fp)
	beq	$v1,$v0,$L51
	li	$v0,-1			# 0xffffffffffffffff
	lw	$v1,48($fp)
	beq	$v1,$v0,$L50
	b	$L45
$L50:
	lw	$a0,24($fp)
	la	$a1,$LC0
	lw	$a2,32($fp)
	la	$t9,sprintf
	jal	$ra,$t9
	lw	$v1,76($fp)
	lw	$v0,24($fp)
	sw	$v0,0($v1)
	li	$v0,1			# 0x1
	sw	$v0,44($fp)
	b	$L40
$L51:
	lw	$a0,24($fp)
	la	$a1,$LC1
	lw	$a2,32($fp)
	la	$t9,sprintf
	jal	$ra,$t9
	lw	$v1,76($fp)
	lw	$v0,24($fp)
	sw	$v0,0($v1)
	li	$v1,1			# 0x1
	sw	$v1,44($fp)
	b	$L40
$L45:
	lw	$v0,28($fp)
	addu	$v0,$v0,1
	sw	$v0,28($fp)
	b	$L41
$L42:
	sw	$zero,44($fp)
$L40:
	lw	$v0,44($fp)
	move	$sp,$fp
	lw	$ra,64($sp)
	lw	$fp,60($sp)
	addu	$sp,$sp,72
	j	$ra
	.end	validate
	.size	validate, .-validate
	.ident	"GCC: (GNU) 3.3.3 (NetBSD nb3 20040520)"
