% Лабораторная работа № 1.1. Раскрутка самоприменимого компилятора
% 18 февраля 2023 г.
% Мельников Андрей, ИУ9-62Б

**Цель работы**
Целью данной работы является ознакомление с раскруткой самоприменимых компиляторов
на примере модельного компилятора.

**Индивидуальный вариант**
В качестве модельного компилятора выступает компилятор BeRo.
Основная задача - добавить альтернативы ~, & и | для операторов not, and и or соответственно.

**Различие между файлами btpc64macOS.pas и btpc64macOS2.pas:**
\-\-- btpc64macOS.pas	2024-02-12 18:35:11
+++ btpc64macOS2.pas	2024-02-18 16:15:03
@@ -651,6 +651,15 @@
&nbsp;&nbsp;&nbsp;&nbsp;end;
&nbsp;&nbsp;&nbsp;&nbsp;s:=s+1;
&nbsp;&nbsp;&nbsp;end;
\+ end else if CurrentChar='~' then begin
\+ &nbsp;ReadChar;
\+ &nbsp;CurrentSymbol:=SymNOT;
\+ end else if CurrentChar='&' then begin
\+ &nbsp;ReadChar;
\+ &nbsp;CurrentSymbol:=SymAND;
\+ end else if CurrentChar='|' then begin
\+ &nbsp;ReadChar;
\+ &nbsp;CurrentSymbol:=SymOR;
&nbsp;&nbsp;end else if (('0'<=CurrentChar) and (CurrentChar<='9')) or (CurrentChar='$') then begin
&nbsp;&nbsp;&nbsp;CurrentSymbol:=TokNumber;
&nbsp;&nbsp;&nbsp;CurrentNumber:=ReadNumber;
\ No newline at end of file
@@ -3440,4 +3449,4 @@
&nbsp;&nbsp;EmitOpcode2(OPHalt);
&nbsp;&nbsp;Check(TokPeriod);
&nbsp;&nbsp;AssembleAndLink;
-end.
+end.
\ No newline at end of file

**Различие между файлами btpc64macOS2.pas и btpc64macOS3.pas:**
\-\-- btpc64macOS2.pas	2024-02-18 16:15:03
+++ btpc64macOS3.pas	2024-02-18 16:28:38
@@ -600,7 +600,7 @@
&nbsp;&nbsp;&nbsp;end;
&nbsp;&nbsp;end else if CurrentChar='$' then begin
&nbsp;&nbsp;&nbsp;ReadChar;
\- &nbsp;while (('0'<=CurrentChar) and (CurrentChar<='9')) or
\+ &nbsp;while (('0'<=CurrentChar) & (CurrentChar<='9')) |
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
