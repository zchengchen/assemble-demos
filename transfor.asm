DATAS SEGMENT
	MENU0 DB "---------------------------MENU---------------------------",0DH,0AH
    MENU1 DB "|X. Conversion of Uppercase to lowercase letters.        |",0DH,0AH
    MENU2 DB "|Y. Conversion of decimal numbers to hexadecimal numbers.|",0DH,0AH
    MENU3 DB "|Z. Conversion of hexadecimal numbers to decimal numbers.|",0DH,0AH
    MENU4 DB "---------------------------END----------------------------",0DH,0AH
    MENU5 DB "Select options: ",'$'
    MENU6 DB "Input the sentect: ",'$'
    MENU7 DB "Result: ",'$'
    MENU8 DB "*****Invalid Input!*****",0DH,0AH,'$'
    MENU9 DB "Input the number to converse: ",'$'
    TMP DB 100 DUP ('$')
    HEX_BASE DD 16
DATAS ENDS

STACKS SEGMENT
    DB 100 DUP(0)
STACKS ENDS

CODES SEGMENT
.386
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV ES,AX
    MOV AX,STACKS
    MOV SS,AX
MAIN_LOOP:
    CALL PRINT_MENU
    MOV AH,01H
    INT 21H
    CMP AL,'X'
    JE SELECT_X
    CMP AL,'x'
    JE SELECT_X
    CMP AL,'Y'
    JE SELECT_Y
    CMP AL,'y'
    JE SELECT_Y
    CMP AL,'Z'
    JE SELECT_Z
    CMP AL,'z'
    JE SELECT_Z
ERROR_PROCESS:
    CALL PRINT_ENTER
    MOV AH,09H
    LEA DX,MENU8
    INT 21H
    JMP MAIN_LOOP
SELECT_X:
    CALL PRINT_ENTER
    LEA DX,MENU6
    MOV AH,09H
    INT 21H
    CALL CLEAN_TMP
    CALL OPTION_X
    JMP MAIN_LOOP
SELECT_Y:
    CALL PRINT_ENTER
    LEA DX,MENU9
    MOV AH,09H
    INT 21H
    CALL OPTION_Y
    JMP MAIN_LOOP
SELECT_Z:
    CALL PRINT_ENTER
    LEA DX,MENU9
    MOV AH,09H
    INT 21H
    CALL OPTION_Z
    CALL PRINT_ENTER
    JMP MAIN_LOOP
    MOV AX,4C00H
    INT 21H

OPTION_X PROC NEAR
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH SI
    MOV CX,99
    XOR SI,SI
OPTION_X_INPUT_LOOP:
    MOV AH,01H
    INT 21H
    CMP AL,0DH
    JE OPTION_X_INPUT_END
    CMP AL,'a'
    JL NOT_OP
    CMP AL,'z'
    JG NOT_OP
    AND AL,11011111B
NOT_OP:
    MOV TMP[SI],AL
    INC SI
    LOOP OPTION_X_INPUT_LOOP
OPTION_X_INPUT_END:
    LEA DX,MENU7
    MOV AH,09H
    INT 21H
    LEA DX,TMP
    INT 21H
    CALL PRINT_ENTER
    POP SI
    POP DX
    POP CX
    POP AX
    RET
OPTION_X ENDP

OPTION_Y PROC NEAR
    CALL DEC_TO_HEX
    RET
OPTION_Y ENDP

OPTION_Z PROC NEAR
    PUSH EAX
    PUSH ECX
    PUSH EBX
    PUSH EDX
    PUSH ESI
    MOV CX,9
    XOR SI,SI
    XOR EAX,EAX
    XOR EBX,EBX
READ_DIGIT:
    MOV AH,01H
    INT 21H
    XOR AH,AH
    CMP AL,'0'
    JL READ_NOT_DIGIT
    CMP AL,'9'
    JG READ_NOT_DIGIT
    SUB AL,30H
    XOR AH,AH
    PUSH AX
    XOR EAX,EAX
    POP AX
    XCHG EAX,EBX
    MUL HEX_BASE
    XCHG EBX,EAX
    ADD EBX,EAX
    INC SI
    LOOP READ_DIGIT
