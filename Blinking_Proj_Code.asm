;**************************************************************************************
;* Lab 3 Main [includes LibV2.2]                                              *
;**************************************************************************************
;* Summary:                                                                           *
;*   -                                                                                *
;*                                                                                    *
;* Author: Sean Nakashimo, Jared Sinasohn                                                                  *
;*   Cal Poly University                                                              *
;*   Spring 2023                                                                      *
;*                                                                                    *
;* Revision History:                                                                  *
;*   -                                                                                *
;*                                                                                    *
;* ToDo:                                                                              *
;*   -                                                                                *
;**************************************************************************************

;/------------------------------------------------------------------------------------\
;| Include all associated files                                                       |
;\------------------------------------------------------------------------------------/
; The following are external files to be included during assembly


;/------------------------------------------------------------------------------------\
;| External Definitions                                                               |
;\------------------------------------------------------------------------------------/
; All labels that are referenced by the linker need an external definition

              XDEF  main

;/------------------------------------------------------------------------------------\
;| External References                                                                |
;\------------------------------------------------------------------------------------/
; All labels from other files must have an external reference

              XREF  ENABLE_MOTOR, DISABLE_MOTOR
              XREF  STARTUP_MOTOR, UPDATE_MOTOR, CURRENT_MOTOR
              XREF  STARTUP_PWM, STARTUP_ATD0, STARTUP_ATD1
              XREF  OUTDACA, OUTDACB
              XREF  STARTUP_ENCODER, READ_ENCODER
              XREF  INITLCD, SETADDR, GETADDR, CURSOR_ON, CURSOR_OFF, DISP_OFF
              XREF  OUTCHAR, OUTCHAR_AT, OUTSTRING, OUTSTRING_AT, CLRSCREEN
              XREF  INITKEY, LKEY_FLG, GETCHAR
              XREF  LCDTEMPLATE, UPDATELCD_L1, UPDATELCD_L2
              XREF  LVREF_BUF, LVACT_BUF, LERR_BUF,LEFF_BUF, LKP_BUF, LKI_BUF
              XREF  Entry, ISR_KEYPAD
            
;/------------------------------------------------------------------------------------\
;| Assembler Equates                                                                  |
;\------------------------------------------------------------------------------------/
; Paste the following code into your Lab 1B in the 'Assembler Equates" section
PORTP        EQU  $0258               ; output port for driving LEDs
DDRP         EQU  $025A
LED_MSK_1    EQU  %00110000           ; LED output pins
G_LED_1      EQU  %00010000           ; green LED output pin
R_LED_1      EQU  %00100000           ; red LED output pin
LED_MSK_2    EQU  %11000000           ; LED output pins
G_LED_2      EQU  %01000000           ; green LED output pin
R_LED_2      EQU  %10000000           ; red LED output pin
;KEYS
F1           EQU  $F1
F2           EQU  $F2
BS           EQU  $08
ENT          EQU  $0A
SPACE        EQU  $20

PER1LOC      EQU  $1F
PER2LOC      EQU  $5F

MAGTOOLARGE  EQU  $01
ZEROMAGERR   EQU  $02
WAITTIME     EQU  1500






;/------------------------------------------------------------------------------------\
;| Variables in RAM                                                                   |
;\------------------------------------------------------------------------------------/
; The following variables are located in unpaged ram

DEFAULT_RAM:  SECTION
DELAY_CNT:    DS.B  1
BUFFER:       DS.B  5
COUNT:        DS.B  1
COUNT_1:      DS.W  1
COUNT_2:      DS.W  1
TICKS_1:      DS.W  1
TICKS_2:      DS.W  1
DONE_1:       DS.B  1
DONE_2:       DS.B  1
PERIOD:       DS.W  1
TEMP:         DS.B  1
DPTR:         DS.W  1
DIGIT:        DS.B  1
t1state:      DS.B  1
t2state:      DS.B  1
t3state:      DS.B  1
t4state:      DS.B  1
t5state:      DS.B  1
t6state:      DS.B  1
t7state:      DS.B  1
t8state:      DS.B  1
CURRKEY       DS.B  1
;FLAGS
KEYFLAG       DS.B  1
F1FLAG        DS.B  1
F2FLAG        DS.B  1
F1MODE        DS.B  1
F2MODE        DS.B  1
BSFLAG        DS.B  1
ENTFLAG       DS.B  1
LETTERFLAG    DS.B  1
DIGITFLAG     DS.B  1
STOP1         DS.B  1
STOP2         DS.B  1
ERRORCODE     DS.B  1
WAITFORON     DS.B  1
FIRSTCH       DS.B  1
CHARCOUNT     DS.B  1
CHARTEMP      DS.B  1
PRINTSPACE    DS.B  1
TIMEHELD      DS.W  1
NUMDIG        DS.B  1
DF1FLAG       DS.B  1
DF2FLAG       DS.B  1      
DBSFLAG       DS.B  1
DENTFLAG      DS.B  1
DLETTERFLAG   DS.B  1
DDIGITFLAG    DS.B  1
SUPERBOOL     DS.B  1
WAIT          DS.B  1
DAYCARE       DS.B  1
LCDaddr       DS.B  1
DONOTHING     DS.B  1
UNFINISHEDPER DS.B  1

