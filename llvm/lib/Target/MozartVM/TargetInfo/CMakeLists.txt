add_llvm_component_library(LLVMMozartVMInfo
  MozartVMTargetInfo.cpp

  LINK_COMPONENTS
  MC
  Support

  ADD_TO_COMPONENT
  MozartVM
  )