READ_NOT_DIGIT:
    CMP AL,0DH
    JE OPTIOIN_Z_END
    CMP AL,'A'
    JL READ_ERROR
    CMP AL,'F'
    JG READ_ERROR
    SUB AL,'A'
    ADD AL,0AH
    XOR AH,AH
    PUSH AX
    XOR EAX,EAX
    POP AX
    XCHG EAX,EBX
    MUL HEX_BASE
    XCHG EBX,EAX
    ADD EBX,EAX
    INC SI
    LOOP READ_DIGIT
READ_ERROR:
    LEA DX,MENU8
    MOV AH,09H
    INT 21H
    POP ESI
    POP EDX
    POP EBX
    POP ECX
    POP EAX
    RET
OPTIOIN_Z_END:
    MOV EAX,EBX
    CALL VALUE_TO_DEC
    POP ESI
    POP EDX
    POP EBX
    POP ECX
    POP EAX
    RET
OPTION_Z ENDP

VALUE_TO_DEC PROC NEAR
    PUSH EAX
    PUSH EBX
    PUSH ECX
    PUSH EDX
    PUSH ESI
    MOV ECX,10
    MOV EBX,10
VALUE_TO_DEC_DIV:
    XOR EDX,EDX
    DIV EBX
    OR DL,30H
    PUSH EDX
    LOOP VALUE_TO_DEC_DIV
    MOV ECX,10
VALUE_TO_DEC_PRINT:
    POP EDX
    MOV AH,2
    INT 21H
    LOOP VALUE_TO_DEC_PRINT
    POP ESI
    POP EDX
    POP ECX
    POP EBX
    POP EAX
    RET
VALUE_TO_DEC ENDP

CLEAN_TMP PROC NEAR
    PUSH AX
    PUSH CX
    PUSH SI
    XOR SI,SI
    MOV CX,100
CLEAN_LOOP:
    MOV AL,'$'
    MOV TMP[SI],AL
    INC SI
    LOOP CLEAN_LOOP
    POP SI
    POP CX
    POP AX
    RET
CLEAN_TMP ENDP

PRINT_MENU PROC NEAR
    PUSH AX
    PUSH DX
    LEA DX,MENU0
    MOV AH,09H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_MENU ENDP

PRINT_ENTER PROC NEAR
    PUSH AX
    PUSH DX
    MOV DL,0AH
    MOV AH,02H
    INT 21H
    POP DX
    POP AX
    RET
PRINT_ENTER ENDP

DEC_TO_HEX PROC NEAR
DEC_TO_HEX_LOOP:
    CALL READ
    LEA DX,MENU7
    MOV AH,09H
    INT 21H
    CALL CHANGE
    RET
DEC_TO_HEX ENDP

READ PROC NEAR
    MOV EBX,0
NEWCHAR:
    MOV AH,1
    INT 21H
    CMP AL,'0'
    JL ERROR_PROCESS
    CMP AL,'9'
    JG ERROR_PROCESS
    SUB AL,30H
    JL READ_EXIT
    CMP AL,9
    JG READ_EXIT
    CBW
    XCHG EAX,EBX
    MOV ECX,10
    MUL ECX
    XCHG EBX,EAX
    ADD EBX,EAX
    JMP NEWCHAR
READ_EXIT:
    RET
READ ENDP

CHANGE PROC NEAR
    MOV CH,8
CHANGE_LOOP:
    MOV CL,4
    ROL EBX,CL
    MOV AL,BL
    AND AL,0FH
    ADD AL,30H
    CMP AL,3AH
    JL PRINT
    ADD AL,07H
PRINT:
    MOV DL,AL
    MOV AH,02H
    INT 21H
    DEC CH
    JNE CHANGE_LOOP
CHANGE ENDP
CODES ENDS
END START