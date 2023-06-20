include \masm64\include64\masm64rt.inc

IDM_Function1 equ 10002
IDM_Function2 equ 10003
IDM_Clear equ 10004
IDM_Exit equ 10005

IDM_Condition equ 10007
IDM_Avtor equ 10008

.const
fmt0 db "���������� ���������� ��������.", 10,
        "���������� ������ ��������� �� ���������:", 10,
		"iX = Xc + Rcos(2? i/n);", 10,
        "iY = Yc + Rsin(2? i/n); i = 1 ? 18,", 10,
        "�� � � ����� �������, R � ����� ���������, ������� ������� ������������; Xc , Yc � ���������� ������.", 0
.data?
hInstance dq ? ; ���������� ��������
hWnd dq ? ; ���������� ����
hIcon dq ? ; ���������� ������
hCursor dq ? ; ���������� �������
sWid dq ? ; ������ ������� (����. ������ �� x)
sHgt dq ? ; ������ ������� (����. ������ �� y)
res2 db 10 dup(?)
hBrush DWORD ?
.data ; ��������� ���������� �����
tit1 db " ���������� ��������",0
 mas dd 18 ; 
 alpha dd 1.0 ; ������� ���������� 
 alpha1 dd 0.0 ; ������� ���������� 
 delta dd 1.0 ; ���� ������
 xdiv2 dq 250    ; �������� �� X 
 ydiv2 dq 120    ; �������� �� Y
 tmpR dd 100.0  ; ��������� ����������
 tmpn dd 18.0
 xr dd 0. 	; ���������� �������
 yr dd 0.
 temp1 dd 0
 temp2 dd 0
 two dd 2
classname db "template_class",0

.code
entry_point proc
mov hInstance,rv(GetModuleHandle,0) 	; ��������� �� ���������� ����������� ��������
mov hIcon, rv(LoadIcon,hInstance,10) 	; ������������ �� ���������� ����������� ������
mov hCursor,rv(LoadCursor,0,IDC_ARROW) 	; ������������ ������� �� ����������
mov sWid,rv(GetSystemMetrics,SM_CXSCREEN) ; ��������� ����. ������ �� � �������
mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN) ; ��������� ����. ������ �� � �������
call main
invoke ExitProcess,0
ret
entry_point endp

main proc
LOCAL wc :WNDCLASSEX; ���������� ��������� ������
LOCAL lft :QWORD 	; ���. ���� �������� � �����
LOCAL top :QWORD 	; � ������� ���� �� ��� ���. ���.
LOCAL wid :QWORD
LOCAL hgt :QWORD
;��������� ������ ����
mov wc.cbSize,SIZEOF WNDCLASSEX ; ����. ����� ���������
mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ;����� ����
mov wc.lpfnWndProc,ptr$(WndProc) ; ������ ��������� WndProc
mov wc.cbClsExtra,0 ; ������� ����� ��� ��������� �����
mov wc.cbWndExtra,0 ; ������� ����� ��� ��������� ����
mrm wc.hInstance,hInstance ; ���������� ���� ����������� � ��������
mrm wc.hIcon, hIcon ; ����� ������
mrm wc.hCursor,hCursor ; ����� �������
mrm wc.hbrBackground,0 ; ���� ����
mov wc.lpszMenuName,0 ; ���������� ���� � �������� � ��'�� ������� ����
mov wc.lpszClassName,ptr$(classname) ; ��'� �����
mrm wc.hIconSm,hIcon
; ��������� �����
invoke RegisterClassEx,ADDR wc ; ��������� ����� ����
mov wid, 500 ; ������ ���� ����������� � �������
mov hgt, 300 ; ������ ���� ����������� � �������
mov rax,sWid ; ����. ������ ������� �� x
sub rax,wid ; ������ � = � (�������) - � (���� �����������)
shr rax,1 ; ��������� �������� �
mov lft,rax ;
mov rax, sHgt ; ����. ������ ������� �� y
sub rax, hgt ;
shr rax, 1 ;
mov top, rax ;

; ��������� ����
; ���������� ���� �� �������������� ��������
invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
ADDR classname,ADDR tit1,WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
lft,top,wid,hgt,0,0,hInstance,0
mov hWnd,rax ; ���������� ����������� ����
call msgloop
ret
main endp

