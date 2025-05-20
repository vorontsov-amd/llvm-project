//===----------------------------------------------------------------------===//
// MozartVM profiles and nodes
//===----------------------------------------------------------------------===//

def SDT_MozartVMBrCC : SDTypeProfile<0, 4, [ SDTCisSameAs<0, 1>,
                                           SDTCisVT<2, OtherVT>,
                                           SDTCisVT<3, OtherVT>]>;

def mozartVM_brcc     : SDNode<"MozartVMISD::BR_CC", SDT_MozartVMBrCC,
                            [SDNPHasChain]>;

def mozartVM_ret      : SDNode<"MozartVMISD::RET", SDTNone,
                            [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

//===----------------------------------------------------------------------===//
// Instruction format superclass
//===----------------------------------------------------------------------===//

include "MozartVMInstrFormats.td"

//===----------------------------------------------------------------------===//
// MozartVM Operand, Complex Patterns and Transformations Definitions.
//===----------------------------------------------------------------------===//

class SImmAsmOperand<int width> : AsmOperandClass {
  let Name = "SImm" # width;
  let RenderMethod = "addImmOperands";
  let DiagnosticType = !strconcat("Invalid", Name);
}

def simm16 : Operand<i32>, ImmLeaf<i32, [{return isUInt<16>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<16>;
  let EncoderMethod = "getSImm16OpValue";
  let DecoderMethod = "decodeSImmOperand<16>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<16>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  let OperandType = "OPERAND_SIMM16";
  let OperandNamespace = "MozartVMOp";
}

def btarget16 : Operand<OtherVT> {
  let ParserMatchClass = SImmAsmOperand<16>;
  let PrintMethod = "printBranchOperand";
  let EncoderMethod = "getBranchTarget16OpValue";
  let DecoderMethod = "decodeSImmOperand<16>";
  let MCOperandPredicate = [{
    int64_t Imm;
    if (MCOp.evaluateAsConstantImm(Imm))
      return isInt<16>(Imm);
    return MCOp.isBareSymbolRef();
  }];
  let OperandType = "OPERAND_PCREL";
}

def LI16 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant((uint64_t)N->getZExtValue() & 0xffff,
                                  SDLoc(N), MVT::i32);
}]>;

def HI16 : SDNodeXForm<imm, [{
  return CurDAG->getTargetConstant((uint64_t)N->getZExtValue() >> 16, SDLoc(N),
                                  MVT::i32);
}]>;

//===----------------------------------------------------------------------===//
// MozartVM Instructions
//===----------------------------------------------------------------------===//


let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isBarrier = 1, isBranch = 1, isTerminator = 1, r1 = 0, r2 = 0 in
def B : MozartVMInst<0x05, (outs), (ins btarget16:$r3_imm), "B $r3_imm",
                [(br bb:$r3_imm)]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isCall = 1, isBranch = 1, isTerminator = 1, r2 = 0, r3_imm = 0 in
def BR : MozartVMInst<0x01, (outs), (ins GPR:$r1), "BR $r1",
                 [(brind GPR:$r1)]>;

let isBarrier = 1, isReturn = 1, isTerminator = 1 in
def PseudoRET : MozartVMPseudoInst<(outs), (ins), "# PseudoRET",
                [(mozartVM_ret)]>,
                PseudoInstExpansion<(BR R0)>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def INC_EQi : MozartVMInst<0x08, (outs GPR:$r1, GPR:$r2_), (ins GPR:$r2, simm16:$r3_imm),
                      "INC_EQi $r1 $r2 $r3_imm", []>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def INC_NEi : MozartVMInst<0x09, (outs GPR:$r1, GPR:$r2_), (ins GPR:$r2, simm16:$r3_imm),
                      "INC_NEi $r1 $r2 $r3_imm", []>;

//let isBranch = 1, isTerminator = 1, r2 = 0 in
//def BR_COND : MozartVMInst<0x09, (outs), (ins GPR:$r1, btarget16:$r3_imm),
//                      "BR_COND $r1 $r3_imm", [(mozartVM_brcc GPR:$r1, bb:$r3_imm)]>;

def IsOrAdd: PatFrag<(ops node:$A, node:$B), (or node:$A, node:$B), [{
  return isOrEquivalentToAdd(N);
}]>;

// movli
let isAsCheapAsAMove = 1, isCodeGenOnly = 1, isReMaterializable = 1, r2 = 0 in
def MOVLI : MozartVMInst<0x02, (outs GPR:$r1), (ins simm16:$r3_imm),
                    "MOVli $r1 $r3_imm",
                    [(set GPR:$r1, simm16:$r3_imm)]>;
// movhi
let isAsCheapAsAMove = 1, isCodeGenOnly = 1, isReMaterializable = 1, r2 = 0  in
def MOVHI : MozartVMInst<0x06, (outs GPR:$r1), (ins simm16:$r3_imm),
                    "MOVhi $r1 $r3_imm", []>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def ADD : MozartVMInst<0x0A, (outs GPR:$r1), (ins GPR:$r2, GPR:$r3_imm),
               "ADD $r1 $r2 $r3_imm", [(set GPR:$r1, (add GPR:$r2, GPR:$r3_imm))]>;

