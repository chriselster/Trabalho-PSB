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
    mov ebp, 0
    mov esp, %5
    
    %6:
        cmp esp, [%4]
        je %7
        
        mov ebx, [%3+esp]
        mov dword [%1+ebp], ebx
        
        inc esp
        inc ebp
        jmp %6
    
    %7:      
        mov dword [%2], ebp
        
%endmacro

section .data
    malForm:   db    'Erro de formatação',10
    malLen:    equ   $-malForm 
    len:       dd    100
    lenS:      dd    0
    lenAux:    dd    0
    parQnt:    dd    0
    

section .bss
    str: resb 100
    aux: resb 100
    exp: resb 100
	
section .text
	global _start

_start:
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
    
    print str, [lenS]
    jmp resolve

    error:
        print malForm,malLen
     
     
    resolve:
        mov edx, 0
        mov esi, 0
        cmp byte [str+0], 45
        
        je seMenos
        jne senaoMenos
        
        seMenos:
            mov edi, 1
            
            atrib aux, lenAux, str, lenS, 1, for1, endFor1
            print aux, [lenAux]
            atrib str, lenS, aux, lenAux, 0, for2, endFor2
            
                
        senaoMenos:
        
        
                
        jmp finish

    finish:
        mov eax,1            
        mov ebx,0            
        int 80h
