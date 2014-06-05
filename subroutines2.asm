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
;UPDATE
        LDAA    #%11110000
        STAA    DDRC
        LDAB    #0
        STAB    PORTC
        LDAA    PORTC

        ANDA    #%00001111

        STAA    INPUT
        LDAA    #%00001111
        STAA    DDRC
        STAB    PORTC
        LDAA    PORTC

        ANDA    #%11110000

        ORAA    INPUT

        STAA    INPUT
        JSR     BOUNCE
        JSR     GETKEY
        RTS
;DELAY
        LDY     #1      ;4 cyc
O_LOOP  LDX     #327    ;3
D_LOOP  DEX             ;3
        BNE     D_LOOP  ;3
        DEY             ;4
        BNE     O_LOOP  ;3
        RTS             ;5
;GETKEY
        PSHA
        LDY     #TABLE
        CLRB
        LDAA    INPUT
COMP    CMPA    0,Y
        BEQ     DONE
        INY
        INCB
        CMPB    #$10
        BEQ     NO_KEY
        BRA     COMP
NO_KEY  LDAB    #$FF
DONE    STAB    BIN_KEY
        PULA
        RTS
;BOUNCE
        LDAA    BIN_KEY
        JSR     GETKEY
        CMPA    BIN_KEY
        BEQ     BOUNCED
DELS    JSR     DELAY
        LDAA    BIN_KEY
        JSR     GETKEY
        CMPA    BIN_KEY
        BNE     DELS
BOUNCED RTS


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
