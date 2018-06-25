; ------------------ MACROS ----------------------

%macro print 2
    mov eax,4
    mov ebx,1
    mov ecx,%1
    mov edx,%2
    int 80h
%endmacro

%macro scan 2
    mov eax,3
    mov ebx,0
    mov ecx,%1
    mov edx,%2
    int 80h
%endmacro

%macro atrib 7 ; aux lenAux str lenS 1
    mov dword [cont], 0
    mov dword [i], %5
    
    %6:
        mov esp, [i]
        cmp esp, [%4]
        je %7
        
        mov esp, [i]
        mov ebp, [cont]
        mov ah, [%3+esp]
        mov byte [%1+ebp], ah
        
        inc dword [i]
        inc dword [cont]
        jmp %6
    
    %7:      
        mov ebp, [cont]
        mov dword [%2], ebp
        
%endmacro

%macro pushar 4

mov word [i], 0

mov eax, %2
mov ebx, 2
mov edx, 0

div ebx

cmp edx, 1
mov esi, %2

jne %3
inc esi

%3:
    cmp dword [i], esi
    je %4
    
    mov edi, dword [i]
    push word [%1+edi]
    add word [i], 2
    jmp %3
    
%4:
    
%endmacro

%macro popar 4

mov eax, %2
mov ebx, 2
mov edx, 0

div ebx

cmp edx, 1
mov esi, %2

jne %3
inc esi

mov dword [i], esi

%3:
    cmp byte [i], 0
    je %4
    
    sub word [i], 2
    mov esi, [i]
    pop word [%1+esi]
    
    jmp %3
    
%4:
    
%endmacro

; ------------------ SECTION ----------------------

section .data
    malForm:   db    'Erro de formatação',10
    malLen:    equ   $-malForm 
    len:       dd    100
    lenS:      dd    0
    lenAux:    dd    0
    parQnt:    dd    0
    p:         dd    0
    neg:       dd    0
    i:         dd    0
    cont:      dd    0
    

section .bss
    str: resb 100
    aux: resb 100
    exp: resb 100
	
section .text
	global _start
    
; ------------------ MAIN ----------------------  

_start:
; ------------------ REMOÇÃO DE ESPAÇOS E VERIFICAÇÃO DE PARÊNTESES ----------------------  
    scan exp,len
    
    mov eax,0x0
    mov ebx,0x0
    
    delSpace:
        cmp eax,[len]
        JE end
        
        cmp byte [exp+eax],32
        JE final 
        
        mov ebx, [lenS]
        mov edx,[exp+eax]
        mov [str+ebx],edx
        inc dword [lenS]
        
        final:
            inc eax
            JMP delSpace
    end:
    
    mov eax,0x0

    jmp checkPar
    
    checkPar:    
        cmp eax,[lenS]
        JE endPar
        
        cmp byte [str+eax],40
        JNE else
        inc dword [parQnt]
        jmp finalPar
        
        else:
            cmp byte [str+eax],41
            JNE finalPar
            dec dword [parQnt]  
        
        finalPar:
            inc eax
            JMP checkPar
    endPar:
    
    cmp dword [parQnt],0
    JNE error
    
    jmp resolve

    error:
        print malForm,malLen
        
; ------------------ CÁLCULO DA EXPRESSÃO ----------------------      
     
    resolve:
    
        ; if (a[0] == '-') {
      
        cmp byte [str], 45
        
        jne senaoMenos
        
        seMenos:
            mov dword [neg], 1
            
            atrib aux, lenAux, str, lenS, 1, for1, endFor1
            atrib str, lenS, aux, lenAux, 0, for2, endFor2
            
        ; }
                
        senaoMenos:
        
        ; if (a[0] == '(') {
        
        cmp byte [str], 40
        
        jne senaoParent
        
        seParent:
            inc dword [p]
            
            ; for (int i = 1; i < a.size()-1; i++) {
            
            mov dword [i], 1
            
            for3:
                mov esp, [i]
                mov ebp, [lenS]
                dec ebp
                
                cmp esp, ebp
                je endFor3
                
                ; if(a[i] == '(') {
                
                cmp dword [str+esp], 40
                jne senaoParentFor3
                
                seParentFor3:
                    inc dword [p]
                    jmp finalFor3
                    
                ; }
                
                senaoParentFor3:
                
                ; if(a[i] == ')') {
                
                cmp dword [str+esp], 41
                jne finalFor3

                cmp dword [p], 1
                jl senaoPFor3

                dec dword [p]

                senaoPFor3:
                cmp dword [p], 0
                je endFor3
                
                ; }

                finalFor3:
                    inc dword [i]
                    jmp for3
                    
            ; }
            
            endFor3:
            
            ; if (p == 1 ) {
            
            cmp dword [p], 1
            jne senaoP1
            
            seP1:
                mov esp, [lenS]
                dec esp
                atrib str, esp, aux, lenAux, 1, for4, endFor4
                
                dec dword [p]
                
                cmp dword [neg], 1
                
            ; }
            
            senaoP1:
            

        ; }
        
        senaoParent:
        
        
                
        jmp finish

    finish:
        mov eax,1            
        mov ebx,0            
        int 80h
