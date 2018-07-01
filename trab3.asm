; ------------------ MACROS ----------------------

%macro print 2
    mov dword [eaz], eax
    mov dword [ebz], ebx
    mov dword [ecz], ecx
    mov dword [edz], edx
    
    mov eax,4
    mov ebx,1
    mov ecx,%1
    mov edx,%2
    int 80h
    
    mov eax, [eaz]
    mov ebx, [ebz]
    mov ecx, [ecz]
    mov edx, [edz]
%endmacro

%macro scan 2
    mov dword [eaz], eax
    mov dword [ebz], ebx
    mov dword [ecz], ecx
    mov dword [edz], edx

    mov eax,3
    mov ebx,0
    mov ecx,%1
    mov edx,%2
    int 80h
    
    mov eax, [eaz]
    mov ebx, [ebz]
    mov ecx, [ecz]
    mov edx, [edz]
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

mov dword [j], 0

mov eax, %2
mov ebx, 2
mov edx, 0

div ebx

mov eax, %2
cmp edx, 1
jne %3

inc eax

%3:
    cmp dword [j], eax
    je %4
    
    mov ebx, dword [j]
    push word [%1+ebx]
    add word [j], 2
    jmp %3
    
%4:
    
%endmacro

%macro popar 4

mov eax, %2
mov ebx, 2
mov edx, 0

div ebx

mov eax, %2
cmp edx, 1
jne %3

inc eax

mov dword [j], eax

%3:
    cmp dword [j], 0
    je %4
    
    sub word [j], 2
    mov ebx, [j]
    pop word [%1+ebx]
    
    jmp %3
    
%4:
    
%endmacro

%macro negat 1
    mov eax, %1
    mov dword %1, 0
    sub dword %1, eax
%endmacro

%macro numToStr 6

mov eax, %1

cmp eax, 0
jge %6

mov dword [val], 45
print val, 1

mov ebx, %1
mov eax, 0
sub eax, ebx

%6:
mov ebx, 10
mov ecx, 0
mov edx, 0

%2:
    cmp eax, 10
    jl %3

    mov edx, 0  
    div ebx
    
    mov dword [val], edx

    push dword [val]
    
    inc ecx
    jmp %2

%3:

mov dword [val], eax
push dword [val]
inc ecx

mov edx, 0

%4:
    cmp edx, ecx
    je %5
    
    pop dword [val]
    add dword [val], '0'
    print val, 1
    
    inc edx
    jmp %4

%5:

%endmacro

; ------------------ SECTION ----------------------

section .data
    malForm:   db    'Erro de formatação',10
    malLen:    equ   $-malForm 
    certo:     db    'Certo'
    noPar:     db    'TonoParenteses'
    base:      db    'TonaBase'
    menos:     db    'TonoMenos'
    mais:      db    'TonoMais'
    noFor:     db    'TonoFor'
    antes:     db    'Antes: '
    depois:    db    'Depois: '
    voltou:    db    'Voltou - '
    resultado: db    'Resultado: '
    quebra:    db    10
    len:       dd    100
    lenS:      dd    0
    lenAux:    dd    0
    parQnt:    dd    0
    p:         dd    0
    neg:       dd    0
    i:         dd    0
    j:         dd    0
    cont:      dd    0
    eaz:       dd    0
    ebz:       dd    0
    ecz:       dd    0
    edz:       dd    0
    space:     dd    32
    
    val:       dd    0
    val1:      dd    0
    val2:      dd    0

section .bss
    str:  resb 100
    aux:  resb 100
    exp:  resb 100
    strX: resb 100
    strY: resb 100
	result: resb 100
section .text
	global _start
    
; ------------------ MAIN ----------------------  

