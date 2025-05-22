	.file	"graphic.c"
	.text
	.globl	main                            ; -- Begin function main
	.type	main,@function
main:                                   ; @main
; %bb.0:                                ; %entry
	ADD r9 r1 60
	ADD r2 r9 r2
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
                                        ; -- End function
	.ident	"clang version 20.1.4 (git@github.com:vorontsov-amd/llvm-project.git 28e76154f5210ef5349c658947d2672f83539519)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
