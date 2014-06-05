PORTB   EQU     $1004
PORTC   EQU     $1003
DDRC    EQU     $1007
ADCTL   EQU     $1030
ADR2    EQU     $1032
OPTION  EQU     $1039
TCNT    EQU     $0E
TOC2    EQU     $18
TMSK2   EQU     $24
TFLG1   EQU     $23
PRTB    EQU     $4
PRTC    EQU     $3
TEMPS   EQU     $B600
SHOW    EQU     $B655
UPDATE  EQU     $B6AC
DELAY   EQU     $B6D5
GETKEY  EQU     $B6E4
BOUNCE  EQU     $B700

SAMPLES EQU     16

        ORG     $0
        LDS     #$37
SHIFTH  RMB     1
SHIFTL  RMB     1       ;initialize number of shifts at -1
INPUT   RMB     1
BIN_KEY RMB     1
TABLE   FCB     %01110111       ;0
        FCB     %01111011       ;1
        FCB     %01111101       ;2
        FCB     %01111110       ;3
        FCB     %10110111       ;4
        FCB     %10111011       ;5
        FCB     %10111101       ;6
        FCB     %10111110       ;7
        FCB     %11010111       ;8
        FCB     %11011011       ;9
        FCB     %11011101       ;A
        FCB     %11011110       ;B
        FCB     %11100111       ;C
        FCB     %11101011       ;D
        FCB     %11101101       ;E
        FCB     %11101110       ;F

        ORG     $100
;TEMPS
        CLR     SHIFTH
        CLR     SHIFTL
        DEC     SHIFTL
        LDAA    #SAMPLES
COUNTER INC     SHIFTL                  ;keep shifting the number of samples right (dividing by 2)
        LSRA                            ;count how many times you can do that and still get positive integer
        BNE     COUNTER
        LDAA    #$90                     ; Turn on the ADC
        STAA    OPTION

        LDY     #SAMPLES                     ; Number of samples
        LDX     #0

SAMPLE  LDAA    #1
        STAA    ADCTL                     ; Channel Selection
WAIT    TST     ADCTL                     ; \ Wait for EOC
        BPL     WAIT

        LDAB    ADR2                     ; Get Converted Result
        ABX                          ;Add Temp to X
        DEY
        BNE     SAMPLE

        XGDX                           ; exchange D and X
        LDY     SHIFTH
        BEQ     DONE2

SHIFT   LSRD                        ; shift D
        DEY                         ; decrease number of remaining shifts
        BNE     SHIFT               ; shift again if number of remaining shifts is above zero

        ; scale to display actual temperature

        ; P = 31

        ; S = 6

DONE2   LDAA #31
        MUL
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD
        LSRD

        ; B is temperature

        LDAA #0

        ; convert to BCD

        LDX     #10
        IDIV
        XGDX
        LSLD
        LSLD
        LSLD
        LSLD
        ABX
        XGDX
        COMB
        STAB    PORTB                ; display average
        RTS
;SHOW
MAIN    LDX     #$1000
        CLR     TFLG1,X
OLOOP   LDX     #PATS
        TSY
        LDAB    2,Y
        ASLB
        ABX
        LDY     0,X

        LDX     #$1000

        LDAA    0,Y
        STAA    CNT
        STY     PATCNT

ILOOP   LDY     PATCNT
        INY
        STY     PATCNT

        LDAA    0,Y
        COMA
        STAA    PRTB,X

        LDY     #RATES
        TSX
        LDAB    3,X
        LDX     #$1000
        LSLB
        ABY
        LDY     0,Y
LP2     LDD     TCNT,X
        ADDD    #$00FF
        STD     TOC2,X
LP1     BRCLR   TFLG1,X,$40,LP1
        BCLR    TFLG1,X,$BF
        DEY
        BNE     LP2
        DEC     CNT
        BNE     ILOOP
        RTS



        ORG     $1AC
RATES   FDB     1000,750,500,5


PAT0    FCB     2
        FCB     %00001111
        FCB     %11110000
PAT1    FCB     8
        FCB     %10000000
        FCB     %01000000
        FCB     %00100000
        FCB     %00010000
        FCB     %00001000
        FCB     %00000100
        FCB     %00000010
        FCB     %00000001
PAT2    FCB     8
        FCB     %00000001
        FCB     %00000010
        FCB     %00000100
        FCB     %00001000
        FCB     %00010000
        FCB     %00100000
        FCB     %01000000
        FCB     %10000000
PAT3    FCB     14
        FCB     %10000000
        FCB     %01000000
        FCB     %00100000
        FCB     %00010000
        FCB     %00001000
        FCB     %00000100
        FCB     %00000010
        FCB     %00000001
        FCB     %00000010
        FCB     %00000100
        FCB     %00001000
        FCB     %00010000
        FCB     %00100000
        FCB     %01000000
PAT4    FCB     2
        FCB     %10101010
        FCB     %01010101
PAT5    FCB     4
        FCB     %10000001
        FCB     %01000010
        FCB     %00100100
        FCB     %00011000
PAT6    FCB     4
        FCB     %00011000
        FCB     %00100100
        FCB     %01000010
        FCB     %10000001
PAT7    FCB     6
        FCB     %10000001
        FCB     %01000010
        FCB     %00100100
        FCB     %00011000
        FCB     %00100100
        FCB     %01000010
PATS    FDB     PAT0,PAT1,PAT2,PAT3,PAT4,PAT5,PAT6,PAT7



PATCNT  RMB     2
CNT     RMB     1


        END