;/------------------------------------------------------------------------------------\
;|  Main Program Code                                                                 |
;\------------------------------------------------------------------------------------/
; This code implements Lab_1A for ME 305

MyCode:       SECTION
main:   jsr   SETUP
top:   
        jsr   TASK1
        jsr   TASK2
        jsr   TASK3
        jsr   TASK4
        jsr   TASK5
        jsr   TASK6
        jsr   TASK7
        jsr   TASK8
        bra   top


;/------------------------------------------------------------------------------------\
;| Subroutines                                                                        |
;\------------------------------------------------------------------------------------/
; -------MASTERMIND-------------------------------------------------------------------
TASK1:  ldaa  t1state
        Lbeq  t1state0                   ;INIT
        deca
        Lbeq  t1state1                   ;WAIT FOR ON DISPLAY
        deca
        Lbeq  t1state2                   ;HUB
        deca
        Lbeq  t1state3                   ;F1 HANDLER
        deca
        Lbeq  t1state4                   ;F2 HANDLER
        deca
        Lbeq  t1state5                   ;BS HANDLER
        deca
        Lbeq  t1state6                   ;ENTER HANDLER
        deca
        Lbeq  t1state7                   ;DIGIT HANDLER
        deca
        Lbeq  t1state8                   ;MASTERMIND DAYCARE
        rts
t1state0:
       	movb  #$01,WAITFORON
        movb  #$00,ENTFLAG
        movb  #$00,DIGITFLAG
        movb  #$00,BSFLAG
        movb  #$00,LETTERFLAG
	      movb  #$00,DF1FLAG
	      movb  #$00,DF2FLAG
	      movb  #$00,DAYCARE
	      movb  #$01,STOP1
	      movb  #$01,STOP2
      	movb  #$01,t1state
        rts
t1state1:
	      tst   WAITFORON
	      beq   exit_t1s1
       	rts
exit_t1s1:
        clr   KEYFLAG
        movb  #$02,t1state
        rts 	
t1state2:
        movb  #$02,t1state
        tst   DAYCARE
        Lbne  setdaycarestate                               
        tst   KEYFLAG
        bne   keytest
        rts
keytest:
        ldab  CURRKEY
        cmpb  #F1
        beq   exit_t1s2F1
        cmpb  #F2
        beq   exit_t1s2F2
        cmpb  #BS
        beq   exit_t1s2BS
        cmpb  #ENT
        beq   exit_t1s2ENT
        cmpb  #$3A
        BMI   exit_t1s2DIGIT
        clr   KEYFLAG
        rts
exit_t1s2F1:
        movb  #$01,F1FLAG
        movb  #$03,t1state
        rts
exit_t1s2F2:
        movb  #$01,F2FLAG
        movb  #$04,t1state
        rts                
exit_t1s2BS:
        movb  #$01,BSFLAG
        movb  #$05,t1state
        rts
exit_t1s2ENT:
        movb  #$01,ENTFLAG
        movb  #$06,t1state
        rts
exit_t1s2DIGIT:
        movb  #$01,DIGITFLAG
        movb  #$07,t1state
        rts
setdaycarestate:
        movb  #$08,t1state
        rts
t1state3: ;F1 Handler
        movb  #$03,t1state
        movb  #$01,STOP1
        clr   F2MODE
        movb  #$01,F1MODE
        tst   F1FLAG
        Lbeq   exit_t1s3
        rts
exit_t1s3:
        clr   KEYFLAG
        movb  #$02,t1state
        rts
t1state4: ;F2 Handler
        movb  #$01,STOP2
        clr   F1MODE
        movb  #$01,F2MODE
        tst   F2FLAG
        beq   exit_t1s4
        rts
