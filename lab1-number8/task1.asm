;; ������ 8 
;; ��������� 3 �������� ������� Yn = 25�^2 + 2,1 
;; (x ��������� �� 3 � ������ 2,5)

include /masm64/include64/masm64rt.inc

.const
    title0 db "����������� 1, �������� 1", 0	; ����� ����
    fmt0 db "Y = 25�^2 + 2,1; X0 = 3; STEP = 2.5", 10,	; ����� ����
            "Y0 = %s", 10,
            "Y1 = %s", 10,
            "Y2 = %s", 10, 10,
            "�����: 2234234 234234", 0        
    const0 dq 2.1	; ���������
    const1 dq 25.0
    step0 dq 2.5	; ���� 
    loop_count0 dq 3	; ������� ������� �� ����� loop
.data
    x0 dq 3.0	; x
    res0 dq 3 dup(0.0)	; ����� ����������
    text0 db 256 dup(0)	; ������������ ����� ��� ������

    sres0 db 32 dup(0) 	; ������������ ����� ��� ����������
    sres1 db 32 dup(0)  
    sres2 db 32 dup(0) 
.code
entry_point proc
    lea rdi, res0	; A����� ������
    mov rcx, loop_count0	; ʳ������ ��������
    finit
m0:
    fld x0	;��������� x0 � ����
    fmul st(0), st(0)	; X^2
	fld const1	;��������� const1 � ����	
    fmulp st(1), st(0)	; 25�^2
    fld const0	;��������� const0 � ����  
    faddp st(1), st(0)	; 25�^2 + 2,1

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
    invoke wsprintf, addr text0, addr fmt0, addr sres0, addr sres1, addr sres2 ; ����� ��� ����� � text0
    invoke MessageBox, 0, addr text0, addr title0, MB_OK ; ������ MessageBox
    invoke ExitProcess, 0
entry_point endp
end