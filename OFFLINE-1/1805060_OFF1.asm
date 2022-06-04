.MODEL SMALL

.STACK 100H

.DATA
 
CR EQU 0DH
LF EQU 0AH
MSG1 DB "ENTER N, THEN N (+)VE INTS IN NEXT N LINES(0 TO EXIT):$"
MSG2 DB "ENTER X TO SEARCH:$"
MSG3 DB "NOT FOUND$"
MSG4 DB "SORTED ARRAY: $"
ND DB ?
N DW ?
NUM DW ?
NS DW ?  ;USED IN SORTING
NB DW ?   ; USED IN SEARCHING
NBS DW ?
J DW ?
X DW ?
LOW DW ?
MID DW ?
HIGH DW ?
IDX DW ?
TWO DW 2
ARR DW 100 DUP(0)


.CODE

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX   ; load data segment
        
   STEP_1:
    MOV AH, 9
    LEA DX, MSG1
    INT 21H 
    CALL INPUT_NUM
    MOV N, BX
    CMP N , 0   ;if num of integers is 0; end the program
    JE END_ALL
    MOV NUM, BX
    MOV NS, BX
    MOV NB, BX
    MOV NBS, BX
    
    LEA SI, ARR
    CALL NEWLINE
   ARR_INPUT:
    CALL INPUT_NUM  ; input a number
    CALL NEWLINE
    MOV [SI], BX    ; store it in the array
    ADD SI, 2
    DEC N
    JNZ ARR_INPUT
    
   CALL INSERTION_SORT   ; to sort the array
    
    CALL NEWLINE
    MOV AH, 9
    LEA DX, MSG4
    INT 21H  
    LEA SI, ARR
   PRINT_ARRAY:  ; to print the whole array as space sep ints
    CMP NUM, 0
    JE BSEARCH
    MOV AX, [SI]
    CALL PRINT_NUM
    CALL WSPACE 
    ADD SI, 2
    DEC NUM
    JMP PRINT_ARRAY
    
   BSEARCH:
    CALL NEWLINE
    MOV AH, 9
    LEA DX, MSG2
    INT 21H 
    CALL INPUT_NUM
    MOV X, BX
    CALL BS
    
    CMP IDX, -1
    JE NFMSG
    CALL NEWLINE
    MOV AX, IDX
    INC AX       
    CALL PRINT_NUM 
    JMP JTO1
    
   NFMSG:
    CALL NEWLINE
    MOV AH, 9
    LEA DX, MSG3
    INT 21H
    
    JTO1:
    CALL NEWLINE
    JMP STEP_1
    
    END_ALL:
    MOV AH, 4CH
    INT 21H
MAIN ENDP

NEWLINE PROC
    MOV AH, 2
    MOV DL, CR
    INT 21H
    MOV DL, LF
    INT 21H   ;new line 
    RET
NEWLINE ENDP  

WSPACE PROC    ;print whitespace
    MOV AH, 2
    MOV DL, 32
    INT 21H 
    RET
WSPACE ENDP

INPUT_NUM PROC
    XOR BX, BX  ;BX = 0  
    INPUT:
    MOV AH, 1
    INT 21H  ;INPUT A CHARACTER
    CMP AL, CR
    JE END_LOOP
    CMP AL, LF
    JE END_LOOP
    
    AND AX, 000FH  ;CHAR TO DIGIT, ah = 00
    MOV CX, AX
    
    MOV AX, 10
    MUL BX        ;AX = 10*BX
    ADD AX, CX    ;10*BX+CX
    MOV BX, AX    ;FINALLY BX = BX*10+CX
    JMP INPUT
    
    END_LOOP:
    RET 
INPUT_NUM ENDP

PRINT_NUM PROC
    MOV CX, 0AH    ;cx=10
    MOV ND, 0      ;num of digit checked
    
    P_LOOP: 
    CMP AX, 10
    JL END_PLOOP
    XOR DX, DX
    DIV CX   ;divide dx:ax by cx, quo->ax; rem->dx
    PUSH DX
    INC ND
    JMP P_LOOP
    
    END_PLOOP:
    MOV AH, 2
    MOV DL, AL
    ADD DL, '0' ;print as digit msb
    INT 21H
    
    PRINT_REMAIN:   ;print other digits which are in stack
    CMP ND, 0
    JLE END_PR
    POP DX
    ADD DL, '0'
    INT 21H
    DEC ND
    JNZ PRINT_REMAIN 
    
    END_PR:
    RET
PRINT_NUM ENDP

INSERTION_SORT PROC   ;this has to be fixed
    LEA SI, ARR
    MOV CX, 2  ;i=1
    MOV DX, NS
    ADD NS, DX  ; NS = 2NS
    
    FOR_LOOP:
    CMP CX, NS
    JE END_SORT  ; if i=n, break loop
    
    MOV BX, CX
    MOV AX, [SI+ bx]  ;  ; key = arr[i]
    
    MOV J, CX
    SUB J, 2   ; j=i-1 
    
    WHILE_LOOP:
    CMP J, 0
    JL END_WHILE    ;IF J<0 OR ARR[J]<=KEY, END LOOP 
    MOV BX, J
    CMP [SI+ BX], AX
    JLE END_WHILE
    MOV DX, [SI+BX]
    ADD BX, 2
    MOV [SI+BX], DX  ; ARR[J+1] = ARR[J]
    SUB J, 2       ;j--
    JMP WHILE_LOOP
    
    
    END_WHILE:
    MOV BX, J
    ADD BX, 2
    MOV [SI+BX] ,AX   ; arr[j+1] = key
    ADD CX, 2 ; i++  
    JMP FOR_LOOP
    
    END_SORT:
    RET
INSERTION_SORT ENDP  

BS PROC           ; this is the binary search procedure
    LEA SI, ARR 
    MOV IDX, -1
    MOV LOW, 0 
    MOV CX, NBS
    MOV HIGH, CX
    DEC HIGH 
    
    SLOOP: 
    MOV CX, LOW
    CMP CX, HIGH
    JG END_S
    
    ADD CX, HIGH
    SHR CX, 1     ; cx = cx/2
    MOV AX, CX
    MOV BX, 2 
    MUL BX
    MOV BX, AX
    MOV DX, X 
    CMP [SI+BX], DX
    JE FIX_ID
    JL CHANGE_LOW
    JG CHANGE_HIGH
    
    CHANGE_HIGH:
    MOV HIGH, CX
    DEC HIGH
    JMP SLOOP
    
    CHANGE_LOW:
    MOV LOW, CX
    INC LOW
    JMP SLOOP
        
    FIX_ID:
    MOV IDX, CX
    
    END_S:
    RET
    
BS ENDP

    

END MAIN




