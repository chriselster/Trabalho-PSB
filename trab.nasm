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
    
    mov eax,0x0
    mov dword [lenS],0x0
    mov ebp,exp
    delSpace:
        cmp byte [ebp+eax],32
        JE delSpace
        mov ebx,lenS
        mov [str+ebx],[ebp+eax]
        inc dword [lenS]
        cmp eax,[lenS]
        JNE delSpace
   
    mov eax, 4
    mov ebx, 1
    mov ecx, str
    mov edx, [lenS]
    int 80h  

	mov eax, 1            
    mov ebx, 0            
    int 80h
