;; ������ 6
;; ��������� �������� 4 �������: Yn = 125/(3�^2 � 1,1)  
;; (� ��������� �� 3 � ������ 1,5). ��������� ���������

include /masm64/include64/masm64rt.inc

.const
    title0 db "����������� 1, �������� 1", 0 ; ����� ����
    fmt0 db "Y = 125/(3�^2 � 1,1); X0 = 3.0; STEP = 1.5", 10,
            "Y0 = %s", 10,
            "Y1 = %s", 10,
            "Y2 = %s", 10,
			"Y3 = %s", 10,10,
            "�����: 1231233 123", 0        
    const0 dq 125.0 ; ���������
	const1 dq 3.0
    const2 dq 1.1
    step0 dq 1.5 ; ����    
    loop_count0 dq 4 ; ������� ������� �� ����� loop 
.data
    x0 dq 3.0 ; x
    res0 dq 4 dup(0.0) ; ����� ����������
    text0 db 256 dup(0) ; ������������ ����� ��� ������

    sres0 db 32 dup(0) ; ������������ ����� ��� ����������
    sres1 db 32 dup(0)  
    sres2 db 32 dup(0)
	sres3 db 32 dup(0)
.code
entry_point proc
    lea rdi, res0 ; A����� ������   
    mov rcx, loop_count0 ; ʳ������ ��������
    finit
m0:
    fld const0 ;��������� const0 � ����
	fld x0 ;��������� x0 � ����
    fmul st(0), st(0) ;x^2
	fld const1 ;��������� const1 � ����	
    fmulp st(1), st(0) ;3�^2
    fld const2 ;��������� const2 � ����
    fsubp st(1), st(0) ;3�^2 � 1,1
	fdivp st(1), st(0) ;125/(3�^2 � 1,1)
	frndint ;����������

    fstp qword ptr [rdi] ; st0 -> array[i]
    add rdi, type res0 ; i += element size
	
    fld x0	;��������� x0 � ����
    fld step0	;��������� step0 � ����
    faddp st(1), st(0)	;������ �������� � �� 4
    fstp qword ptr [x0]	;����� � st(0) � �������� �����������

    loop m0 ; ���� loop_count != 0

    invoke fptoa, qword ptr[res0], addr sres0 ; ����������� ���������� 1 �� ����� � ��������� ������
    invoke fptoa, qword ptr[res0 + 8h], addr sres1 ; ����������� ���������� 2 �� ����� � ��������� ������
    invoke fptoa, qword ptr[res0 + 10h], addr sres2 ; ����������� ���������� 3 �� ����� � ��������� ������
	invoke fptoa, qword ptr[res0 + 18h], addr sres3 ; ����������� ���������� 3 �� ����� � ��������� ������
    invoke wsprintf, addr text0, addr fmt0, addr sres0, addr sres1, addr sres2, addr sres3 ; ����� ��� ����� � text0
    invoke MessageBox, 0, addr text0, addr title0, MB_OK ; ������ MessageBox
    invoke ExitProcess, 0
entry_point endp
end