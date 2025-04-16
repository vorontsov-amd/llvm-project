#ifndef LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCASMINFO_H
#define LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCASMINFO_H

#include "llvm/MC/MCAsmInfoELF.h"

namespace llvm {

class Triple;

class MozartVMELFMCAsmInfo : public MCAsmInfoELF {
public:
  explicit MozartVMELFMCAsmInfo(const Triple &TheTriple);
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCASMINFO_H