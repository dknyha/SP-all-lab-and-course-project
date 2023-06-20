include \masm64\include64\masm64rt.inc

IDM_Function equ 10002
IDM_Clear equ 10003
IDM_Exit equ 10004

IDM_S1 equ 10010
IDM_S2 equ 10011
IDM_S3 equ 10012
IDM_S4 equ 10013

IDM_Condition equ 10007
IDM_Avtor equ 10008

.const
fmt0 db " Намалювати кілька зображень Лемнискаты Бернуллі за формулами:", 10,
		"X(t) = c (sqrt2)(p + p^3)/(1 + p^4);", 10,
        "Y(t)= c (sqrt2)(p – p^3)/(1 + p^4)", 10,
        "де p = tg(p/4 – j), с – відстань між фокусами.", 0
.data?
hInstance dq ? ; дескриптор програми
hWnd dq ? ; дескриптор вікна
hIcon dq ? ; дескриптор іконки
hCursor dq ? ; дескриптор курсору
sWid dq ? ; ширина монітора (кільк. пікселів по x)
sHgt dq ? ; висота монітора (кільк. пікселів по y)
res2 db 10 dup(?)
hBrush DWORD ?
.data ; директива визначення даних
tit1 db "Лемнискати Бернуллі",0
mas dd 2000 ; 
 alpha dd 0.01 ; кутова координата 
 delta dd 0.00975 ; один градус
 xdiv2 dq 250    ; середина по X 
 ydiv2 dq 110    ; середина по Y
 tmpC dd 6.0  ; тимчасова змінна
 tmpC0 dd -1.0
 tmpC1 dd 4.0
 tmpC2 dd 6.0
 tmpC3 dd 8.0
 tmpC4 dd 10.0
 two dd 2.0
 four dd 4.0
 divK dd 10.0 ; масштабний коефіцієнт
 

 xr dd 0. 	; координати функції
 yr dd 0.
 temp1 dd 0
classname db "template_class",0

.code
entry_point proc
mov hInstance,rv(GetModuleHandle,0) 	; отримання та збереження дескриптора програми
mov hIcon, rv(LoadIcon,hInstance,10) 	; завантаження та збереження дескриптора іконки
mov hCursor,rv(LoadCursor,0,IDC_ARROW) 	; завантаження курсору та збереження
mov sWid,rv(GetSystemMetrics,SM_CXSCREEN) ; отримання кільк. пікселів по х монітора
mov sHgt,rv(GetSystemMetrics,SM_CYSCREEN) ; отримання кільк. пікселів по у монітора
call main
invoke ExitProcess,0
ret
entry_point endp

main proc
LOCAL wc :WNDCLASSEX; оголошення локальних змінних
LOCAL lft :QWORD 	; Лок. змінні містяться у стеку
LOCAL top :QWORD 	; і існують лише під час вип. відс.
LOCAL wid :QWORD
LOCAL hgt :QWORD
;Створення образу вікна
mov wc.cbSize,SIZEOF WNDCLASSEX ; кільк. байтів структури
mov wc.style,CS_BYTEALIGNCLIENT or CS_BYTEALIGNWINDOW ;стиль вікна
mov wc.lpfnWndProc,ptr$(WndProc) ; адреса процедури WndProc
mov wc.cbClsExtra,0 ; кількість байтів для структури класу
mov wc.cbWndExtra,0 ; кількість байтів для структури вікна
mrm wc.hInstance,hInstance ; заповнення поля дескриптора у структурі
mrm wc.hIcon, hIcon ; хендл іконки
mrm wc.hCursor,hCursor ; хендл курсору
mrm wc.hbrBackground,0 ; колір вікна
mov wc.lpszMenuName,0 ; заповнення поля у структурі з ім'ям ресурсу меню
mov wc.lpszClassName,ptr$(classname) ; ім'я класу
mrm wc.hIconSm,hIcon
; Реєстрація класу
invoke RegisterClassEx,ADDR wc ; реєстрація класу вікна
mov wid, 500 ; ширина вікна користувача в пікселях
mov hgt, 300 ; висота вікна користувача в пікселях
mov rax,sWid ; кільк. пікселів монітора по x
sub rax,wid ; дельта Х = Х (монітора) - х (вікна користувача)
shr rax,1 ; отримання середини Х
mov lft,rax ;
mov rax, sHgt ; кільк. пікселів монітора по y
sub rax, hgt ;
shr rax, 1 ;
mov top, rax ;

