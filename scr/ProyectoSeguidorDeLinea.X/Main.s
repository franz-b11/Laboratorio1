PROCESSOR 16F877A

#include <xc.inc>

; CONFIGURATION WORD PG 144 datasheet

CONFIG CP=OFF ; PFM and Data EEPROM code protection disabled
CONFIG DEBUG=OFF ; Background debugger disabled
CONFIG WRT=OFF
CONFIG CPD=OFF
CONFIG WDTE=OFF ; WDT Disabled; SWDTEN is ignored
CONFIG LVP=ON ; Low voltage programming enabled, MCLR pin, MCLRE ignored
CONFIG FOSC=XT
CONFIG PWRTE=ON
CONFIG BOREN=OFF
PSECT udata_bank0

max:
DS 1 ;reserve 1 byte for max

tmp:
DS 1 ;reserve 1 byte for tmp
PSECT resetVec,class=CODE,delta=2

resetVec:
    PAGESEL INISYS ;jump to the main routine
    goto INISYS

PSECT code

INISYS:
    ;Cambio a Banco N1
    BCF STATUS, 6
    BSF STATUS, 5 ; Bank1
    ; Modificar TRIS
    BSF TRISB, 0    ; PortB0 <- entrada SC-C
    BSF TRISB, 1    ; PortB1 <- entrada SD-D
    BSF TRISB, 2    ; PortB2 <- entrada SZ-B
    BSF TRISB, 3    ; PortB3 <- entrada SED-E
    BSF TRISB, 4    ; PortB4 <- entrada SEZ-A
    ;------------------------------------------
    BCF TRISD, 0    ; PortD0 <- salida M1
    BCF TRISD, 1    ; PortD1 <- salida M2
    BCF TRISD, 2    ; PortD2 <- salida M1R
    BCF TRISD, 3    ; PortD3 <- salida M2R
    BCF TRISD, 4    ; PortD2 <- salida LED IZ
    BCF TRISD, 5    ; PortD3 <- salida LED DE
    BCF TRISD, 6    ; portD4 <- salida LED CEN
    ; Regresar a banco 
    BCF STATUS, 5 ; Bank0

Main:
    MOVF PORTB,0
    MOVWF 0X20
    ;A=25
    MOVF    0X20,0
    ANDLW  0b00010000
    MOVWF   0X25
    RRF	    0X25,1
    RRF	    0X25,1
    RRF	    0X25,1
    RRF	    0X25,1
    MOVF    0X25,0
    ANDLW   0b00000001
    MOVWF   0X25
    
    ;E=24
    MOVF    0X20,0
    ANDLW  0b00001000
    MOVWF   0X24
    RRF	    0X24,1
    RRF	    0X24,1
    RRF	    0X24,1
    MOVF    0X24,0
    ANDLW   0b00000001
    MOVWF   0X24
    
    ;B=23
    MOVF    0X20,0
    ANDLW   0b00000100
    MOVWF   0x23
    RRF	    0x23,1
    RRF	    0x23,1
    MOVF    0x23,0
    ANDLW   0b00000001
    MOVWF   0x23
    
    ;D=22
    MOVF    0X20,0
    ANDLW 0b00000010
    MOVWF 0x22
    RRF   0x22,1
    MOVF  0x22,0
    ANDLW 0b00000001
    MOVWF 0x22
    
    ;C=21
    MOVF   0X20,0
    ANDLW 0b00000001
    MOVWF 0X21
    MOVF  0X21,0
    ANDLW 0b00000001
    MOVWF 0X21
      
    ;!A=30
    MOVF    0X20,0
    ANDLW 0b00010000
    MOVWF   0X30
    RRF	    0X30,1
    RRF	    0X30,1
    RRF	    0X30,1
    RRF	    0X30,1
    COMF    0X30
    MOVF    0X30,0
    ANDLW 0b00000001
    MOVWF   0X30
    
    ;!E=29
    MOVF    0X20,0
    ANDLW 0b00001000
    MOVWF   0X29
    RRF	    0X29,1
    RRF	    0X29,1
    RRF	    0X29,1
    COMF    0X29
    MOVF    0X29,0
    ANDLW 0b00000001
    MOVWF   0X29
    
    ;!B=28
    MOVF    0X20,0
    ANDLW 0b00000100
    MOVWF   0X28
    RRF	    0X28,1
    RRF	    0X28,1
    COMF    0X28
    MOVF    0X28,0
    ANDLW 0b00000001
    MOVWF   0X28
    
    ;!D=27
    MOVF    0X20,0
    ANDLW 0b00000010
    MOVWF   0X27
    RRF	    0X27,1
    COMF    0X27
    MOVF    0X27,0
    ANDLW 0b00000001
    MOVWF   0X27
    
    ;!C=26
    MOVF    0X20,0
    ANDLW   0b00000001
    MOVWF   0X26
    COMF    0X26,1
    MOVF  0X26,0
    ANDLW 0b00000001
    MOVWF 0X26