exit_t1s4:
        clr   KEYFLAG
        movb  #$02,t1state
        rts
t1state5: ;BS Handler
        tst   BSFLAG
        Lbeq   exit_t1s5
        rts
exit_t1s5:
        clr   KEYFLAG
        movb  #$02,t1state
        rts
t1state6: ;ENT Handler
        ldaa  F1MODE
        ldab  F2MODE
        aba
        beq   exit_t1s6
        clra
        clrb
        jsr   BCD
        tst   ERRORCODE
        Lbne  exit_t1s6
        jsr   CLR_BUFF
      	jsr   CURSOR_OFF
        tst   F1MODE
        bne   f1start
        tst   F2MODE
        bne   f2start
        bra   exit_t1s6 
f1start:
       	movb  #$00,F1MODE
      	movb  #$00,STOP1
      	bra   exit_t1s6
f2start:
       	movb  #$00,F2MODE
      	movb  #$00,STOP2      	
exit_t1s6:
        clr   KEYFLAG
        movb  #$02,t1state
        rts 
        

t1state7: ;digit handler
      	tst  DIGITFLAG
      	beq  exit_t1s7
      	rts
exit_t1s7:
        clr   KEYFLAG
        movb  #$02,t1state
        rts 

t1state8: ;mastermind daycare
        tst   DAYCARE
        Lbeq   exit_t1s8
        rts
exit_t1s8:
        clr   KEYFLAG
        movb  #$02,t1state
        rts                    

; -------TASK 2: KEYPAD DRIVER-----------------------------------------------       
TASK2:
        ldaa  t2state
        Lbeq   t2state0
        deca
        Lbeq   t2state1
        deca
        Lbeq   t2state2
t2state0:
        clr   KEYFLAG
        tst   WAITFORON
        beq   sett2st1
        rts
sett2st1:
        movb  #$01,t2state
        rts
t2state1:
        movb  #$01,t2state
        tst   LKEY_FLG
        Lbne  setkeyflag
        rts
setkeyflag:
        movb  #$01,KEYFLAG
        jsr   GETCHAR
        stab  CURRKEY
        movb  #$02,t2state
        rts
t2state2:
        movb  #$02,t2state
        tst   KEYFLAG
        Lbeq   sett2st1
        rts
; -------TASK 3: DISPLAY DRIVER-----------------------------------------------        
         
TASK3:
        ldaa   t3state
        Lbeq   t3state0
        deca
        Lbeq   t3state1
        deca
        Lbeq   t3state2
        deca
        Lbeq   t3state3
        deca
        Lbeq   t3state4
        deca
        Lbeq   t3state5
        deca
        Lbeq   t3state6
        deca
        Lbeq   t3state7
        deca
        Lbeq   t3state8
        rts
t3state0:
        movb  #$00,DLETTERFLAG
        movb  #$00,DENTFLAG
        movb  #$00,DBSFLAG
        movb  #$00,DDIGITFLAG
        movb  #$01,DF1FLAG
        movb  #$01,DF2FLAG
        movb  #$01,FIRSTCH
        movb  #$00,SUPERBOOL
        movb  #$01,t3state
        rts
t3state1:
        tst   ERRORCODE
        Lbne  exit_t3s1ERROR
        tst   KEYFLAG
        Lbne  exit_t3s1ECHO
      	tst   DDIGITFLAG
      	bne   exit_t3s1DIGIT
      	tst   DBSFLAG
      	Lbne  exit_t3s1BS
      	tst   DF1FLAG
      	Lbne  exit_t3s1F1
      	tst   DF2FLAG
      	Lbne  exit_t3s1F2
      	rts
exit_t3s1ERROR:
        movb  #$01,PRINTSPACE
        ldaa  ERRORCODE
        deca
        beq   exit_t3s1OVERFLOW
        deca
        beq   exit_t3s1ZEROMAG
exit_t3s1OVERFLOW:
        tst   F1MODE
        bne   f1ovaddr
        tst   F2MODE
        bne   f2ovaddr
f1ovaddr:
        ldaa  #$00
        bra   continueov
f2ovaddr:
        ldaa  #$40
continueov:
        jsr   SETADDR
        movb  #$01,FIRSTCH
        movb  #$01,DAYCARE
        movb  #$07,t3state
        rts
exit_t3s1ZEROMAG:
        tst   F1MODE
        bne   f1zmaddr
        tst   F2MODE
        bne   f2zmaddr
f1zmaddr:
        ldaa  #$00
        bra   continuezm
f2zmaddr:
        ldaa  #$40
