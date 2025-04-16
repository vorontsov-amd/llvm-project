#ifndef LLVM_LIB_TARGET_MOZARTVM_MOZARTVMINSTRINFO_H
#define LLVM_LIB_TARGET_MOZARTVM_MOZARTVMINSTRINFO_H

#include "MozartVMRegisterInfo.h"
#include "MCTargetDesc/MozartVMInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "MozartVMGenInstrInfo.inc"

namespace llvm {

class MozartVMSubtarget;

class MozartVMInstrInfo : public MozartVMGenInstrInfo {
public:
  MozartVMInstrInfo();

};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_MOZARTVM_MOZARTVMINSTRINFO_H
