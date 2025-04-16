#include "MozartVMRegisterInfo.h"
#include "MozartVM.h"
#include "MozartVMFrameLowering.h"
#include "llvm/CodeGen/TargetInstrInfo.h"

using namespace llvm;

#define GET_REGINFO_TARGET_DESC
#include "MozartVMGenRegisterInfo.inc"

MozartVMRegisterInfo::MozartVMRegisterInfo() : MozartVMGenRegisterInfo(MozartVM::R0) {
  MOZARTVM_DUMP_GREEN
}
const MCPhysReg *
MozartVMRegisterInfo::getCalleeSavedRegs(const MachineFunction *MF) const {
  MOZARTVM_DUMP_GREEN
  return CSR_MozartVM_SaveList;
}

BitVector MozartVMRegisterInfo::getReservedRegs(const MachineFunction &MF) const {
  MOZARTVM_DUMP_GREEN
  MozartVMFrameLowering const *TFI = getFrameLowering(MF);

  BitVector Reserved(getNumRegs());
  Reserved.set(MozartVM::R1);

  if (TFI->hasFP(MF)) {
    Reserved.set(MozartVM::R2);
  }
  return Reserved;
}

bool MozartVMRegisterInfo::requiresRegisterScavenging(
    const MachineFunction &MF) const {
  return false;
}

bool MozartVMRegisterInfo::eliminateFrameIndex(MachineBasicBlock::iterator II,
                                          int SPAdj, unsigned FIOperandNum,
                                          RegScavenger *RS) const {
  MOZARTVM_DUMP_GREEN
  assert(SPAdj == 0 && "Unexpected non-zero SPAdj value");

  MachineInstr &MI = *II;
  MachineFunction &MF = *MI.getParent()->getParent();
  DebugLoc DL = MI.getDebugLoc();

  int FrameIndex = MI.getOperand(FIOperandNum).getIndex();
  Register FrameReg;
  int Offset = getFrameLowering(MF)
                   ->getFrameIndexReference(MF, FrameIndex, FrameReg)
                   .getFixed();
  Offset += MI.getOperand(FIOperandNum + 1).getImm();

  if (!isInt<16>(Offset)) {
    llvm_unreachable("");
  }

  MI.getOperand(FIOperandNum).ChangeToRegister(FrameReg, false, false, false);
  MI.getOperand(FIOperandNum + 1).ChangeToImmediate(Offset);
  return false;
}

Register MozartVMRegisterInfo::getFrameRegister(const MachineFunction &MF) const {
  MOZARTVM_DUMP_GREEN
  const TargetFrameLowering *TFI = getFrameLowering(MF);
  return TFI->hasFP(MF) ? MozartVM::R2 : MozartVM::R1;
}

const uint32_t *
MozartVMRegisterInfo::getCallPreservedMask(const MachineFunction &MF,
                                      CallingConv::ID CC) const {
  MOZARTVM_DUMP_GREEN
  return CSR_MozartVM_RegMask;
}
