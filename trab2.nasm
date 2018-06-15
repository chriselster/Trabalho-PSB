section .data
    len: dd 32
    lenS: dd 32

section .bss
    exp: resb 1
    str: resb 1
	
section .text
	global _start

_start:
    mov eax, 3          
    mov ebx, 0          
    mov ecx, exp
    mov edx, len       
    int 80h
    
    ;mov eax,0x0
    ;delSpace:
    ;    cmp eax,[len]
     ;   JE end
      ;  
       ; cmp byte [exp+eax],32        
       ; JE inside
       ; inc eax
        
       ; JMP delSpace
        
       ; inside:
        ;    mov ebx,[exp+eax+1]
         ;   mov [exp+eax],ebx
          ;  mov byte [exp+eax+1],32
           ; dec dword [len]
            
        ;JMP delSpace    
    ;end:
    
    ;mov eax,0x0
    ;mov dword [lenS],0x0
    ;mov ebp,exp
    ;delSpace:
        ;cmp byte [ebp+eax],32
        ;JE delSpace
        ;mov ebx,lenS
        ;mov edx,[ebp+eax]
        ;mov [str+ebx],edx
        ;inc dword [lenS]
        ;cmp eax,[lenS]
        ;JNE delSpace
   
    mov eax, 4
    mov ebx, 1
    mov ecx, exp
    mov edx, 64
    int 80h  

	mov eax, 1            
    mov ebx, 0            
    int 80h
