
;CodeVisionAVR C Compiler V3.25 Evaluation
;(C) Copyright 1998-2016 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Build configuration    : Debug
;Chip type              : ATmega64A
;Program type           : Application
;Clock frequency        : 8.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 1024 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: Yes
;Enhanced function parameter passing: Mode 2
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#define _MODEL_SMALL_

	#pragma AVRPART ADMIN PART_NAME ATmega64A
	#pragma AVRPART MEMORY PROG_FLASH 65536
	#pragma AVRPART MEMORY EEPROM 2048
	#pragma AVRPART MEMORY INT_SRAM SIZE 4096
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU USR=0xB
	.EQU UDR=0xC
	.EQU SPSR=0xE
	.EQU SPDR=0xF
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU EECR=0x1C
	.EQU EEDR=0x1D
	.EQU EEARL=0x1E
	.EQU EEARH=0x1F
	.EQU WDTCR=0x21
	.EQU MCUCR=0x35
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU XMCRA=0x6D
	.EQU XMCRB=0x6C

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x10FF
	.EQU __DSTACK_SIZE=0x0400
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD2M
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	PUSH R26
	PUSH R27
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	POP  R27
	POP  R26
	ICALL
	.ENDM

	.MACRO __CALL2EX
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	CALL __EEPROMRDD
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1STACK
	IN   R30,SPL
	IN   R31,SPH
	ADIW R30,@0+1
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z
	MOVW R30,R0
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _LT=R5
	.DEF _RT=R4

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer2_ovf_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer1_ovf_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x30,0x30

_0x2000060:
	.DB  0x1
_0x2000000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x02
	.DW  0x04
	.DW  __REG_VARS*2

	.DW  0x01
	.DW  __seed_G100
	.DW  _0x2000060*2

_0xFFFFFFFF:
	.DW  0

#define __GLOBAL_INI_TBL_PRESENT 1

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30
	STS  XMCRB,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x500

	.CSEG
;/*******************************************************
;This program was created by the CodeWizardAVR V3.25
;Automatic Program Generator
;© Copyright 1998-2016 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com
;
;Project :
;Version :
;Date    : 3/17/2016
;Author  :
;Company :
;Comments:
;
;
;Chip type               : ATmega64A
;Program type            : Application
;AVR Core Clock frequency: 8.000000 MHz
;Memory model            : Small
;External RAM size       : 0
;Data Stack size         : 1024
;*******************************************************/
;
;#include <io.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x20
	.EQU __sm_mask=0x1C
	.EQU __sm_powerdown=0x10
	.EQU __sm_powersave=0x18
	.EQU __sm_standby=0x14
	.EQU __sm_ext_standby=0x1C
	.EQU __sm_adc_noise_red=0x08
	.SET power_ctrl_reg=mcucr
	#endif
;#include <delay.h>
;#include <stdlib.h>
;#include <mega64a.h>
;
;// Declare your global variables here
;unsigned long int freq1c,freq2c,speed_rpm,speed_ecu,speed_ecu_prev,tire_dim,steer_wheel;
;unsigned long i=0,j=0,dur1,dur2,s=0, in, ok=0,tr=0,sp=0,sw=0,m=0,done=0,cycle;
;char input[20],td[6],sp_ecu[6],st_wh[6],buffer1[6],buffer2[6],buffer3[6],LT='0',RT='0';
;
;#define DATA_REGISTER_EMPTY (1<<UDRE0)
;#define RX_COMPLETE (1<<RXC1)
;#define FRAMING_ERROR (1<<FE1)
;#define PARITY_ERROR (1<<UPE1)
;#define DATA_OVERRUN (1<<DOR1)
;
;#pragma used+
;char getchar1(void)
; 0000 0029 {

	.CSEG
_getchar1:
; .FSTART _getchar1
; 0000 002A unsigned char status;
; 0000 002B char data;
; 0000 002C while (1)
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
_0x3:
; 0000 002D       {
; 0000 002E       while (((status=UCSR1A) & RX_COMPLETE)==0);
_0x6:
	LDS  R30,155
	MOV  R17,R30
	ANDI R30,LOW(0x80)
	BREQ _0x6
; 0000 002F       data=UDR1;
	LDS  R16,156
; 0000 0030       if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x9
; 0000 0031          return data;
	MOV  R30,R16
	RJMP _0x2080001
; 0000 0032       }
_0x9:
	RJMP _0x3
; 0000 0033 }
_0x2080001:
	LD   R16,Y+
	LD   R17,Y+
	RET
; .FEND
;void putchar0(char c)
; 0000 0035 {
_putchar0:
; .FSTART _putchar0
; 0000 0036 while ((UCSR0A & DATA_REGISTER_EMPTY)==0);
	ST   -Y,R17
	MOV  R17,R26
;	c -> R17
_0xA:
	SBIS 0xB,5
	RJMP _0xA
; 0000 0037 UDR0=c;
	OUT  0xC,R17
; 0000 0038 }
	LD   R17,Y+
	RET
