% Лабораторная работа № 1.1. Раскрутка самоприменимого компилятора
% 18 февраля 2023 г.
% Мельников Андрей, ИУ9-62Б

### Цель работы
Целью данной работы является ознакомление с раскруткой самоприменимых компиляторов на
примере модельного компилятора.

### Индивидуальный вариант
В качестве модельного компилятора выступает компилятор BeRo.
Основная задача - добавить альтернативы ~, & и | для операторов not, and и or соответственно.

### Различие между файлами btpc64macOS.pas и btpc64macOS2.pas:
```
--- btpc64macOS.pas	2024-02-12 18:35:11
+++ btpc64macOS2.pas	2024-02-18 16:15:03
@@ -651,6 +651,15 @@
    end;
    s:=s+1;
   end;
+ end else if CurrentChar='~' then begin
+  ;ReadChar;
+  ;CurrentSymbol:=SymNOT;
+ end else if CurrentChar='&' then begin
+  ReadChar;
+  CurrentSymbol:=SymAND;
+ end else if CurrentChar='|' then begin
+  ReadChar;
+  CurrentSymbol:=SymOR;
  end else if (('0'<=CurrentChar) and (CurrentChar<='9')) or (CurrentChar='$') then begin
   CurrentSymbol:=TokNumber;
   CurrentNumber:=ReadNumber;
\ No newline at end of file
@@ -3440,4 +3449,4 @@
  EmitOpcode2(OPHalt);
  Check(TokPeriod);
  AssembleAndLink;
-end.
+end.
\ No newline at end of file
```
### Различие между файлами btpc64macOS2.pas и btpc64macOS3.pas
```
--- btpc64macOS2.pas	2024-02-18 16:15:03
+++ btpc64macOS3.pas	2024-02-18 16:28:38
@@ -600,7 +600,7 @@
&ensp;&nbsp;end;
&ensp;end else if CurrentChar='$' then begin
&ensp;&nbsp;ReadChar;
-  while (('0'<=CurrentChar) and (CurrentChar<='9')) or
+  while (('0'<=CurrentChar) & (CurrentChar<='9')) |
         (('a'<=CurrentChar) and (CurrentChar<='f')) or
         (('A'<=CurrentChar) and (CurrentChar<='F')) do begin
          if ('0'<=CurrentChar) and (CurrentChar<='9') then begin
\ No newline at end of file
@@ -761,7 +761,7 @@
   if CurrentChar='*' then begin
    ReadChar;
    LastChar:='-';
-   while (CurrentChar<>#0) and not ((CurrentChar=')') and (LastChar='*')) do begin
+   while (CurrentChar<>#0) and ~ ((CurrentChar=')') and (LastChar='*')) do begin
       LastChar:=CurrentChar;
       ReadChar;
      end;
\ No newline at end of file
```
### Тестирование
**Тестовая программа**
```
program Hello;

begin
 if (1<2)&(2<3)|~(4<3)and(1<2)or(not(3<4)) then begin
  WriteLn('Hello, student!');
 end;
end.
```
**Вывод тестовой программы на stdout**
```Hello, student!```

### Вывод
В ходе данной лабораторной работы на практике были закреплены знания о работе самоприменимых 
компиляторов, полученные на лекции на примере компилятора BeRo, получен опыт программирования на
языке Pascal и выполнена поставленная задача. Также были изучены особенности работы компилятора и
его процесса раскрутки. Работа оказалась несложной, но интересной, впервые посмотрел на компилятор
изнутри, смог найти в коде отдельные этапы компиляции, в ходе данной работы былы внесены 
модификации в стадию лексического анализа.
