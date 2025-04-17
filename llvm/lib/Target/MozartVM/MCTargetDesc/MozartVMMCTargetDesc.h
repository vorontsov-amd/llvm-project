#ifndef LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCTARGETDESC_H
#define LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCTARGETDESC_H

#include <memory>
namespace llvm {
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCAsmBackend;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class MCTargetOptions;
class Target;

MCCodeEmitter *createMozartVMMCCodeEmitter(const MCInstrInfo &MCII, MCContext &Ctx);
MCAsmBackend *createMozartVMAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                  const MCRegisterInfo &MRI,
                                  const MCTargetOptions &Options);
std::unique_ptr<MCObjectTargetWriter> createMozartVMELFObjectWriter(bool Is64Bit,
                                                               uint8_t OSABI);
} // namespace llvm

// Defines symbolic names for MozartVM registers.  This defines a mapping from
// register name to register number.
//
#define GET_REGINFO_ENUM
#include "MozartVMGenRegisterInfo.inc"

// Defines symbolic names for the MozartVM instructions.
#define GET_INSTRINFO_ENUM
#include "MozartVMGenInstrInfo.inc"

#endif // LLVM_LIB_TARGET_MOZARTVM_MCTARGETDESC_MOZARTVMMCTARGETDESC_H
