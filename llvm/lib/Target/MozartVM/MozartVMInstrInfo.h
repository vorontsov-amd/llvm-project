#ifndef LLVM_LIB_TARGET_MOZARTVM_MOZARTVMINSTRINFO_H
#define LLVM_LIB_TARGET_MOZARTVM_MOZARTVMINSTRINFO_H

#include "MCTargetDesc/MozartVMInfo.h"
#include "MozartVMRegisterInfo.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

#define GET_INSTRINFO_HEADER
#include "MozartVMGenInstrInfo.inc"

namespace llvm {

class MozartVMSubtarget;

class MozartVMInstrInfo : public MozartVMGenInstrInfo {
public:
  MozartVMInstrInfo();
  void copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator MBBI,
                   const DebugLoc &DL, MCRegister DestReg, MCRegister SrcReg,
                   bool KillSrc, bool RenamableDest = false,
                   bool RenamableSrc = false) const override;
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_MOZARTVM_MOZARTVMINSTRINFO_H