continuezm:
        jsr   SETADDR
        movb  #$01,FIRSTCH
        movb  #$01,DAYCARE
        movb  #$08,t3state
        rts        
exit_t3s1ECHO:
        movb  #$06,t3state
        rts
exit_t3s1DIGIT:
        movb  #$04,t3state
        rts
exit_t3s1BS:
        movb  #$05,t3state
        rts
exit_t3s1F1:
        movb  #$01,PRINTSPACE
        ldaa  #$00
        jsr   SETADDR
        jsr   CURSOR_ON
        movb  #$01,FIRSTCH
        movb  #$02,t3state
        rts
exit_t3s1F2:
        movb  #$01,PRINTSPACE
        ldaa  #$40
        jsr   SETADDR
        jsr   CURSOR_ON
        movb  #$01,FIRSTCH
        movb  #$03,t3state
        rts

t3state2:  ;MESSAGE 1 HANDLER
        tst   PRINTSPACE
        bne   spprF1
        tst   UNFINISHEDPER
        bne   spprF1PER2
        tst   FIRSTCH
      	bne   firstchF1
	      jsr   PUTCHAR
      	tst   FIRSTCH
	      bne   exit_t3s2
      	rts
spprF1:
        jsr   GETADDR
        ldab  #$20
        cmpa  #$27
        beq   exitspF1
        jsr   OUTCHAR
        rts
exitspF1:
        movb  #$00,PRINTSPACE
        ldaa  #$00
        jsr   SETADDR
        tst   STOP2
        bne   setUNFINISHEDPER2
        bra   exit_actually1
setUNFINISHEDPER2:
        movb  #$01,UNFINISHEDPER
        ldaa  #PER2LOC
        jsr   SETADDR
exit_actually1:        
        rts
spprF1PER2:
        jsr   GETADDR
        ldab  #$20
        cmpa  #$67
        beq   exitspF1PER2
        jsr   OUTCHAR
        rts
exitspF1PER2:
        movb  #$00,UNFINISHEDPER
        ldaa  #$00
        jsr   SETADDR
        rts
firstchF1:
        ldx   #F1MESSAGE
        jsr   GETADDR
        jsr   PUTCHAR1ST
        rts
exit_t3s2:
        movb  #$00,DF1FLAG
        movb  #$00,F1FLAG
        ldaa  #PER1LOC
        jsr   SETADDR
        movb  #$01,t3state
        jsr   CLR_BUFF
        rts
                        
t3state3:  ;MESSAGE 2 HANDLER
        tst   PRINTSPACE
        bne   spprF2
        tst   UNFINISHEDPER
        bne   spprF2PER1
        tst   FIRSTCH
      	bne   firstchF2
	      jsr   PUTCHAR
      	tst   FIRSTCH
	      bne   exit_t3s3
      	rts
spprF2:
        jsr   GETADDR
        ldab  #$20
        cmpa  #$67
        beq   exitspF2
        jsr   OUTCHAR
        rts
exitspF2:
        movb  #$00,PRINTSPACE
        ldaa  #$40
        jsr   SETADDR
        tst   STOP1
        bne   setUNFINISHEDPER1
        bra   exit_actually2
setUNFINISHEDPER1:
        movb  #$01,UNFINISHEDPER
        ldaa  #PER1LOC
        jsr   SETADDR
exit_actually2:        
        rts
spprF2PER1:
        jsr   GETADDR
        ldab  #$20
        cmpa  #$27
        beq   exitspF2PER1
        jsr   OUTCHAR
        rts
exitspF2PER1:
        movb  #$00,UNFINISHEDPER
        ldaa  #$40
        jsr   SETADDR
        rts
firstchF2:
        ldx   #F2MESSAGE
        jsr   GETADDR
        jsr   PUTCHAR1ST
        rts
exit_t3s3:
        movb  #$00,DF2FLAG
        movb  #$00,F2FLAG
        ldaa  #PER2LOC
        jsr   SETADDR
        movb  #$01,t3state
        jsr   CLR_BUFF
        tst   WAITFORON
        bne   openshop
        rts
openshop:
        movb  #$00,WAITFORON
        jsr   CURSOR_OFF
        rts
                
t3state4: ;Digit handler
        ldaa  F1MODE
        ldab  F2MODE
        aba
        beq   exit_t3s4b
        clra
        clrb
        ldaa  COUNT
        cmpa  #$05
        beq   exit_t3s4b
        clra
      	ldab  CURRKEY
      	jsr   GETADDR
      	jsr   OUTCHAR
      	bra   exit_t3s4a