; Створення вікна
; центральне вікно за розрахунковими розмірами
invoke CreateWindowEx,WS_EX_LEFT or WS_EX_ACCEPTFILES, \
ADDR classname,ADDR tit1,WS_OVERLAPPED or WS_VISIBLE or WS_SYSMENU,\
lft,top,wid,hgt,0,0,hInstance,0
mov hWnd,rax ; збереження дескриптора вікна
call msgloop
ret
main endp

msgloop proc ; цикл повідомлень (черга повідомлень)
LOCAL msg :MSG
LOCAL pmsg :QWORD
mov pmsg,ptr$(msg) ; отримання адреси структури повідомлення
jmp gmsg ; перейти безпосередньо до GetMessage()
mloop:
invoke TranslateMessage,pmsg
invoke DispatchMessage,pmsg ; відправка на обслуговування до WndProc
gmsg:
test rax, rv(GetMessage,pmsg,0,0,0) ; поки GetMessage не поверне нуль
jnz mloop
ret
msgloop endp

WndProc proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
LOCAL dfbuff[260]:BYTE
LOCAL pbuff :QWORD
LOCAL hdc:HDC               ; резервування стека для дескриптора вікна
LOCAL ps:PAINTSTRUCT        ; для структури PAINTSTRUCT
LOCAL rect:RECT             ; для структури координат RECT
.switch uMsg
.case WM_COMMAND ; якщо є меню
.switch wParam
.case IDM_Function
invoke InvalidateRect, hWnd, NULL, TRUE
invoke BeginPaint,hWnd, ADDR ps ; виклик підготовчої процедури
mov hdc,rax                 ; збереження контексту
invoke GetClientRect,hWnd,ADDR rect ; занесення до структури rect характеристик вікна
mov r10d,mas ; збереження кількості циклів
mov temp1,r10d
finit

l1:
	fldpi
	fdiv four
	fsub alpha
	FPTAN
	fmulp

	fsqrt
	fld st
	
	fldpi
	fdiv four
	fsub alpha
	FPTAN
	fmulp
	fmulp
	
	faddp
	
	fldpi
	fdiv four
	fsub alpha
	FPTAN
	fmulp
	
	
	fmul st,st
	fld1
	faddp
	
	fdivp
	
	fld two
	fsqrt
	fmulp
	fmul tmpC
	
	
	fmul divK		;домножаємо на масштабний коєф.
	fild xdiv2 		;встановлюємо на потрібну позицію 
	fadd

	fistp dword ptr xr

	fldpi
	fdiv four
	fsub alpha
	FPTAN
	fmulp

	fsqrt
	fld st
	
	fldpi
	fdiv four
	fsub alpha
	FPTAN
	fmulp
	fmulp
	
	fsubp
	
	fldpi
	fdiv four
	fsub alpha
	FPTAN
	fmulp
	
	
	fmul st,st
	fld1
	faddp
	
	fdivp
	
	fld two
	fsqrt
	fmulp
	fmul tmpC
	
	fmul divK		;домножаємо на масштабний коєф.
	fild ydiv2 		;встановлюємо на потрібну позицію
	fadd
	
	fistp dword ptr yr

;invoke Sleep,1           ; затримка
;invoke SetCursorPos,xr, yr
invoke SetPixel,hdc, xr, yr, 0
movss XMM3,delta
addss XMM3,alpha
movss alpha,XMM3
cmp temp1,1000
jnz l
movss XMM3,tmpC0
mulss XMM3,tmpC
movss tmpC,XMM3
l:dec temp1   ; зменшення лічильника
jz l2       ; продовження малювання
jmp l1	; вихід із циклу
l2:

invoke EndPaint,hWnd, ADDR ps ; завершення малювання

.case IDM_Clear

invoke InvalidateRect, hWnd, NULL, TRUE
invoke BeginPaint,hWnd, ADDR ps ; виклик підготовчої процедури
mov hdc,rax                 ; збереження контексту
invoke GetClientRect,hWnd,ADDR rect ; занесення до структури rect характеристик вікна
invoke FillRect, hdc, ADDR rect, -1	; очищення вікна для наступного графіку(фугури)
invoke EndPaint,hWnd, ADDR ps ; завершення малювання

.case IDM_S1
movss XMM3,tmpC1
movss tmpC,XMM3
.case IDM_S2
movss XMM3,tmpC2
movss tmpC,XMM3
.case IDM_S3
movss XMM3,tmpC3
movss tmpC,XMM3
.case IDM_S4
movss XMM3,tmpC4
movss tmpC,XMM3

.case IDM_Exit
rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
.case IDM_Condition
invoke MessageBox,hWin,addr fmt0, "Умова",MB_ICONINFORMATION
.case IDM_Avtor
invoke MessageBox,hWin,"11 11", "Автор",MB_ICONINFORMATION
.endsw
.case WM_CREATE ; якщо створити
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