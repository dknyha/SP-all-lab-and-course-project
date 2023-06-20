;; Варіант 8 
;; Обчислити 3 значення функції Yn = 25х^2 + 2,1 
;; (x змінюється від 3 з кроком 2,5)

include /masm64/include64/masm64rt.inc

.const
    title0 db "Лабораторна 1, Завдання 1", 0	; назва вікна
    fmt0 db "Y = 25х^2 + 2,1; X0 = 3; STEP = 2.5", 10,	; текст вікна
            "Y0 = %s", 10,
            "Y1 = %s", 10,
            "Y2 = %s", 10, 10,
            "Автор: 2234234 234234", 0        
    const0 dq 2.1	; константи
    const1 dq 25.0
    step0 dq 2.5	; крок 
    loop_count0 dq 3	; кількість проходів по циклу loop
.data
    x0 dq 3.0	; x
    res0 dq 3 dup(0.0)	; Масив результатів
    text0 db 256 dup(0)	; резервування якеек для тексту

    sres0 db 32 dup(0) 	; резервування якеек для результатів
    sres1 db 32 dup(0)  
    sres2 db 32 dup(0) 
.code
entry_point proc
    lea rdi, res0	; Aдреса масиву
    mov rcx, loop_count0	; Кількість ітерацій
    finit
m0:
    fld x0	;Занесення x0 в стек
    fmul st(0), st(0)	; X^2
	fld const1	;Занесення const1 в стек	
    fmulp st(1), st(0)	; 25х^2
    fld const0	;Занесення const0 в стек  
    faddp st(1), st(0)	; 25х^2 + 2,1

    fstp qword ptr [rdi] ; st0 -> array[i]
    add rdi, type res0 ; i += element size

    fld x0	;Занесення x0 в стек
    fld step0	;Занесення step0 в стек
    faddp st(1), st(0)	;збільшує значення х на 2,5
    fstp qword ptr [x0]	;копіює з st(0) в операндр призначення

    loop m0 ; поки loop_count != 0

    invoke fptoa, qword ptr[res0], addr sres0 ; редагування результату 1 до числа з плаваючою точкою
    invoke fptoa, qword ptr[res0 + 8h], addr sres1 ; редагування результату 2 до числа з плаваючою точкою
    invoke fptoa, qword ptr[res0 + 10h], addr sres2 ; редагування результату 3 до числа з плаваючою точкою
    invoke wsprintf, addr text0, addr fmt0, addr sres0, addr sres1, addr sres2 ; формує наш текст у text0
    invoke MessageBox, 0, addr text0, addr title0, MB_OK ; виклик MessageBox
    invoke ExitProcess, 0
entry_point endp
end