;INICIO
; Operaciones
;M1=A´*E + A´*D + C*B´
	;A´*E
    MOVF  0X30,0
    ANDWF 0X24,0
    MOVWF 0X31   ;RESULTADO DE A´*E
	;A´*D
    MOVF  0X30,0
    ANDWF 0X22,0
    MOVWF 0X32   ;RESULTADO DE A´*D
	;C*B´
    MOVF  0X21,0
    ANDWF 0X28,0
    MOVWF 0X33   ;RESULTADO DE C*B´
	
    MOVF  0X31,0
    IORWF 0X32,0 
    MOVWF 0X34   ;RESULTADO DE A´*E + A´*D
	
    MOVF  0X33,0
    IORWF 0X34,0
    MOVWF 0X35   ;RESULTADO DE M1
;M2=B´D´C+ A´B + AE´  
	;B´D´C
    MOVF  0X27,0
    ANDWF 0X28,0
    ANDWF 0X21,0
    MOVWF 0X36   ;RESPUESTA DE B´D´C
	;A´B
    MOVF  0X30,0
    ANDWF 0X23,0
    MOVWF 0X37   ;RESPUESTA DE A´B
	;AE´
    MOVF  0X25,0
    ANDWF 0X29,0
    MOVWF 0X38   ;RESPUESTA DE AE´   ---//TAMBIEN ES M1R//---
	
    MOVF  0X36,0 
    IORWF 0X37,0 
    IORWF 0X38,0	
    MOVWF 0X39  ; RESULTADO DE M2 
	
	;//MOTOR EN REVERSA M2R EB´
    MOVF  0X24,0 
    ANDWF 0X28,0
    MOVWF 0X40
;----LEDS----
	;LED IZQUIERDO  AE´ + BD´
    MOVF 0X23,0
    ANDWF 0X27,0
    IORWF 0X38,0
    MOVWF 0X41
	;LED DERECHO   A´E + B´D
    MOVF 0X28,0
    ANDWF 0X22,0
    IORWF 0X31,0
    MOVWF 0X42
	;LED CENTRAL  EB
    MOVF 0X24,0
    ANDWF 0X23,0
    MOVWF 0X43
;------PREGUNTAS-----
    CLRF    PORTD
    BTFSC 0X35,0	;PARA M1
    BSF PORTD,0		;PARA M1
    
    BTFSC 0X39,0	;M2
    BSF PORTD,1		;M2
    
    BTFSC 0X38,0	;M1R 
    BSF PORTD,2		;M1R
    
    BTFSC 0X40,0	;M2R
    BSF PORTD,3		;M2R
    
    BTFSC 0X41,0	;LED IZ
    BSF PORTD,4		;LED DE
    
    BTFSC 0X42,0	;LED DE
    BSF PORTD,5		;LED DE
    
    BTFSC 0X43,0	;LED CE
    BSF PORTD,6		;LED CE
    
GOTO Main
GOTO Main
END resetVec
    