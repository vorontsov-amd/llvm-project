# MozartVM backend for LLVM course

## Build LLVM

```
git checkout release/20.x
cmake -S llvm -B build -G Ninja -DLLVM_USE_LINKER=mold -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_ASSERTIONS=ON -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_ENABLE_PROJECTS="clang"
ninja -C build
./build/bin/llc --version
```

## Tasks 1. Register your LLVM target

Commit id: [e1422a39680ceba840befbc41a27fae4a385f9b1](https://github.com/vorontsov-amd/llvm-project/commit/e1422a39680ceba840befbc41a27fae4a385f9b1)

```
../build/bin/llc --version
../build/bin/clang -print-targets 
```
Expected output:
```
  Registered Targets:
    mozartVM - MozartVM target for LLVM course
    x86      - 32-bit X86: Pentium-Pro and above
    x86-64   - 64-bit X86: EM64T and AMD64
```

## Task 2. Generate simple ASM

Commit id: [e1422a39680ceba840befbc41a27fae4a385f9b1](https://github.com/vorontsov-amd/llvm-project/commit/e1422a39680ceba840befbc41a27fae4a385f9b1)

`cat test.ll` :
```
define dso_local i32 @main() {
  ret i32 12
}
```

Compile:
```
../build/bin/llc ./test.ll -march mozartVM
```

`cat test.s` :

```
        .file   "test.ll"
        .text
        .globl  main                            ; -- Begin function main
        .type   main,@function
main:                                   ; @main
; %bb.0:
        MOVli r9 12
        BR r0
.Lfunc_end0:
        .size   main, .Lfunc_end0-main
                                        ; -- End function
        .section        ".note.GNU-stack","",@progbits
```

## Task 3. Generate object file

Commit id: [1627e18faad693bc6b40648c1bedde2a62747d37](https://github.com/vorontsov-amd/llvm-project/commit/1627e18faad693bc6b40648c1bedde2a62747d37)

Compile:
```
../build/bin/llc test.ll -march mozartVM --filetype=obj
```


Check object file with llvm-readobj:
```
../build/bin/llvm-readobj test.o
```
Expected output:
```
File: test.o
Format: elf32-mozartVM
Arch: mozartVM
AddressSize: 32bit
LoadName: <Not found>
```

Check object file with llvm-readelf:
```
../build/bin/llvm-readelf -a test.o
```
Expected output:
```
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              REL (Relocatable file)
  Machine:                           MozartVM target for LLVM course
  Version:                           0x1
  Entry point address:               0x0
  Start of program headers:          0 (bytes into file)
  Start of section headers:          160 (bytes into file)
  Flags:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           0 (bytes)
  Number of program headers:         0
  Size of section headers:           40 (bytes)
  Number of section headers:         5
  Section header string table index: 1
There are 5 section headers, starting at offset 0xa0:

Section Headers:
  [Nr] Name              Type            Address  Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .strtab           STRTAB          00000000 00006c 000034 00      0   0  1
  [ 2] .text             PROGBITS        00000000 000034 000008 00  AX  0   0  4
  [ 3] .note.GNU-stack   PROGBITS        00000000 00003c 000000 00      0   0  1
  [ 4] .symtab           SYMTAB          00000000 00003c 000030 10      1   2  4
```

Check inctructions in object file:
```
hexedit test.o
```
Expected output:
```
...
00000034   0C 00 90 02  00 00 00 01  ...
...
```

* 0x01 is BR instruction
* 0x02 is MOVLI instruction

## Task 4. Add graphical intrinsics and throw their usage into clang via ClangBuiltins

Commit id: [f5dcca9d4eaf1d46f20cc988df5316c749cfadb4](https://github.com/vorontsov-amd/llvm-project/commit/f5dcca9d4eaf1d46f20cc988df5316c749cfadb4)

[Graphics APIs from the first semester](https://github.com/vorontsov-amd/compiler_course/blob/main/task_1/src/sdl.h) (In the future, functions will need to be renamed according to intrinsics)

`cat graphic.ll` :
```
define dso_local void @app() {
entry:
  call void @llvm.mozartVM.putpixel(i32 5, i32 5, i32 -1)
  call void @llvm.mozartVM.flush()
  ret void
}

declare void @llvm.mozartVM.putpixel(i32, i32, i32)

declare void @llvm.mozartVM.flush()
```

Compile:
```
../build/bin/llc graphic.ll -march mozartVM --filetype=asm
```

`cat graphic.s`
```
        .file   "graphics.c"
        .text
        .globl  app                             ; -- Begin function app
        .type   app,@function
app:                                    ; @app
; %bb.0:                                ; %entry
        MOVli r2 -1
        MOVli r4 5
        PUTPIXEL r4 r4 r2
        FLUSH
        BR r0
.Lfunc_end0:
        .size   app, .Lfunc_end0-app
                                        ; -- End function
        .ident  "clang version 20.1.4 (git@github.com:vorontsov-amd/llvm-project.git 1627e18faad693bc6b40648c1bedde2a62747d37)"
        .section        ".note.GNU-stack","",@progbits
```

Check clang:

`cat graphic.c` : 
```
void app() {
    mozartVMPutPixel(5, 5, 0xFFFFFFFF);
    mozartVMFlush();
}
```

Compile with clang:
```
../build/bin/clang -emit-llvm -S graphic.c -target mozartVM
```

`cat graphic.ll` :
```
; ModuleID = 'graphic.c'
source_filename = "graphic.c"
target datalayout = "e-m:e-p:32:32-i8:8:32-i16:16:32-i64:64-n32"
target triple = "mozartVM"

; Function Attrs: noinline nounwind optnone
define dso_local void @app() #0 {
entry:
  call void @llvm.mozartVM.putpixel(i32 5, i32 5, i32 -1)
  call void @llvm.mozartVM.flush()
  ret void
}

; Function Attrs: nounwind
declare void @llvm.mozartVM.putpixel(i32, i32, i32) #1

; Function Attrs: nounwind
declare void @llvm.mozartVM.flush() #1

attributes #0 = { noinline nounwind optnone "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 1}
!1 = !{i32 7, !"frame-pointer", i32 2}
!2 = !{!"clang version 20.1.4 (git@github.com:vorontsov-amd/llvm-project.git 1627e18faad693bc6b40648c1bedde2a62747d37)"}
```

Compile object file using clang:
```
../build/bin/clang -c graphic.c -target mozartVM
```

`hexedit graphic.o` :
```
...
00000034    FF FF 40 02  05 00 20 02  04 00 22 04  00 00 00 03  00 00 00 01  ...
...
```

```
FF FF 40 02 	MOVli r2 -1
05 00 20 02 	MOVli r4 5
04 00 22 04 	PUTPIXEL r4 r4 r2
00 00 00 03 	FLUSH
00 00 00 01 	BR r0
```

## Task 5. Add full support for graphich appication

Commit id: [480c5be3070f3b408e1b291477122e5650b7a2df](https://github.com/vorontsov-amd/llvm-project/commit/480c5be3070f3b408e1b291477122e5650b7a2df)

Commit id: [27119846da14ec3a56f6f2e19992a705a7089862](https://github.com/vorontsov-amd/llvm-project/commit/27119846da14ec3a56f6f2e19992a705a7089862)

Commit id: [1be3df751c7148ef6bc86c44a963d59fce416c75](https://github.com/vorontsov-amd/llvm-project/commit/1be3df751c7148ef6bc86c44a963d59fce416c75)

Commit id: [28e76154f5210ef5349c658947d2672f83539519](https://github.com/vorontsov-amd/llvm-project/commit/28e76154f5210ef5349c658947d2672f83539519)

Commit id: [b7bbde6b05f9c2e0f8f54570f2803ab8687449ad](https://github.com/vorontsov-amd/llvm-project/commit/b7bbde6b05f9c2e0f8f54570f2803ab8687449ad)

Commit id: [440bca067ba3c02092ce50b6682d452888bf8507](https://github.com/vorontsov-amd/llvm-project/commit/440bca067ba3c02092ce50b6682d452888bf8507)


### Modern application from 1st semester

[Original](https://github.com/vorontsov-amd/compiler_course/blob/main/task_1/src/main.cpp)

[Simlified variant](./graphic.c)

Gerenate ASM

```
../build/bin/clang++ -S -O0 graphic.c -target mozartVM
```

Click to see ASM [here](./graphic.s)

Click to see IR [here](./graphic.ll)

Compile binary

```
../build/bin/clang++ -c -O0 graphic.c -target mozartVM
```

## Task 6. Simulator

Clone [repository](https://github.com/vorontsov-amd/simlinx/tree/llvm-course)

```
git clone https://github.com/vorontsov-amd/simlinx
cd simlinx
git switch llvm-course
```

Build
```
python3 -m venv .venv
source .venv/bin/activate

pip install -r requirements.txt
pip install -e .

cmake -B build
cmake --build build
```

Run graphic application

```
./build/bin/simlinx ./examples/graphic.o
```
