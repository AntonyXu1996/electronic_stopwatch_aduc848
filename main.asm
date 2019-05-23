;��������
T0_COUNTERH		EQU	00H
T0_COUNTERL		EQU	00H
T1_COUNTERH		EQU	00H
T1_COUNTERL		EQU	00H

;�ֽڵ�ַ����
PARA1			EQU	70H
PARA2			EQU	71H

KEY_TrgP		EQU	78H
KEY_Cont		EQU	79H

TIMER_10MS		EQU	30H
TIMER_S			EQU	31H
TIMER_MIN		EQU	32H
TIMER_COUNT		EQU	36H

;λѰַ����
LCD1602_RS		EQU P3.6
LCD1602_RW		EQU P3.5
LCD1602_EN		EQU P3.3
LCD1602_BUSY	EQU	7FH
LCD_UPDATE_FLAG	EQU	7EH
TIMER_5MS		EQU 7DH
	

ORG	0000H
	LJMP	MAIN
	
ORG	000BH
	LJMP	T0ISR
	
ORG	001BH
	LJMP	T1ISR
	
ORG	0033H
MAIN:
	;����PLLCONʹ����Ƶ�ʱ�Ƶ��12.58MHz
	MOV		0xD7,#0F8H
	
	;������ʼ��
	MOV		SP,#08H
	ACALL	Clear0
	CLR		LCD_UPDATE_FLAG
	MOV		R3,#8
	
	;��ʼ��LCD1602
	ACALL	LCD1602_INIT
	
	;��ʼ����ʱ��
	MOV		TMOD,#11H
	MOV		TH0,#T0_COUNTERH
	MOV		TL0,#T0_COUNTERL
	MOV		TH1,#T1_COUNTERH
	MOV		TL1,#T1_COUNTERL
	MOV		IE,#8AH			;��ȫ���жϺ�������ʱ���ж�
	CLR		TR0
	SETB	TR1
	
LOOP:
	;----------LCD��ʾˢ��----------
	JNB		LCD_UPDATE_FLAG,LOOP
	CLR		LCD_UPDATE_FLAG
	
	MOV		PARA1,TIMER_COUNT
	ACALL	COUNTER2MS
	MOV		TIMER_10MS,PARA1
	
	MOV		PARA1,#04H
	ACALL	LCD1602_SetCursor
	
	MOV		A,TIMER_MIN
	MOV		B,#10
	DIV		AB
	MOV		R4,A
	MOV		R5,B
	
	MOV		A,#30H
	ADD		A,R4
	MOV		PARA1,A
	ACALL	LCD1602_PrintChar
	
	MOV		A,#30H
	ADD		A,R5
	MOV		PARA1,A
	ACALL	LCD1602_PrintChar
	
	MOV		PARA1,#':'
	ACALL	LCD1602_PrintChar
	
	MOV		A,TIMER_S
	MOV		B,#10
	DIV		AB
	MOV		R4,A
	MOV		R5,B
	
	MOV		A,#30H
	ADD		A,R4
	MOV		PARA1,A
	ACALL	LCD1602_PrintChar
	
	MOV		A,#30H
	ADD		A,R5
	MOV		PARA1,A
	ACALL	LCD1602_PrintChar
	
	MOV		PARA1,#':'
	ACALL	LCD1602_PrintChar
	
	MOV		A,TIMER_10MS
	MOV		B,#10
	DIV		AB
	MOV		R4,A
	MOV		R5,B
	
	MOV		A,#30H
	ADD		A,R4
	MOV		PARA1,A
	ACALL	LCD1602_PrintChar
	
	MOV		A,#30H
	ADD		A,R5
	MOV		PARA1,A
	ACALL	LCD1602_PrintChar
	
	
	JMP		LOOP
	
	
;*****************************�ӳ��򲿷�*****************************

;==================================
;				����
;==================================
Clear0:
	MOV		KEY_Cont,#0FFH
	MOV		TIMER_COUNT,#0
	MOV		TIMER_10MS,#0
	MOV		TIMER_S,#0
	MOV		TIMER_MIN,#0
	
	RET
	
	
;==================================
;		����ֵת��Ϊ10MS��ֵ
;==================================
COUNTER2MS:;����1������ļ���ֵ�����ز���1
	MOV		A,PARA1
	MOV		DPTR,#TAB
	MOVC	A,@A+DPTR
	MOV		PARA1,A
	
	RET
	
TAB:	DB	 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9
		DB	10,10,11,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19
		DB	20,20,21,21,22,23,23,24,24,25,25,26,26,27,27,28,28,29,29
		DB	30,30,31,31,32,32,33,34,34,35,35,36,36,37,37,38,38,39,39
		DB	40,40,41,41,42,42,43,43,44,45,45,46,46,47,47,48,48,49,49
		DB	50,50,51,51,52,52,53,53,54,54,55,55,56,57,57,58,58,59,59
		DB	60,60,61,61,62,62,63,63,64,64,65,65,66,66,67,68,68,69,69
		DB	70,70,71,71,72,72,73,73,74,74,75,75,76,76,77,77,78,79,79
		DB	80,80,81,81,82,82,83,83,84,84,85,85,86,86,87,87,88,88,89
		DB	89,90,90,91,91,92,92,93,93,94,94,95,95,96,96,97,97,98,98,99,99
	
	
;*****************************�жϷ�����򲿷�*****************************

