; ------------------ MACROS ----------------------

; ------------------ PRINT STRING ----------------------

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

; ------------------ SCAN STRING ----------------------

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

; ------------------ ATRIBUIR STRING ----------------------

%macro atrib 7
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

; ------------------ PUSH STRING ----------------------

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

; ------------------ POP STRING ----------------------

%macro popar 4

mov eax, %2
mov ebx, 2
mov edx, 0
mov dword [j], eax

div ebx

mov eax, %2
cmp edx, 1

jne %3

inc dword [j]
%3:
    cmp dword [j], 0
    je %4
    
    sub word [j], 2
    mov ebx, [j]
    pop word [%1+ebx]
    
    jmp %3
    
%4:
    
%endmacro

; ------------------ NEGAR INTEIRO ----------------------

%macro negat 1
    mov eax, %1
    mov dword %1, 0
    sub dword %1, eax
%endmacro

; ------------------ IMPRIMIR NUMERO EM STRING ----------------------

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
    string:    db    'String: '
    base:      db    'Base'
    antes:     db    'Antes: '
    depois:    db    'Depois: '
    formatada: db    'Bem Formatada'
    quebra:    db    10
    len:       dd    100
    lenS:      dd    0
    lenAux:    dd    0
    parQnt:    dd    0
    p:         dd    0
    neg:       dd    0
    erro:      dd    0
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
 
    scan exp,len ; exp = EXPRESSÃO COM ESPAÇOS
    
    ; REMOVE OS ESPAÇOS DA EXPRESSÃO. EX: ( 1 + 4 ) => (1+4)
    
    mov ebx, 0
    mov dword [j], 0
    mov dword [lenS], 0
    
    delSpace:
        ; VERIFICA SE j < len
        mov eax, [j]
        cmp eax, [len]
        JE end
        
        ; VERIFICA SE exp[j] == '\n'
        cmp byte [exp+eax], 10
        je end
        
        ; VERIFICA SE exp[j] == ' '
        cmp byte [exp+eax], 32
        JE final 
        
        ; CASO NÃO SEJA, str[lenS] = exp[j]
        mov ebx, [lenS]
        mov ah, [exp+eax]
        mov byte [str+ebx], ah
        inc dword [lenS] ; 
        
        ; INCREMENTA j E VOLTA PARA O INICIO DO LOOP
        final:
            inc dword [j]
            JMP delSpace
    end:
    
    ; VERIFICA SE HÁ ERRO DE FORMATAÇÃO NOS PARÊNTESES
    
    mov eax, 0x0
    mov dword [parQnt], 0
    
    checkPar:    
        ; VERIFICA SE eax < lenS
        cmp eax,[lenS]
        JE endPar
        
        ; VERIFICA SE str[eax] == '('
        cmp byte [str+eax],40
        JNE else
        
        ; SE FOR, parQnt = parQnt + 1 E CONTINUA O LOOP
        inc dword [parQnt]
        jmp finalPar
        
        ; SE NÃO FOR
        else:
            ; VERIFICA SE str[eax] == ')'
            cmp byte [str+eax],41
            JNE finalPar
            
            ; SE FOR, parQnt = parQnt - 1 E CONTINUA O LOOP
            dec dword [parQnt]  
        
        ; INCREMENTA eax E VOLTA PARA O INICIO DO LOOP
        finalPar:
            inc eax
            JMP checkPar
            
    endPar:
    
    ; VERIFICA SE parQnt == 0; SE FOR, RETORNA MENSAGEM DE ERRO DE FORMATAÇÃO
    cmp dword [parQnt], 0
    JNE error
    
    ; SE NÃO FOR, A EXPRESSÃO ESTÁ BEM FORMATADA E COM ISSO É POSSÍVEL EFETUAR OS CÁLCULOS
    mov dword [result], 0
    
    ; FAZ A CHAMADA RECURSIVA EM resolve
    call resolve
    
    ; PULA PARA O FINAL DO PROGRAMA APÓS CALCULAR A EXPRESSÃO
    jmp finish
    
    ; IMPRIME MENSAGEM DE ERRO E PULA PARA O FINAL
    error:
        print malForm,malLen
        mov dword [erro], 1
        jmp finish
        
