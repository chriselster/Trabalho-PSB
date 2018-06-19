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

section .data
    malForm:   db    'Erro de formatação',10
    malLen:    equ   $-malForm 
    len:       dd    100
    lenS:      dd    0
    parQnt:    dd    0
    

section .bss
    str: resb 100
    exp: resb 100
	
section .text
	global _start

_start:
    scan exp,len
    
    mov eax,0x0
    mov dword [lenS],0x0
    delSpace:
        cmp eax,[len]
        JE end
        
        cmp byte [exp+eax],32
        JE final                
        
        mov ebx,[lenS]
        mov edx,[exp+eax]
        mov [str+ebx],edx
        inc dword [lenS]
        final:
            inc eax
            JMP delSpace
    end:
    
    mov eax,0x0
    checkPar:    
        cmp eax,[lenS]
        JE endPar
        
        cmp byte [exp+eax],40
        JNE else
        inc dword [parQnt]
        
        else:
            cmp byte [exp+eax],41
            JNE finalPar
            dec dword [parQnt]        
        
        finalPar:
            inc eax
            JMP checkPar
    endPar:
    
    cmp dword [parQnt],0
    JNE error
    
    print str,[lenS]
    JMP finish

    error:
        print malForm,malLen

    finish:
        mov eax,1            
        mov ebx,0            
        int 80h
