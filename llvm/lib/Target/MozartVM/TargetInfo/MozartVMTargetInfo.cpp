#include "TargetInfo/MozartVMTargetInfo.h"
#include "MozartVM.h"
#include "llvm/MC/TargetRegistry.h"

using namespace llvm;

Target &llvm::getTheMozartVMTarget() {
  // MOZARTVM_DUMP_YELLOW
  static Target TheMozartVMTarget;
  return TheMozartVMTarget;
}

extern "C" LLVM_EXTERNAL_VISIBILITY void LLVMInitializeMozartVMTargetInfo() {
  // MOZARTVM_DUMP_YELLOW
  RegisterTarget<Triple::mozartVM> X(getTheMozartVMTarget(), "mozartVM",
                                "Simulator target for LLVM course", "MOZARTVM");
}
