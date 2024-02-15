; number1 operation number2
assume cs: code, ds: data

data segment

dummy db 0Ah, '$'
IRP var, <number1, number2, tmp, res>
    var db 100, 110 dup ('$')
endm
op db 2, 5 dup('$')
big_number db 0, 105, 1, 104 dup (0), '$'
digit_tmp db 0
grade_tmp db 0
sign db ''

data ends

code segment

start:
    mov ax, data
	mov ds, ax

    IRP var, <number1, op, number2>
    	mov dx, offset var
    	mov ax, 0
    	mov ah, 0Ah
    	int 21h

        mov dx, offset dummy
    	mov ah, 09h
    	int 21h
    endm

    IRP var, <number1, number2>
        local check_symbol, return, pass

        mov si, 1
        mov cl, byte ptr var[si]

        inc si
        mov dl, byte ptr var[si]

        mov ax, '-'
        cmp dx, ax
        jne check_symbol
        inc si
        dec cl

        check_symbol:
            mov dl, byte ptr var[si]

            mov ax, '0'
            cmp dx, ax
            jl return

            mov ax, '9'
            cmp dx, ax
            jg return

            sub byte ptr var[si], '0'

            inc si
            loop check_symbol

        jmp pass

        return:
            mov ah, 4ch
        	int 21h

        pass:
    endm

    sum MACRO x, y, res
        local column_addition, iter, put_len, put_number, done
        push di

        xor dx, dx

        mov di, 1
        mov dl, byte ptr x[di]
        add di, dx

        mov si, 1
        mov dl, byte ptr y[si]
        add si, dx
        mov cl, dl

        xor ax, ax
        mov bl, 10

        column_addition:
            add al, byte ptr x[di]
            add al, byte ptr y[si]

            div bl

            mov dl, ah
            push dx
            xor ah, ah

            dec di
            dec si

            loop column_addition
        
        iter:
            cmp di, 1
            jle done 

            add al, byte ptr x[di]

            div bl

            mov dl, ah
            push dx
            xor ah, ah

            dec di

            jmp iter

        done:
            mov di, 1
            mov cl, byte ptr x[di]

            mov di, offset res
            inc di

            cmp al, 0
            je put_len

            mov dl, al
            push dx
            inc cl

        put_len:
            mov ds:[di], cl
            inc di

        put_number:
            pop dx
            mov ds:[di], dx
            inc di

            loop put_number

        pop di
    endm

    subtract MACRO x, y, res
        local column_subtraction, iter, put_len, put_number, done

        xor dx, dx

        mov di, 1
        mov dl, byte ptr x[di]
        add di, dx

        mov si, 1
        mov dl, byte ptr y[si]
        add si, dx

        mov cl, dl

        xor ax, ax
        mov bl, 10

        column_subtraction:
            add al, byte ptr x[di]
            sub al, byte ptr y[si]

            add al, 10
            div bl
            dec al

            mov dl, ah
            push dx
            xor ah, ah

            dec di
            dec si

            loop column_subtraction

        iter:
            cmp di, 1
            jle done

            add al, byte ptr x[di]

            add al, 10
            div bl
            dec al

            mov dl, ah
            push dx
            xor ah, ah

            dec di

            jmp iter

        done:
            mov di, 1
            mov cl, byte ptr x[di]

            mov di, offset res
            inc di

        put_len:
            mov ds:[di], cl
            inc di

        put_number:
            pop dx
            mov ds:[di], dx
            inc di

            loop put_number
    endm

    multiply_by_digit MACRO x, digit, grade, res
        local fill_zeros, next, column_multiplication, done, put_len, put_number

        push di
        xor cx, cx
        xor dx, dx

        mov cl, grade
        cmp cl, 0
        je next

        fill_zeros:
            push dx
            loop fill_zeros

        next:
            mov di, 1
            mov cl, byte ptr x[di]
            add di, cx

            xor ax, ax
            mov bh, 0
            mov bl, 10

        column_multiplication:
            mov al, byte ptr x[di]
            mul digit

            div bl

            mov dl, ah
            add dl, bh 
            push dx
            xor ah, ah

            mov bh, al

            dec di

            loop column_multiplication

        done:
            mov di, 1
            mov cl, byte ptr x[di]
            add cl, grade

            mov di, offset res
            inc di
            cmp bh, 0
            je put_len

            mov dl, bh
            push dx
            inc cl

        put_len:
            mov ds:[di], cl
            inc di

        put_number:
            pop dx
            mov ds:[di], dx
            inc di

            loop put_number

        pop di
    endm

    multiply MACRO x, y, res
        local iter, done

        push dx 
        xor dx, dx
        mov di, 1
        mov bl, byte ptr y[di]
        dec bl
        mov grade_tmp, bl 
        inc di
        mov bl, byte ptr y[di]
        mov digit_tmp, bl

        multiply_by_digit x, digit_tmp, grade_tmp, res

        cmp grade_tmp, 0
        jne iter
        jmp done

        iter:
            dec grade_tmp
            inc di

            mov bl, byte ptr y[di]
            mov digit_tmp, bl

            multiply_by_digit x, digit_tmp, grade_tmp, tmp

            sum res, tmp, res

            cmp grade_tmp, 0
            je done

            jmp iter

        done:
            pop dx
    endm

    to_tens_complement MACRO x
        local exit

        xor di, di
        mov x[di], 0

        mov di, 2
        cmp x[di], '-'
        jne exit

        mov x[di], 0

        subtract big_number, x, x

        xor di, di
        inc x[di]

        exit:
    endm

    mov di, 2
    mov dl, op[di]

    cmp dl, '-'
    je perform_sub

    cmp dl, '+'
    je perform_sum

    jmp check 

    perform_sub:
        subtract number1, number2, res
        jmp result

    perform_sum:
        to_tens_complement number1
        to_tens_complement number2

        mov di, 1
        mov dl, number1[di]

        cmp dl, number2[di]
        jge greater
        jmp less

        greater:
            sum number1, number2, res
            jmp set_sign

        less:
            sum number2, number1, res
            jmp set_sign

        set_sign:
            xor di, di
            mov al, number1[di]
            add al, number2[di]

            cmp al, 0
            je positive

            mov di, 2
            add al, res[di]

            mov bl, 2
            div bl

            cmp ah, 0
            je positive

            negative:
                subtract big_number, res, res
                mov di, 2
                mov res[di], 0
                mov sign, '-' 
                jmp result

            positive:
                mov res[di], 0
                jmp result

    check:
        cmp dl, '*'
        je perform_mul
        jmp result

    perform_mul:
        xor dl, dl
        mov di, 2

        first:
            cmp number1[di], '-'
            jne second

            mov number1[di], 0
            inc dl

        second:
            cmp number2[di], '-'
            jne perform

            mov number2[di], 0
            inc dl

        perform:
            multiply number1, number2, res

            cmp dl, 1
            jne result

            mov sign, '-'

    result:
        mov si, 1
        mov di, 1
        mov cl, byte ptr res[si]

        skip_zeros:
            inc si
            cmp res[si], 0
            jne catch_zero
            inc di
            loop skip_zeros

        catch_zero:
            cmp cl, 0
            jne put_sign
            inc cl
            jmp iter

        put_sign:
            inc di
            mov dl, sign
            cmp dl, '-'
            jne iter

            dec di
            mov res[di], dl

        iter:
            add byte ptr res[si], '0'

            inc si
            loop iter

        mov dx, offset dummy
        mov ah, 09h
        int 21h

        mov dx, offset res
        add dx, di
        mov ah, 09h
        int 21h

	mov ah, 4ch
	int 21h

code ends
end start