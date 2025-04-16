#include "MozartVMTargetMachine.h"
#include "MozartVM.h"
#include "TargetInfo/MozartVMTargetInfo.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"
#include "llvm/CodeGen/TargetPassConfig.h"
#include "llvm/MC/TargetRegistry.h"
#include <optional>

using namespace llvm;

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeMozartVMTarget() {
  // Register the target.
  // MOZARTVM_DUMP_CYAN
  RegisterTargetMachine<MozartVMTargetMachine> A(getTheMozartVMTarget());
}

MozartVMTargetMachine::MozartVMTargetMachine(const Target &T, const Triple &TT,
                                   StringRef CPU, StringRef FS,
                                   const TargetOptions &Options,
                                   std::optional<Reloc::Model> RM,
                                   std::optional<CodeModel::Model> CM,
                                   CodeGenOptLevel OL, bool JIT)
    : CodeGenTargetMachineImpl(T, "e-m:e-p:32:32-i8:8:32-i16:16:32-i64:64-n32",
                               TT, CPU, FS, Options, Reloc::Static,
                               getEffectiveCodeModel(CM, CodeModel::Small), OL),
      TLOF(std::make_unique<TargetLoweringObjectFileELF>()),
      Subtarget(TT, std::string(CPU), std::string(FS), *this) {
  MOZARTVM_DUMP_CYAN
  initAsmInfo();
}

namespace {

/// MozartVM Code Generator Pass Configuration Options.
class MozartVMPassConfig : public TargetPassConfig {
public:
  MozartVMPassConfig(MozartVMTargetMachine &TM, PassManagerBase &PM)
      : TargetPassConfig(TM, PM) {}

  MozartVMTargetMachine &getMozartVMTargetMachine() const {
    return getTM<MozartVMTargetMachine>();
  }

  bool addInstSelector() override {
    MOZARTVM_DUMP_CYAN
    addPass(createMozartVMISelDag(getMozartVMTargetMachine(), getOptLevel()));
    return false;
  }
};

} // end anonymous namespace

TargetPassConfig *MozartVMTargetMachine::createPassConfig(PassManagerBase &PM) {
  MOZARTVM_DUMP_CYAN
  return new MozartVMPassConfig(*this, PM);
}

TargetLoweringObjectFile *MozartVMTargetMachine::getObjFileLowering() const {
  MOZARTVM_DUMP_CYAN
  return TLOF.get();
}
