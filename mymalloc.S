#include <sys/syscall.h>
#include <mips/regdef.h>

/*
 * void *
 * mymalloc(size_t sz)
 */

#define MYMALLOC_SIGNATURE 0xdeadbeef

#ifndef PROT_READ
#define PROT_READ 0x01
#endif

#ifndef PROT_WRITE
#define PROT_WRITE 0x02
#endif

#ifndef MAP_PRIVATE
#define MAP_PRIVATE 0x02
#endif

#ifndef MAP_ANON
#define MAP_ANON 0x1000
#endif

#define MALLOC_SS			56

#define MALLOC_O_ARG 		(MALLOC_SS)

#define MALLOC_O_RA  		48
#define MALLOC_O_FP			44
#define MALLOC_O_GP			40

#define MALLOC_LTA_SIZE		36	
#define MALLOC_LTA_RVAL		32 

#define MALLOC_ABA_7		28
#define MALLOC_ABA_6		24

#define MALLOC_ABA_5		16



	.text
	.align	2
	.globl	mymalloc
	.ent	mymalloc
mymalloc:
	subu	sp, sp, MALLOC_SS 
	sw	ra, MALLOC_O_RA(sp)
	sw	$fp,MALLOC_O_FP(sp)
	sw	gp, MALLOC_O_GP(sp)

	sw	a0, MALLOC_O_ARG(sp)  # Temporary: original allocation size.

	sw	a0, MALLOC_LTA_SIZE(sp)  # Temporary: actual allocation size.
	li	t0, -1
	sw	t0, MALLOC_LTA_RVAL(sp)  # Temporary: return value (defaults to -1).

	move	$fp, sp

	# Adjust the original allocation size to a 4-byte boundary.
	#
	lw	t0, MALLOC_O_ARG(sp)
	addiu	t0, t0, 3
	and	t0, t0, 0xfffffffc
	sw	t0, MALLOC_O_ARG(sp)

	# Increment the allocation size by 12 units, in order to 
	# make room for the allocation signature, block size and
	# trailer information.
	#
	lw	t0, MALLOC_O_ARG(sp)
	addiu	t0, t0, 12
	sw	t0, MALLOC_LTA_SIZE(sp)

	# Do the actual allocation
	# mmap(0, sz, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
	#
	li	v0, SYS_mmap
	li	a0, 0
	lw	a1, MALLOC_LTA_SIZE(sp)
	li	a2, PROT_READ|PROT_WRITE
	li	a3, MAP_PRIVATE|MAP_ANON

	# According to mmap(2), the file descriptor 
	# must be specified as -1 when using MAP_ANON.
	#
	li	t0, -1
	sw	t0,MALLOC_ABA_5(sp)

	# Use a trivial offset.
	#
	li	t0, 0
	sw	t0,MALLOC_ABA_6(sp)
	sw	t0,MALLOC_ABA_7(sp)


	# Excecute the syscall, save the return value.
	#
	syscall
	bne	a3, zero,  mymalloc_die
	sw	v0, MALLOC_LTA_RVAL(sp)
	beqz	v0, mymalloc_return

	# Success. Check out the allocated pointer.
	#
	lw	t0, MALLOC_LTA_RVAL(sp)
	li	t1, MYMALLOC_SIGNATURE
	sw	t1, 0(t0)

	# The actual allocation size goes right after the signature.
	#
	lw	t0, MALLOC_LTA_RVAL(sp)
	lw	t1, MALLOC_LTA_SIZE(sp)
	sw	t1,  4(t0)

	# Trailer information.
	#
	lw	t0, MALLOC_LTA_SIZE(sp) # t0: actual allocation size.
	lw	t1, MALLOC_LTA_RVAL(sp) # t1: Pointer.
	addu	t1, t1, t0 # t1 now points to the trailing 4-byte area.
	xor	t2, t0, MYMALLOC_SIGNATURE
	sw	t2, -4(t1)

	# Increment the result pointer.
	#
	lw	t0, MALLOC_LTA_RVAL(sp)
	addiu	t0, t0, 8
	sw	t0, MALLOC_LTA_RVAL(sp)

mymalloc_return:
	# Restore the return value.
	#
	lw	v0, MALLOC_LTA_RVAL(sp)

	# Destroy the stack frame.
	#
	move	sp, $fp
	lw	ra, MALLOC_O_RA(sp)
	lw	$fp, MALLOC_O_FP(sp)
	addu	sp, sp,MALLOC_SS

	j	ra
	.end	mymalloc

mymalloc_die:
	sw zero, MALLOC_LTA_RVAL(sp)	
	b	mymalloc_return


/*
 * void
 * myfree(void * p)
 *
 * Free previously mymalloc'd memory. No-ops on a null pointer
 */

#define FREE_SS				40

#define FREE_O_ARG 			(FREE_SS)

#define FREE_O_RA  			32
#define FREE_O_FP			28
#define FREE_O_GP			24

#define FREE_LTA_ARG		20	 
#define FREE_LTA_ACTUAL		16	 

	.globl	myfree
	.ent	myfree
myfree:
	subu	sp, sp, FREE_SS		

	sw	ra, FREE_O_RA(sp)			
	sw	$fp,FREE_O_FP(sp)
	sw	gp,FREE_O_GP(sp)						

	sw	a0, FREE_O_ARG(sp)  # Temporary: argument pointer.			
	
	#FAST nop on the NULL  pointer
	beqz	a0, myfree_return

	sw	a0, FREE_LTA_ACTUAL(sp)  # Temporary: actual mmap(2) pointer.	
	move	$fp, sp

	# Calculate the actual mmap(2) pointer.
	#
	lw	t0, FREE_O_ARG(sp)			
	subu	t0, t0, 8
	sw	t0, FREE_LTA_ACTUAL(sp)		

	# XXX Sanity check: the argument pointer must be checked
	# in before we try to release the memory block.
	#
	# First, check the allocation signature.
	#
	lw	t0, FREE_LTA_ACTUAL(sp) # t0: actual mmap(2) pointer.
	lw	t1, 0(t0)
	bne	t1, MYMALLOC_SIGNATURE, myfree_die

	# Second, check the memory block trailer.
	#
	lw	t0, FREE_LTA_ACTUAL(sp) # t0: actual mmap(2) pointer. 	
	lw	t1, 4(t0)  # t1: actual mmap(2) block size.
	addu	t2, t0, t1 # t2: trailer pointer.
	lw	t3, -4(t2)
	xor	t3, t3, t1
	bne	t3, MYMALLOC_SIGNATURE, myfree_die

	# All checks passed. Try to free this memory area.
	#
	li	v0, SYS_munmap
	lw	a0, FREE_LTA_ACTUAL(sp) # a0: actual mmap(2) pointer.	
	lw	a1, 4(a0)  # a1: actual allocation size.
	syscall

	# Bail out if we cannot unmap this memory block.
	#
	bnez	a3, myfree_die
	bnez	v0, myfree_die

	# Success.
	#
	j 	myfree_return

myfree_die:
	# Generate a segmentation faul by writing to the first
	# byte of the adress space (a.ka. the NULL pointer).
	#
	sw 	t0, 0(zero)

myfree_return:
	# Destroy the stack frame.
	#
	move	sp, $fp
	lw	ra,  FREE_O_RA(sp)		
	lw	$fp, FREE_O_FP(sp)	
	addu	sp, sp,FREE_SS

	j	ra
	.end	myfree
