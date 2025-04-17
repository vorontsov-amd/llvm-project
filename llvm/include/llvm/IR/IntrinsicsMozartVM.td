let TargetPrefix = "mozartVM" in {  // All intrinsics start with "llvm.mozartVM.".
 
 def int_mozartVM_putpixel: ClangBuiltin<"mozartVMPutPixel">,
   Intrinsic<[], [llvm_i32_ty, llvm_i32_ty, llvm_i32_ty], [IntrNoMem, IntrHasSideEffects]>;
 
 def int_mozartVM_flush: ClangBuiltin<"mozartVMFlush">,
   Intrinsic<[], [], [IntrNoMem, IntrHasSideEffects]>;
 
 } // TargetPrefix = "mozartVM"