msgloop proc ; ���� ���������� (����� ����������)
LOCAL msg :MSG
LOCAL pmsg :QWORD
mov pmsg,ptr$(msg) ; ��������� ������ ��������� �����������
jmp gmsg ; ������� ������������� �� GetMessage()
mloop:
invoke TranslateMessage,pmsg
invoke DispatchMessage,pmsg ; �������� �� �������������� �� WndProc
gmsg:
test rax, rv(GetMessage,pmsg,0,0,0) ; ���� GetMessage �� ������� ����
jnz mloop
ret
msgloop endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
LOCAL dfbuff[260]:BYTE
LOCAL pbuff :QWORD
LOCAL hdc:HDC               ; ������������ ����� ��� ����������� ����
LOCAL ps:PAINTSTRUCT        ; ��� ��������� PAINTSTRUCT
LOCAL rect:RECT             ; ��� ��������� ��������� RECT
.switch uMsg
.case WM_COMMAND ; ���� � ����
.switch wParam
.case IDM_Function1
invoke InvalidateRect, hWnd, NULL, TRUE
invoke BeginPaint,hWnd, ADDR ps ; ������ ��������� ���������
mov hdc,rax                 ; ���������� ���������
invoke GetClientRect,hWnd,ADDR rect ; ��������� �� ��������� rect ������������� ����
mov r10d,mas ; ���������� ������� �����
mov temp1,r10d
finit

finit   ; x(t) 
l1:          ; x = x0 + �fcosf

movss XMM3,alpha
addss XMM3,delta
movss alpha1,XMM3
mov r11d,mas ; ���������� ���������� ������
mov temp2,r11d
l3:  
fldpi
fild two  
fmulp
fdiv tmpn
fmul alpha
fcos 
fmul tmpR

fild xdiv2
fadd


fistp dword ptr xr

fldpi
fild two  
fmulp
fdiv tmpn
fmul alpha
fsin 
fmul tmpR

fild ydiv2
fadd

fistp dword ptr yr

invoke MoveToEx,hdc,xr,yr,0; ����������� ����� ������ 

fldpi
fild two  
fmulp
fdiv tmpn
fmul alpha1
fcos 
fmul tmpR

fild xdiv2
fadd


fistp dword ptr xr

fldpi
fild two  
fmulp
fdiv tmpn
fmul alpha1
fsin 
fmul tmpR

fild ydiv2
fadd

fistp dword ptr yr

;invoke Sleep,10             ; ��������
;invoke SetCursorPos,xr, yr
invoke LineTo,hdc,xr,yr; ��������� ������ 
movss XMM3,delta
addss XMM3,alpha1
movss alpha1,XMM3
dec temp2   ; ���������� ��������
jz l4       ; ����������� ���������
jmp l3	; ����� �� �����
l4:

movss XMM3,delta
addss XMM3,alpha
movss alpha,XMM3
dec temp1   ; ���������� ��������
jz l2       ; ����������� ���������
jmp l1	; ����� �� �����
l2:

invoke EndPaint,hWnd, ADDR ps ; ���������� ���������

.case IDM_Clear

invoke InvalidateRect, hWnd, NULL, TRUE
invoke BeginPaint,hWnd, ADDR ps ; ������ ��������� ���������
mov hdc,rax                 ; ���������� ���������
invoke GetClientRect,hWnd,ADDR rect ; ��������� �� ��������� rect ������������� ����
invoke FillRect, hdc, ADDR rect, -1	; �������� ���� ��� ���������� �������(������)
invoke EndPaint,hWnd, ADDR ps ; ���������� ���������
.case IDM_Exit ;
rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
.case IDM_Condition ; 
invoke MessageBox,hWin,addr fmt0, "�����",MB_ICONINFORMATION
.case IDM_Avtor ;
invoke MessageBox,hWin,"11", "�����",MB_ICONINFORMATION
.endsw
.case WM_CREATE ; ���� ��������
rcall LoadMenu,hInstance,10000
rcall SetMenu,hWin,rax
.return 0
.case WM_CLOSE
rcall SendMessage,hWin,WM_DESTROY,0,0
.case WM_DESTROY
rcall PostQuitMessage,NULL
.endsw
rcall DefWindowProc,hWin,uMsg,wParam,lParam
ret
WndProc endp
end