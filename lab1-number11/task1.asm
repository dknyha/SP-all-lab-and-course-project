;; ������ 11 
;; ������ ����� �������� ��������� ������� Y = 7(x + 0,3), ���
;; ����� ������� ���� ����� ���������� ��������� ������� ����
;; ���� 5 (x ��������� �� 2 � ������ 3,5).

include /masm64/include64/masm64rt.inc

.const
    title0 db "����������� 1, �������� 1", 0 ; ����� ����
    fmt0 db "Y = 7(x + 0,3); X0 = 2; STEP = 3.5", 10, ; ����� ����
            "X0 = %s", 10, 10,
            "�����: ", 0        
    const0 dq 7.0       ; ��������� �������
    const1 dq 0.3
	const2 dq 10.0
	c1 dw 1.0
    step0 dq 3.5        ; ���� �
	cm dq 5.0			; �������� �����
    loop_count0 dq 3    ; ������� ������� �� ����� loop
.data
    x0 dq 2.0           ; �������� x
    res0 dq 3 dup(0.0)  ; ����� ����������s
    text0 db 256 dup(0) ; ������������ ����� ��� ������

    sres0 db 32 dup(0)  ; ������������ ����� ��� ����������
    sres1 db 32 dup(0) 
.code
entry_point proc
    lea rdi, res0           ; A����� ������
    mov rcx, loop_count0    ; ʳ������ �������� �������
    finit
m0:
    
	fld x0              ;����� x0 � ����
    fld const1			;����� const1 � ����
	faddp   			; x + 0,3 	
    fld const0          ;����� const0 � ����  
    fmulp				;7(x + 0,3)
	
	frndint				;���������� ����������
	fld const2			;����� const2 � ����
	fdivp				;���������/10
	fld1				;�������� ��������
	fmul st(0),st(1)
	frndint				;���������� ����� ��������
	fsubp				;��������� ���� �������
	fld const2
	fmulp				;���������*10
	fld cm				
	fcomip st(0),st(1)	;�������� �� � �� ����� �'������
	fmulp st(4),st(0)	
	jnz M
	
	
	fld x0
	fstp qword ptr [rdi] ; st0 -> array[i]
    add rdi, type res0 ; i += element size
	M:

    fld x0              ;����� x0 � ����
    fld step0           ;����� step0 � ����
    faddp st(1), st(0)  ;������ �������� � �� 2,5
    fstp qword ptr [x0] ;����� �������� � ������� st(0) � �������� �����������

    loop m0 ; ���� loop_count != 0

    invoke fptoa, qword ptr[res0], addr sres0           ; ����������� ������� ���������� �� ��������� ����� � ��������� ������
    invoke wsprintf, addr text0, addr fmt0, addr sres0 ; ����� ��� ������� � ������� � �����
    invoke MessageBox, 0, addr text0, addr title0, MB_OK ; ������� ������� ���� MessageBox
    invoke ExitProcess, 0   ; �����
entry_point endp
end