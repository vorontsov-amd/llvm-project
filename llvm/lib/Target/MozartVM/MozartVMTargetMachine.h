#ifndef LLVM_LIB_TARGET_MOZARTVM_MOZARTVMTARGETMACHINE_H
#define LLVM_LIB_TARGET_MOZARTVM_MOZARTVMTARGETMACHINE_H

#include "MozartVMSubtarget.h"
#include "llvm/CodeGen/CodeGenTargetMachineImpl.h"
#include <optional>

namespace llvm {
extern Target TheMozartVMTarget;

class MozartVMTargetMachine : public CodeGenTargetMachineImpl {
  std::unique_ptr<TargetLoweringObjectFile> TLOF;
  MozartVMSubtarget Subtarget;

public:
  MozartVMTargetMachine(const Target &T, const Triple &TT, StringRef CPU,
                   StringRef FS, const TargetOptions &Options,
                   std::optional<Reloc::Model> RM,
                   std::optional<CodeModel::Model> CM, CodeGenOptLevel OL,
                   bool JIT);

  const MozartVMSubtarget *getSubtargetImpl(const Function &) const override {
    MOZARTVM_DUMP_CYAN
    return &Subtarget;
  }
  // Pass Pipeline Configuration
  TargetPassConfig *createPassConfig(PassManagerBase &PM) override;
  TargetLoweringObjectFile *getObjFileLowering() const override;
};
} // end namespace llvm

#endif // LLVM_LIB_TARGET_MOZARTVM_MOZARTVMTARGETMACHINE_H
