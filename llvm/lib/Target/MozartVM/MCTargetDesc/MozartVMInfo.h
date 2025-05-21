#ifndef LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMINFO_H
#define LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMINFO_H

#include "llvm/MC/MCInstrDesc.h"

namespace llvm {

namespace MozartVMCC {
enum CondCode {
  EQ,
  NE,
  LE,
  GT,
  LEU,
  GTU,
  INVALID,
};
}

namespace MozartVMOp {
enum OperandType : unsigned {
  OPERAND_SIMM16 = MCOI::OPERAND_FIRST_TARGET,
};
} // namespace MozartVMOp

} // end namespace llvm

#endif
