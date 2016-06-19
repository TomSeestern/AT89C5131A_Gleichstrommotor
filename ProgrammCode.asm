cseg at 0
jmp main


;Externe Interrupt
;---------------------------------------------------------------------------------------------
;P3.2  level hochz�hlen
org 03h 
	   jmp runter
	   reti

org 13h 
	   jmp hoch
	   reti

;org 0Bh
		;jmp interruptzahlen
;---------------------------------------------------------------------------------------------
hoch:					mov a,level
						cjne a,#000Fh,erhoehe
						jmp zurueck


runter:					mov a,level
						cjne a,#0000h,vermindere
						jmp zurueck

zurueck:				clr C
						call anzeigen
						reti


erhoehe:		inc level
				jmp zurueck
vermindere: 	dec level
				jmp zurueck			 
;---------------------------------------------------------------------------------------------



;---------------------------------------------------------------------------------------------

;Einsprung (Hauptprogramm)
main:
								;Vorbereitung f�r PGM
;-------------------------------------------------------------------------------------------------------------------------------------------

;Interrupts vorbereiten
;---------------------------------------------------------------------------------------------
setb ea
setb ex0
setb IT0					;�bernehmen bei Aballender Flanke des Interrupts 0
setb ex1
setb IT1
;---------------------------------------------------------------------------------------------


;Equals (Zuweisung der ''Variablen'')
;---------------------------------------------------------------------------------------------
anfangswert equ 30h
endwert equ 04h
level equ 50h
zeahlfaktor equ 60h
uberlaufzahler equ 70h
;---------------------------------------------------------------------------------------------


;Port zuweisung
;---------------------------------------------------------------------------------------------
Ausgabeport equ p2.0
AusgabeDisplayport equ p0
;---------------------------------------------------------------------------------------------


;Config (Startwerte f�r das Programm
;---------------------------------------------------------------------------------------------
mov anfangswert,#0			//11111110b
mov endwert,#11111111b
mov level,#1		
mov uberlaufzahler,#0
;---------------------------------------------------------------------------------------------


;Timer init (Einstellungen des Timers)
;---------------------------------------------------------------------------------------------
anl tmod,#11110001b	
orl tmod,#01h
mov tl0,anfangswert
mov th0,endwert
;---------------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------------------------------------------------------------


;Start des eigentlichen Programms
call anzeigen
jmp aus


;Auszyklus f�r den Motor
;---------------------------------------------------------------------------------------------
aus:
mov tl0,anfangswert
mov th0,endwert
clr C
mov Ausgabeport,C
mov A,#15					;Akku mit Konstante 15 vorladen
clr C						;Carry bit auf 0 setzen
SUBB A,level				;Level wird von 10 Abgezogen um die "Aus" Zeit des Ports zu bestimmen allerdings wird das doppelte ben�tigt (ein durchgang nur 0,06s lang)

mov zeahlfaktor,A			; anzahl an duchg�ngen des z�hlers mal 2


call zaehlen


jmp an
;---------------------------------------------------------------------------------------------


;Auszyklus f�r den Motor
;---------------------------------------------------------------------------------------------
an:
mov tl0,anfangswert
mov th0,endwert
setb C
mov Ausgabeport,C
mov A,level					;Akku mit level laden		
mov zeahlfaktor,A
			
call zaehlen


jmp aus
;---------------------------------------------------------------------------------------------


;Zeitliche verz�gerung f�r den aus bzw an zustand des Motors
;�berpr�fung ob Z�hler schon so oft �bergelaufen ist wie gew�nscht
;---------------------------------------------------------------------------------------------
zaehlen:
setb tr0 									;Starten von timer
mov a,zeahlfaktor							;zeahlfaktor wird geladen(Wie oft �berlaufen soll, wird in akku geladen)
cjne a,uberlaufzahler,uberlaufcheck			;Akku mit �berlaufz�hler vergleichen wenn ungleich sprung nach uberlaufcheck sonst weiter
mov uberlaufzahler,#0000h
clr tr0
ret										   	;springe zur�ck zur stelle nach dem zaehlen aufgerufen wurde
;---------------------------------------------------------------------------------------------


;�berpr�fung ob der Z�hler �bergelaufen ist
;---------------------------------------------------------------------------------------------
uberlaufcheck:
jnb tf0,zaehlen				;Timer �berlauf? wenn nein, springe zu zaehlen
inc uberlaufzahler
clr tf0
mov tl0,anfangswert
mov th0,endwert

jmp zaehlen
;---------------------------------------------------------------------------------------------


;Ausgabe an der 7-Segment-Anzeige
;---------------------------------------------------------------------------------------------
anzeigen:				  	
		mov a, level					; Zahl an level einlesen	
		anl a, #0Fh						; obere 4 Bits ausblenden
		mov dptr, #seg7code 			; Datenpointer init.
		movc a, @a+dptr					; ROM-Zugriff
		mov AusgabeDisplayport, a		; Zahl anzeigen
		ret
;---------------------------------------------------------------------------------------------


;look-up Tabelle f�r die 7-Segment-Anzeige
;---------------------------------------------------------------------------------------------
seg7code:   DB 01111110b,00010010b,10111100b,10110110b
			DB 11010010b,11100110b,11101110b,00110010b
			DB 11111110b,11110110b,11111010b,11001110b
			DB 01101100b,10011110b,11101100b,11101000b	
;---------------------------------------------------------------------------------------------

	
					
end	