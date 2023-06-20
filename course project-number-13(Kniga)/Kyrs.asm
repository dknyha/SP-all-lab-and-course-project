include \masm64\include64\masm64rt.inc

.data?
	hInstance dq ?
	hIcon dq ?
	tEdit dq ?
	pbuff dq ?
	buff dq ?
	
.code
entry_point proc
	mov hInstance, rvcall(GetModuleHandle,0)
	mov hIcon, rv(LoadImage,hInstance,10,IMAGE_ICON,256,256, LR_DEFAULTCOLOR)
	invoke DialogBoxParam,hInstance,10,0,ADDR PartsWindow,hIcon
	.exit
entry_point endp

PartsWindow proc hWin:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
	LOCAL buffer[260]:BYTE
	.switch uMsg
	.case WM_INITDIALOG
		invoke SendMessage,hWin,WM_SETICON,1,lParam
		mov tEdit, rvcall(GetDlgItem,hWin,11)
		invoke SetFocus, tEdit
		mov pbuff, ptr$(buffer)
	.case WM_COMMAND
	.switch wParam
	.case 12
		invoke GetWindowText,tEdit,pbuff,sizeof buffer
		.if rax == 0
			rcall MessageBox,hWin,"Введіть текст або натисніть Закрити вікно","Текст не введено",MB_ICONINFORMATION
			rcall SetFocus,tEdit
		.else
			xor rbx,rbx
			mov rcx,sizeof buffer
			mov rsi,pbuff
		n:
			cmp byte ptr [rsi],0
			jz m
			inc rsi
			inc rbx
			dec rcx
			jnz n
		m:
			mov rcx,rbx
			dec rsi
			lea rdi,buff   
			
		loopp:
			
			mov al,byte ptr [rsi]
			mov byte ptr [rdi],al
			inc rdi
			dec rsi
			loop loopp

			invoke MessageBox,0,addr buff,"Текст у зворотньому порядку",MB_ICONINFORMATION
		.endif
	.case 13
	jmp exit_dialog
	.endsw
	.case WM_CLOSE
	exit_dialog:
	rcall EndDialog,hWin,0
	.endsw
	xor rax, rax
	ret
PartsWindow endp
end