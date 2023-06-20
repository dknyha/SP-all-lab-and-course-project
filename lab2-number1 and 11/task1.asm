;; ¬ар≥ант 1 
;; ¬иконати пор≥вн€нн€ ц≥лих чисел 2-х масив≥в. якщо один  
;; масив при першому цикл≥ пор≥вн€нн€ б≥льше ≥ншого масиву, то 
;; виконати операц≥ю a Ц e/c Ц ab, де a, b, c, d Ц д≥йсн≥ числа;
;; ≥накше Ц виконати операц≥ю ab.

include \masm64\include64\masm64rt.inc  
IDI_ICON EQU 1001  
MSGBOXPARAMSA STRUCT

cbSize	DWORD ?,?
hwndOwner	QWORD ?
hInstance QWORD ?
lpszText QWORD ?
lpszCaption QWORD ?
dwStyle DWORD ?,?
lpszIcon QWORD ?
dwContextHelpId QWORD ?
lpfnMsgBoxCallback QWORD ?
dwLanguageId DWORD ?,?
MSGBOXPARAMSA ENDS
fpuMul macro _a,_b  	; макрос з ≥м'€м fpuMul
fld _a
fmul _b
endm 


.data
params MSGBOXPARAMSA <>
_a REAL4 2.8
_b REAL4 8.05
_c REAL4 2.2
_d REAL4 3.3

arr1 dw 5,6,7,8		; масив чисел arr1 розм≥ром у слово
len1 equ ($-arr1)/type arr1	; к≥льк≥сть чисел масиву
arr2 dw 1,2,3,4	; масив чисел arr2 розм≥ром у слово
len2 equ ($-arr2)/type arr2	; к≥льк≥сть чисел масиву 
tit1 db "ќперац≥њ MMX-FPU",0	; назва в≥кна
st2 dd 0
buf1 db 0,0	; буфер чисел дл€ виведенн€ пов≥домленн€
ifmt db "¬иконати пор≥вн€нн€ ц≥лих чисел 2-х масив≥в.",10,
"якщо один масив при першому цикл≥ пор≥вн€нн€ б≥льше ≥ншого масиву, то виконати операц≥ю",10,
"a Ц d/c Ц ab, де a, b, c, d Ц д≥йсн≥ числа;, де де a = 2,8; b = 8,05; c = 2,2; d = 3,3; Ц д≥йсн≥ числа;",10,
"≥накше Ц виконати операц≥ю ab",10,10,
"¬≥дпов≥дь = %d ",10,10,
"јвтор: 1 1",10,0
len11 equ ($-ifmt)/type ifmt
.code
entry_point proc
movq MM1,QWORD PTR arr1	; завантаженн€ масиву чисел arr1
movq MM2,QWORD PTR arr2	; завантаженн€ масиву чисел arr2
pcmpgtw MM1,MM2	; пор≥внн€ масив≥в
pextrw eax,MM1,0 ; в eax записуЇмо 1 значен€ з масиву arr1
cmp ax,-1 ; перев≥рка чи б≥льший перший елемент arr1 н≥ж arr2
mov rcx,3 ; к≥льк≥сть цикл≥в
jnz @1 ; if != -1
m0: 
PSRLQ MM1, 16 ; зсув масиву правруч на один елемент
pextrw eax,MM1,0 ; в eax записуЇмо 1 значен€ з масиву arr1
cmp ax,-1 ; перев≥рка чи б≥льший перший елемент arr1 н≥ж arr2
jnz @2 ; if != -1
loop m0
jmp @3
@1:
m1: 
PSRLQ MM1, 16 ; зсув масиву правруч на один елемент
pextrw eax,MM1,0 ; в eax записуЇмо 1 значен€ з масиву arr1
cmp ax,0 ; перев≥рка чи менший перший елемент arr1 н≥ж arr2
jnz @2 ; if != 0
loop m1
@3: emms ; зв≥льненн€ сп≥впроцесора
fpuMul [_a],[_b] ; виклик fpuMul
fld _d
fdiv _c
fadd
fsubr _a
jmp @4

@2: emms ; зв≥льненн€ сп≥впроцесора
fpuMul [_a],[_b]  ; виклик fpuMul
@4: fisttp st2 ; збереженн€ ц≥лочисленного значенн€ та округленн€ у б≥к нул€
invoke wsprintf,ADDR buf1,ADDR ifmt,st2
mov params.cbSize,SIZEOF MSGBOXPARAMSA ; розм≥р структури
mov params.hwndOwner,0 		; дескриптор в≥кна власника
invoke GetModuleHandle,0 	; отриманн€ дескриптора програми
mov params.hInstance,rax 	; збереженн€ дескриптора програми
lea rax, buf1 				; адреса пов≥домленн€
mov params.lpszText,rax
lea rax,tit1 ;Caption 		; адреса назви в≥кна
mov params.lpszCaption,rax
mov params.dwStyle,MB_USERICON ; стиль в≥кна
mov params.lpszIcon,IDI_ICON ; ресурс значка
mov params.dwContextHelpId,0 ; контекст дов≥дки
mov params.lpfnMsgBoxCallback,0 ;
mov params.dwLanguageId,LANG_NEUTRAL ; мова пов≥домленн€
lea rcx,params
invoke MessageBoxIndirect
invoke ExitProcess,0
entry_point endp
end

