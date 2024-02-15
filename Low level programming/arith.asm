;(a+b/c) * d - 4
assume CS:code, DS:data

data segment
    a dw 7
    b dw 12
    c dw 6
    d dw 2

    res dw ?		
    msg db 2 dup(30h), 0dh, 0ah, "$"
    msg2 db 2 dup(30h), "$"	
data ends

sseg segment stack
    db 100h dup (?)
sseg ends

code segment
    start:      

    mov AX, data
    mov DS, AX
    mov AX, b
    cwd
    div c
    add AX, a
    mul d
    sub AX, 4
    mov res, AX

    mov DI, offset msg
    push DI

    mov BX, 10
    xor CX, CX
    inDec:
        xor DX, DX
        div BX
        add DL, 30h
        push DX
        inc CX
        or AX, AX 		
        jne inDec

    makeStr:
        pop AX
        mov [DI], AL
        inc DI				
        dec CX				
        or CX, CX
        jne makeStr

    mov AH, 09h
    pop DI
    mov DX, DI			
    int 21h	

    xor DI,DI
    mov DI, offset msg2 		
    push DI
                    
    mov AX, res
    mov BX, 16			
    xor CX, CX 			
    inHex: 	
        xor DX, DX 		
        div BX			
        cmp DL, 9
        jbe oi1
        add DL, 7
        oi1:
            add DL, 30h	
        push DX			
        inc CX			
        or AX, AX 		
        jne inHex

    mov [DI], byte ptr '0'
    inc DI

    makeStr2:
        pop AX			
        mov [DI], AL		
        inc DI				
        dec CX				
        or CX, CX
        jne makeStr2

    mov AH, 09h			
    pop DI				
    mov DX, DI			
    int 21h	

    mov AX, 4C00h
    int 21h
code ends
end start