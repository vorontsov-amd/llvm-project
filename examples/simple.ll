; ModuleID = 'simple.c'
source_filename = "simple.c"
target datalayout = "e-m:e-p:32:32-i8:8:32-i16:16:32-i64:64-n32"
target triple = "mozartVM"

; Function Attrs: mustprogress noinline nounwind optnone
define dso_local void @_Z3appv() #0 {
entry:
  %y = alloca i32, align 4
  %x = alloca i32, align 4
  br label %while.body

while.body:                                       ; preds = %entry, %for.end7
  store i32 0, ptr %y, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc5, %while.body
  %0 = load i32, ptr %y, align 4
  %cmp = icmp slt i32 %0, 1000
  br i1 %cmp, label %for.body, label %for.end7

for.body:                                         ; preds = %for.cond
  store i32 0, ptr %x, align 4
  br label %for.cond1

for.cond1:                                        ; preds = %for.inc, %for.body
  %1 = load i32, ptr %x, align 4
  %cmp2 = icmp slt i32 %1, 1000
  br i1 %cmp2, label %for.body3, label %for.end

for.body3:                                        ; preds = %for.cond1
  %2 = load i32, ptr %x, align 4
  %3 = load i32, ptr %y, align 4
  %4 = load i32, ptr %x, align 4
  %add = add nsw i32 255, %4
  %5 = load i32, ptr %y, align 4
  %add4 = add nsw i32 %add, %5
  call void @llvm.mozartVM.putpixel(i32 %2, i32 %3, i32 %add4)
  br label %for.inc

for.inc:                                          ; preds = %for.body3
  %6 = load i32, ptr %x, align 4
  %inc = add nsw i32 %6, 1
  store i32 %inc, ptr %x, align 4
  br label %for.cond1, !llvm.loop !3

for.end:                                          ; preds = %for.cond1
  br label %for.inc5

for.inc5:                                         ; preds = %for.end
  %7 = load i32, ptr %y, align 4
  %inc6 = add nsw i32 %7, 1
  store i32 %inc6, ptr %y, align 4
  br label %for.cond, !llvm.loop !5

for.end7:                                         ; preds = %for.cond
  br label %while.body, !llvm.loop !6
}

; Function Attrs: nounwind
declare void @llvm.mozartVM.putpixel(i32, i32, i32) #1

attributes #0 = { mustprogress noinline nounwind optnone "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { nounwind }

!llvm.module.flags = !{!0, !1}
!llvm.ident = !{!2}

!0 = !{i32 1, !"wchar_size", i32 1}
!1 = !{i32 7, !"frame-pointer", i32 2}
!2 = !{!"clang version 20.1.4 (git@github.com:vorontsov-amd/llvm-project.git 28e76154f5210ef5349c658947d2672f83539519)"}
!3 = distinct !{!3, !4}
!4 = !{!"llvm.loop.mustprogress"}
!5 = distinct !{!5, !4}
!6 = distinct !{!6, !4}
