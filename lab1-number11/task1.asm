;; Варіант 11 
;; Знайти перше значення аргументу функції Y = 7(x + 0,3), при
;; якому молодша ціла цифра результату виконання функції буде
;; рівна 5 (x змінюється від 2 з кроком 3,5).

include /masm64/include64/masm64rt.inc

.const
    title0 db "Лабораторна 1, Завдання 1", 0 ; назва вікна
    fmt0 db "Y = 7(x + 0,3); X0 = 2; STEP = 3.5", 10, ; текст вікна
            "X0 = %s", 10, 10,
            "Автор: ", 0        
    const0 dq 7.0       ; константи рівняння
    const1 dq 0.3
	const2 dq 10.0
	c1 dw 1.0
    step0 dq 3.5        ; крок х
	cm dq 5.0			; значення умови
    loop_count0 dq 3    ; кількість проходів по циклу loop
.data
    x0 dq 2.0           ; значення x
    res0 dq 3 dup(0.0)  ; Масив результатівs
    text0 db 256 dup(0) ; резервування якеек для тексту

    sres0 db 32 dup(0)  ; резервування якеек для результатів
    sres1 db 32 dup(0) 
.code
entry_point proc
    lea rdi, res0           ; Aдреса масиву
    mov rcx, loop_count0    ; Кількість ітерацій функцій
    finit
m0:
    
	fld x0              ;Поміщає x0 в стек
    fld const1			;Поміщає const1 в стек
	faddp   			; x + 0,3 	
    fld const0          ;Поміщає const0 в стек  
    fmulp				;7(x + 0,3)
	
	frndint				;округлення результату
	fld const2			;Поміщає const2 в стек
	fdivp				;результат/10
	fld1				;дублюємо значення
	fmul st(0),st(1)
	frndint				;округлення цього значення
	fsubp				;видаляємо цілу частину
	fld const2
	fmulp				;результат*10
	fld cm				
	fcomip st(0),st(1)	;перевірка чи є ця цифра п'ятіркою
	fmulp st(4),st(0)	
	jnz M
	
	
	fld x0
	fstp qword ptr [rdi] ; st0 -> array[i]
    add rdi, type res0 ; i += element size
	M:

    fld x0              ;Поміщає x0 в стек
    fld step0           ;Поміщає step0 в стек
    faddp st(1), st(0)  ;збільшує значення х на 2,5
    fstp qword ptr [x0] ;копіює значення в регистрі st(0) в операндр призначення

    loop m0 ; поки loop_count != 0

    invoke fptoa, qword ptr[res0], addr sres0           ; редагування першого результату до потрібного числа з плаваючою точкою
    invoke wsprintf, addr text0, addr fmt0, addr sres0 ; формує ряд символів і значень у буфері
    invoke MessageBox, 0, addr text0, addr title0, MB_OK ; викликає функцію вікна MessageBox
    invoke ExitProcess, 0   ; Вихід
entry_point endp
end