#include "MozartVMInstrInfo.h"
#include "MozartVM.h"
#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineMemOperand.h"
#include "llvm/MC/TargetRegistry.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ErrorHandling.h"

using namespace llvm;

#define GET_INSTRINFO_CTOR_DTOR
#include "MozartVMGenInstrInfo.inc"

#define DEBUG_TYPE "MozartVM-inst-info"

MozartVMInstrInfo::MozartVMInstrInfo() : MozartVMGenInstrInfo() { MOZARTVM_DUMP_GREEN }