exit_t3s4a:
        ldx   #BUFFER
        ldaa  COUNT
        movb  CURRKEY,A,X
        inc   COUNT
exit_t3s4b:
        movb  #$00,DDIGITFLAG
        movb  #$00,DIGITFLAG
        movb  #$01,t3state
        rts
        
t3state5: ;backspace state
        tst   COUNT
        beq   exit_t3s5
      	ldaa  SUPERBOOL
      	beq   back
      	deca
      	beq   printsp
      	deca  
       	beq   exitbs
	      rts
	
back:
      	ldab  #$08
      	jsr   OUTCHAR
      	movb  #$01,SUPERBOOL
       	rts
printsp:
      	ldab  #$20
       	jsr   OUTCHAR
       	movb  #$02,SUPERBOOL
       	rts
exitbs:
      	jsr   GETADDR
       	deca
        jsr   SETADDR
        dec   COUNT
        ldaa  COUNT
        ldx   #BUFFER
        movb  #$00,A,X
exit_t3s5:
        movb  #$00,DBSFLAG
        movb  #$00,BSFLAG
        movb  #$01,t3state
        movb  #$00,SUPERBOOL
        rts

t3state6:  ;echo state
        clr   KEYFLAG
	      tst   DIGITFLAG
	      Lbne  ddig
      	tst   BSFLAG
      	Lbne  dbs
      	tst   F1FLAG
      	Lbne  df1
      	tst   F2FLAG
        Lbne  df2
        movb  #$01,t3state
      	rts
ddig:
        movb  #$01,t3state	
      	movb  #$01,DDIGITFLAG
      	rts
dbs:
        movb  #$01,t3state	
      	movb  #$01,DBSFLAG
      	rts
df1:
        movb  #$01,t3state	
      	movb  #$01,DF1FLAG
      	rts
df2:
        movb  #$01,t3state
	      movb  #$01,DF2FLAG
	      rts
	      
t3state7:  ;ERROR 1 HANDLER
	      decw  TIMEHELD
       	tstw  TIMEHELD
	      beq   exit_t3s7
       	tst   DONOTHING
       	bne   exit_rtsOVER
       	tst   PRINTSPACE
       	bne   spprOVER
       	tst   FIRSTCH
       	bne   firstchOVER
       	jsr   PUTCHAR
       	tst   FIRSTCH
       	bne   setDONOTHINGOVER
       	rts
exit_rtsOVER:
        rts
spprOVER:
        ldab  #$20
        tst   F1MODE
        bne   compoverF1
        tst   F2MODE
        bne   compoverF2
compoverF1:
        jsr   GETADDR
        cmpa  #$27
        beq   exitspOVER
        jsr   OUTCHAR
        rts
compoverF2:
        jsr   GETADDR
        cmpa  #$67
        beq   exitspOVER
        jsr   OUTCHAR
        rts         
exitspOVER:
        movb  #$00,PRINTSPACE
        tst   F1MODE
        bne   line1setaddrOVER
        tst   F2MODE
        bne   line2setaddrOVER
line1setaddrOVER:
        ldaa  #$00
        jsr   SETADDR
        rts
line2setaddrOVER:
        ldaa  #$40
        jsr   SETADDR
        rts  
firstchOVER:
        ldx   #OVERFLOWMESS
        jsr   PUTCHAR1ST
        rts
setDONOTHINGOVER:
        movb  #$01,DONOTHING
        rts
exit_t3s7:
        movw  #WAITTIME,TIMEHELD
        movb  #$00,DAYCARE
        movb  #$00,ERRORCODE
        movb  #$00,DONOTHING
        movb  #$01,t3state
        tst   F1MODE
        bne   exit_t3s7a
        tst   F2MODE
        bne   exit_t3s7b
        rts
exit_t3s7a:
        movb  #$01,DF1FLAG
        rts
exit_t3s7b:
        movb  #$01,DF2FLAG
        rts
        
t3state8:  ;ZERO MAGNITUDE ERROR HANDLER
	      decw  TIMEHELD
       	tstw  TIMEHELD
	      beq   exit_t3s8
       	tst   DONOTHING
       	bne   exit_rtsZM
       	tst   PRINTSPACE
       	bne   spprZM
       	tst   FIRSTCH
       	bne   firstchZM
       	jsr   PUTCHAR
       	tst   FIRSTCH
       	bne   setDONOTHINGZM
       	rts
exit_rtsZM:
        rts
