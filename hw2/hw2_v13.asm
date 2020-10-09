format PE console
entry start

include 'win32a.inc'

;--------------------------------------------------------------------------
section '.data' data readable writable

        strVecSize    db 'How much elements do you want? ', 0
        strVecElemI   db '[%d] = ', 0
        strScanInt    db '%d', 0
        strMinValue   db 'Minimum: %d', 10, 0
        strVecElemOut db '[%d]: %d', 10, 0

        arr_a_count    dd 0
        arr_b_count    dd 0
        min            dd 0
        i              dd ?
        tmp            dd ?
        tmpStack       dd ?
        arr_a          rd 200
        arr_b          rd 200

;--------------------------------------------------------------------------
section '.code' code readable executable
start:
; 1) INPUT ARRAY A
        call VectorInput
; 2) CALC MIN
        call CalcFuncInArray
; 2) CREATE ARRAY B
        call CreateArray
; 3) OUTPUT MIN STR
        push [min]
        push strMinValue
        call [printf]
; 4) OUTPUT ARRAY B
        call VectorOut
finish:
        call [getch]

        push 0
        call [ExitProcess]

;--------------------------------------------------------------------------
VectorInput:
        push strVecSize
        call [printf]
        add esp, 4

        push arr_a_count
        push strScanInt
        call [scanf]
        add esp, 8

        mov eax, [arr_a_count]
        cmp eax, 0
        jg  getVector
; fail size
        push 0
        call [ExitProcess]
; else continue...
getVector:
        xor ecx, ecx            
        mov ebx, arr_a            
getVecLoop:
        mov [tmp], ebx
        cmp ecx, [arr_a_count]
        jge endInputVector

        ; input element
        mov [i], ecx
        push ecx
        push strVecElemI
        call [printf]
        add esp, 8

        push ebx
        push strScanInt
        call [scanf]
        add esp, 8

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp getVecLoop
endInputVector:
        ret

;--------------------------------------------------------------------------
CalcFuncInArray:
        xor ecx, ecx
        mov ebx, arr_a
        mov [min], ebx
                
        jmp funcLoop
funcLoop:
        mov [tmp], ebx
        cmp ecx, [arr_a_count]
        jge endCalcFuncInArrayLoop
        mov [i], ecx

        jmp checkElementLoop
endCheckElementLoop:
        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
                
        jmp funcLoop
checkElementLoop:
        mov ecx, [ebx]
        cmp ecx, [min]
                
        jl updateVal
        jmp endCheckElementLoop
updateVal:
        mov ecx, [ebx]
        mov [min], ecx
        jmp endCheckElementLoop
endCalcFuncInArrayLoop:
        ret

;--------------------------------------------------------------------------
CreateArray:
        xor ecx, ecx
        mov ebx, arr_a
        mov eax, arr_b
        jmp createArrayLoop
                
createArrayLoop:
        mov [tmp], ebx
        cmp ecx, [arr_a_count]
        jge endCreateArrayLoop
        mov [i], ecx

        jmp checkElementNewVec
checkElementNewVec:
        mov ecx, [ebx]
        cmp ecx, [min]
        jg moveElement

        jmp endCreateArrayVec
moveElement:
        mov [eax], ecx
        add eax, 4

        mov edx, [arr_b_count]
        inc edx
        mov [arr_b_count], edx

        jmp endCreateArrayVec
endCreateArrayVec:
        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp createArrayLoop
endCreateArrayLoop:
        ret

;--------------------------------------------------------------------------
VectorOut:
        mov [tmpStack], esp
        xor ecx, ecx            
        mov ebx, arr_b            
putVecLoop:
        mov [tmp], ebx
        cmp ecx, [arr_b_count]
        je endOutputVector      
        mov [i], ecx

        ; output element
        push dword [ebx]
        push ecx
        push strVecElemOut
        call [printf]

        mov ecx, [i]
        inc ecx
        mov ebx, [tmp]
        add ebx, 4
        jmp putVecLoop
endOutputVector:
        mov esp, [tmpStack]
        ret
;-------------------------------third act - including HeapApi--------------------------
                                                 
section '.idata' import data readable
    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll',\
            user32,'USER32.DLL'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
  include 'api\kernel32.inc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'