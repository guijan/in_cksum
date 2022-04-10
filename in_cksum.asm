	PUBLIC IN_CKSUM
; 8086 implementation of the internet checksum
; https://datatracker.ietf.org/doc/html/rfc1071
;
; No special treatment is made to the checksum field of the IPv4 packet; zero
; it yourself if needed.
;
; input:
;     DS:[SI]: packet
;     CX: unsigned packet length
; output:
;     AX: checksum
IN_CKSUM	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	SI

	SHR	CX,1	; Divide CX by 2 and check if it was odd.
	PUSHF		; Push carry.

	XOR	BX,BX	; Also clears the carry for the SUM loop.
	JCXZ	ONE_BYTE

SUM:
	LODSW		; 1 byte, 12 clocks
	ADC	BX,AX	; 2 bytes, 3 clocks
	LOOP	SUM
	ADC	BX,0

ONE_BYTE:
	POPF
	JNC	FINAL_INVERSION
	; Micro-optimization: CH is always 0, so we MOV to CL instead of AL,
	; which would require a XOR AH,AH
	MOV	CL,[SI]
	ADD	BX,CX
	ADC	BX,0

FINAL_INVERSION:
	MOV	AX,BX
	NOT	AX

	POP	SI
	POP	CX
	POP	BX
	RET
IN_CKSUM	ENDP
