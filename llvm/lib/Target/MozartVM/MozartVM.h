#ifndef LLVM_LIB_TARGET_MozartVM_MozartVM_H
#define LLVM_LIB_TARGET_MozartVM_MozartVM_H

#include "MCTargetDesc/MozartVMMCTargetDesc.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Target/TargetMachine.h"

#define MOZARTVM_DUMP(Color)                                                        \
  {                                                                            \
    llvm::errs().changeColor(Color)                                            \
        << __func__ << "\n\t\t" << __FILE__ << ":" << __LINE__ << "\n";        \
    llvm::errs().changeColor(llvm::raw_ostream::WHITE);                        \
  }
// #define MOZARTVM_DUMP(Color) {}

#define MOZARTVM_DUMP_RED MOZARTVM_DUMP(llvm::raw_ostream::RED)
#define MOZARTVM_DUMP_GREEN MOZARTVM_DUMP(llvm::raw_ostream::GREEN)
#define MOZARTVM_DUMP_YELLOW MOZARTVM_DUMP(llvm::raw_ostream::YELLOW)
#define MOZARTVM_DUMP_CYAN MOZARTVM_DUMP(llvm::raw_ostream::CYAN)
#define MOZARTVM_DUMP_MAGENTA MOZARTVM_DUMP(llvm::raw_ostream::MAGENTA)
#define MOZARTVM_DUMP_WHITE MOZARTVM_DUMP(llvm::raw_ostream::WHITE)
namespace llvm {
class MozartVMTargetMachine;
class FunctionPass;
class MozartVMSubtarget;
class AsmPrinter;
class InstructionSelector;
class MCInst;
class MCOperand;
class MachineInstr;
class MachineOperand;
class PassRegistry;

bool lowerMozartVMMachineInstrToMCInst(const MachineInstr *MI, MCInst &OutMI,
                                  AsmPrinter &AP);
bool LowerMozartVMMachineOperandToMCOperand(const MachineOperand &MO,
                                       MCOperand &MCOp, const AsmPrinter &AP);
FunctionPass *createMozartVMISelDag(MozartVMTargetMachine &TM, CodeGenOptLevel OptLevel);

} // namespace llvm

#endif // LLVM_LIB_TARGET_MozartVM_MozartVM_H