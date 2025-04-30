//===----------------------------------------------------------------------===//
// MozartVM profiles and nodes
//===----------------------------------------------------------------------===//

def SDT_MozartVMBrCC  : SDTypeProfile<0, 2, [ SDTCisVT<0, i32>,
                                         SDTCisVT<1, OtherVT>]>;

def mozartVM_brcc     : SDNode<"MozartVMISD::BR_CC", SDT_MozartVMBrCC,
                            [SDNPHasChain]>;

def mozartVM_ret      : SDNode<"MozartVMISD::RET", SDTNone,
                            [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;


def SDT_MozartVMCallSetup : SDTypeProfile<0, 1, [ 
    SDTCisVT<0, i32> 
]>;

def mozartVM_call_setup : SDNode<"MozartVMISD::CALL_SETUP", SDT_MozartVMCallSetup,
                               [SDNPHasChain, SDNPOptInGlue]>;

def SDT_MozartVMCallAlloc : SDTypeProfile<1, 2, [
    SDTCisVT<0, i32>, 
    SDTCisVT<1, i32>, 
    SDTCisVT<2, i32>  
]>;

def mozartVM_call_alloc : SDNode<"MozartVMISD::CALL_ALLOC", SDT_MozartVMCallAlloc,
                               [SDNPHasChain]>;

def SrcValue : SDNode<"MozartVMISD::SRC_VALUE", SDTIntUnaryOp>;

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

def HI16 : SDNodeXForm<imm, [{
  if (const auto *GA = dyn_cast<GlobalAddressSDNode>(N)) {
    uint64_t Val = GA->getOffset();
    return CurDAG->getTargetConstant((Val >> 16) & 0xFFFF, SDLoc(N), MVT::i32);
  }
  return CurDAG->getTargetConstant((N->getZExtValue() >> 16) & 0xFFFF, SDLoc(N), MVT::i32);
}]>;

def LI16 : SDNodeXForm<imm, [{
  if (const auto *GA = dyn_cast<GlobalAddressSDNode>(N)) {
    uint64_t Val = GA->getOffset();
    return CurDAG->getTargetConstant(Val & 0xFFFF, SDLoc(N), MVT::i32);
  }
  return CurDAG->getTargetConstant(N->getZExtValue() & 0xFFFF, SDLoc(N), MVT::i32);
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

let isBranch = 1, isTerminator = 1, r2 = 0 in
def BR_COND : MozartVMInst<0x09, (outs), (ins GPR:$r1, btarget16:$r3_imm),
                      "BR_COND $r1 $r3_imm", [(mozartVM_brcc GPR:$r1, bb:$r3_imm)]>;

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

let isCodeGenOnly = 0, mayLoad = 1 in
def LD : MozartVMInst<0x0C, 
    (outs GPR:$r1), 
    (ins GPR:$r2, simm16:$r3_imm), 
    "ld $r1, $r3_imm($r2)",       
    [(set GPR:$r1, (load (add GPR:$r2, simm16:$r3_imm)))]>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in
def ADDI : MozartVMInst<0x0D, (outs GPR:$r1), (ins GPR:$r2, simm16:$r3_imm),
                   "ADDI $r1, $r2, $r3_imm",
                   [(set GPR:$r1, (add GPR:$r2, simm16:$r3_imm))]>;

// В MozartVMInstrInfo.td
def call_setup : SDNode<"MozartVMISD::CALL_SETUP", SDTNone,
                        [SDNPHasChain, SDNPOptInGlue]>;

let isCodeGenOnly = 1, isPseudo = 1 in
def PseudoCALL_SETUP : MozartVMPseudoInst<(outs), (ins GPR:$addr),
                                        "# CALL_SETUP",
                                        [(mozartVM_call_setup GPR:$addr)]>;

let isCodeGenOnly = 1, isPseudo = 1 in
def PseudoCALL_ALLOC : MozartVMPseudoInst<
    (outs GPR:$dst), 
    (ins GPR:$addr1, GPR:$addr2),
    "# CALL_ALLOC",
    [(set GPR:$dst, (mozartVM_call_alloc GPR:$addr1, GPR:$addr2))]>;


let hasSideEffects = 0, mayLoad = 1 in
def LOAD_SRC : MozartVMInst<0x10,
    (outs GPR:$r1),          // Выходной регистр
    (ins GPR:$r2, simm16:$r3_imm),  // Входные: регистр и immediate
    "load_src $r1, $r3_imm",  // Ассемблерный шаблон (r2 не используется)
    [(set GPR:$r1, (SrcValue simm16:$r3_imm))]> {
  
  // 2. Явно укажите, что r2 игнорируется
  let r2 = 0;  // Фиктивный операнд
  let hasSideEffects = 0;  // Нет побочных эффектов
}
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

def : Pat<(i32 (globaladdr:$sym)),
          (ORI (MOVHI (HI16 (i32 (tglobaladdr:$sym)))), 
               (MOVLI (LI16 (i32 (tglobaladdr:$sym)))))>;

def : Pat<(add GPR:$r2, simm16:$offset), (ADDI GPR:$r2, simm16:$offset)>;

