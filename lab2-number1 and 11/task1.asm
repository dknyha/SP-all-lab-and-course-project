;; ������ 1 
;; �������� ��������� ����� ����� 2-� ������. ���� ����  
;; ����� ��� ������� ���� ��������� ����� ������ ������, �� 
;; �������� �������� a � e/c � ab, �� a, b, c, d � ���� �����;
;; ������ � �������� �������� ab.

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
fpuMul macro _a,_b  	; ������ � ��'�� fpuMul
fld _a
fmul _b
endm 


.data
params MSGBOXPARAMSA <>
_a REAL4 2.8
_b REAL4 8.05
_c REAL4 2.2
_d REAL4 3.3

arr1 dw 5,6,7,8		; ����� ����� arr1 ������� � �����
len1 equ ($-arr1)/type arr1	; ������� ����� ������
arr2 dw 1,2,3,4	; ����� ����� arr2 ������� � �����
len2 equ ($-arr2)/type arr2	; ������� ����� ������ 
tit1 db "�������� MMX-FPU",0	; ����� ����
st2 dd 0
buf1 db 0,0	; ����� ����� ��� ��������� �����������
ifmt db "�������� ��������� ����� ����� 2-� ������.",10,
"���� ���� ����� ��� ������� ���� ��������� ����� ������ ������, �� �������� ��������",10,
"a � d/c � ab, �� a, b, c, d � ���� �����;, �� �� a = 2,8; b = 8,05; c = 2,2; d = 3,3; � ���� �����;",10,
"������ � �������� �������� ab",10,10,
"³������ = %d ",10,10,
"�����: 1 1",10,0
len11 equ ($-ifmt)/type ifmt
.code
entry_point proc
movq MM1,QWORD PTR arr1	; ������������ ������ ����� arr1
movq MM2,QWORD PTR arr2	; ������������ ������ ����� arr2
pcmpgtw MM1,MM2	; ������� ������
pextrw eax,MM1,0 ; � eax �������� 1 ������� � ������ arr1
cmp ax,-1 ; �������� �� ������ ������ ������� arr1 �� arr2
mov rcx,3 ; ������� �����
jnz @1 ; if != -1
m0: 
PSRLQ MM1, 16 ; ���� ������ ������� �� ���� �������
pextrw eax,MM1,0 ; � eax �������� 1 ������� � ������ arr1
cmp ax,-1 ; �������� �� ������ ������ ������� arr1 �� arr2
jnz @2 ; if != -1
loop m0
jmp @3
@1:
m1: 
PSRLQ MM1, 16 ; ���� ������ ������� �� ���� �������
pextrw eax,MM1,0 ; � eax �������� 1 ������� � ������ arr1
cmp ax,0 ; �������� �� ������ ������ ������� arr1 �� arr2
jnz @2 ; if != 0
loop m1
@3: emms ; ��������� ������������
fpuMul [_a],[_b] ; ������ fpuMul
fld _d
fdiv _c
fadd
fsubr _a
jmp @4

@2: emms ; ��������� ������������
fpuMul [_a],[_b]  ; ������ fpuMul
@4: fisttp st2 ; ���������� �������������� �������� �� ���������� � �� ����
invoke wsprintf,ADDR buf1,ADDR ifmt,st2
mov params.cbSize,SIZEOF MSGBOXPARAMSA ; ����� ���������
mov params.hwndOwner,0 		; ���������� ���� ��������
invoke GetModuleHandle,0 	; ��������� ����������� ��������
mov params.hInstance,rax 	; ���������� ����������� ��������
lea rax, buf1 				; ������ �����������
mov params.lpszText,rax
lea rax,tit1 ;Caption 		; ������ ����� ����
mov params.lpszCaption,rax
mov params.dwStyle,MB_USERICON ; ����� ����
mov params.lpszIcon,IDI_ICON ; ������ ������
mov params.dwContextHelpId,0 ; �������� ������
mov params.lpfnMsgBoxCallback,0 ;
mov params.dwLanguageId,LANG_NEUTRAL ; ���� �����������
lea rcx,params
invoke MessageBoxIndirect
invoke ExitProcess,0
entry_point endp
end

