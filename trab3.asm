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
    mov dword [j], %5
    
    %6:
        mov eax, [j]
        cmp eax, [%4]
        je %7
        
        mov eax, [j]
        mov ebx, [cont]
        mov ah, [%3+eax]
        mov byte [%1+ebx], ah
        
        inc dword [j]
        inc dword [cont]
        jmp %6
    
    %7:      
        mov ebx, [cont]
        mov dword [%2], ebx
        
%endmacro

%macro pushar 4

mov word [j], 0

mov eax, %2
mov ebx, 2
mov edx, 0

div ebx

cmp edx, 1
mov esi, %2

jne %3
inc esi

%3:
    cmp dword [j], esi
    je %4
    
    mov edi, dword [j]
    push word [%1+edi]
    add word [j], 2
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

mov dword [j], esi

%3:
    cmp byte [j], 0
    je %4
    
    sub word [j], 2
    mov esi, [j]
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
    j:         dd    0
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
    
        mov dword [neg], 0
        
        ; if(a.size() == 1) {
        
        cmp dword [lenS],1
        jne endResultBase
        
        resultBase:
            print base, 8
            
            cmp dword [neg],0
            jne baseNeg
            
            mov eax,[str]
            mov dword [result], eax
            ret
            
            baseNeg:
                mov eax,[str+0]
                negat eax
                mov dword [result],eax
                ret
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
                mov ecx, [i]
                mov edx, [lenS]
                dec edx
                
                cmp ecx, edx
                je endFor3
                
                ; if(a[i] == '(') {
                
                cmp dword [str+ecx], 40
                jne senaoParentFor3
                
                seParentFor3:
                    inc dword [p]
                    jmp finalFor3
                    
                ; }
                
                senaoParentFor3:
                
                ; if(a[i] == ')') {
                
                cmp dword [str+ecx], 41
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
                print str, [lenS]
                dec dword [lenS]
                
                atrib aux, lenAux, str, lenS, 1, for12, endFor12
                atrib str, lenS, aux, lenAux, 0, for4, endFor4
                print str, [lenS]
                
                dec dword [p]
                
                cmp dword [neg], 1
                jne resultP1
                
                negat [result]
                
                resultP1:
                call resolve
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
            print str, [lenS]
            call resolve
            
            
            pop word [i]
            pop word [lenS]
            popar str, [lenS], for9, endFor9
               
            push word [result]
            mov ecx, [i]
            inc ecx
            
            atrib aux, lenAux, str, lenS, ecx, for10, endFor10
            atrib str, lenS, aux, lenAux, 0, for11, endFor11
            print str, [lenS]
            call resolve
            
            pop word [val1]
            
            print val1, 1
            mov eax, [val1] ; eax = resolve(x)
            sub eax, '0'
            mov edx, [result]
            sub edx, '0'
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
        add dword [result], 48
        cmp dword [result], 51
        jne over
        
        print certo, 4
        
        over:
        mov eax,1            
        mov ebx,0            
        int 80h
