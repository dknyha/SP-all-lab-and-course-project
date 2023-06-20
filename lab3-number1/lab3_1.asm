;; ������ 1
;; �������� ���������� ��������� 2-� ������ �� 6 64-��������� ������ �����.
;; ���� �� ����� ������� ������ ����� �������,
;; �� ������� �� ����� ������� ������, � ���� ������� � �� �������. 
include \masm64\include64\masm64rt.inc ; ������������ ����������

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
len1 equ ($-mas2)/ type mas2 ; ���������� ����� ������� mas2
res dd len1 DUP(0),0
fmt db "�������� ���������� ��������� 2-� ������ �� 6-�� 64-��������� ������ �����.",10,
"��������� ��������� ������ � ������:  %d", 10,10,
"�����:  1 1",0
buf dq 0,0 ; ������ ������
titl1 db "masm64. ���������� ��������� �� ��������� AVX-������",0; �������� ������
buf1 dq 0,0 

.code
entry_point proc				
mov eax,len1   ; 
mov ebx,4      ; ���������� 32-��������� ����� � 128 ��������� ��������
xor edx,edx    ; 
div ebx  ; ����������� ���������� ������ ��� ������������� ���������� � �������
mov ecx,eax       ; ������� ������ ��� ������������� ����������
lea rsi,mas1  	; 
lea rdi,mas2  	; 
next:  vmovups XMM0,xmmword ptr [rsi]; 4- 32 ����� �� mas1
vmovups XMM1,[rdi]     ; 4-  32 ����� �� mas2
vcmpltps xmm10,XMM0,XMM1 ; ��������� �� ������: ���� ������, �� ����
vmovmskps ebx,xmm10 ; ����������� �������� �����
add rsi,16 ; ���������� ������ ��� ������ ���������� mas1
add rdi,16 ; ���������� ������ ��� ������ ���������� mas2
dec ecx    ; ���������� �������� ������
jnz m1     ; �������� �������� �� ��������� ��������
jmp m2     ;
m1: mov r10,rbx 
shl r10,4 ; ����� ������ �� 4 ����
jmp next       ; �� ����� ����
m2:  cmp edx,0  ; �������� �������
jz _end         ; 
mov ecx,edx   ; ���� � ������� �� ����, �� ��������� ��������
m4:   
vmovss XMM0,dword ptr[rsi]    ; 
vmovss XMM1,dword ptr[rdi]    ; 
vcomiss XMM0,XMM1 ; ��������� ������� ����� ��������
jg @f  	  ; ���� ������
shl r10,1 ; ����� ������ �� 1 ������
inc r10   ; ������������ 1, ��������� XMM0[0] < XMM1[0]
jmp m3
@@:
shl r10,1 ; ����� ������ �� 1 ������
m3: 
add rsi,4  ; ������ ��� ������ ����� mas1
add rdi,4  ; ������ ��� ������ ����� mas2
loop m4
_end:
mov rax,len1 ; ���������� ����� � �������
mov rbx,4 ; ���������� ������������ ���������� ����� � XMM
xor rdx,rdx ; �������� �� ������� 2 (���������)
div rbx ; rax := 4 � ���������� ������ rdx := 1
mov rcx,rax ; �������� ��������
lea rsi,mas1 ; rsi := addr mas1
lea rdi,mas2 ; rdi := addr mas2
lea rbx,res ; ��������� ������ ������

mb:
cmp r10,0 	; �������� �������� �����
jz m7
vmovups XMM0,[rdi] ; mas2
jmp m8
m7: vmovups XMM0,[rsi] ; mas1 ;
m8:

vunpckhpd xmm4,xmm4,xmm0 ; ������������ ��. �. xmm0 � ��. �. xmm4 �� ���� ���. �. xmm4
vunpckhpd xmm4,xmm4,xmm5 ; ���������� ��. ������� xmm4 � ���. �. xmm4
vunpcklpd xmm5,xmm5,xmm0 ; ������������ ���. �. xmm0 � ��. �. xmm5 �� ���� ���. �. xmm5
vunpckhpd xmm5,xmm5,xmm6 ; ���������� ��. ������� xmm5 � ���. ������� xmm5
vaddps xmm4,xmm4,xmm5 ; ���� xmm4 �� xmm5

add rsi,16;type mas2 ; ���������� ������ mas1 � ������ ����������
add rdi,16 ; ���������� ������ mas2 � ������ ����������
cmp rdx,0 ; ����������� ������� �������������� ��������� ��������
jz m5 ; ���� �������� �����������, �� ������� �� exit
mov rcx,rdx ; ��������� � ������� ���. �������������� �����
m6: 
cmp r10,0 	; �������� �������� �����
jz m9
vmovss xmm3,dword ptr [rdi] ; mas2
jmp m0
m9: vmovss xmm3,dword ptr [rsi] ; mas1 ;
m0:
vaddps xmm4,xmm4,xmm3 ; ���� xmm4 �� xmm3
add rsi,4 ; ���������� � ������� �������� �� mas1
add rdi,4 ; ���������� � ������� �������� �� mas2
loop m6 ; ecx := ecx � 1 � �������, ���� ecx /= 0

vunpcklps xmm6,xmm6,xmm4
vunpckhpd xmm7,xmm7,xmm6
vunpcklpd xmm6,xmm6,xmm6
vunpckhpd xmm6,xmm6,xmm8
vunpckhpd xmm7,xmm7,xmm8
vaddps xmm6,xmm6,xmm7 ; ���� xmm6 �� xmm7
m5:
vcvtps2dq xmm2,xmm6
vmovups xmmword ptr [rbx],xmm2
movsxd rdi,res[4]

invoke wsprintf,addr buf1,addr fmt,rdi ; ������������
mov params.cbSize,SIZEOF MSGBOXPARAMSA ; ����� ���������
mov params.hwndOwner,0 		; ���������� ���� ��������
invoke GetModuleHandle,0 	; ��������� ����������� ��������
mov params.hInstance,rax 	; ���������� ����������� ��������
lea rax, buf1 				; ������ �����������
mov params.lpszText,rax
lea rax,titl1 ;Caption 		; ������ ����� ����
mov params.lpszCaption,rax
mov params.dwStyle, MB_USERICON ; ����� ����
mov params.lpszIcon,IDI_ICON ; ������ ������
mov params.dwContextHelpId,0 ; �������� ������
mov params.lpfnMsgBoxCallback,0 ;
mov params.dwLanguageId,LANG_NEUTRAL ; ���� �����������
lea rcx,params
invoke MessageBoxIndirect
invoke ExitProcess,0
entry_point endp
end