spprZM:
        ldab  #$20
        tst   F1MODE
        bne   compzmF1
        tst   F2MODE
        bne   compzmF2
compzmF1:
        jsr   GETADDR
        cmpa  #$27
        beq   exitspZM
        jsr   OUTCHAR
        rts
compzmF2:
        jsr   GETADDR
        cmpa  #$67
        beq   exitspZM
        jsr   OUTCHAR
        rts         
exitspZM:
        movb  #$00,PRINTSPACE
        tst   F1MODE
        bne   line1setaddrZM
        tst   F2MODE
        bne   line2setaddrZM
line1setaddrZM:
        ldaa  #$00
        jsr   SETADDR
        rts
line2setaddrZM:
        ldaa  #$40
        jsr   SETADDR
        rts  
firstchZM:
        ldx   #ZEROMAGMESS
        jsr   PUTCHAR1ST
        rts
setDONOTHINGZM:
        movb  #$01,DONOTHING
        rts
exit_t3s8:
        movw  #WAITTIME,TIMEHELD
        movb  #$00,DAYCARE
        movb  #$00,ERRORCODE
        movb  #$00,DONOTHING
        movb  #$01,t3state
        tst   F1MODE
        bne   exit_t3s8a
        tst   F2MODE
        bne   exit_t3s8b
        rts
exit_t3s8a:
        movb  #$01,DF1FLAG
        rts
exit_t3s8b:
        movb  #$01,DF2FLAG
        rts

; -------TASK 4: Pattern 1-----------------------------------------------   
TASK4:
        ldaa  t4state
        beq   t4state0
        deca
        beq   t4state1
        deca
        beq   t4state2
        deca
        beq   t4state3
        deca        
        beq   t4state4
        deca
        Lbeq   t4state5
        deca        
        Lbeq   t4state6
        deca
        Lbeq   t4state7
        deca
        rts
        
t4state0:        
        bclr  PORTP, LED_MSK_1
        bset  DDRP, LED_MSK_1
        movb  #$01,t4state
        rts

t4state1:
        tst   STOP1
        bne   exit_t4s1a
        bset  PORTP,G_LED_1
        tst   DONE_1
        beq   exit_t4s1
        movb  #$02,t4state
exit_t4s1:
        rts
exit_t4s1a:
        movb  #$07,t4state
        rts
        
t4state2:
        tst   STOP1
        bne   exit_t4s2a
        bclr  PORTP,G_LED_1
        tst   DONE_1
        beq   exit_t4s2
        movb  #$03, t4state
exit_t4s2:
        rts
exit_t4s2a:
        movb  #$07,t4state
        rts

t4state3:
        tst   STOP1
        bne   exit_t4s3a
        bset  PORTP,R_LED_1
        tst   DONE_1
        beq   exit_t4s3
        movb  #$04,t4state
exit_t4s3:
        rts
exit_t4s3a:
        movb  #$07,t4state
        rts

t4state4:
        tst   STOP1
        bne   exit_t4s4a
        bclr  PORTP,R_LED_1
        tst   DONE_1
        beq   exit_t4s4
        movb  #$05, t4state
exit_t4s4:
        rts
exit_t4s4a:
        movb  #$07,t4state
        rts

t4state5:
        tst   STOP1
        bne   exit_t4s5a
        bset  PORTP,LED_MSK_1
        tst   DONE_1
        beq   exit_t4s5
        movb  #$06,t4state
exit_t4s5:
        rts
exit_t4s5a:
        movb  #$07,t4state
        rts

t4state6:
        tst   STOP1
        bne   exit_t4s6a
        bclr  PORTP,LED_MSK_1
        tst   DONE_1
        beq   exit_t4s6
        movb  #$01, t4state
exit_t4s6:
        rts
exit_t4s6a:
        movb  #$07,t4state
        rts
                  
t4state7:
        bclr  PORTP,LED_MSK_1
        tst  STOP1
        beq  exit_t4s7
        rts
exit_t4s7:
        movb #$01,t4state
        rts  
               
;-------------TASK_5 Timing 1---------------------------------------------------------
TASK5:
        ldaa  t5state
        beq   t5state0
        deca
        beq   t5state1
        rts

t5state0:
        clr   DONE_1
        movw  TICKS_1,COUNT_1
        movb  #$01,t5state
        rts

t5state1:
        tst   DONE_1
        beq   t5s1a
        movw  TICKS_1,COUNT_1
        clr   DONE_1
