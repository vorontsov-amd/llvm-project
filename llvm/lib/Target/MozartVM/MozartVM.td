include "llvm/Target/Target.td"
include "MozartVMRegisterInfo.td"
include "MozartVMInstrInfo.td"
include "MozartVMCallingConv.td"

class Proc<string Name, list<SubtargetFeature> Features>
 : Processor<Name, NoItineraries, Features>;

def : Proc<"generic", []>;

def MozartVMInstrInfo : InstrInfo;
def MozartVM : Target {
  let InstructionSet = MozartVMInstrInfo;
}