;==================================
;		��ʱ��0�жϷ������
;==================================
T0ISR:
	;���������ֵ
	CLR		TR0
	MOV		TH0,#T0_COUNTERH
	MOV		TL0,#T0_COUNTERL
	SETB	TR0
	
	;���ݴ����ջ
	CLR		EA
	PUSH	PSW
	PUSH	ACC
	SETB	EA
	
	;���Ӽ���ֵ
	INC		TIMER_COUNT
	MOV		A,TIMER_COUNT
	CJNE	A,#192,t0_conver
	MOV		TIMER_COUNT,#0
	INC		TIMER_S
	MOV		A,TIMER_S
	CJNE	A,#60,t0_conver
	MOV		TIMER_S,#0
	INC		TIMER_MIN
	MOV		A,TIMER_MIN
	CJNE	A,#60,t0_conver
	MOV		TIMER_MIN,#0
	
t0_conver:
	;���ݶ�����ջ
	CLR		EA
	POP		ACC
	POP		PSW
	SETB	EA
	
	RETI
	
	
;==================================
;		��ʱ��1�жϷ������
;==================================
T1ISR:
	;���������ֵ
	CLR		TR1
	MOV		TH1,#T1_COUNTERH
	MOV		TL1,#T1_COUNTERL
	SETB	TR1
	
	;���ݴ����ջ
	CLR		EA
	PUSH	PSW
	PUSH	ACC
	SETB	EA
	
	;�˷�Ƶ
	DJNZ	R3,t1_over
	MOV		R3,#8
	
	;����Һ����ʾ
	SETB	LCD_UPDATE_FLAG
	
	;ɨ�����
	ACALL	KEYBOARD_UPDATE
	
	MOV		A,KEY_TrgP
	JNB		ACC.3,no_motion1
	CPL		TR0
	
no_motion1:
	JNB		ACC.2,no_motion2
	ACALL	Clear0

no_motion2:
t1_over:

	;���ݶ�����ջ
	CLR		EA
	POP		ACC
	POP		PSW
	SETB	EA
	
	RETI
	

;*****************************����ͨ�ú�������*****************************

;==================================
;			ms�ӳٳ���
;==================================
DELAYMS:;����1���ӳٵ�ѭ������
delayms1:
	MOV		R7,#230
delayms2:
	NOP
	NOP
	DJNZ	R7,delayms2
	DJNZ	PARA1,delayms1
	
	RET
	
	
;*****************************����ɨ�貿��*****************************

;==================================
;		����ɨ����³���
;==================================
KEYBOARD_UPDATE:
	;����λ׼������
	ANL		P1,#0F0H
	MOV		A,P1
	CPL		A
	MOV		B,A
	XRL		A,KEY_Cont
	ANL		A,B
	MOV		KEY_TrgP,A
	MOV		KEY_Cont,B
	
	RET

		
;*****************************LCD1602��������*****************************

;==================================
;		LCD1602��ʼ������
;==================================
LCD1602_INIT:
	CLR		LCD1602_BUSY
	CLR		LCD1602_RW
	CLR		LCD1602_EN
	;�ӳ�15ms
	MOV 	PARA1,#15
	ACALL	DELAYMS
	;ָ�� 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	;�ӳ�5ms
	MOV 	PARA1,#5
	ACALL	DELAYMS
	;ָ�� 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	;�ӳ�5ms
	MOV 	PARA1,#5
	ACALL	DELAYMS
	;ָ�� 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	SETB	LCD1602_BUSY
	;ָ�� 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	;ָ�� 08H
	MOV 	PARA1,#0
	MOV 	PARA2,#08H
	ACALL	LCD1602_Write
	;ָ�� 06H
	MOV 	PARA1,#0
	MOV 	PARA2,#06H
	ACALL	LCD1602_Write
	;ָ�� 0cH
	MOV 	PARA1,#0
	MOV 	PARA2,#0CH
	ACALL	LCD1602_Write
	
	RET
		

;==================================
;		LCD1602д������
;==================================	
LCD1602_Write:;����1������/���ݣ�����2������
	ACALL  LCD1602_CHECKBUSY
lcd1602_write0:
	CLR 	LCD1602_EN
	MOV		A,PARA1
	MOV		C,ACC.0
	MOV		LCD1602_RS,C
	CLR 	LCD1602_RW
	MOV		P0,PARA2
	;�ӳ�1ms
	MOV 	PARA1,#1
	ACALL	DELAYMS
	;����������
	SETB	LCD1602_EN
	;�ӳ�1ms
	MOV 	PARA1,#1
	ACALL	DELAYMS
	CLR		LCD1602_EN
	
	RET
			

;==================================
;		LCD1602���ù�����
;==================================	
LCD1602_SetCursor:;����1��λ��
	;��Ļ�ַ�λ�÷�Ϊ0-31��32��λ��
	;��������ֲ᣺����ָ������
	MOV		A,PARA1
	SETB	ACC.7
	MOV		C,ACC.4
	MOV		ACC.6,C
	CLR		ACC.4
	;ָ����ù��
	MOV 	PARA1,#0
	MOV 	PARA2,A
	ACALL	LCD1602_Write
	
	RET
	

;==================================
;		LCD1602д���ַ�����
;==================================	
LCD1602_PrintChar:;����1���ַ�
	PUSH	PARA1
	;ָ��������
	MOV 	PARA1,#1
	POP		PARA2
	ACALL	LCD1602_Write
	
	RET
	
	
;==================================
;		LCD1602��æ����
;==================================	
LCD1602_CHECKBUSY:
	JNB		LCD1602_BUSY,lcd1602_checkbusy1
	CLR		LCD1602_EN
    CLR		LCD1602_RS
    SETB	LCD1602_RW
lcd1602_checkbusy0:
    MOV		P0,#0FFH;
    SETB	LCD1602_EN
    MOV		C,P0.7
    CLR		LCD1602_EN
	JC		lcd1602_checkbusy0
lcd1602_checkbusy1:

	RET
	
	
END
	