t5s1a:
        tst   STOP1
        bne   exit_t5s1a
        decw  COUNT_1
        bne   exit_t5s1
        movb  #$01,DONE_1
exit_t5s1a:
        movb  #$01,DONE_1 
exit_t5s1:
        rts

; -------TASK 6: Pattern 6-----------------------------------------------   
TASK6:
        ldaa  t6state
        beq   t6state0
        deca
        beq   t6state1
        deca
        beq   t6state2
        deca
        beq   t6state3
        deca        
        beq   t6state4
        deca
        Lbeq   t6state5
        deca        
        Lbeq   t6state6
        deca
        Lbeq   t6state7
        deca
        rts
        
t6state0:        
        bclr  PORTP, LED_MSK_2
        bset  DDRP, LED_MSK_2
        movb  #$01,t6state
        rts

t6state1:
        tst   STOP2
        bne   exit_t6s1a
        bset  PORTP,G_LED_2
        tst   DONE_2
        beq   exit_t6s1
        movb  #$02,t6state
exit_t6s1:
        rts
exit_t6s1a:
        movb  #$07,t6state
        rts
        
t6state2:
        tst   STOP2
        bne   exit_t6s2a
        bclr  PORTP,G_LED_2
        tst   DONE_2
        beq   exit_t6s2
        movb  #$03, t6state
exit_t6s2:
        rts
exit_t6s2a:
        movb  #$07,t6state
        rts

t6state3:
        tst   STOP2
        bne   exit_t6s3a
        bset  PORTP,R_LED_2
        tst   DONE_2
        beq   exit_t6s3
        movb  #$04,t6state
exit_t6s3:
        rts
exit_t6s3a:
        movb  #$07,t6state
        rts

t6state4:
        tst   STOP2
        bne   exit_t6s4a
        bclr  PORTP,R_LED_2
        tst   DONE_2
        beq   exit_t6s4
        movb  #$05, t6state
exit_t6s4:
        rts
exit_t6s4a:
        movb  #$07,t6state
        rts

t6state5:
        tst   STOP2
        bne   exit_t6s5a
        bset  PORTP,LED_MSK_2
        tst   DONE_2
        beq   exit_t6s5
        movb  #$06,t6state
exit_t6s5:
        rts
exit_t6s5a:
        movb  #$07,t6state
        rts

t6state6:
        tst   STOP2
        bne   exit_t6s6a
        bclr  PORTP,LED_MSK_2
        tst   DONE_2
        beq   exit_t6s6
        movb  #$01, t6state
exit_t6s6:
        rts
exit_t6s6a:
        movb  #$07,t6state
        rts
                  
t6state7:
        bclr  PORTP,LED_MSK_2
        tst  STOP2
        beq  exit_t6s7
        rts
exit_t6s7:
        movb #$01,t6state
        rts 
               
;-------------TASK_7 Timing 7---------------------------------------------------------
TASK7:
        ldaa  t7state
        beq   t7state0
        deca
        beq   t7state1
        rts

t7state0:
        clr   DONE_2
        movw  TICKS_2,COUNT_2
        movb  #$01,t7state
        rts

t7state1:
        tst   DONE_2
        beq   t7s1a
        movw  TICKS_2,COUNT_2
        clr   DONE_2
t7s1a:
        tst   STOP2
        bne   exit_t7s1a
        decw  COUNT_2
        bne   exit_t7s1
        movb  #$01,DONE_2
exit_t7s1a:
        movb  #$01,DONE_2 
exit_t7s1:
        rts                
;-------------TASK_8 Delay 1ms---------------------------------------------------------
TASK8:  ldaa  t8state                  ; get current t3state and Lbranch accordingly
        Lbeq   t8state0
        deca
        Lbeq   t8state1
        rts                            ; undefined state - do nothing but return

t8state0:                              ; initialization for TASK_5
                                       ; no initialization required
        movb  #$01, t8state            ; set next state
        rts

t8state1:
        
        jsr   DELAY_1ms
        rts                            ; exit TASK_5
;/------------------------------------------------------------------------------------\  
;| Subroutines                                                                        | 
;/------------------------------------------------------------------------------------/          

        
BCD:   
        ldx  #BUFFER
        movw #$0000,PERIOD
        ldab COUNT
        beq  endloop
