#ifndef LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCTARGETDESC_H
#define LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCTARGETDESC_H

// Defines symbolic names for MozartVM registers.  This defines a mapping from
// register name to register number.
//
#define GET_REGINFO_ENUM
#include "MozartVMGenRegisterInfo.inc"

// Defines symbolic names for the MozartVM instructions.
#define GET_INSTRINFO_ENUM
#include "MozartVMGenInstrInfo.inc"

#endif // LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCTARGETDESC_H
