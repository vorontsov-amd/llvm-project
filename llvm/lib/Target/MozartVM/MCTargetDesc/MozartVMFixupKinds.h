#ifndef LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMFIXUPKINDS_H
#define LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMFIXUPKINDS_H

#include "llvm/MC/MCFixup.h"

namespace llvm {
namespace MozartVM {
// Although most of the current fixup types reflect a unique relocation
// one can have multiple fixup types for a given relocation and thus need
// to be uniquely named.
//
// This table *must* be in the same order of
// MCFixupKindInfo Infos[MozartVM::NumTargetFixupKinds]
// in MozartVMAsmBackend.cpp.
//
enum Fixups {
  fixup_MozartVM_PC16 = FirstTargetFixupKind,
  // Marker
  LastTargetFixupKind,
  NumTargetFixupKinds = LastTargetFixupKind - FirstTargetFixupKind
};
} // namespace MozartVM
} // namespace llvm

#endif
