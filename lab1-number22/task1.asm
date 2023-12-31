;; ������ 22 
;; ��������� 4 �������� ������� Y = 5^x + cosx 
;; (x ��������� �� 0,4 � ������ 0,15)

include /masm64/include64/masm64rt.inc

.const
    title0 db "����������� 1, �������� 1", 0	; ����� ����
    fmt0 db "Y = 5^x + cosx; X0 = 0.4; STEP = 0.15", 10,	; ����� ����
            "Y0 = %s", 10,
            "Y1 = %s", 10,
            "Y2 = %s", 10,
            "Y3 = %s", 10, 10,
            "�����: 22 22", 0        
    const0 dq 5.0	; ���������
    step0 dq 0.15	; ���� 
    loop_count0 dq 4	; ������� ������� �� ����� loop
.data
    x0 dq 0.4	; x
    res0 dq 3 dup(0.0)	; ����� ����������
    text0 db 256 dup(0)	; ������������ ����� ��� ������

    sres0 db 32 dup(0) 	; ������������ ����� ��� ����������
    sres1 db 32 dup(0)  
    sres2 db 32 dup(0)   
    sres3 db 32 dup(0)
.code
entry_point proc
    lea rdi, res0	; A����� ������
    mov rcx, loop_count0	; ʳ������ ��������
    finit
m0:
	fld const0 ;��������� const0 � ����
    fld x0 ;��������� x0 � ����
		;; ���������� 5^x
    fxch st(1)   		; st(0)=a   st(1)=x
 
    fldln2        		; st(0)=ln(2)   st(1)=a     st(2)=x
    fxch st(1)  		; st(0)=a   st(1)=ln(2) st(2)=x
    fyl2x         	 	; st(0)=log2(a)*ln(2)=ln(a) st(1)=x
 
    fmulp st(1),st(0)   ; st(0)=x*ln(a)=B
 
    fldl2e      		;st(0)=1/ln(2)=log2(e)
    fmul       			;st(0)=B/ln(2)=B*log2(e)
    fld st
    frndint 
    fsub st(1), st
    fxch st(1)
    f2xm1
    fld1
    fadd
    fscale 			; 5^x
	
	fld x0	;��������� x0 � ����
    fcos    ; cosx
	faddp 	;5^x + cosx

    fstp qword ptr [rdi] ; st0 -> array[i]
    add rdi, type res0 ; i += element size

    fld x0	;��������� x0 � ����
    fld step0	;��������� step0 � ����
    faddp st(1), st(0)	;������ �������� � �� 2,5
    fstp qword ptr [x0]	;����� � st(0) � �������� �����������

    loop m0 ; ���� loop_count != 0

    invoke fptoa, qword ptr[res0], addr sres0 ; ����������� ���������� 1 �� ����� � ��������� ������
    invoke fptoa, qword ptr[res0 + 8h], addr sres1 ; ����������� ���������� 2 �� ����� � ��������� ������
    invoke fptoa, qword ptr[res0 + 10h], addr sres2 ; ����������� ���������� 3 �� ����� � ��������� ������
    invoke fptoa, qword ptr[res0 + 18h], addr sres3 ; ����������� ���������� 4 �� ����� � ��������� ������
    invoke wsprintf, addr text0, addr fmt0, addr sres0, addr sres1, addr sres2, addr sres3 ; ����� ��� ����� � text0
    invoke MessageBox, 0, addr text0, addr title0, MB_OK ; ������ MessageBox
    invoke ExitProcess, 0
entry_point endp
end