;; Варіант 6
;; Обчислити значення 4 функції: Yn = 125/(3х^2 – 1,1)  
;; (х змінюється від 3 з кроком 1,5). результат округлити

include /masm64/include64/masm64rt.inc

.const
    title0 db "Лабораторна 1, Завдання 1", 0 ; назва вікна
    fmt0 db "Y = 125/(3х^2 – 1,1); X0 = 3.0; STEP = 1.5", 10,
            "Y0 = %s", 10,
            "Y1 = %s", 10,
            "Y2 = %s", 10,
			"Y3 = %s", 10,10,
            "Автор: 1231233 123", 0        
    const0 dq 125.0 ; константи
	const1 dq 3.0
    const2 dq 1.1
    step0 dq 1.5 ; крок    
    loop_count0 dq 4 ; кількість проходів по циклу loop 
.data
    x0 dq 3.0 ; x
    res0 dq 4 dup(0.0) ; Масив результатів
    text0 db 256 dup(0) ; резервування якеек для тексту

    sres0 db 32 dup(0) ; резервування якеек для результатів
    sres1 db 32 dup(0)  
    sres2 db 32 dup(0)
	sres3 db 32 dup(0)
.code
entry_point proc
    lea rdi, res0 ; Aдреса масиву   
    mov rcx, loop_count0 ; Кількість ітерацій
    finit
m0:
    fld const0 ;Занесення const0 в стек
	fld x0 ;Занесення x0 в стек
    fmul st(0), st(0) ;x^2
	fld const1 ;Занесення const1 в стек	
    fmulp st(1), st(0) ;3х^2
    fld const2 ;Занесення const2 в стек
    fsubp st(1), st(0) ;3х^2 – 1,1
	fdivp st(1), st(0) ;125/(3х^2 – 1,1)
	frndint ;округлення

    fstp qword ptr [rdi] ; st0 -> array[i]
    add rdi, type res0 ; i += element size
	
    fld x0	;Занесення x0 в стек
    fld step0	;Занесення step0 в стек
    faddp st(1), st(0)	;збільшує значення х на 4
    fstp qword ptr [x0]	;копіює з st(0) в операндр призначення

    loop m0 ; поки loop_count != 0

    invoke fptoa, qword ptr[res0], addr sres0 ; редагування результату 1 до числа з плаваючою точкою
    invoke fptoa, qword ptr[res0 + 8h], addr sres1 ; редагування результату 2 до числа з плаваючою точкою
    invoke fptoa, qword ptr[res0 + 10h], addr sres2 ; редагування результату 3 до числа з плаваючою точкою
	invoke fptoa, qword ptr[res0 + 18h], addr sres3 ; редагування результату 3 до числа з плаваючою точкою
    invoke wsprintf, addr text0, addr fmt0, addr sres0, addr sres1, addr sres2, addr sres3 ; формує наш текст у text0
    invoke MessageBox, 0, addr text0, addr title0, MB_OK ; виклик MessageBox
    invoke ExitProcess, 0
entry_point endp
end