loop:
        ldd  PERIOD   ;loads result into ac. d
        ldy  #$0A     ;loads index register y w/10
        emul          ;multiplies result by 10 to make room for next digit
        tsty          ;Tests to see if index register y is zero or negative
        Lbne  overflow ;Lbranches to an overflow error if the high byte of the result is
                      ;greater than zero meaning the entry is more than 16bits
        std  PERIOD   ;stores whatever is in d to the result
        ldaa TEMP     ;loads temp into accumulator A
        ldab A,X      ;loads b by getting the current location 
        subb #$30
        clra
        addd PERIOD
        std  PERIOD
        inc  TEMP
        dec  COUNT
        ldab COUNT
        tstb
        Lbeq  endloop
        Lbra  loop

endloop:
        clr   TEMP
        tstw  PERIOD
        Lbeq  zeromag
        Lbra  noerror
                
zeromag:
        ldab  0,X
        subb  #$31
        bpl   overflow
        clrb
        jsr   CLR_BUFF
        movb  #$02,ERRORCODE ;sets the error code to 2, the ZERO MAGNITUDE INAPPROPRIATE code
        movb  #$01,DAYCARE
        jsr   CLR_BUFF
        rts
        
overflow:
        movb  #$01,ERRORCODE ;sets the error code to 1, the MAGNITUDE TOO LARGE code
        movb  #$01,DAYCARE
        jsr   CLR_BUFF
        movb  #$00,TEMP
        rts                  ;returns to the initial subroutine

noerror:
        movb  #$00,ERRORCODE
        movb  #$00,COUNT
        ldd   PERIOD
        tst   F1MODE
        Lbne  TICKER1
        tst   F2MODE
        Lbne  TICKER2
        rts   
TICKER1:
        std   TICKS_1
        rts
TICKER2:
        std   TICKS_2
        rts 



PUTCHAR1ST:
	      stx   DPTR
       	jsr   GETADDR	
      	clr   FIRSTCH
PUTCHAR:
      	stx   DPTR
      	ldab  0,X
      	Lbeq  DONE
      	inx
      	stx   DPTR
      	jsr   OUTCHAR
      	rts
DONE:
      	movb  #$01,FIRSTCH
      	rts
	        
; Paste the following code into your Lab 1B in the "Subroutines" section

SETUP:
; setup IO ports 
        movw  #$0001,TICKS_1
        movw  #$0001,TICKS_2
        movw  #$0000,COUNT_1
        movw  #$0000,COUNT_2
        movb  #$00,TEMP
        jsr   INITLCD
        jsr   INITKEY 
        movb  #$00,t1state
        movb  #$00,t2state
        movb  #$00,t3state
        movb  #$00,t4state
        movb  #$00,t5state
        movb  #$00,t6state
        movb  #$00,t7state
        movb  #$00,t8state 
        movb  #$00,ERRORCODE
        movb  #$00,LCDaddr
        movb  #$00,COUNT
        ldx   #BUFFER
        movb  #$00,0,X
        movb  #$00,1,X
        movb  #$00,2,X
        movb  #$00,3,X
        movb  #$00,4,X
        movb  #$00,F2MODE
        movb  #$00,F1MODE
        movw  #WAITTIME,TIMEHELD
        clr   DONOTHING   
        rts                             ; exit SETUP
        
DELAY_1ms:
      	ldy #$0584
INNER: ; inside loop
       	cpy #0
      	Lbeq EXIT
      	dey
      	Lbra INNER
EXIT:
      	rts ; exit DELAY_1ms

; end subroutine SETUP

CLR_BUFF:
        movb  #$00,COUNT
        ldx   #BUFFER
      	movb  #$00,0,X
      	movb  #$00,1,X
      	movb  #$00,2,X
      	movb  #$00,3,X
      	movb  #$00,4,X
        rts

;/------------------------------------------------------------------------------------\
;| ASCII Messages and Constant Data                                                   |
;\------------------------------------------------------------------------------------/
; Any constants can be defined here
F1MESSAGE:     DC.B  'PAIR 1 TIME (UPDATE W/ <F1>):  ',$00
F2MESSAGE:     DC.B  'PAIR 2 TIME (UPDATE W/ <F2>):  ',$00
OVERFLOWMESS:  DC.B  'PERIOD MUST BE <65536',$00
ZEROMAGMESS:   DC.B  'PERIOD MUST BE >0',$00




;/------------------------------------------------------------------------------------\
;| Vectors                                                                            |
;\------------------------------------------------------------------------------------/
; Add interrupt and reset vectors here

        ORG   $FFFE                    ; reset vector address
        DC.W  Entry
        ORG   $FFCE                    ; Key Wakeup interrupt vector address [Port J]
        DC.W  ISR_KEYPAD