; ------------------ CÁLCULO DA EXPRESSÃO ----------------------      
     
    resolve:
        ; str = EXPRESSÃO SEM ESPAÇOS
        ; lenS = TAMANHO DE str
        ; result = RETORNO DA FUNÇÃO
    
        ;print string, 8
        ;print str, [lenS]
        ;print space, 1
        
        mov dword [neg], 0 ; neg = 0

        ; VERIFICA SE str[0] == '-'
        cmp byte [str], 45
        jne senaoMenos
        
        ; SE FOR, REMOVE O '-' DA EXPRESSÃO
        seMenos:
            mov dword [neg], 1 ; neg = 1
            
            ;print antes, 7
            ;print str, [lenS]
            ;print space, 1
            
            ; FAZ str = str.substring(1, str.size())
            atrib aux, lenAux, str, lenS, 1, for1, endFor1 
            atrib str, lenS, aux, lenAux, 0, for2, endFor2
            
            ;print depois, 8
            ;print str, [lenS]
            ;print quebra, 1
            
        senaoMenos:
        
        ; VERIFICA SE lenS == 1
        cmp dword [lenS], 1
        jne endResultBase
        
        ; SE FOR, str[0] É UM NÚMERO E ESTAMOS NO CASO BASE
        resultBase:
            ;print base, 4
            ;print quebra, 1
            
            ; VERIFICA SE neg == 0
            cmp dword [neg],0
            jne baseNeg
            
            ; SE FOR, RETORNA str[0] POSITIVO
            mov ah, [str] ; ah = str[0]
            sub ah, '0' ; ah -= '0'
            movzx eax, ah ; eax = ah
            mov dword [result], eax ; result = eax
            
            ret
            
            ; SE NÃO FOR, RETORNA str[0] NEGATIVO
            baseNeg:
                mov ah, [str]
                sub ah, '0'
                movzx eax, ah
                mov dword [result], eax
                negat [result]
                
                ret
        ; }
         
        endResultBase:
            
        ;  VERIFICA SE str[0] == '('
        cmp byte [str], 40
        jne senaoParent
        
        ; SE FOR, VERIFICA SE A EXPRESSÃO ESTÁ CONTIDA DENTRO DE PARÊNTESES PARA FUTURA ELIMINAÇÃO DOS MESMOS
        seParent:
            
            inc dword [p] ; p = p+1
            
            ; LOOP QUE VAI DE 1 ATÉ lenS-2
            
            mov dword [i], 1
            
            for3:
                ; VERIFICA SE i == lenS-1
                mov eax, [i]
                mov edx, [lenS]
                dec edx
                
                cmp eax, edx
                je endFor3
                
                ; VERIFICA SE str[i] == '('
                cmp byte [str+eax], 40
                jne senaoParentFor3
                
                ; SE FOR, FAZ p = p+1 E CONTINUA O LOOP
                seParentFor3:
                    inc dword [p]
                    jmp finalFor3
                    
                senaoParentFor3:
                
                ; SE NÃO FOR,  VERIFICA SE str[i] == ')'
                cmp byte [str+eax], 41
                jne finalFor3
                
                ; SE FOR, VERIFICA SE p == 1
                cmp dword [p], 1
                jl senaoPFor3
                
                ; SE FOR, FAZ p = p-1
                dec dword [p]
                
                ; SE NÃO FOR, VERIFICA SE p == 0
                senaoPFor3:
                cmp dword [p], 0
                je endFor3
                
                ; SE FOR, PULA PARA O FIM DO LOOP
                
                ; INCREMENTA i E VOLTA PARA O INICIO DO LOOP
                finalFor3:
                    inc dword [i]
                    jmp for3
                    
            endFor3:
            
            ; VERIFICA SE p == 1
            cmp dword [p], 1
            jne senaoParent
            
            ; SE FOR ENTÃO HÁ PARÊNTESES ENVOLVENDO A EXPRESSÃO, NESSE CASO IREMOS REMOVÊ-LOS E CHAMAR A RECURSÃO PARA O QUE ESTIVER DENTRO
            
            seP1:
                ;print antes, 7
                ;print str, [lenS]
                ;print space, 1
                
                dec dword [lenS] ; lenS = lenS-1
                
                ; FAZ str = str.substring(1, str.size()-1)
                atrib aux, lenAux, str, lenS, 1, for4, endFor4
                atrib str, lenS, aux, lenAux, 0, for5, endFor5
                
                ;print depois, 8
                ;print str, [lenS]
                ;print quebra, 1
                
                dec dword [p] ; p = p-1
                
                ; VERIFICA SE A EXPRESSÃO POSSUI '-' ANTES DOS PARÊNTESES (neg == 1)
                cmp dword [neg], 1
                jne resultP1
                
                ; SE FOR, CHAMA A RECURSÃO PARA A EXPRESSÃO DE DENTRO E APÓS O CÁLCULO FAZ result = -result, RETORNANDO UM VALOR OPOSTO
                call resolve
                negat [result]
                ret
                
                ; SE NÃO FOR, CHAMA A RECURSÃO PARA A EXPRESSÃO DE DENTRO E, APÓS O CÁLCULO, RETORNA
                resultP1:
                call resolve
                ret
                    

        senaoParent:
            
        ; SE A RECURSÃO CHEGOU ATÉ ESTE PONTO, ENTÃO NÃO HÁ PARÊNTESES ENVOLVENDO A EXPRESSÃO
        ; COM ISSO DEVEMOS PROCURAR O OPERADOR DE MENOR PRECEDÊNCIA
        
        ; LOOP DE 0 até lenS-1
        mov dword [i], 0

        for6:
            ; VERIFICA SE i == lenS
            mov ecx, [i]
            mov edx, [lenS]
            cmp ecx, edx
            je endFor6
            
            ; VERIFICA SE str[i] == '(' 
            cmp byte [str+ecx], 40
            jne senaoParentFor6
            
            ; SE FOR, FAZ p = p+1 E CONTINUA O LOOP
            seParentFor6:
                inc dword [p]
                jmp finalFor6

            senaoParentFor6:
            
            ; SE NÃO FOR, VERIFICA SE str[i] == ')'
            cmp byte [str+ecx], 41
            jne maisPrec
            
            seParentInvFor6:
                ; SE FOR, VERIFICA SE p == 1
                cmp dword [p], 1
                jl finalFor6
                
                ; SE FOR, FAZ p = p-1 E CONTINUA O LOOP
                dec dword [p]
                jmp finalFor6

            
            maisPrec:
            
            ; SE NÃO FOR, VERIFICA SE str[i] == '+' E p == 0
            cmp byte [str+ecx],43
            jne menosPrec
            
            cmp dword [p],0
            jne menosPrec
            
            seMaisPrec:
            
                ; SE FOREM, COLOCAMOS neg, str, lenS e i NA PILHA
                push dword [neg]
                pushar str, [lenS], for7, endFor7
                push dword [lenS]
                push dword [i]
                
                ;print antes, 7
                ;print str, [lenS]
                ;print space, 1
                
                mov dword [lenS], ecx ; lenS = i
                
                ; APÓS ISSO, FAZ str = str.substring(0, i)
                atrib aux, lenAux, str, lenS, 0, for8, endFor8 
                atrib str, lenS, aux, lenAux, 0, for9, endFor9 
                
                ;print depois, 8
                ;print str, [lenS]
                ;print quebra, 1
                
                ; CHAMAMOS A RECURSÃO PARA CALCULAR O QUE HÁ ANTES DO OPERADOR '+'
                call resolve
                
                ; RECUPERAMOS i, lenS e str DA PILHA
                pop dword [i]
                pop dword [lenS]
                popar str, [lenS], for10, endFor10
        
                ;print quebra, 1
                
                ;print antes, 7
                ;print str, [lenS]
                ;print space, 1
                
                ; COLOCAMOS NA PILHA O RESULTADO DO CÁLCULO PARA A EXPRESSÃO ANTES DO '+'               
                push dword [result]
                
                mov ecx, [i]
                inc ecx
                
                ; APÓS ISSO, FAZEMOS str = str.substring(i+1, str.size())
                atrib aux, lenAux, str, lenS, ecx, for11, endFor11
                atrib str, lenS, aux, lenAux, 0, for12, endFor12
                
                ;print depois, 8
                ;print str, [lenS]
                ;print space, 1
                ;print quebra, 1
                
                ; CHAMAMOS A RECURSÃO PARA CALCULAR O QUE HÁ DEPOIS DO OPERADOR '+' 
                call resolve
                
                ; RECUPERAMOS O RESULTADO DA EXPRESSÃO ANTES DO '+', O VALOR DE neg E COLOCAMOS O RESULTADO DA EXPRESSÃO DEPOIS DO '+' EM edx
                pop eax
                pop dword [neg]
                mov edx, [result]
                
                ;print quebra, 1
                
                ; VERIFICA SE str PRECEDE DE '-' (neg == 1)
                cmp dword [neg], 1
                jne senaoNegMaisPrec
                
                ; SE FOR, FAZEMOS result = 0-eax+edx E RETORNAMOS
                seNegMaisPrec:   
                    mov ebx, 0
                    sub ebx, eax
                    add ebx, edx
                    mov dword [result], ebx
                    ret
                
                ; SE NÃO FOR, FAZEMOS result = eax+edx E RETORNAMOS
                senaoNegMaisPrec:
                    mov ebx, 0
                    add ebx, eax
                    add ebx, edx
                    mov dword [result], ebx
                    ret
                
                
                
            menosPrec:
            
            ; SE NÃO FOREM, VERIFICA SE str[i] == '-' E p == 0
            cmp byte [str+ecx],45
            jne finalFor6
            
            cmp dword [p],0
            jne finalFor6
            
            ; SE FOREM, VERIFICA SE HÁ '/' OU '*' ANTES DO '-'
            mov eax, ecx
            dec ecx
            
            cmp byte [str+ecx], 42
            je finalFor6
            
            cmp byte [str+ecx], 47
            je finalFor6
            
            ; SE NÃO HOUVER, CONTINUAMOS
            mov ecx, eax
            
            seMenosPrec:
            
                ; COLOCAMOS neg, str, lenS e i NA PILHA
                push dword [neg]
                pushar str, [lenS], for13, endFor13
                push dword [lenS]
                push dword [i]
                
                ;print antes, 7
                ;print str, [lenS]
                ;print space, 1
                
                mov dword [lenS], ecx ; lenS = i
                
                ; APÓS ISSO, FAZ str = str.substring(0, i)
                atrib aux, lenAux, str, lenS, 0, for14, endFor14 
                atrib str, lenS, aux, lenAux, 0, for15, endFor15 
                
                ;print depois, 8
                ;print str, [lenS]
                ;print quebra, 1
                
                ; CHAMAMOS A RECURSÃO PARA CALCULAR O QUE HÁ ANTES DO OPERADOR '-'
                call resolve
                
                ; RECUPERAMOS i, lenS e str DA PILHA
                pop dword [i]
                pop dword [lenS]
                popar str, [lenS], for48, endFor48
                
                ;print quebra, 1
                ;print antes, 7
                ;print str, [lenS]
                ;print space, 1
                               
                ; COLOCAMOS NA PILHA O RESULTADO DO CÁLCULO PARA A EXPRESSÃO ANTES DO '-'   
                push dword [result]
                
                mov ecx, [i]
                
                ; APÓS ISSO, FAZEMOS str = str.substring(i, str.size())
                atrib aux, lenAux, str, lenS, ecx, for16, endFor16
                atrib str, lenS, aux, lenAux, 0, for17, endFor17
                
                ;print depois, 8
                ;print str, [lenS]
                ;print quebra, 1
                
                ; CHAMAMOS A RECURSÃO PARA CALCULAR DO OPERADOR '-' ATÉ O FINAL DA EXPRESSÃO 
                call resolve
                
                ; RECUPERAMOS O RESULTADO DA EXPRESSÃO ANTES DO '-', O VALOR DE neg E COLOCAMOS O RESULTADO DA EXPRESSÃO DO '-' ATÉ O FINAL DE str EM edx
                pop eax
                pop dword [neg]
                mov edx, [result]
                
                ;print quebra, 1
                
                ; VERIFICA SE str PRECEDE DE '-' (neg == 1)
                cmp dword [neg], 1
                jne senaoNegMenosPrec
                
                ; SE FOR, FAZEMOS result = 0-eax-edx E RETORNAMOS
                seNegMenosPrec:   
                    mov ebx, 0
                    sub ebx, eax
                    add ebx, edx
                    mov dword [result], ebx
                    ret
                    
                ; SE NÃO FOR, FAZEMOS result = eax-edx E RETORNAMOS                
                senaoNegMenosPrec:
                    mov ebx, 0
                    add ebx, eax
                    add ebx, edx
                    mov dword [result], ebx                
                    ret
                    
            ; INCREMENTA i E VOLTA PARA O INICIO DO LOOP    
            finalFor6:
                inc dword [i]
                jmp for6

            ; }
        ; }

        endFor6:
        
        ; LOOP DE lenS-2 até 0
        
        mov ecx, [lenS]
        dec ecx
        mov dword [i], ecx

        for18:
            ; VERIFICA SE i == 0
            mov ecx, [i]
            cmp ecx, 0
            je endFor18
            
            ; VERIFICA SE str[i] == ')' 
            cmp byte [str+ecx], 41
            jne senaoParentFor18
            
            ; SE FOR, FAZ p = p+1 E CONTINUA O LOOP
            seParentFor18:
                inc dword [p]
                jmp finalFor18
                
            senaoParentFor18:
            
            ; SE NÃO FOR, VERIFICA SE str[i] == '('
            cmp byte [str+ecx], 40
            jne multPrec
            
            seParentInvFor18:    
                ; SE FOR, VERIFICA SE p == 1
                cmp dword [p], 1
                jl finalFor18
                
                ; SE FOR, FAZ p = p-1 E CONTINUA O LOOP
                dec dword [p]
                jmp finalFor18
            
            
            ; if(a[i] == '*' && !p) {
            

; SE NÃO FOR, VERIFICA SE str[i] == '*' E p == 0
 ; SE FOREM, COLOCAMOS neg, str, lenS e i NA PILHA
; APÓS ISSO, FAZ str = str.substring(0, i)
; CHAMAMOS A RECURSÃO PARA CALCULAR O QUE HÁ ANTES DO OPERADOR '*'
; RECUPERAMOS i, lenS e str DA PILHA
; COLOCAMOS NA PILHA O RESULTADO DO CÁLCULO PARA A EXPRESSÃO ANTES DO '*'
; APÓS ISSO, FAZEMOS str = str.substring(i+1, str.size())
; CHAMAMOS A RECURSÃO PARA CALCULAR O QUE HÁ DEPOIS DO OPERADOR '+'
; RECUPERAMOS O RESULTADO DA EXPRESSÃO ANTES DO '+', O VALOR DE neg E COLOCAMOS O RESULTADO DA EXPRESSÃO DEPOIS DO '+' EM edx
; VERIFICA SE str PRECEDE DE '-' (neg == 1)
; SE FOR, FAZEMOS result = 0-eax+edx E RETORNAMOS
; SE NÃO FOR, FAZEMOS result = eax+edx E RETORNAMOS

            ; SE NÃO FOR, VERIFICA SE str[i] == '*' E p == 0
            multPrec:
            
            cmp byte [str+ecx], 42
            jne divPrec
            
            cmp dword [p], 0
            jne divPrec
            
            seMultPrec:
                ; SE FOREM, COLOCAMOS neg, str, lenS e i NA PILHA
                push dword [neg]
                pushar str, [lenS], for19, endFor19
                push dword [lenS]
                push dword [i]
                
                ;print antes, 7
                ;print str, [lenS]
                ;print space, 1
                
                mov dword [lenS], ecx ; lenS = i
                
                ; APÓS ISSO, FAZ str = str.substring(0, i)
                atrib aux, lenAux, str, lenS, 0, for20, endFor20 
                atrib str, lenS, aux, lenAux, 0, for21, endFor21 
                
                ;print depois, 8
                ;print str, [lenS]
                ;print quebra, 1
                
                ; CHAMAMOS A RECURSÃO PARA CALCULAR O QUE HÁ ANTES DO OPERADOR '*'
                call resolve
                
                ; RECUPERAMOS i, lenS e str DA PILHA
                pop dword [i]
                pop dword [lenS]
                popar str, [lenS], for22, endFor22
    
                ;print quebra, 1
                ;print antes, 7
                ;print str, [lenS]
                ;print space, 1
                               
                ; COLOCAMOS NA PILHA O RESULTADO DO CÁLCULO PARA A EXPRESSÃO ANTES DO '*'
                push dword [result]
                
                mov ecx, [i]
                inc ecx
                
                ; APÓS ISSO, FAZEMOS str = str.substring(i+1, str.size())
                atrib aux, lenAux, str, lenS, ecx, for23, endFor23
                atrib str, lenS, aux, lenAux, 0, for24, endFor24
                
                ;print depois, 8
                ;print str, [lenS]
                ;print quebra, 1
                
                ; CHAMAMOS A RECURSÃO PARA CALCULAR O QUE HÁ DEPOIS DO OPERADOR '*'
                call resolve
                
                ; RECUPERAMOS O RESULTADO DA EXPRESSÃO ANTES DO '*', O VALOR DE neg E COLOCAMOS O RESULTADO DA EXPRESSÃO DEPOIS DO '*' EM ecx
                pop eax
                pop dword [neg]
                mov ecx, [result]
                
                ;print quebra, 1
                
                ; VERIFICA SE str PRECEDE DE '-' (neg == 1)
                cmp dword [neg], 1
                jne senaoNegMultPrec
                
                ; SE FOR, FAZEMOS result = 0-eax*edx E RETORNAMOS

                seNegMultPrec:   
                    mov ebx, eax
                    mov eax, 0
                    sub eax, ebx
                    imul edx
                    mov dword [result], eax
                    ret
                
                ; SE NÃO FOR, FAZEMOS result = eax*edx E RETORNAMOS
                senaoNegMultPrec:
                    mov ebx, eax
                    mov eax, 0
                    add eax, ebx
                    imul edx
                    mov dword [result], eax
                    ret
            
            ; if(a[i] == '/' && !p) {
            
            divPrec:
            
            cmp byte [str+ecx],47
            jne finalFor18
            
            cmp dword [p],0
            jne finalFor18
            
            push dword [neg]
            pushar str, [lenS], for25, endFor25
            push dword [lenS]
            push dword [i]
            
            print antes, 7
            print str, [lenS]
            print space, 1
            
            mov dword [lenS], ecx ; lenS = i
            atrib aux, lenAux, str, lenS, 0, for26, endFor26 ; for (int j=0; j<lenS; j++) aux += a[j]
            atrib str, lenS, aux, lenAux, 0, for27, endFor27 ; for (int j=0; j<lenAux; j++) a += aux[j]
            
            print depois, 8
            print str, [lenS]
            print quebra, 1
            
            call resolve
            
            pop dword [i]
            pop dword [lenS]
            popar str, [lenS], for28, endFor28

            print quebra, 1
            print antes, 7
            print str, [lenS]
            print space, 1
                           
            push dword [result]
            
            mov ecx, [i]
            inc ecx
            
            atrib aux, lenAux, str, lenS, ecx, for29, endFor29
            atrib str, lenS, aux, lenAux, 0, for30, endFor30
            
            print depois, 8
            print str, [lenS]
            print quebra, 1
            call resolve
            
            pop dword [val1]
            pop dword [neg]
            
            mov eax, [val1] ; eax = resolve(x)
            mov ecx, [result]
    
            print quebra, 1
            
            cmp dword [neg], 1
            jne senaoNegDivPrec
            
            seNegDivPrec:   
                mov ebx, eax
                mov eax, 0
                sub eax, ebx
                mov edx, 0
                
                cmp eax, 0
                jge senaoVal1Neg1
                
                mov dword [j], eax
                negat [j]
                mov eax, [j]
                
                idiv ecx
                mov dword [result], eax
                negat [result]
                ret
                
                senaoVal1Neg1:
                
                idiv ecx
                mov dword [result], eax
                
                ret
            
            senaoNegDivPrec:
                mov edx, 0
                
                cmp eax, 0
                jge senaoVal1Neg2
                
                mov dword [j], eax
                negat [j]
                mov eax, [j]
                
                idiv ecx
                mov dword [result], eax
                negat [result]
                ret
                
                senaoVal1Neg2:
                
                idiv ecx
                mov dword [result], eax
                
                ret
                
            ; }
                
            finalFor18:
                dec dword [i]
                jmp for18
                
        ; }

        endFor18:
  
    finish:
        mov eax, [erro]
        cmp eax, 1
        je over
        
        mov ecx, [result]
        print quebra, 1
        print formatada, 13
        print quebra, 1
        numToStr ecx, w1, ew1, f1, ef1, c1
        
        over:
        mov eax,1            
        mov ebx,0            
        int 80h
