;; Варіант 1
;; Виконати паралельне порівняння 2-х масивів по 6 64-розрядних дійсних числа.
;; Якщо всі числа другого масиву більше першого,
;; то скласти всі числа другого масиву, а якщо навпаки – то першого. 
include \masm64\include64\masm64rt.inc ; подключаемые библиотеки

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

.data
params MSGBOXPARAMSA <>     	         				
mas2 dd 1.4, 2.1, 3.8, 4.6, 5.4, 6.12
mas1 dd -1.34,-5.0,-3.54,1.5,-5.8,-6.53
len1 equ ($-mas2)/ type mas2 ; количество чисел массива mas2
res dd len1 DUP(0),0
fmt db "Виконати паралельне порівняння 2-х масивів по 6-ть 64-розрядних дійсних числа.",10,
"Результат складання одного з масивів:  %d", 10,10,
"Автор:  1 1",0
buf dq 0,0 ; размер буфера
titl1 db "masm64. Паралельне порівняння за допомогою AVX-команд",0; название окошка
buf1 dq 0,0 

.code
entry_point proc				
mov eax,len1   ; 
mov ebx,4      ; количество 32-разрядных чисел в 128 разрядном регистре
xor edx,edx    ; 
div ebx  ; определение количества циклов для параллельного считывания и остатка
mov ecx,eax       ; счетчик циклов для параллельного считывания
lea rsi,mas1  	; 
lea rdi,mas2  	; 
next:  vmovups XMM0,xmmword ptr [rsi]; 4- 32 числа из mas1
vmovups XMM1,[rdi]     ; 4-  32 числа из mas2
vcmpltps xmm10,XMM0,XMM1 ; сравнение на меньше: если меньше, то нули
vmovmskps ebx,xmm10 ; перенесение знаковых битов
add rsi,16 ; подготовка адреса для нового считывания mas1
add rdi,16 ; подготовка адреса для нового считывания mas2
dec ecx    ; уменьшение счетчика циклов
jnz m1     ; проверка счетчика на ненулевое значение
jmp m2     ;
m1: mov r10,rbx 
shl r10,4 ; сдвиг налево на 4 бита
jmp next       ; на новый цикл
m2:  cmp edx,0  ; проверка остатка
jz _end         ; 
mov ecx,edx   ; если в остатке не нуль, то установка счетчика
m4:   
vmovss XMM0,dword ptr[rsi]    ; 
vmovss XMM1,dword ptr[rdi]    ; 
vcomiss XMM0,XMM1 ; сравнение младших чисел массивов
jg @f  	  ; если больше
shl r10,1 ; сдвиг налево на 1 разряд
inc r10   ; встановление 1, поскольку XMM0[0] < XMM1[0]
jmp m3
@@:
shl r10,1 ; сдвиг налево на 1 разряд
m3: 
add rsi,4  ; адреса для нового числа mas1
add rdi,4  ; адреса для нового числа mas2
loop m4
_end:
mov rax,len1 ; количество чисел в массиве
mov rbx,4 ; количество одновременно занесенных чисел в XMM
xor rdx,rdx ; сложение по модулем 2 (обнуление)
div rbx ; rax := 4 – количество циклов rdx := 1
mov rcx,rax ; загрузка счетчика
lea rsi,mas1 ; rsi := addr mas1
lea rdi,mas2 ; rdi := addr mas2
lea rbx,res ; занесение начала массив

mb:
cmp r10,0 	; проверка знаковых битов
jz m7
vmovups XMM0,[rdi] ; mas2
jmp m8
m7: vmovups XMM0,[rsi] ; mas1 ;
m8:

vunpckhpd xmm4,xmm4,xmm0 ; розпакування ст. ч. xmm0 у ст. ч. xmm4 та зсув мол. ч. xmm4
vunpckhpd xmm4,xmm4,xmm5 ; переміщення ст. частини xmm4 у мол. ч. xmm4
vunpcklpd xmm5,xmm5,xmm0 ; розпакування мол. ч. xmm0 у ст. ч. xmm5 та зсув мол. ч. xmm5
vunpckhpd xmm5,xmm5,xmm6 ; переміщення ст. частини xmm5 у мол. частина xmm5
vaddps xmm4,xmm4,xmm5 ; сума xmm4 та xmm5

add rsi,16;type mas2 ; подготовка адреса mas1 к новому считыванию
add rdi,16 ; подготовка адреса mas2 к новому считыванию
cmp rdx,0 ; определение остатка необработанных элементов массивов
jz m5 ; если элементы закончились, то перейти на exit
mov rcx,rdx ; занесение в счетчик кол. необработанных чисел
m6: 
cmp r10,0 	; проверка знаковых битов
jz m9
vmovss xmm3,dword ptr [rdi] ; mas2
jmp m0
m9: vmovss xmm3,dword ptr [rsi] ; mas1 ;
m0:
vaddps xmm4,xmm4,xmm3 ; сума xmm4 та xmm3
add rsi,4 ; подготовка к выборке элемента из mas1
add rdi,4 ; подготовка к выборке элемента из mas2
loop m6 ; ecx := ecx – 1 и переход, если ecx /= 0

vunpcklps xmm6,xmm6,xmm4
vunpckhpd xmm7,xmm7,xmm6
vunpcklpd xmm6,xmm6,xmm6
vunpckhpd xmm6,xmm6,xmm8
vunpckhpd xmm7,xmm7,xmm8
vaddps xmm6,xmm6,xmm7 ; сума xmm6 та xmm7
m5:
vcvtps2dq xmm2,xmm6
vmovups xmmword ptr [rbx],xmm2
movsxd rdi,res[4]

invoke wsprintf,addr buf1,addr fmt,rdi ; перетворення
mov params.cbSize,SIZEOF MSGBOXPARAMSA ; розмір структури
mov params.hwndOwner,0 		; дескриптор вікна власника
invoke GetModuleHandle,0 	; отримання дескриптора програми
mov params.hInstance,rax 	; збереження дескриптора програми
lea rax, buf1 				; адреса повідомлення
mov params.lpszText,rax
lea rax,titl1 ;Caption 		; адреса назви вікна
mov params.lpszCaption,rax
mov params.dwStyle, MB_USERICON ; стиль вікна
mov params.lpszIcon,IDI_ICON ; ресурс значка
mov params.dwContextHelpId,0 ; контекст довідки
mov params.lpfnMsgBoxCallback,0 ;
mov params.dwLanguageId,LANG_NEUTRAL ; мова повідомлення
lea rcx,params
invoke MessageBoxIndirect
invoke ExitProcess,0
entry_point endp
end