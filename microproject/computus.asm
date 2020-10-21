format PE console
include 'win32a.inc'
entry start

section 'data' data readable writeable

        str1 db 'Enter year:',10,0           ;������ ��� ������
        str2 db 'Computus date is %d ',0
        str3 db 'March',10,0          ;� ������ ������ �������
        str4 db 'April',10,0
        str5 db 'Number must be positive',10,0
        scanf_int db '%d',0           ;��� ����� ����� � scanf
        year dd ?                     ;���������� ��� ����
        month dd ?                    ;������
        date dd ?                     ;���

          Y dd ?       ;���������� ��� ��������� ���������� ��� �����
          G dd ?
          C dd ?
          X dd ?
          Z dd ?
          D dd ?
          E dd ?
          N dd ?

section 'text' code executable readable
start:                   ;������ ���������
        push str1
        call [printf]    ;����� ��������� ������
        push year        ;� ��������� year
        push scanf_int   ;��� - int (dword)
        call [scanf]     ;����� ������� scanf

        xor eax,eax      ;eax=0
        cmp [year],eax   ;���������� year � eax(=0)
        jle .incorrect   ;���� ������ ��� ����� �� ������� � ����� .incorrect (�������� ���������)


        call GetComputusDate   ;����� ������� ��� ���������� ���� �����
        push [date]        ;��������� ����
        push str2          ;� ������ str2
        call [printf]          ;����� ������ str2 � date ����� "%d" � ������� printf
        mov ebx,str4       ;���� ��������� month ����� 0 �� ebx = str3(����) ���� month = 1 �� ebx = str4(������)
        mov eax,[month]
        cmp eax,1
        je .april
        mov ebx,str3
        .april:
        push ebx           ;����� ������ ebx(str3 ��� str4)
        call [printf]

        jmp .end           ;���������� ����� ��������� � �������������� ������

        .incorrect:
        push str5           ;����� ��������� � �������������� ������
        call [printf]

        .end:
        call [getch]       ;������� ������� ����� �������
        ret

GetComputusDate:           ;�������� ���������� ���� �����, ����� � https://ru.wikipedia.org/wiki/%D0%9F%D0%B0%D1%81%D1%85%D0%B0%D0%BB%D0%B8%D1%8F
        mov eax,[year]     ;���������� ������� ��� �  ���������� Y
        mov [Y],eax

        mov eax,[Y]        ;G = (Y mod 19) + 1
        xor edx,edx        ;���������������� � �������
        mov ebx,19         ;��� ���������� �������
        div ebx            ;����� ������� �� 19
        mov eax,edx        ;������� ����������� � edx
        inc eax            ; +1
        mov [G],eax        ;��������� ���������� G

        mov eax,[Y]        ;C = Y/100 + 1
        xor edx,edx        ;���������������� � �������
        mov ebx,100        ;����� �� 100
        div ebx            ;�����
        inc eax            ;+1
        mov [C],eax        ;���������

        mov eax,[C]        ;X = 3C/4 - 12
        mov ebx,3          ;���� �������� �� 3
        mul ebx            ;��������
        shr eax,2          ;������� ����� ������ �� 2 ���� - ���������� ������� �� 4
        sub eax,12         ;-12
        mov [X],eax        ;���������

        mov eax,[C]        ;Z = (8C + 5)/25 - 5
        shl eax,3          ;������� ����� ����� �� 3 ���� - ���������� ��������� �� 8
        add eax,5          ;+1
        xor edx,edx        ;���������������� � �������
        mov ebx,25         ;��������� ��������� �� 25
        div ebx            ;�������
        sub eax,5          ;-5
        mov [Z],eax        ;���������

        mov eax,[Y]        ;D = 5Y/4 - X - 10
        mov ebx,5          ;��������� �������� �� 5
        mul ebx            ;���������
        shr eax,2          ;������� ����� ������ �� 2 ���� = ������� �� 4
        sub eax,[X]        ;-X
        sub eax,10         ;-10
        mov [D],eax        ;���������

        mov eax,[G]        ;[(11G + 20 + Z - X) mod 30 + 30] mod 30
        mov ebx,11         ;���������������� � ��������� �� 11
        mul ebx            ;��������
        add eax,20         ;+20
        add eax,[Z]        ;+Z
        sub eax,[X]        ;+X
        mov ebx,30         ;���������������� � ������� �� 30
        xor edx,edx
        div ebx            ;�������
        mov eax,edx        ;������� ���������� �� edx � eax
        add eax,30         ;+30
        xor edx,edx        ;���������������� � �������
        div ebx            ;�������
        mov [E],edx        ;��������� �����

        cmp [E],24         ;���� (E = 24) ��� (E = 25 � G > 11), �� ��������� E �� 1
        je .l1             ;���� E=24 �� inc [E]
        cmp [E],25         ;���� E �� ����� 25 �� ���������� ����������
        jne .l2
        cmp [G],11         ;���� G ������ ��� ����� 11 �� ���������� ����������
        jle .l2
        .l1:
        inc [E]
        .l2:

        mov eax,44          ;N = 44 - E
        sub eax,[E]         ;-E
        mov [N],eax         ;���������


        cmp [N],21          ;���� N < 21, �� ��������� N �� 30
        jge .l3             ;���� N ������ ��� ����� 30 �� ���������� ����������
        add [N],30
        .l3:

        mov eax,[N]         ;N = N + 7 - (D + N) mod 7
        mov ecx,eax         ;��������� ����� N � ecx
        add eax,7           ;+7
        mov edi,eax         ;��������� ��������� ����� � edi
        mov eax,ecx         ;eax=N
        add eax,[D]         ;+D
        xor edx,edx         ;���������������� � �������
        mov ebx,7           ;�� 7
        div ebx             ;�������
        sub edi,edx         ;�������� �� "N+7" "(D+N) mod 7"
        mov [N],edi         ;��������� ���������

        cmp [N],31          ;���� N > 31, �� ���� ����� (N - 31) ������, ����� ���� ����� N �����
        jbe .l4             ;���� N ������ ��� ����� 31 �� ���������� "������������" �� ������
        sub [N],31
        mov [month],1
        .l4:

        mov eax,[N]         ;���������� ����������� �������
        mov [date],eax
        ret

section '.idata' import readable

library msvcrt,'msvcrt.dll'

import msvcrt,\
       printf,'printf',\
       scanf,'scanf',\
       getch,'_getch'