; .FEND
;#pragma used-
;// Timer1 overflow interrupt service routine
;interrupt [TIM1_OVF] void timer1_ovf_isr(void)
; 0000 003C {
_timer1_ovf_isr:
; .FSTART _timer1_ovf_isr
	RCALL SUBOPT_0x0
; 0000 003D // Place your code here
; 0000 003E     i++;
	LDI  R26,LOW(_i)
	LDI  R27,HIGH(_i)
	RJMP _0x41
; 0000 003F }
; .FEND
;
;// Timer2 overflow interrupt service routine
;interrupt [TIM2_OVF] void timer2_ovf_isr(void)
; 0000 0043 {
_timer2_ovf_isr:
; .FSTART _timer2_ovf_isr
	RCALL SUBOPT_0x0
; 0000 0044 // Place your code here
; 0000 0045     j++;
	LDI  R26,LOW(_j)
	LDI  R27,HIGH(_j)
_0x41:
	RCALL __GETD1P_INC
	RCALL SUBOPT_0x1
; 0000 0046 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R23,Y+
	LD   R22,Y+
	RETI
; .FEND
;
;void main(void)
; 0000 0049 {
_main:
; .FSTART _main
; 0000 004A // Declare your local variables here
; 0000 004B 
; 0000 004C // Input/Output Ports initialization
; 0000 004D // Port A initialization
; 0000 004E // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 004F DDRA=(0<<DDA7) | (0<<DDA6) | (0<<DDA5) | (0<<DDA4) | (0<<DDA3) | (0<<DDA2) | (0<<DDA1) | (0<<DDA0);
	LDI  R30,LOW(0)
	OUT  0x1A,R30
; 0000 0050 // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 0051 PORTA=(0<<PORTA7) | (0<<PORTA6) | (0<<PORTA5) | (0<<PORTA4) | (0<<PORTA3) | (0<<PORTA2) | (0<<PORTA1) | (0<<PORTA0);
	OUT  0x1B,R30
; 0000 0052 
; 0000 0053 // Port B initialization
; 0000 0054 // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 0055 DDRB=(0<<DDB7) | (0<<DDB6) | (0<<DDB5) | (0<<DDB4) | (0<<DDB3) | (0<<DDB2) | (0<<DDB1) | (0<<DDB0);
	OUT  0x17,R30
; 0000 0056 // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 0057 PORTB=(0<<PORTB7) | (0<<PORTB6) | (0<<PORTB5) | (0<<PORTB4) | (0<<PORTB3) | (0<<PORTB2) | (0<<PORTB1) | (0<<PORTB0);
	OUT  0x18,R30
; 0000 0058 
; 0000 0059 // Port C initialization
; 0000 005A // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 005B DDRC=(0<<DDC7) | (0<<DDC6) | (0<<DDC5) | (0<<DDC4) | (0<<DDC3) | (0<<DDC2) | (0<<DDC1) | (0<<DDC0);
	OUT  0x14,R30
; 0000 005C // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 005D PORTC=(0<<PORTC7) | (0<<PORTC6) | (0<<PORTC5) | (0<<PORTC4) | (0<<PORTC3) | (0<<PORTC2) | (0<<PORTC1) | (0<<PORTC0);
	OUT  0x15,R30
; 0000 005E 
; 0000 005F // Port D initialization
; 0000 0060 // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 0061 DDRD=(0<<DDD7) | (0<<DDD6) | (0<<DDD5) | (0<<DDD4) | (0<<DDD3) | (0<<DDD2) | (0<<DDD1) | (0<<DDD0);
	OUT  0x11,R30
; 0000 0062 // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 0063 PORTD=(0<<PORTD7) | (0<<PORTD6) | (0<<PORTD5) | (0<<PORTD4) | (0<<PORTD3) | (0<<PORTD2) | (0<<PORTD1) | (0<<PORTD0);
	OUT  0x12,R30
; 0000 0064 
; 0000 0065 // Port E initialization
; 0000 0066 // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 0067 DDRE=(0<<DDE7) | (0<<DDE6) | (0<<DDE5) | (0<<DDE4) | (0<<DDE3) | (0<<DDE2) | (0<<DDE1) | (0<<DDE0);
	OUT  0x2,R30
; 0000 0068 // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 0069 PORTE=(0<<PORTE7) | (0<<PORTE6) | (0<<PORTE5) | (0<<PORTE4) | (0<<PORTE3) | (0<<PORTE2) | (0<<PORTE1) | (0<<PORTE0);
	OUT  0x3,R30
; 0000 006A 
; 0000 006B // Port F initialization
; 0000 006C // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 006D DDRF=(0<<DDF7) | (0<<DDF6) | (0<<DDF5) | (0<<DDF4) | (0<<DDF3) | (0<<DDF2) | (0<<DDF1) | (0<<DDF0);
	STS  97,R30
; 0000 006E // State: Bit7=T Bit6=T Bit5=T Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 006F PORTF=(0<<PORTF7) | (0<<PORTF6) | (0<<PORTF5) | (0<<PORTF4) | (0<<PORTF3) | (0<<PORTF2) | (0<<PORTF1) | (0<<PORTF0);
	STS  98,R30
; 0000 0070 
; 0000 0071 // Port G initialization
; 0000 0072 // Function: Bit4=In Bit3=In Bit2=In Bit1=In Bit0=In
; 0000 0073 DDRG=(0<<DDG4) | (0<<DDG3) | (0<<DDG2) | (0<<DDG1) | (0<<DDG0);
	STS  100,R30
; 0000 0074 // State: Bit4=T Bit3=T Bit2=T Bit1=T Bit0=T
; 0000 0075 PORTG=(0<<PORTG4) | (0<<PORTG3) | (0<<PORTG2) | (0<<PORTG1) | (0<<PORTG0);
	STS  101,R30
; 0000 0076 
; 0000 0077 // Timer/Counter 0 initialization
; 0000 0078 // Clock source: System Clock
; 0000 0079 // Clock value: Timer 0 Stopped
; 0000 007A // Mode: Normal top=0xFF
; 0000 007B // OC0 output: Disconnected
; 0000 007C ASSR=0<<AS0;
	OUT  0x30,R30
; 0000 007D TCCR0=(0<<WGM00) | (0<<COM01) | (0<<COM00) | (0<<WGM01) | (0<<CS02) | (0<<CS01) | (0<<CS00);
	OUT  0x33,R30
; 0000 007E TCNT0=0x00;
	OUT  0x32,R30
; 0000 007F OCR0=0x00;
	OUT  0x31,R30
; 0000 0080 
; 0000 0081 // Timer/Counter 1 initialization
; 0000 0082 // Clock source: System Clock
; 0000 0083 // Clock value: 8000.000 kHz
; 0000 0084 // Mode: Fast PWM top=0x00FF
; 0000 0085 // OC1A output: Disconnected
; 0000 0086 // OC1B output: Disconnected
; 0000 0087 // OC1C output: Disconnected
; 0000 0088 // Noise Canceler: Off
; 0000 0089 // Input Capture on Rising Edge
; 0000 008A // Timer Period: 0.032 ms
; 0000 008B // Timer1 Overflow Interrupt: On
; 0000 008C // Input Capture Interrupt: Off
; 0000 008D // Compare A Match Interrupt: Off
; 0000 008E // Compare B Match Interrupt: Off
; 0000 008F // Compare C Match Interrupt: Off
; 0000 0090 TCCR1A=(0<<COM1A1) | (0<<COM1A0) | (0<<COM1B1) | (0<<COM1B0) | (0<<COM1C1) | (0<<COM1C0) | (0<<WGM11) | (1<<WGM10);
	LDI  R30,LOW(1)
	OUT  0x2F,R30
; 0000 0091 TCCR1B=(0<<ICNC1) | (1<<ICES1) | (0<<WGM13) | (1<<WGM12) | (0<<CS12) | (0<<CS11) | (1<<CS10);
	LDI  R30,LOW(73)
	OUT  0x2E,R30
; 0000 0092 TCNT1H=0x00;
	LDI  R30,LOW(0)
	OUT  0x2D,R30
; 0000 0093 TCNT1L=0x00;
	OUT  0x2C,R30
; 0000 0094 ICR1H=0x00;
	OUT  0x27,R30
; 0000 0095 ICR1L=0x00;
	OUT  0x26,R30
; 0000 0096 OCR1AH=0x00;
	OUT  0x2B,R30
; 0000 0097 OCR1AL=0x00;
	OUT  0x2A,R30
; 0000 0098 OCR1BH=0x00;
	OUT  0x29,R30
; 0000 0099 OCR1BL=0x00;
	OUT  0x28,R30
; 0000 009A OCR1CH=0x00;
	STS  121,R30
; 0000 009B OCR1CL=0x00;
	STS  120,R30
; 0000 009C 
; 0000 009D // Timer/Counter 2 initialization
; 0000 009E // Clock source: System Clock
; 0000 009F // Clock value: 8000.000 kHz
; 0000 00A0 // Mode: Normal top=0xFF
; 0000 00A1 // OC2 output: Disconnected
; 0000 00A2 // Timer Period: 0.032 ms
; 0000 00A3 TCCR2=(0<<WGM20) | (0<<COM21) | (0<<COM20) | (0<<WGM21) | (0<<CS22) | (0<<CS21) | (1<<CS20);
	LDI  R30,LOW(1)
	OUT  0x25,R30
; 0000 00A4 TCNT2=0x00;
	LDI  R30,LOW(0)
	OUT  0x24,R30
; 0000 00A5 OCR2=0x00;
	OUT  0x23,R30
; 0000 00A6 
; 0000 00A7 // Timer/Counter 3 initialization
; 0000 00A8 // Clock source: System Clock
; 0000 00A9 // Clock value: Timer3 Stopped
; 0000 00AA // Mode: Normal top=0xFFFF
; 0000 00AB // OC3A output: Disconnected
; 0000 00AC // OC3B output: Disconnected
; 0000 00AD // OC3C output: Disconnected
; 0000 00AE // Noise Canceler: Off
; 0000 00AF // Input Capture on Falling Edge
; 0000 00B0 // Timer3 Overflow Interrupt: Off
; 0000 00B1 // Input Capture Interrupt: Off
; 0000 00B2 // Compare A Match Interrupt: Off
; 0000 00B3 // Compare B Match Interrupt: Off
; 0000 00B4 // Compare C Match Interrupt: Off
; 0000 00B5 TCCR3A=(0<<COM3A1) | (0<<COM3A0) | (0<<COM3B1) | (0<<COM3B0) | (0<<COM3C1) | (0<<COM3C0) | (0<<WGM31) | (0<<WGM30);
	STS  139,R30
; 0000 00B6 TCCR3B=(0<<ICNC3) | (1<<ICES3) | (0<<WGM33) | (0<<WGM32) | (0<<CS32) | (0<<CS31) | (0<<CS30);
	LDI  R30,LOW(64)
	STS  138,R30
; 0000 00B7 TCNT3H=0x00;
	LDI  R30,LOW(0)
	STS  137,R30
; 0000 00B8 TCNT3L=0x00;
	STS  136,R30
; 0000 00B9 ICR3H=0x00;
	STS  129,R30
; 0000 00BA ICR3L=0x00;
	STS  128,R30
; 0000 00BB OCR3AH=0x00;
	STS  135,R30
; 0000 00BC OCR3AL=0x00;
	STS  134,R30
; 0000 00BD OCR3BH=0x00;
	STS  133,R30
; 0000 00BE OCR3BL=0x00;
	STS  132,R30
; 0000 00BF OCR3CH=0x00;
	STS  131,R30
; 0000 00C0 OCR3CL=0x00;
	STS  130,R30
; 0000 00C1 
; 0000 00C2 // Timer(s)/Counter(s) Interrupt(s) initialization
; 0000 00C3 TIMSK=(0<<OCIE2) | (1<<TOIE2) | (0<<TICIE1) | (0<<OCIE1A) | (0<<OCIE1B) | (1<<TOIE1) | (0<<OCIE0) | (0<<TOIE0);
	LDI  R30,LOW(68)
	OUT  0x37,R30
; 0000 00C4 ETIMSK=(0<<TICIE3) | (0<<OCIE3A) | (0<<OCIE3B) | (0<<TOIE3) | (0<<OCIE3C) | (0<<OCIE1C);
	LDI  R30,LOW(0)
	STS  125,R30
; 0000 00C5 
; 0000 00C6 // External Interrupt(s) initialization
; 0000 00C7 // INT0: Off
; 0000 00C8 // INT1: Off
; 0000 00C9 // INT2: Off
; 0000 00CA // INT3: Off
; 0000 00CB // INT4: Off
; 0000 00CC // INT5: Off
; 0000 00CD // INT6: Off
; 0000 00CE // INT7: Off
; 0000 00CF EICRA=(0<<ISC31) | (0<<ISC30) | (0<<ISC21) | (0<<ISC20) | (0<<ISC11) | (0<<ISC10) | (0<<ISC01) | (0<<ISC00);
	STS  106,R30
; 0000 00D0 EICRB=(0<<ISC71) | (0<<ISC70) | (0<<ISC61) | (0<<ISC60) | (0<<ISC51) | (0<<ISC50) | (0<<ISC41) | (0<<ISC40);
	OUT  0x3A,R30
; 0000 00D1 EIMSK=(0<<INT7) | (0<<INT6) | (0<<INT5) | (0<<INT4) | (0<<INT3) | (0<<INT2) | (0<<INT1) | (0<<INT0);
	OUT  0x39,R30
; 0000 00D2 
; 0000 00D3 // USART0 initialization
; 0000 00D4 // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 00D5 // USART0 Receiver: Off
; 0000 00D6 // USART0 Transmitter: On
; 0000 00D7 // USART0 Mode: Asynchronous
; 0000 00D8 // USART0 Baud Rate: 9600
; 0000 00D9 UCSR0A=(0<<RXC0) | (0<<TXC0) | (0<<UDRE0) | (0<<FE0) | (0<<DOR0) | (0<<UPE0) | (0<<U2X0) | (0<<MPCM0);
	OUT  0xB,R30
; 0000 00DA UCSR0B=(0<<RXCIE0) | (0<<TXCIE0) | (0<<UDRIE0) | (0<<RXEN0) | (1<<TXEN0) | (0<<UCSZ02) | (0<<RXB80) | (0<<TXB80);
	LDI  R30,LOW(8)
	OUT  0xA,R30
; 0000 00DB UCSR0C=(0<<UMSEL0) | (0<<UPM01) | (0<<UPM00) | (0<<USBS0) | (1<<UCSZ01) | (1<<UCSZ00) | (0<<UCPOL0);
	LDI  R30,LOW(6)
	STS  149,R30
; 0000 00DC UBRR0H=0x00;
	LDI  R30,LOW(0)
	STS  144,R30
; 0000 00DD UBRR0L=0x33;
	LDI  R30,LOW(51)
	OUT  0x9,R30
; 0000 00DE 
; 0000 00DF // USART1 initialization
; 0000 00E0 // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 00E1 // USART1 Receiver: On
; 0000 00E2 // USART1 Transmitter: Off
; 0000 00E3 // USART1 Mode: Asynchronous
; 0000 00E4 // USART1 Baud Rate: 9600
; 0000 00E5 UCSR1A=(0<<RXC1) | (0<<TXC1) | (0<<UDRE1) | (0<<FE1) | (0<<DOR1) | (0<<UPE1) | (0<<U2X1) | (0<<MPCM1);
	LDI  R30,LOW(0)
	STS  155,R30
; 0000 00E6 UCSR1B=(0<<RXCIE1) | (0<<TXCIE1) | (0<<UDRIE1) | (1<<RXEN1) | (0<<TXEN1) | (0<<UCSZ12) | (0<<RXB81) | (0<<TXB81);
	LDI  R30,LOW(16)
	STS  154,R30
; 0000 00E7 UCSR1C=(0<<UMSEL1) | (0<<UPM11) | (0<<UPM10) | (0<<USBS1) | (1<<UCSZ11) | (1<<UCSZ10) | (0<<UCPOL1);
	LDI  R30,LOW(6)
	STS  157,R30
; 0000 00E8 UBRR1H=0x00;
	LDI  R30,LOW(0)
	STS  152,R30
; 0000 00E9 UBRR1L=0x33;
	LDI  R30,LOW(51)
	STS  153,R30
; 0000 00EA 
; 0000 00EB // Analog Comparator initialization
; 0000 00EC // Analog Comparator: Off
; 0000 00ED // The Analog Comparator's positive input is
; 0000 00EE // connected to the AIN0 pin
; 0000 00EF // The Analog Comparator's negative input is
; 0000 00F0 // connected to the AIN1 pin
; 0000 00F1 ACSR=(1<<ACD) | (0<<ACBG) | (0<<ACO) | (0<<ACI) | (0<<ACIE) | (0<<ACIC) | (0<<ACIS1) | (0<<ACIS0);
	LDI  R30,LOW(128)
	OUT  0x8,R30
; 0000 00F2 SFIOR=(0<<ACME);
	LDI  R30,LOW(0)
	OUT  0x20,R30
; 0000 00F3 
; 0000 00F4 // ADC initialization
; 0000 00F5 // ADC disabled
; 0000 00F6 ADCSRA=(0<<ADEN) | (0<<ADSC) | (0<<ADFR) | (0<<ADIF) | (0<<ADIE) | (0<<ADPS2) | (0<<ADPS1) | (0<<ADPS0);
	OUT  0x6,R30
; 0000 00F7 
; 0000 00F8 // SPI initialization
; 0000 00F9 // SPI disabled
; 0000 00FA SPCR=(0<<SPIE) | (0<<SPE) | (0<<DORD) | (0<<MSTR) | (0<<CPOL) | (0<<CPHA) | (0<<SPR1) | (0<<SPR0);
	OUT  0xD,R30
; 0000 00FB 
; 0000 00FC // TWI initialization
; 0000 00FD // TWI disabled
; 0000 00FE TWCR=(0<<TWEA) | (0<<TWSTA) | (0<<TWSTO) | (0<<TWEN) | (0<<TWIE);
	STS  116,R30
; 0000 00FF 
; 0000 0100 // Globally enable interrupts
; 0000 0101 #asm("sei")
	sei
; 0000 0102 TCCR2=0x00;
	LDI  R30,LOW(0)
	OUT  0x25,R30
; 0000 0103 TCCR1B=0x00;
	OUT  0x2E,R30
; 0000 0104 TCCR1A=0x01;
	LDI  R30,LOW(1)
	OUT  0x2F,R30
; 0000 0105 TCNT1=0x00;
	RCALL SUBOPT_0x2
; 0000 0106 TCNT2=0x00;
	LDI  R30,LOW(0)
	OUT  0x24,R30
; 0000 0107 TIMSK=0x00;
	OUT  0x37,R30
; 0000 0108 
; 0000 0109 while (1){
_0xD:
; 0000 010A         in=0;
	LDI  R30,LOW(0)
	STS  _in,R30
	STS  _in+1,R30
	STS  _in+2,R30
	STS  _in+3,R30
; 0000 010B         ok=0;
	STS  _ok,R30
	STS  _ok+1,R30
	STS  _ok+2,R30
	STS  _ok+3,R30
; 0000 010C         tr=0;
	STS  _tr,R30
	STS  _tr+1,R30
	STS  _tr+2,R30
	STS  _tr+3,R30
; 0000 010D         sp=0;
	STS  _sp,R30
	STS  _sp+1,R30
	STS  _sp+2,R30
	STS  _sp+3,R30
; 0000 010E         sw=0;
	STS  _sw,R30
	STS  _sw+1,R30
	STS  _sw+2,R30
	STS  _sw+3,R30
; 0000 010F         m=0;
	RCALL SUBOPT_0x3
; 0000 0110         done=0;
	LDI  R30,LOW(0)
	STS  _done,R30
	STS  _done+1,R30
	STS  _done+2,R30
	STS  _done+3,R30
; 0000 0111         while (1){
_0x10:
; 0000 0112             if (getchar1()=='V'){
	RCALL _getchar1
	CPI  R30,LOW(0x56)
	BRNE _0x13
; 0000 0113              while (1){
_0x14:
; 0000 0114                 input[in]=getchar1();
	RCALL SUBOPT_0x4
	PUSH R31
	PUSH R30
	RCALL _getchar1
	POP  R26
	POP  R27
	ST   X,R30
; 0000 0115                 if (input[in]=='V'){
	RCALL SUBOPT_0x4
	LD   R26,Z
	CPI  R26,LOW(0x56)
	BRNE _0x17
; 0000 0116                     done=1;
	RCALL SUBOPT_0x5
	STS  _done,R30
	STS  _done+1,R31
	STS  _done+2,R22
	STS  _done+3,R23
; 0000 0117                     break;
	RJMP _0x16
; 0000 0118                     }
; 0000 0119                 else
_0x17:
; 0000 011A                     in=in+1;
	RCALL SUBOPT_0x6
	RCALL SUBOPT_0x7
	STS  _in,R30
	STS  _in+1,R31
	STS  _in+2,R22
	STS  _in+3,R23
; 0000 011B                 }
	RJMP _0x14
_0x16:
; 0000 011C             }
; 0000 011D             if (done==1)
_0x13:
	LDS  R26,_done
	LDS  R27,_done+1
	LDS  R24,_done+2
	LDS  R25,_done+3
	RCALL SUBOPT_0x8
	BRNE _0x10
; 0000 011E                 break;
; 0000 011F         }
; 0000 0120         input[in+1]='\0';
	LDS  R30,_in
	LDS  R31,_in+1
	__ADDW1MN _input,1
	LDI  R26,LOW(0)
	STD  Z+0,R26
; 0000 0121         for (m =0;m<in; m++){
	RCALL SUBOPT_0x3
_0x1B:
	RCALL SUBOPT_0x6
	LDS  R26,_m
	LDS  R27,_m+1
	LDS  R24,_m+2
	LDS  R25,_m+3
	RCALL __CPD21
	BRLO PC+2
	RJMP _0x1C
; 0000 0122             if (input[m]=='T'){
	RCALL SUBOPT_0x9
	CPI  R26,LOW(0x54)
	BRNE _0x1D
; 0000 0123                 ok=1;
	RCALL SUBOPT_0x5
	RCALL SUBOPT_0xA
; 0000 0124                 m=m+1;
; 0000 0125             }
; 0000 0126             if (input[m]=='S'){
_0x1D:
	RCALL SUBOPT_0x9
	CPI  R26,LOW(0x53)
	BRNE _0x1E
; 0000 0127                 ok=2;
	RCALL SUBOPT_0xB
	RCALL SUBOPT_0xA
; 0000 0128                 m=m+1;
; 0000 0129             }
; 0000 012A             if (ok==0){
_0x1E:
	LDS  R30,_ok
	LDS  R31,_ok+1
	LDS  R22,_ok+2
	LDS  R23,_ok+3
	RCALL __CPD10
	BRNE _0x1F
; 0000 012B                 td[tr]=input[m];
	LDS  R26,_tr
	LDS  R27,_tr+1
	SUBI R26,LOW(-_td)
	SBCI R27,HIGH(-_td)
	RCALL SUBOPT_0xC
; 0000 012C                 tr=tr+1;
	LDS  R30,_tr
	LDS  R31,_tr+1
	LDS  R22,_tr+2
	LDS  R23,_tr+3
	RCALL SUBOPT_0x7
	STS  _tr,R30
	STS  _tr+1,R31
	STS  _tr+2,R22
	STS  _tr+3,R23
; 0000 012D             }
; 0000 012E             else if(ok==1){
	RJMP _0x20
_0x1F:
	LDS  R26,_ok
	LDS  R27,_ok+1
	LDS  R24,_ok+2
	LDS  R25,_ok+3
	RCALL SUBOPT_0x8
	BRNE _0x21
; 0000 012F                 sp_ecu[sp]=input[m];
	LDS  R26,_sp
	LDS  R27,_sp+1
	SUBI R26,LOW(-_sp_ecu)
	SBCI R27,HIGH(-_sp_ecu)
	RCALL SUBOPT_0xC
; 0000 0130                 sp=sp+1;
	LDS  R30,_sp
	LDS  R31,_sp+1
	LDS  R22,_sp+2
	LDS  R23,_sp+3
	RCALL SUBOPT_0x7
	STS  _sp,R30
	STS  _sp+1,R31
	STS  _sp+2,R22
	STS  _sp+3,R23
; 0000 0131             }
; 0000 0132             else{
	RJMP _0x22
_0x21:
; 0000 0133                 st_wh[sw]=input[m];
	LDS  R26,_sw
	LDS  R27,_sw+1
	SUBI R26,LOW(-_st_wh)
	SBCI R27,HIGH(-_st_wh)
	RCALL SUBOPT_0xC
; 0000 0134                 sw=sw+1;
	LDS  R30,_sw
	LDS  R31,_sw+1
	LDS  R22,_sw+2
	LDS  R23,_sw+3
	RCALL SUBOPT_0x7
	STS  _sw,R30
	STS  _sw+1,R31
	STS  _sw+2,R22
	STS  _sw+3,R23
; 0000 0135             }
_0x22:
_0x20:
; 0000 0136         }
	LDI  R26,LOW(_m)
	LDI  R27,HIGH(_m)
	RCALL __GETD1P_INC
	RCALL SUBOPT_0x1
	RJMP _0x1B
_0x1C:
; 0000 0137         td[tr]='\0';
	LDS  R30,_tr
	LDS  R31,_tr+1
	SUBI R30,LOW(-_td)
	SBCI R31,HIGH(-_td)
	LDI  R26,LOW(0)
	STD  Z+0,R26
; 0000 0138         sp_ecu[sp]='\0';
	LDS  R30,_sp
	LDS  R31,_sp+1
	SUBI R30,LOW(-_sp_ecu)
	SBCI R31,HIGH(-_sp_ecu)
	STD  Z+0,R26
; 0000 0139         st_wh[sw]='\0';
	LDS  R30,_sw
	LDS  R31,_sw+1
	SUBI R30,LOW(-_st_wh)
	SBCI R31,HIGH(-_st_wh)
	STD  Z+0,R26
; 0000 013A 
; 0000 013B         tire_dim = atoi(td);
	LDI  R26,LOW(_td)
	LDI  R27,HIGH(_td)
	RCALL _atoi
	RCALL __CWD1
	STS  _tire_dim,R30
	STS  _tire_dim+1,R31
	STS  _tire_dim+2,R22
	STS  _tire_dim+3,R23
; 0000 013C         speed_ecu = atoi(sp_ecu);
	LDI  R26,LOW(_sp_ecu)
	LDI  R27,HIGH(_sp_ecu)
	RCALL _atoi
	RCALL __CWD1
	STS  _speed_ecu,R30
	STS  _speed_ecu+1,R31
	STS  _speed_ecu+2,R22
	STS  _speed_ecu+3,R23
; 0000 013D         steer_wheel = atoi(st_wh);
	LDI  R26,LOW(_st_wh)
	LDI  R27,HIGH(_st_wh)
	RCALL _atoi
	RCALL __CWD1
	STS  _steer_wheel,R30
	STS  _steer_wheel+1,R31
	STS  _steer_wheel+2,R22
	STS  _steer_wheel+3,R23
; 0000 013E 
; 0000 013F //      Place your code here
; 0000 0140         TIMSK=0x04; // enable overflow interrupt of timer1
	LDI  R30,LOW(4)
	OUT  0x37,R30
; 0000 0141         TCNT1=0x00;
	RCALL SUBOPT_0x2
; 0000 0142         TCCR1B=0x4F; /* start timer1 with external pulses (T1 rising edge) */
	LDI  R30,LOW(79)
	OUT  0x2E,R30
; 0000 0143         delay_ms(500); // wait for one second
	RCALL SUBOPT_0xD
; 0000 0144         TCCR1B=0x00; //stop timer1
	OUT  0x2E,R30
; 0000 0145         dur1=TCNT1; /* store the number of counts from TCNT1 register */
	IN   R30,0x2C
	IN   R31,0x2C+1
	CLR  R22
	CLR  R23
	STS  _dur1,R30
	STS  _dur1+1,R31
	STS  _dur1+2,R22
	STS  _dur1+3,R23
; 0000 0146         TIMSK=0x00; //disable interrupt
	LDI  R30,LOW(0)
	OUT  0x37,R30
; 0000 0147         freq1c = (dur1+i*256)*2; /* calculate the frequency as in previous equation */
	LDS  R30,_i
	LDS  R31,_i+1
	LDS  R22,_i+2
	LDS  R23,_i+3
	RCALL SUBOPT_0xE
	LDS  R26,_dur1
	LDS  R27,_dur1+1
	LDS  R24,_dur1+2
	LDS  R25,_dur1+3
	RCALL __ADDD21
	RCALL SUBOPT_0xB
	RCALL __MULD12U
	RCALL SUBOPT_0xF
; 0000 0148         freq1c = freq1c;//*10000/9635;
	RCALL SUBOPT_0x10
	RCALL SUBOPT_0xF
; 0000 0149         TCNT1=0x00; /* clear TCNT1 register for the next reading */
	RCALL SUBOPT_0x2
; 0000 014A         i=0; /* clear number of overflows in one second for the next reading */
	LDI  R30,LOW(0)
	STS  _i,R30
	STS  _i+1,R30
	STS  _i+2,R30
	STS  _i+3,R30
; 0000 014B         ltoa(freq1c,buffer1);
	RCALL SUBOPT_0x10
	RCALL __PUTPARD1
	LDI  R26,LOW(_buffer1)
	LDI  R27,HIGH(_buffer1)
	RCALL _ltoa
; 0000 014C 
; 0000 014D         TIMSK=0x40;
	LDI  R30,LOW(64)
	OUT  0x37,R30
; 0000 014E         TCNT2=0x00;
	LDI  R30,LOW(0)
	OUT  0x24,R30
; 0000 014F         TCCR2=0x07;
	LDI  R30,LOW(7)
	OUT  0x25,R30
; 0000 0150         delay_ms(500); // wait for one second
	RCALL SUBOPT_0xD
; 0000 0151         TCCR2=0x00; //stop timer2
	OUT  0x25,R30
; 0000 0152         dur2=TCNT2; /* store the number of counts in TCNT3 register */
	IN   R30,0x24
	CLR  R31
	CLR  R22
	CLR  R23
	STS  _dur2,R30
	STS  _dur2+1,R31
	STS  _dur2+2,R22
	STS  _dur2+3,R23
; 0000 0153         TIMSK=0x00;
	LDI  R30,LOW(0)
	OUT  0x37,R30
; 0000 0154         freq2c = (dur2 + j*256)*2; /* calculate the frequency */
	LDS  R30,_j
	LDS  R31,_j+1
	LDS  R22,_j+2
	LDS  R23,_j+3
	RCALL SUBOPT_0xE
	LDS  R26,_dur2
	LDS  R27,_dur2+1
	LDS  R24,_dur2+2
	LDS  R25,_dur2+3
	RCALL __ADDD21
	RCALL SUBOPT_0xB
	RCALL __MULD12U
	STS  _freq2c,R30
	STS  _freq2c+1,R31
	STS  _freq2c+2,R22
	STS  _freq2c+3,R23
; 0000 0155         TCNT2=0x00; /* clear TCNT1 register for the next reading */
	LDI  R30,LOW(0)
	OUT  0x24,R30
; 0000 0156         j=0; /* clear number of overflows in one second for the next reading */
	STS  _j,R30
	STS  _j+1,R30
	STS  _j+2,R30
	STS  _j+3,R30
; 0000 0157 //        if (freq2c!=0){
; 0000 0158 //            freq2c=freq2c+30;
; 0000 0159 //        }
; 0000 015A         s=0;
	RCALL SUBOPT_0x11
; 0000 015B          ltoa(freq2c,buffer2);
	RCALL SUBOPT_0x12
	RCALL __PUTPARD1
	LDI  R26,LOW(_buffer2)
	LDI  R27,HIGH(_buffer2)
	RCALL _ltoa
; 0000 015C         while (buffer1[s]!='\0'){
_0x23:
	RCALL SUBOPT_0x13
	LD   R30,Z
	CPI  R30,0
	BREQ _0x25
; 0000 015D             putchar0(buffer1[s]);
	RCALL SUBOPT_0x13
	RCALL SUBOPT_0x14
; 0000 015E             s++;
; 0000 015F         }
	RJMP _0x23
_0x25:
; 0000 0160         putchar0(',');
	LDI  R26,LOW(44)
	RCALL _putchar0
; 0000 0161 
; 0000 0162         s=0;
	RCALL SUBOPT_0x11
; 0000 0163         while (buffer2[s]!='\0'){
_0x26:
	RCALL SUBOPT_0x15
	LD   R30,Z
	CPI  R30,0
	BREQ _0x28
; 0000 0164             putchar0(buffer2[s]);
	RCALL SUBOPT_0x15
	RCALL SUBOPT_0x14
; 0000 0165             s++;
; 0000 0166         }
	RJMP _0x26
_0x28:
; 0000 0167         putchar0(';');
	LDI  R26,LOW(59)
	RCALL _putchar0
; 0000 0168 
; 0000 0169         speed_rpm = ((freq1c+freq2c)/2.0)*3.14*tire_dim*6/10000;
	RCALL SUBOPT_0x12
	RCALL SUBOPT_0x16
	RCALL __ADDD12
	RCALL __CDF1U
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x40000000
	RCALL __DIVF21
	__GETD2N 0x4048F5C3
	RCALL __MULF12
	MOVW R26,R30
	MOVW R24,R22
	LDS  R30,_tire_dim
	LDS  R31,_tire_dim+1
	LDS  R22,_tire_dim+2
	LDS  R23,_tire_dim+3
	RCALL __CDF1U
	RCALL __MULF12
	__GETD2N 0x40C00000
	RCALL __MULF12
	MOVW R26,R30
	MOVW R24,R22
	__GETD1N 0x461C4000
	RCALL __DIVF21
	LDI  R26,LOW(_speed_rpm)
	LDI  R27,HIGH(_speed_rpm)
	RCALL __CFD1U
	RCALL __PUTDP1
; 0000 016A 
; 0000 016B         if (steer_wheel==0){
	LDS  R30,_steer_wheel
	LDS  R31,_steer_wheel+1
	LDS  R22,_steer_wheel+2
	LDS  R23,_steer_wheel+3
	RCALL __CPD10
	BREQ PC+2
	RJMP _0x29
; 0000 016C             if (speed_ecu==speed_ecu_prev){
	LDS  R30,_speed_ecu_prev
	LDS  R31,_speed_ecu_prev+1
	LDS  R22,_speed_ecu_prev+2
	LDS  R23,_speed_ecu_prev+3
	LDS  R26,_speed_ecu
	LDS  R27,_speed_ecu+1
	LDS  R24,_speed_ecu+2
	LDS  R25,_speed_ecu+3
	RCALL __CPD12
	BREQ PC+2
	RJMP _0x2A
; 0000 016D                 if (cycle==3){
	LDS  R26,_cycle
	LDS  R27,_cycle+1
	LDS  R24,_cycle+2
	LDS  R25,_cycle+3
	__CPD2N 0x3
	BRNE _0x2B
; 0000 016E                      if (freq1c>(freq2c+30))
	RCALL SUBOPT_0x12
	RCALL SUBOPT_0x17
	RCALL SUBOPT_0x16
	RCALL __CPD12
	BRSH _0x2C
; 0000 016F                         LT='1';
	LDI  R30,LOW(49)
	MOV  R5,R30
; 0000 0170                      else if (freq2c>(freq1c+30))
	RJMP _0x2D
_0x2C:
	RCALL SUBOPT_0x10
	RCALL SUBOPT_0x17
	RCALL SUBOPT_0x18
	RCALL __CPD12
	BRSH _0x2E
; 0000 0171                         RT='1';
	LDI  R30,LOW(49)
	MOV  R4,R30
; 0000 0172                      else if (speed_rpm>speed_ecu+5){
	RJMP _0x2F
_0x2E:
	RCALL SUBOPT_0x19
	__ADDD1N 5
	LDS  R26,_speed_rpm
	LDS  R27,_speed_rpm+1
	LDS  R24,_speed_rpm+2
	LDS  R25,_speed_rpm+3
	RCALL __CPD12
	BRSH _0x30
; 0000 0173                         LT='1';
	LDI  R30,LOW(49)
	MOV  R5,R30
; 0000 0174                         RT='1';
	MOV  R4,R30
; 0000 0175                      }
; 0000 0176                      else
	RJMP _0x31
_0x30:
; 0000 0177                         cycle=0;
	RCALL SUBOPT_0x1A
; 0000 0178                 }
_0x31:
_0x2F:
_0x2D:
; 0000 0179                 else{
	RJMP _0x32
_0x2B:
; 0000 017A                     cycle=cycle+1;
	LDS  R30,_cycle
	LDS  R31,_cycle+1
	LDS  R22,_cycle+2
	LDS  R23,_cycle+3
	RCALL SUBOPT_0x7
	STS  _cycle,R30
	STS  _cycle+1,R31
	STS  _cycle+2,R22
	STS  _cycle+3,R23
; 0000 017B                 }
_0x32:
; 0000 017C             }
; 0000 017D             else {
	RJMP _0x33
_0x2A:
; 0000 017E                 cycle=0;
	RCALL SUBOPT_0x1A
; 0000 017F             }
_0x33:
; 0000 0180         }
; 0000 0181         else{
	RJMP _0x34
_0x29:
; 0000 0182             cycle=0;
	RCALL SUBOPT_0x1A
; 0000 0183         }
_0x34:
; 0000 0184        if ((freq1c==0&&freq2c==0)||(sp_ecu==0)){
	RCALL SUBOPT_0x16
	RCALL __CPD02
	BRNE _0x36
	RCALL SUBOPT_0x18
	RCALL __CPD02
	BREQ _0x38
_0x36:
	LDI  R26,LOW(_sp_ecu)
	LDI  R27,HIGH(_sp_ecu)
	SBIW R26,0
	BRNE _0x35
_0x38:
; 0000 0185         LT='0';
	LDI  R30,LOW(48)
	MOV  R5,R30
; 0000 0186         RT='0';
	MOV  R4,R30
; 0000 0187         cycle=0;
	RCALL SUBOPT_0x1A
; 0000 0188        }
; 0000 0189         putchar0(LT);
_0x35:
	MOV  R26,R5
	RCALL _putchar0
; 0000 018A         putchar0('L');
	LDI  R26,LOW(76)
	RCALL _putchar0
; 0000 018B         putchar0(RT);
	MOV  R26,R4
	RCALL _putchar0
; 0000 018C         putchar0('R');
	LDI  R26,LOW(82)
	RCALL _putchar0
; 0000 018D 
; 0000 018E         if ((LT=='1')||RT=='1'){
	LDI  R30,LOW(49)
	CP   R30,R5
	BREQ _0x3B
	CP   R30,R4
	BRNE _0x3A
_0x3B:
; 0000 018F             speed_rpm=speed_ecu;
	RCALL SUBOPT_0x19
	STS  _speed_rpm,R30
	STS  _speed_rpm+1,R31
	STS  _speed_rpm+2,R22
	STS  _speed_rpm+3,R23
; 0000 0190         }
; 0000 0191         s=0;
_0x3A:
	RCALL SUBOPT_0x11
; 0000 0192         ltoa(speed_rpm,buffer3);
	LDS  R30,_speed_rpm
	LDS  R31,_speed_rpm+1
	LDS  R22,_speed_rpm+2
	LDS  R23,_speed_rpm+3
	RCALL __PUTPARD1
	LDI  R26,LOW(_buffer3)
	LDI  R27,HIGH(_buffer3)
	RCALL _ltoa
; 0000 0193         while (buffer3[s]!='\0'){
_0x3D:
	RCALL SUBOPT_0x1B
	LD   R30,Z
	CPI  R30,0
	BREQ _0x3F
; 0000 0194                 putchar0(buffer3[s]);
	RCALL SUBOPT_0x1B
	RCALL SUBOPT_0x14
; 0000 0195                 s++;
; 0000 0196         }
	RJMP _0x3D
_0x3F:
; 0000 0197         putchar0('S');
	LDI  R26,LOW(83)
	RCALL _putchar0
; 0000 0198         speed_ecu_prev=speed_ecu;
	RCALL SUBOPT_0x19
	STS  _speed_ecu_prev,R30
	STS  _speed_ecu_prev+1,R31
	STS  _speed_ecu_prev+2,R22
	STS  _speed_ecu_prev+3,R23
; 0000 0199     }
	RJMP _0xD
; 0000 019A }
_0x40:
	RJMP _0x40
; .FEND

	.CSEG
_atoi:
; .FSTART _atoi
	ST   -Y,R27
	ST   -Y,R26
   	ldd  r27,y+1
   	ld   r26,y
__atoi0:
   	ld   r30,x
        mov  r24,r26
	MOV  R26,R30
	RCALL _isspace
        mov  r26,r24
   	tst  r30
   	breq __atoi1
   	adiw r26,1
   	rjmp __atoi0
__atoi1:
   	clt
   	ld   r30,x
   	cpi  r30,'-'
   	brne __atoi2
   	set
   	rjmp __atoi3
__atoi2:
   	cpi  r30,'+'
   	brne __atoi4
__atoi3:
   	adiw r26,1
__atoi4:
   	clr  r22
   	clr  r23
__atoi5:
   	ld   r30,x
    mov  r24,r26
	MOV  R26,R30
	RCALL _isdigit
    mov  r26,r24
   	tst  r30
   	breq __atoi6
   	movw r30,r22
   	lsl  r22
   	rol  r23
   	lsl  r22
   	rol  r23
   	add  r22,r30
   	adc  r23,r31
   	lsl  r22
   	rol  r23
   	ld   r30,x+
   	clr  r31
   	subi r30,'0'
   	add  r22,r30
   	adc  r23,r31
   	rjmp __atoi5
__atoi6:
   	movw r30,r22
   	brtc __atoi7
   	com  r30
   	com  r31
   	adiw r30,1
__atoi7:
   	adiw r28,2
   	ret
; .FEND
_ltoa:
; .FSTART _ltoa
	SBIW R28,4
	RCALL __SAVELOCR4
	MOVW R18,R26
	__GETD1N 0x3B9ACA00
	RCALL SUBOPT_0x1C
	LDI  R16,LOW(0)
	LDD  R26,Y+11
	TST  R26
	BRPL _0x2000003
	__GETD1S 8
	RCALL __ANEGD1
	RCALL SUBOPT_0x1D
	MOVW R26,R18
	__ADDWRN 18,19,1
	LDI  R30,LOW(45)
	ST   X,R30
_0x2000003:
_0x2000005:
	RCALL SUBOPT_0x1E
	RCALL __DIVD21U
	MOV  R17,R30
	CPI  R17,0
	BRNE _0x2000008
	CPI  R16,0
	BRNE _0x2000008
	RCALL SUBOPT_0x1F
	RCALL SUBOPT_0x8
	BRNE _0x2000007
_0x2000008:
	PUSH R19
	PUSH R18
	__ADDWRN 18,19,1
	MOV  R30,R17
	SUBI R30,-LOW(48)
	POP  R26
	POP  R27
	ST   X,R30
	LDI  R16,LOW(1)
_0x2000007:
	RCALL SUBOPT_0x1E
	RCALL __MODD21U
	RCALL SUBOPT_0x1D
	RCALL SUBOPT_0x1F
	__GETD1N 0xA
	RCALL __DIVD21U
	RCALL SUBOPT_0x1C
	__GETD1S 4
	RCALL __CPD10
	BRNE _0x2000005
	MOVW R26,R18
	LDI  R30,LOW(0)
	ST   X,R30
	RCALL __LOADLOCR4
	ADIW R28,12
	RET
; .FEND

	.DSEG

	.CSEG

	.CSEG
_isdigit:
; .FSTART _isdigit
	ST   -Y,R26
    ldi  r30,1
    ld   r31,y+
    cpi  r31,'0'
    brlo isdigit0
    cpi  r31,'9'+1
    brlo isdigit1
isdigit0:
    clr  r30
isdigit1:
    ret
; .FEND
_isspace:
; .FSTART _isspace
	ST   -Y,R26
    ldi  r30,1
    ld   r31,y+
    cpi  r31,' '
    breq isspace1
    cpi  r31,9
    brlo isspace0
    cpi  r31,13+1
    brlo isspace1
isspace0:
    clr  r30
isspace1:
    ret
; .FEND

	.CSEG

	.CSEG

	.DSEG
_freq1c:
	.BYTE 0x4
_freq2c:
	.BYTE 0x4
_speed_rpm:
	.BYTE 0x4
_speed_ecu:
	.BYTE 0x4
_speed_ecu_prev:
	.BYTE 0x4
_tire_dim:
	.BYTE 0x4
_steer_wheel:
	.BYTE 0x4
_i:
	.BYTE 0x4
_j:
	.BYTE 0x4
_dur1:
	.BYTE 0x4
_dur2:
	.BYTE 0x4
_s:
	.BYTE 0x4
_in:
	.BYTE 0x4
_ok:
	.BYTE 0x4
_tr:
	.BYTE 0x4
_sp:
	.BYTE 0x4
_sw:
	.BYTE 0x4
_m:
	.BYTE 0x4
_done:
	.BYTE 0x4
_cycle:
	.BYTE 0x4
_input:
	.BYTE 0x14
_td:
	.BYTE 0x6
_sp_ecu:
	.BYTE 0x6
_st_wh:
	.BYTE 0x6
_buffer1:
	.BYTE 0x6
_buffer2:
	.BYTE 0x6
_buffer3:
	.BYTE 0x6
__seed_G100:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x0:
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 5 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x1:
	__SUBD1N -1
	RCALL __PUTDP1_DEC
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x2:
	LDI  R30,LOW(0)
	LDI  R31,HIGH(0)
	OUT  0x2C+1,R31
	OUT  0x2C,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:6 WORDS
SUBOPT_0x3:
	LDI  R30,LOW(0)
	STS  _m,R30
	STS  _m+1,R30
	STS  _m+2,R30
	STS  _m+3,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x4:
	LDS  R30,_in
	LDS  R31,_in+1
	SUBI R30,LOW(-_input)
	SBCI R31,HIGH(-_input)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x5:
	__GETD1N 0x1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x6:
	LDS  R30,_in
	LDS  R31,_in+1
	LDS  R22,_in+2
	LDS  R23,_in+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 7 TIMES, CODE SIZE REDUCTION:16 WORDS
SUBOPT_0x7:
	__ADDD1N 1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:10 WORDS
SUBOPT_0x8:
	__CPD2N 0x1
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0x9:
	LDS  R30,_m
	LDS  R31,_m+1
	SUBI R30,LOW(-_input)
	SBCI R31,HIGH(-_input)
	LD   R26,Z
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:22 WORDS
SUBOPT_0xA:
	STS  _ok,R30
	STS  _ok+1,R31
	STS  _ok+2,R22
	STS  _ok+3,R23
	LDS  R30,_m
	LDS  R31,_m+1
	LDS  R22,_m+2
	LDS  R23,_m+3
	RCALL SUBOPT_0x7
	STS  _m,R30
	STS  _m+1,R31
	STS  _m+2,R22
	STS  _m+3,R23
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:4 WORDS
SUBOPT_0xB:
	__GETD1N 0x2
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0xC:
	LDS  R30,_m
	LDS  R31,_m+1
	SUBI R30,LOW(-_input)
	SBCI R31,HIGH(-_input)
	LD   R30,Z
	ST   X,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0xD:
	LDI  R26,LOW(500)
	LDI  R27,HIGH(500)
	RCALL _delay_ms
	LDI  R30,LOW(0)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0xE:
	__GETD2N 0x100
	RCALL __MULD12U
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0xF:
	STS  _freq1c,R30
	STS  _freq1c+1,R31
	STS  _freq1c+2,R22
	STS  _freq1c+3,R23
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x10:
	LDS  R30,_freq1c
	LDS  R31,_freq1c+1
	LDS  R22,_freq1c+2
	LDS  R23,_freq1c+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:14 WORDS
SUBOPT_0x11:
	LDI  R30,LOW(0)
	STS  _s,R30
	STS  _s+1,R30
	STS  _s+2,R30
	STS  _s+3,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x12:
	LDS  R30,_freq2c
	LDS  R31,_freq2c+1
	LDS  R22,_freq2c+2
	LDS  R23,_freq2c+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x13:
	LDS  R30,_s
	LDS  R31,_s+1
	SUBI R30,LOW(-_buffer1)
	SBCI R31,HIGH(-_buffer1)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:8 WORDS
SUBOPT_0x14:
	LD   R26,Z
	RCALL _putchar0
	LDI  R26,LOW(_s)
	LDI  R27,HIGH(_s)
	RCALL __GETD1P_INC
	RJMP SUBOPT_0x1

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x15:
	LDS  R30,_s
	LDS  R31,_s+1
	SUBI R30,LOW(-_buffer2)
	SBCI R31,HIGH(-_buffer2)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x16:
	LDS  R26,_freq1c
	LDS  R27,_freq1c+1
	LDS  R24,_freq1c+2
	LDS  R25,_freq1c+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x17:
	__ADDD1N 30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x18:
	LDS  R26,_freq2c
	LDS  R27,_freq2c+1
	LDS  R24,_freq2c+2
	LDS  R25,_freq2c+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 3 TIMES, CODE SIZE REDUCTION:12 WORDS
SUBOPT_0x19:
	LDS  R30,_speed_ecu
	LDS  R31,_speed_ecu+1
	LDS  R22,_speed_ecu+2
	LDS  R23,_speed_ecu+3
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 4 TIMES, CODE SIZE REDUCTION:22 WORDS
SUBOPT_0x1A:
	LDI  R30,LOW(0)
	STS  _cycle,R30
	STS  _cycle+1,R30
	STS  _cycle+2,R30
	STS  _cycle+3,R30
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:3 WORDS
SUBOPT_0x1B:
	LDS  R30,_s
	LDS  R31,_s+1
	SUBI R30,LOW(-_buffer3)
	SBCI R31,HIGH(-_buffer3)
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1C:
	__PUTD1S 4
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1D:
	__PUTD1S 8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:5 WORDS
SUBOPT_0x1E:
	__GETD1S 4
	__GETD2S 8
	RET

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1F:
	__GETD2S 4
	RET

;RUNTIME LIBRARY

	.CSEG
__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

__ADDD12:
	ADD  R30,R26
	ADC  R31,R27
	ADC  R22,R24
	ADC  R23,R25
	RET

__ADDD21:
	ADD  R26,R30
	ADC  R27,R31
	ADC  R24,R22
	ADC  R25,R23
	RET

__ANEGD1:
	COM  R31
	COM  R22
	COM  R23
	NEG  R30
	SBCI R31,-1
	SBCI R22,-1
	SBCI R23,-1
	RET

__CWD1:
	MOV  R22,R31
	ADD  R22,R22
	SBC  R22,R22
	MOV  R23,R22
	RET

__MULD12U:
	MUL  R23,R26
	MOV  R23,R0
	MUL  R22,R27
	ADD  R23,R0
	MUL  R31,R24
	ADD  R23,R0
	MUL  R30,R25
	ADD  R23,R0
	MUL  R22,R26
	MOV  R22,R0
	ADD  R23,R1
	MUL  R31,R27
	ADD  R22,R0
	ADC  R23,R1
	MUL  R30,R24
	ADD  R22,R0
	ADC  R23,R1
	CLR  R24
	MUL  R31,R26
	MOV  R31,R0
	ADD  R22,R1
	ADC  R23,R24
	MUL  R30,R27
	ADD  R31,R0
	ADC  R22,R1
	ADC  R23,R24
	MUL  R30,R26
	MOV  R30,R0
	ADD  R31,R1
	ADC  R22,R24
	ADC  R23,R24
	RET

__DIVD21U:
	PUSH R19
	PUSH R20
	PUSH R21
	CLR  R0
	CLR  R1
	MOVW R20,R0
	LDI  R19,32
__DIVD21U1:
	LSL  R26
	ROL  R27
	ROL  R24
	ROL  R25
	ROL  R0
	ROL  R1
	ROL  R20
	ROL  R21
	SUB  R0,R30
	SBC  R1,R31
	SBC  R20,R22
	SBC  R21,R23
	BRCC __DIVD21U2
	ADD  R0,R30
	ADC  R1,R31
	ADC  R20,R22
	ADC  R21,R23
	RJMP __DIVD21U3
__DIVD21U2:
	SBR  R26,1
__DIVD21U3:
	DEC  R19
	BRNE __DIVD21U1
	MOVW R30,R26
	MOVW R22,R24
	MOVW R26,R0
	MOVW R24,R20
	POP  R21
	POP  R20
	POP  R19
	RET

__MODD21U:
	RCALL __DIVD21U
	MOVW R30,R26
	MOVW R22,R24
	RET

__GETD1P_INC:
	LD   R30,X+
	LD   R31,X+
	LD   R22,X+
	LD   R23,X+
	RET

__PUTDP1:
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	RET

__PUTDP1_DEC:
	ST   -X,R23
	ST   -X,R22
	ST   -X,R31
	ST   -X,R30
	RET

__PUTPARD1:
	ST   -Y,R23
	ST   -Y,R22
	ST   -Y,R31
	ST   -Y,R30
	RET

__CPD10:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	RET

__CPD02:
	CLR  R0
	CP   R0,R26
	CPC  R0,R27
	CPC  R0,R24
	CPC  R0,R25
	RET

__CPD12:
	CP   R30,R26
	CPC  R31,R27
	CPC  R22,R24
	CPC  R23,R25
	RET

__CPD21:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R25,R23
	RET

__ROUND_REPACK:
	TST  R21
	BRPL __REPACK
	CPI  R21,0x80
	BRNE __ROUND_REPACK0
	SBRS R30,0
	RJMP __REPACK
__ROUND_REPACK0:
	ADIW R30,1
	ADC  R22,R25
	ADC  R23,R25
	BRVS __REPACK1

__REPACK:
	LDI  R21,0x80
	EOR  R21,R23
	BRNE __REPACK0
	PUSH R21
	RJMP __ZERORES
__REPACK0:
	CPI  R21,0xFF
	BREQ __REPACK1
	LSL  R22
	LSL  R0
	ROR  R21
	ROR  R22
	MOV  R23,R21
	RET
__REPACK1:
	PUSH R21
	TST  R0
	BRMI __REPACK2
	RJMP __MAXRES
__REPACK2:
	RJMP __MINRES

__UNPACK:
	LDI  R21,0x80
	MOV  R1,R25
	AND  R1,R21
	LSL  R24
	ROL  R25
	EOR  R25,R21
	LSL  R21
	ROR  R24

__UNPACK1:
	LDI  R21,0x80
	MOV  R0,R23
	AND  R0,R21
	LSL  R22
	ROL  R23
	EOR  R23,R21
	LSL  R21
	ROR  R22
	RET

__CFD1U:
	SET
	RJMP __CFD1U0
__CFD1:
	CLT
__CFD1U0:
	PUSH R21
	RCALL __UNPACK1
	CPI  R23,0x80
	BRLO __CFD10
	CPI  R23,0xFF
	BRCC __CFD10
	RJMP __ZERORES
__CFD10:
	LDI  R21,22
	SUB  R21,R23
	BRPL __CFD11
	NEG  R21
	CPI  R21,8
	BRTC __CFD19
	CPI  R21,9
__CFD19:
	BRLO __CFD17
	SER  R30
	SER  R31
	SER  R22
	LDI  R23,0x7F
	BLD  R23,7
	RJMP __CFD15
__CFD17:
	CLR  R23
	TST  R21
	BREQ __CFD15
__CFD18:
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R23
	DEC  R21
	BRNE __CFD18
	RJMP __CFD15
__CFD11:
	CLR  R23
__CFD12:
	CPI  R21,8
	BRLO __CFD13
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R23
	SUBI R21,8
	RJMP __CFD12
__CFD13:
	TST  R21
	BREQ __CFD15
__CFD14:
	LSR  R23
	ROR  R22
	ROR  R31
	ROR  R30
	DEC  R21
	BRNE __CFD14
__CFD15:
	TST  R0
	BRPL __CFD16
	RCALL __ANEGD1
__CFD16:
	POP  R21
	RET

__CDF1U:
	SET
	RJMP __CDF1U0
__CDF1:
	CLT
__CDF1U0:
	SBIW R30,0
	SBCI R22,0
	SBCI R23,0
	BREQ __CDF10
	CLR  R0
	BRTS __CDF11
	TST  R23
	BRPL __CDF11
	COM  R0
	RCALL __ANEGD1
__CDF11:
	MOV  R1,R23
	LDI  R23,30
	TST  R1
__CDF12:
	BRMI __CDF13
	DEC  R23
	LSL  R30
	ROL  R31
	ROL  R22
	ROL  R1
	RJMP __CDF12
__CDF13:
	MOV  R30,R31
	MOV  R31,R22
	MOV  R22,R1
	PUSH R21
	RCALL __REPACK
	POP  R21
__CDF10:
	RET

__ZERORES:
	CLR  R30
	CLR  R31
	MOVW R22,R30
	POP  R21
	RET

__MINRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	SER  R23
	POP  R21
	RET

__MAXRES:
	SER  R30
	SER  R31
	LDI  R22,0x7F
	LDI  R23,0x7F
	POP  R21
	RET

__MULF12:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BREQ __ZERORES
	CPI  R25,0x80
	BREQ __ZERORES
	EOR  R0,R1
	SEC
	ADC  R23,R25
	BRVC __MULF124
	BRLT __ZERORES
__MULF125:
	TST  R0
	BRMI __MINRES
	RJMP __MAXRES
__MULF124:
	PUSH R0
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R17
	CLR  R18
	CLR  R25
	MUL  R22,R24
	MOVW R20,R0
	MUL  R24,R31
	MOV  R19,R0
	ADD  R20,R1
	ADC  R21,R25
	MUL  R22,R27
	ADD  R19,R0
	ADC  R20,R1
	ADC  R21,R25
	MUL  R24,R30
	RCALL __MULF126
	MUL  R27,R31
	RCALL __MULF126
	MUL  R22,R26
	RCALL __MULF126
	MUL  R27,R30
	RCALL __MULF127
	MUL  R26,R31
	RCALL __MULF127
	MUL  R26,R30
	ADD  R17,R1
	ADC  R18,R25
	ADC  R19,R25
	ADC  R20,R25
	ADC  R21,R25
	MOV  R30,R19
	MOV  R31,R20
	MOV  R22,R21
	MOV  R21,R18
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	POP  R0
	TST  R22
	BRMI __MULF122
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	RJMP __MULF123
__MULF122:
	INC  R23
	BRVS __MULF125
__MULF123:
	RCALL __ROUND_REPACK
	POP  R21
	RET

__MULF127:
	ADD  R17,R0
	ADC  R18,R1
	ADC  R19,R25
	RJMP __MULF128
__MULF126:
	ADD  R18,R0
	ADC  R19,R1
__MULF128:
	ADC  R20,R25
	ADC  R21,R25
	RET

__DIVF21:
	PUSH R21
	RCALL __UNPACK
	CPI  R23,0x80
	BRNE __DIVF210
	TST  R1
__DIVF211:
	BRPL __DIVF219
	RJMP __MINRES
__DIVF219:
	RJMP __MAXRES
__DIVF210:
	CPI  R25,0x80
	BRNE __DIVF218
__DIVF217:
	RJMP __ZERORES
__DIVF218:
	EOR  R0,R1
	SEC
	SBC  R25,R23
	BRVC __DIVF216
	BRLT __DIVF217
	TST  R0
	RJMP __DIVF211
__DIVF216:
	MOV  R23,R25
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH R20
	CLR  R1
	CLR  R17
	CLR  R18
	CLR  R19
	MOVW R20,R18
	LDI  R25,32
__DIVF212:
	CP   R26,R30
	CPC  R27,R31
	CPC  R24,R22
	CPC  R20,R17
	BRLO __DIVF213
	SUB  R26,R30
	SBC  R27,R31
	SBC  R24,R22
	SBC  R20,R17
	SEC
	RJMP __DIVF214
__DIVF213:
	CLC
__DIVF214:
	ROL  R21
	ROL  R18
	ROL  R19
	ROL  R1
	ROL  R26
	ROL  R27
	ROL  R24
	ROL  R20
	DEC  R25
	BRNE __DIVF212
	MOVW R30,R18
	MOV  R22,R1
	POP  R20
	POP  R19
	POP  R18
	POP  R17
	TST  R22
	BRMI __DIVF215
	LSL  R21
	ROL  R30
	ROL  R31
	ROL  R22
	DEC  R23
	BRVS __DIVF217
__DIVF215:
	RCALL __ROUND_REPACK
	POP  R21
	RET

_delay_ms:
	adiw r26,0
	breq __delay_ms1
__delay_ms0:
	wdr
	__DELAY_USW 0x7D0
	sbiw r26,1
	brne __delay_ms0
__delay_ms1:
	ret

;END OF CODE MARKER
__END_OF_CODE:
