add_llvm_component_group(MozartVM)

set(LLVM_TARGET_DEFINITIONS MozartVM.td)

tablegen(LLVM MozartVMGenRegisterInfo.inc -gen-register-info)
tablegen(LLVM MozartVMGenInstrInfo.inc -gen-instr-info)
tablegen(LLVM MozartVMGenSubtargetInfo.inc -gen-subtarget)
tablegen(LLVM MozartVMGenMCPseudoLowering.inc -gen-pseudo-lowering)
tablegen(LLVM MozartVMGenDAGISel.inc -gen-dag-isel)
tablegen(LLVM MozartVMGenCallingConv.inc -gen-callingconv)
tablegen(LLVM MozartVMGenAsmWriter.inc -gen-asm-writer)
tablegen(LLVM MozartVMGenMCCodeEmitter.inc -gen-emitter)

add_public_tablegen_target(MozartVMCommonTableGen)

add_llvm_target(MozartVMCodeGen
  MozartVMTargetMachine.cpp
  MozartVMRegisterInfo.cpp
  MozartVMInstrInfo.cpp
  MozartVMSubtarget.cpp
  MozartVMAsmPrinter.cpp
  MozartVMISelDagToDag.cpp
  MozartVMISelLowering.cpp
  MozartVMMCInstLower.cpp

  LINK_COMPONENTS
  CodeGen
  Core
  Support
  Target
  MozartVMInfo
  AsmPrinter
  SelectionDAG

  ADD_TO_COMPONENT
  MozartVM
  )

add_subdirectory(MCTargetDesc)
add_subdirectory(TargetInfo)