// sub
let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def SUB : MozartVMInst<0x18, (outs GPR:$r1), (ins GPR:$r2, GPR:$r3_imm),
              "SUB $r1 $r2 $r3_imm", [(set GPR:$r1, (sub GPR:$r2, GPR:$r3_imm))]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def MUL : MozartVMInst<0x0B, (outs GPR:$r1), (ins GPR:$r2, GPR:$r3_imm),
               "MUL $r1 $r2 $r3_imm", [(set GPR:$r1, (mul GPR:$r2, GPR:$r3_imm))]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def ORI : MozartVMInst<0x07, (outs GPR:$r1), (ins GPR:$r2, simm16:$r3_imm),
                  "ORi $r1 $r2 $r3_imm", [(set GPR:$r1, (or GPR:$r2, simm16:$r3_imm))]>;

// flush
let r1 = 0, r2 = 0, r3_imm = 0 in
def FLUSH : MozartVMInst<0x03, (outs), (ins), "FLUSH", [(int_mozartVM_flush)]>;

// putpixel
def PUTPIXEL : MozartVMInst<0x04, (outs), (ins GPR:$r1, GPR:$r2, GPR:$r3_imm),
                      "PUTPIXEL $r1 $r2 $r3_imm", [(int_mozartVM_putpixel GPR:$r1, GPR:$r2, GPR:$r3_imm)]>;

def BaseAddr : ComplexPattern<iPTR, 1, "SelectBaseAddr">;
def AddrFI : ComplexPattern<iPTR, 1, "SelectAddrFI", [frameindex], []>;

class PatBcc<CondCode Cond, MozartVMInst Inst>
    : Pat<(mozartVM_brcc GPR:$r1, GPR:$r2, Cond, bb:$r3_imm),
          (Inst GPR:$r1, GPR:$r2, btarget16:$r3_imm)>;

// store
let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in
def STORE: MozartVMInst<0x0C, (outs), (ins GPR:$r1, GPR:$r2, simm16:$r3_imm),
              "STORE $r1 ${r2} ${r3_imm}",
              []>;
def : Pat<(store (i32 GPR:$r1), BaseAddr:$r2),
        (STORE GPR:$r1, BaseAddr:$r2, 0)>;
def : Pat<(store (i32 GPR:$r1), (add BaseAddr:$r2, simm16:$r3_imm)),
        (STORE GPR:$r1, BaseAddr:$r2, simm16:$r3_imm)>;
def : Pat<(store (i32 GPR:$r1), (IsOrAdd AddrFI:$r2, simm16:$r3_imm)),
         (STORE GPR:$r1, AddrFI:$r2, simm16:$r3_imm)>;

// load
let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in
def LOAD: MozartVMInst<0x0D, (outs GPR:$r1), (ins GPR:$r2, simm16:$r3_imm),
              "LOAD $r1 ${r2} ${r3_imm}",
              []>;
def : Pat<(i32 (load BaseAddr:$r2)), (LOAD BaseAddr:$r2, 0)>;
def : Pat<(i32 (load (add BaseAddr:$r2, simm16:$r3_imm))),
          (LOAD BaseAddr:$r2, simm16:$r3_imm)>;
def : Pat<(i32 (load (IsOrAdd AddrFI:$r2, simm16:$r3_imm))),
           (LOAD AddrFI:$r2, simm16:$r3_imm)>;


let hasSideEffects = 0, mayLoad = 0, mayStore = 0, isBranch = 1, isTerminator = 1 in
class BranchCC<bits<8> op, string opcodestr>
    : MozartVMInst<op, (outs), (ins GPR:$r1, GPR:$r2, btarget16:$r3_imm),
              !strconcat(opcodestr, " $r1 $r2 $r3_imm"), []>;

def BEQ  : BranchCC<0x0E, "B.EQ">;
def BNE  : BranchCC<0x0F, "B.NE">;
def BLE  : BranchCC<0x10, "B.LE">;
def BGT  : BranchCC<0x11, "B.GT">;
def BLEU  : BranchCC<0x12, "B.LEU">;
def BGTU  : BranchCC<0x13, "B.GTU">;

def : PatBcc<SETEQ, BEQ>;
def : PatBcc<SETNE, BNE>;
def : PatBcc<SETLE, BLE>;
def : PatBcc<SETGT, BGT>;
def : PatBcc<SETULE, BLEU>;
def : PatBcc<SETUGT, BGTU>;


let hasSideEffects = false, mayLoad = false, mayStore = false in
class Shifts<bits<8> op, SDPatternOperator OpNode, string opcodestr>
    : MozartVMInst<op, (outs GPR:$r1), (ins GPR:$r2, simm16:$r3_imm),
                !strconcat(opcodestr, " $r1, $r2, $r3_imm"),
                [(set GPR:$r1, (OpNode GPR:$r2, simm16:$r3_imm))]>;


def SRL : Shifts<0x14, srl, "SRL">;
def SRA : Shifts<0x15, sra, "SRA">;
def SHL : Shifts<0x16, shl, "SHL">;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def XOR : MozartVMInst<0x17, (outs GPR:$r1), (ins GPR:$r2, GPR:$r3_imm),
               "XOR $r1 $r2 $r3_imm", [(set GPR:$r1, (xor GPR:$r2, GPR:$r3_imm))]>;

//===----------------------------------------------------------------------===//
// MozartVM Other patterns
//===----------------------------------------------------------------------===//

def i32hi16 : Operand<i32>, PatLeaf<(i32 imm), [{
    // i32hi16 predicate - true if the 32-bit immediate has only leftmost 16
    // bits set.
    return ((N->getZExtValue() & 0xFFFF0000UL) == N->getZExtValue());}], HI16> {
}

// i32 imm
def : Pat<(i32 imm:$r3_imm), (ORI (MOVHI (HI16 imm:$r3_imm)), (LI16 imm:$r3_imm))>;
def : Pat<(i32 i32hi16:$r3_imm), (MOVHI i32hi16:$r3_imm)>;
