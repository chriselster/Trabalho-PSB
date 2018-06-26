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
        mov eax, [i]
        cmp eax, [%4]
        je %7
        
        mov eax, [i]
        mov ebx, [cont]
        mov ah, [%3+eax]
        mov byte [%1+ebx], ah
        
        inc dword [i]
        inc dword [cont]
        jmp %6
    
    %7:      
        mov ebx, [cont]
        mov dword [%2], ebx
        
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

%macro negat 1
    mov dword ebx,%1
    mov eax,0
    sub eax,ebx
    mov dword %1,eax
%endmacro

; ------------------ SECTION ----------------------

section .data
    malForm:   db    'Erro de formatação',10
    malLen:    equ   $-malForm 
    certo:     db    'Eh 9'
    noPar:     db    'TonoParenteses'
    base:      db    'TonaBase'
    menos:     db    'TonoMenos'
    mais:      db    'TonoMais'
    noFor:     db    'TonoFor'
    len:       dd    100
    lenS:      dd    0
    lenAux:    dd    0
    parQnt:    dd    0
    p:         dd    0
    neg:       dd    0
    i:         dd    0
    cont:      dd    0
    
    result:    dd    0
    val1:      dd    0
    val2:      dd    0

section .bss
    str:  resb 100
    aux:  resb 100
    exp:  resb 100
    strX: resb 100
    strY: resb 100
	
section .text
	global _start
    
; ------------------ MAIN ----------------------  

_start:
; ------------------ REMOÇÃO DE ESPAÇOS E VERIFICAÇÃO DE PARÊNTESES ----------------------  
 
    scan exp,len
    
    mov eax,0x0
    mov ebx,0x0
    mov dword [lenS], 0
    
    delSpace:
        cmp eax,[len]
        JE end
        
        cmp byte [exp+eax], 10
        je end
        
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
    
    print str, [lenS]
    cmp dword [lenS], 4
    jne qualfoi
    
    print certo, 4
    
    qualfoi:
    
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
    
    call resolve
    jmp finish
    
    error:
        print malForm,malLen
        jmp finish
        
; ------------------ CÁLCULO DA EXPRESSÃO ----------------------      
     
    resolve:
        
        ; if(a.size() == 1) {
        
        cmp dword [lenS],1
        jne endResultBase
        
        resultBase:
            print base, 8
            cmp dword [neg],1
            jne baseNeg
            
            mov eax,[str]
            sub eax, 48
            mov [result],eax
            jmp endResultBase
            
            baseNeg:
                mov eax,[str]
                sub eax, 48
                negat eax
                mov dword [result],eax
        ; }
         
        endResultBase:
        
        
         
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
                dec dword [lenS]
                atrib str, lenS, aux, lenAux, 1, for4, endFor4
                
                dec dword [p]
                
                cmp dword [neg], 1
                jne resultP1
                
                call resolve
                
                negat [result]
                
                resultP1:
                
                ret
                    
            ; }
            
            senaoP1:
            
            

        ; }
        
        senaoParent:
            
        ; for (int i = 0; i < a.size(); i++) {

        mov dword [i], 0

        for5:
            mov ecx,[i]

            cmp ecx, [lenS]
            je endFor5

            ; if(a[i] == '(') {

            cmp dword [str+ecx], 40
            jne senaoParentFor5

            seParentFor5:
                inc dword [p]
                jmp finalFor5

            ; }

            senaoParentFor5:

            ; if(a[i] == ')') {

            cmp byte [str+ecx], 41
            jne menorPrec

            cmp dword [p], 1
            jne finalFor5

            dec dword [p]
            jmp finalFor5

            ; }
            
            ; if(a[i] == '+' && !p) {
            
            menorPrec:
            
            cmp byte [str+ecx],43
            jne elseMenorPrec
            cmp dword [p],0
            jne elseMenorPrec
            
            pushar str, [lenS], for6, endFor6
            push word [lenS]
            push word [i]

            mov dword [lenS], ecx ; lenS = i
            atrib aux, lenAux, str, lenS, 0, for7, endFor7 ; for (int j=0; j<lenS; j++) aux += a[j]

            atrib str, lenS, aux, lenAux, 0, for8, endFor8 ; for (int j=0; j<lenAux; j++) a += aux[j]
            call resolve

            pop word [i]
            pop word [lenS]
            popar str, [lenS], for9, endFor9

            push word [result]
            mov ecx, [i]
            atrib aux, lenAux, str, lenS, ecx, for10, endFor10
            atrib str, lenS, aux, lenAux, ecx, for11, endFor11
            call resolve
            
            pop word [val1]
            mov eax, [val1] ; eax = resolve(x)
            mov edx, [result]
            mov dword [val2], edx ; edx = resolve(y)
                
            cmp dword [neg], 1
            jne senaoNegPrec
            
            seNegPrec:   
                mov dword [result], 0
                sub dword [result], eax
                add dword [result], edx
                ret
            
            senaoNegPrec:
                mov dword [result], 0
                add dword [result], eax
                add dword [result], edx
                ret
                
            elseMenorPrec:
                
            finalFor5:
                inc dword [i]
                jmp for5

            ; }
        ; }

        endFor5:
            
                
        jmp finish

    finish:
        cmp dword [result], 9
        jne over
        
        print certo, 4
        
        over:
        mov eax,1            
        mov ebx,0            
        int 80h
