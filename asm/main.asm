;常量定义
T0_COUNTERH		EQU	00H
T0_COUNTERL		EQU	00H
T1_COUNTERH		EQU	00H
T1_COUNTERL		EQU	00H

;字节地址定义
PARA1			EQU	70H
PARA2			EQU	71H

KEY_TrgP		EQU	78H
KEY_Cont		EQU	79H

TIMER_10MS		EQU	30H
TIMER_S			EQU	31H
TIMER_MIN		EQU	32H
TIMER_COUNT		EQU	36H

;位寻址定义
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
	;更改PLLCON使总线频率倍频至12.58MHz
	MOV		0xD7,#0F8H
	
	;变量初始化
	MOV		SP,#08H
	ACALL	Clear0
	CLR		LCD_UPDATE_FLAG
	MOV		R3,#8
	
	;初始化LCD1602
	ACALL	LCD1602_INIT
	
	;初始化定时器
	MOV		TMOD,#11H
	MOV		TH0,#T0_COUNTERH
	MOV		TL0,#T0_COUNTERL
	MOV		TH1,#T1_COUNTERH
	MOV		TL1,#T1_COUNTERL
	MOV		IE,#8AH			;打开全局中断和两个定时器中断
	CLR		TR0
	SETB	TR1
	
LOOP:
	;----------LCD显示刷新----------
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
	
	
;*****************************子程序部分*****************************

;==================================
;				清零
;==================================
Clear0:
	MOV		KEY_Cont,#0FFH
	MOV		TIMER_COUNT,#0
	MOV		TIMER_10MS,#0
	MOV		TIMER_S,#0
	MOV		TIMER_MIN,#0
	
	RET
	
	
;==================================
;		计数值转换为10MS的值
;==================================
COUNTER2MS:;参数1：输入的计数值，返回参数1
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
	
	
;*****************************中断服务程序部分*****************************

;==================================
;		定时器0中断服务程序
;==================================
T0ISR:
	;重新载入初值
	CLR		TR0
	MOV		TH0,#T0_COUNTERH
	MOV		TL0,#T0_COUNTERL
	SETB	TR0
	
	;数据存入堆栈
	CLR		EA
	PUSH	PSW
	PUSH	ACC
	SETB	EA
	
	;增加计数值
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
	;数据读出堆栈
	CLR		EA
	POP		ACC
	POP		PSW
	SETB	EA
	
	RETI
	
	
;==================================
;		定时器1中断服务程序
;==================================
T1ISR:
	;重新载入初值
	CLR		TR1
	MOV		TH1,#T1_COUNTERH
	MOV		TL1,#T1_COUNTERL
	SETB	TR1
	
	;数据存入堆栈
	CLR		EA
	PUSH	PSW
	PUSH	ACC
	SETB	EA
	
	;八分频
	DJNZ	R3,t1_over
	MOV		R3,#8
	
	;更新液晶显示
	SETB	LCD_UPDATE_FLAG
	
	;扫描键盘
	ACALL	KEYBOARD_UPDATE
	
	MOV		A,KEY_TrgP
	JNB		ACC.3,no_motion1
	CPL		TR0
	
no_motion1:
	JNB		ACC.2,no_motion2
	ACALL	Clear0

no_motion2:
t1_over:

	;数据读出堆栈
	CLR		EA
	POP		ACC
	POP		PSW
	SETB	EA
	
	RETI
	

;*****************************基本通用函数部分*****************************

;==================================
;			ms延迟程序
;==================================
DELAYMS:;参数1：延迟的循环数量
delayms1:
	MOV		R7,#230
delayms2:
	NOP
	NOP
	DJNZ	R7,delayms2
	DJNZ	PARA1,delayms1
	
	RET
	
	
;*****************************按键扫描部分*****************************

;==================================
;		按键扫描更新程序
;==================================
KEYBOARD_UPDATE:
	;低四位准备输入
	ANL		P1,#0F0H
	MOV		A,P1
	CPL		A
	MOV		B,A
	XRL		A,KEY_Cont
	ANL		A,B
	MOV		KEY_TrgP,A
	MOV		KEY_Cont,B
	
	RET

		
;*****************************LCD1602驱动部分*****************************

;==================================
;		LCD1602初始化程序
;==================================
LCD1602_INIT:
	CLR		LCD1602_BUSY
	CLR		LCD1602_RW
	CLR		LCD1602_EN
	;延迟15ms
	MOV 	PARA1,#15
	ACALL	DELAYMS
	;指令 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	;延迟5ms
	MOV 	PARA1,#5
	ACALL	DELAYMS
	;指令 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	;延迟5ms
	MOV 	PARA1,#5
	ACALL	DELAYMS
	;指令 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	SETB	LCD1602_BUSY
	;指令 38H
	MOV 	PARA1,#0
	MOV 	PARA2,#38H
	ACALL	LCD1602_Write
	;指令 08H
	MOV 	PARA1,#0
	MOV 	PARA2,#08H
	ACALL	LCD1602_Write
	;指令 06H
	MOV 	PARA1,#0
	MOV 	PARA2,#06H
	ACALL	LCD1602_Write
	;指令 0cH
	MOV 	PARA1,#0
	MOV 	PARA2,#0CH
	ACALL	LCD1602_Write
	
	RET
		

;==================================
;		LCD1602写入命令
;==================================	
LCD1602_Write:;参数1：命令/数据，参数2：内容
	ACALL  LCD1602_CHECKBUSY
lcd1602_write0:
	CLR 	LCD1602_EN
	MOV		A,PARA1
	MOV		C,ACC.0
	MOV		LCD1602_RS,C
	CLR 	LCD1602_RW
	MOV		P0,PARA2
	;延迟1ms
	MOV 	PARA1,#1
	ACALL	DELAYMS
	;产生高脉冲
	SETB	LCD1602_EN
	;延迟1ms
	MOV 	PARA1,#1
	ACALL	DELAYMS
	CLR		LCD1602_EN
	
	RET
			

;==================================
;		LCD1602设置光标程序
;==================================	
LCD1602_SetCursor:;参数1：位置
	;屏幕字符位置分为0-31共32个位置
	;详见数据手册：数据指针设置
	MOV		A,PARA1
	SETB	ACC.7
	MOV		C,ACC.4
	MOV		ACC.6,C
	CLR		ACC.4
	;指令：设置光标
	MOV 	PARA1,#0
	MOV 	PARA2,A
	ACALL	LCD1602_Write
	
	RET
	

;==================================
;		LCD1602写入字符程序
;==================================	
LCD1602_PrintChar:;参数1：字符
	PUSH	PARA1
	;指令：输出数据
	MOV 	PARA1,#1
	POP		PARA2
	ACALL	LCD1602_Write
	
	RET
	
	
;==================================
;		LCD1602判忙程序
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
	