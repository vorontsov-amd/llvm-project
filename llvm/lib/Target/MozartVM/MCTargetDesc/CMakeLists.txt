add_llvm_component_library(LLVMMozartVMDesc
  MozartVMMCTargetDesc.cpp
  MozartVMMCAsmInfo.cpp
  MozartVMInstPrinter.cpp
  MozartVMMCCodeEmitter.cpp
  MozartVMAsmBackend.cpp
  MozartVMELFObjectWriter.cpp

  LINK_COMPONENTS
  MC
  Support
  MozartVMInfo

  ADD_TO_COMPONENT
  MozartVM
 )
