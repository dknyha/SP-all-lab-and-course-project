include \masm64\include64\masm64rt.inc

IDM_Function1 equ 10002
IDM_Function2 equ 10003
IDM_Clear equ 10004
IDM_Exit equ 10005

IDM_Condition equ 10007
IDM_Avtor equ 10008

.const
fmt0 db "Намалювати зображення Мережива.", 10,
        "Координати вершин задаються за формулами:", 10,
		"iX = Xc + Rcos(2? i/n);", 10,
        "iY = Yc + Rsin(2? i/n); i = 1 ? 18,", 10,
        "де і – номер вершини, R – радіус окружності, описаної близько многокутника; Xc , Yc – координати центру.", 0
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
tit1 db " зображення Мережива",0
 mas dd 18 ; 
 alpha dd 1.0 ; угловая координата 
 alpha1 dd 0.0 ; угловая координата 
 delta dd 1.0 ; один градус
 xdiv2 dq 250    ; середина по X 
 ydiv2 dq 120    ; середина по Y
 tmpR dd 100.0  ; временная переменная
 tmpn dd 18.0
 xr dd 0. 	; координаты функции
 yr dd 0.
 temp1 dd 0
 temp2 dd 0
 two dd 2
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
.case IDM_Function1
invoke InvalidateRect, hWnd, NULL, TRUE
invoke BeginPaint,hWnd, ADDR ps ; виклик підготовчої процедури
mov hdc,rax                 ; збереження контексту
invoke GetClientRect,hWnd,ADDR rect ; занесення до структури rect характеристик вікна
mov r10d,mas ; збереження кількості циклів
mov temp1,r10d
finit

finit   ; x(t) 
l1:          ; x = x0 + Кfcosf

movss XMM3,alpha
addss XMM3,delta
movss alpha1,XMM3
mov r11d,mas ; сохранение количества циклов
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

invoke MoveToEx,hdc,xr,yr,0; перемещение точки начала 

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

;invoke Sleep,10             ; задержка
;invoke SetCursorPos,xr, yr
invoke LineTo,hdc,xr,yr; рисование прямой 
movss XMM3,delta
addss XMM3,alpha1
movss alpha1,XMM3
dec temp2   ; уменьшение счетчика
jz l4       ; продолжение рисование
jmp l3	; выход из цикла
l4:

movss XMM3,delta
addss XMM3,alpha
movss alpha,XMM3
dec temp1   ; уменьшение счетчика
jz l2       ; продолжение рисование
jmp l1	; выход из цикла
l2:

invoke EndPaint,hWnd, ADDR ps ; завершення малювання

.case IDM_Clear

invoke InvalidateRect, hWnd, NULL, TRUE
invoke BeginPaint,hWnd, ADDR ps ; виклик підготовчої процедури
mov hdc,rax                 ; збереження контексту
invoke GetClientRect,hWnd,ADDR rect ; занесення до структури rect характеристик вікна
invoke FillRect, hdc, ADDR rect, -1	; очищення вікна для наступного графіку(фугури)
invoke EndPaint,hWnd, ADDR ps ; завершення малювання
.case IDM_Exit ;
rcall SendMessage,hWin,WM_SYSCOMMAND,SC_CLOSE,NULL
.case IDM_Condition ; 
invoke MessageBox,hWin,addr fmt0, "Умова",MB_ICONINFORMATION
.case IDM_Avtor ;
invoke MessageBox,hWin,"11", "Автор",MB_ICONINFORMATION
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