_start:
; ------------------ REMOÇÃO DE ESPAÇOS E VERIFICAÇÃO DE PARÊNTESES ----------------------  
 
    scan exp,len
    
    mov ebx,0x0
    mov dword [j], 0
    mov dword [lenS], 0
    
    delSpace:
        mov eax, [j]
        cmp eax,[len]
        JE end
        
        cmp byte [exp+eax], 10
        je end
        
        cmp byte [exp+eax], 32
        JE final 
        
        mov ebx, [lenS]
        mov ah, [exp+eax]
        mov byte [str+ebx], ah
        inc dword [lenS]
        
        final:
            inc dword [j]
            JMP delSpace
    end:
    
    mov eax, 0x0

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
    
    cmp dword [parQnt], 0
    JNE error
    
    mov dword [result], 0
    call resolve
    jmp finish
    
    error:
        print malForm,malLen
        jmp finish
        
; ------------------ CÁLCULO DA EXPRESSÃO ----------------------      
     
    resolve:
        print str, [lenS]
        print space, 1
        mov dword [neg], 0

        ; if (a[0] == '-') {
      
        cmp byte [str], 45
        
        jne senaoMenos
        
        seMenos:
            mov dword [neg], 1
            
            atrib aux, lenAux, str, lenS, 1, for1, endFor1
            atrib str, lenS, aux, lenAux, 0, for2, endFor2
            print str, [lenS]
            print space, 1
        ; }
                
        senaoMenos:
        
        ; if(a.size() == 1) {
        
        cmp dword [lenS], 1
        jne endResultBase
        
        resultBase:
            print base, 8
            print space, 1
            
            cmp dword [neg],0
            jne baseNeg
            
            mov ah, [str]
            sub ah, '0'
            mov byte [result], ah
            
            ret
            
            baseNeg:
                mov ah, [str]
                sub ah, '0'
                mov byte [result], ah
                negat [result]
                
                ret
        ; }
         
        endResultBase:
            
        ; if (a[0] == '(') {
        
        cmp byte [str], 40
        
        jne senaoParent
        
        seParent:
            
            inc dword [p]
            
            ; for (int i = 1; i < a.size()-1; i++) {
            
            mov dword [i], 1
            
            for3:
                mov eax, [i]
                mov edx, [lenS]
                dec edx
                
                cmp eax, edx
                je endFor3
                
                ; if(a[i] == '(') {
                
                cmp byte [str+eax], 40
                jne senaoParentFor3

                seParentFor3:
                    inc dword [p]
                    jmp finalFor3
                    
                ; }
                
                senaoParentFor3:
                
                ; if(a[i] == ')') {
                cmp byte [str+eax], 41
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
            jne senaoParent
            
            seP1:
                print antes, 7
                print str, [lenS]
                print space, 1
                dec dword [lenS]
                
                atrib aux, lenAux, str, lenS, 1, for12, endFor12
                atrib str, lenS, aux, lenAux, 0, for4, endFor4
                print depois, 8
                print str, [lenS]
                print space, 1
                print quebra, 1
                
                dec dword [p]
                
                cmp dword [neg], 1
                jne resultP1
                
                call resolve
                print noPar, 14
                print voltou, 9
                print quebra, 1
                negat [result]
                ret
                
                resultP1:
                call resolve
                print voltou, 9
                print quebra, 1
                ret
                    
            ; }
            
            
            

        ; }
        
        senaoParent:
            
        ; for (int i = 0; i < a.size(); i++) {
        mov dword [i], 0

        for5:
            mov ecx, [i]
            mov edx, [lenS]
            cmp ecx, edx
            je endFor5
            
            ; if(a[i] == '(') {
            cmp byte [str+ecx], 40
            jne senaoParentFor5

            seParentFor5:
                inc dword [p]
                jmp finalFor5
            ; }
            
            senaoParentFor5:
            
            ; if(a[i] == ')') {
            
            cmp byte [str+ecx], 41
            jne maisPrec
                        
            cmp dword [p], 1
            jl finalFor5

            dec dword [p]
            jmp finalFor5

            ; }
            
            ; if(a[i] == '+' && !p) {
            
            maisPrec:
            
            cmp byte [str+ecx],43
            jne menosPrec
            
            cmp dword [p],0
            jne menosPrec
            
            pushar str, [lenS], for6, endFor6
            push dword [lenS]
            push dword [i]
            
            print antes, 7
            print str, [lenS]
            print space, 1
            
            
            
            mov dword [lenS], ecx ; lenS = i
            atrib aux, lenAux, str, lenS, 0, for7, endFor7 ; for (int j=0; j<lenS; j++) aux += a[j]
            atrib str, lenS, aux, lenAux, 0, for8, endFor8 ; for (int j=0; j<lenAux; j++) a += aux[j]
            
            
            
            print depois, 8
            print str, [lenS]
            print space, 1
            print quebra, 1
            call resolve
            
            pop dword [i]
            pop dword [lenS]
            popar str, [lenS], for9, endFor9
            
            print voltou, 9
            print quebra, 1
            print antes, 7
            print str, [lenS]
            print space, 1
                           
            push dword [result]
            
            mov ecx, [i]
            inc ecx
            
            atrib aux, lenAux, str, lenS, ecx, for10, endFor10
            atrib str, lenS, aux, lenAux, 0, for11, endFor11
            
            print depois, 8
            print str, [lenS]
            print space, 1
            print quebra, 1
            call resolve
            
            pop dword [val1]

            mov eax, [val1] ; eax = resolve(x)
            mov edx, [result]
            print quebra, 1
            
            cmp dword [neg], 1
            jne senaoNegMaisPrec
            
            seNegMaisPrec:   
                mov ebx, 0
                sub ebx, eax
                add ebx, edx
                mov dword [result], ebx
                ret
            
            senaoNegMaisPrec:
                mov ebx, 0
                add ebx, eax
                add ebx, edx
                mov dword [result], ebx
                ret
                
                
                
            menosPrec:
            cmp byte [str+ecx],45
            jne finalFor5

            cmp dword [p],0
            jne finalFor5
            
            push dword [neg]
            pushar str, [lenS], for45, endFor45
            push dword [lenS]
            push dword [i]
            
            print antes, 7
            print str, [lenS]
            print space, 1
            
            mov dword [lenS], ecx ; lenS = i
            atrib aux, lenAux, str, lenS, 0, for46, endFor46 ; for (int j=0; j<lenS; j++) aux += a[j]
            atrib str, lenS, aux, lenAux, 0, for47, endFor47 ; for (int j=0; j<lenAux; j++) a += aux[j]
            
            print depois, 8
            print str, [lenS]
            print space, 1
            print quebra, 1
            call resolve
            
            pop dword [i]
            pop dword [lenS]
            popar str, [lenS], for48, endFor48
            
            print voltou, 9
            print quebra, 1
            print antes, 7
            print str, [lenS]
            print space, 1
                           
            push dword [result]
            
            mov ecx, [i]
            
            atrib aux, lenAux, str, lenS, ecx, for49, endFor49
            atrib str, lenS, aux, lenAux, 0, for50, endFor50
            
            print depois, 8
            print str, [lenS]
            print space, 1
            print quebra, 1
            call resolve
            
            pop dword [val1]
            pop dword [neg]

            mov eax, [val1] ; eax = resolve(x)
            mov edx, [result]
            print certo, 5
            cmp dword [neg], 1
            jne senaoNegMenosPrec
           
            seNegMenosPrec:   
                mov ebx, 0
                sub ebx, eax
                add ebx, edx
                mov dword [result], ebx
                ret
                            
            senaoNegMenosPrec:
                mov ebx, 0
                add ebx, eax
                add ebx, edx
                mov dword [result], ebx                
                ret
                
            finalFor5:
                inc dword [i]
                jmp for5

            ; }
        ; }

        endFor5:
            
                
        jmp finish

    finish:
        mov ecx, [result]
        cmp ecx, -9
        jne over
        print quebra, 1
        print resultado, 11
        numToStr ecx, w1, ew1, f1, ef1, c1
        
        over:
        mov eax,1            
        mov ebx,0            
        int 80h
