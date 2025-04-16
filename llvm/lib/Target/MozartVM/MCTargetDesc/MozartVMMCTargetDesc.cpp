#include "MCTargetDesc/MozartVMInfo.h"
#include "MozartVM.h"
#include "MozartVMInstPrinter.h"
#include "MozartVMMCAsmInfo.h"
#include "TargetInfo/MozartVMTargetInfo.h"
#include "llvm/MC/MCDwarf.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_REGINFO_MC_DESC
#include "MozartVMGenRegisterInfo.inc"

#define GET_INSTRINFO_MC_DESC
#include "MozartVMGenInstrInfo.inc"

#define GET_SUBTARGETINFO_MC_DESC
#include "MozartVMGenSubtargetInfo.inc"

static MCRegisterInfo *createMozartVMMCRegisterInfo(const Triple &TT) {
  MOZARTVM_DUMP_MAGENTA
  MCRegisterInfo *X = new MCRegisterInfo();
  InitMozartVMMCRegisterInfo(X, MozartVM::R0);
  return X;
}

static MCInstrInfo *createMozartVMMCInstrInfo() {
  MOZARTVM_DUMP_MAGENTA
  MCInstrInfo *X = new MCInstrInfo();
  InitMozartVMMCInstrInfo(X);
  return X;
}

static MCSubtargetInfo *createMozartVMMCSubtargetInfo(const Triple &TT,
                                                 StringRef CPU, StringRef FS) {
  MOZARTVM_DUMP_MAGENTA
  return createMozartVMMCSubtargetInfoImpl(TT, CPU, /*TuneCPU*/ CPU, FS);
}

static MCAsmInfo *createMozartVMMCAsmInfo(const MCRegisterInfo &MRI,
                                     const Triple &TT,
                                     const MCTargetOptions &Options) {
  MOZARTVM_DUMP_MAGENTA
  MCAsmInfo *MAI = new MozartVMELFMCAsmInfo(TT);
  unsigned SP = MRI.getDwarfRegNum(MozartVM::R1, true);
  MCCFIInstruction Inst = MCCFIInstruction::cfiDefCfa(nullptr, SP, 0);
  MAI->addInitialFrameState(Inst);
  return MAI;
}

static MCInstPrinter *createMozartVMMCInstPrinter(const Triple &T,
                                             unsigned SyntaxVariant,
                                             const MCAsmInfo &MAI,
                                             const MCInstrInfo &MII,
                                             const MCRegisterInfo &MRI) {
  MOZARTVM_DUMP_MAGENTA
  return new MozartVMInstPrinter(MAI, MII, MRI);
}

// We need to define this function for linking succeed
extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeMozartVMTargetMC() {
  // MOZARTVM_DUMP_MAGENTA
  Target &TheMozartVMTarget = getTheMozartVMTarget();
  RegisterMCAsmInfoFn X(TheMozartVMTarget, createMozartVMMCAsmInfo);
  // Register the MC register info.
  TargetRegistry::RegisterMCRegInfo(TheMozartVMTarget, createMozartVMMCRegisterInfo);
  // Register the MC instruction info.
  TargetRegistry::RegisterMCInstrInfo(TheMozartVMTarget, createMozartVMMCInstrInfo);
  // Register the MC subtarget info.
  TargetRegistry::RegisterMCSubtargetInfo(TheMozartVMTarget,
                                          createMozartVMMCSubtargetInfo);

  // Register the MCInstPrinter
  TargetRegistry::RegisterMCInstPrinter(TheMozartVMTarget, createMozartVMMCInstPrinter);
}
