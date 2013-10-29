BLE Demo - Simple Controls

A.  General Description

	This demo shows how to create controls from App that read from or write to BLE Shield connected to Arduino board.

B.  System Setup

	Arduino Pins:

	Pin 4 - Digital Output pin, for example, connect to a LED
	Pin 5 - Digital Input pin, connect to a button
	Pin 6 - PWM pin, connect to a LED
	Pin 7 - Servo pin, connect to a Servo
	Pin A5 - Analog Input pin, connect to a variable resistor 

C.  System Design

	I. iOS/OS X App
	
	This App provides a simple GUI for controlling or displaying information

	RSSI - Current RSSI reading
	Digital Out - Control Arduino digital output Pin 4
	Digital In - Reading of Arduino digital input Pin 5
	PWM - Control Arduino PWM on Pin 6
	Servo - Control Arduino Servo on Pin 7
	Analog In - Enable reading of Arduino analog input Pin A5
	
	II. Protocol

	App to send:

	Opcode   	Data			Description
	0x01		0x0000			Digital Output Pin - Off
				0x0001			Digital Output Pin - On

	0x02		0x0000 ~ 0x00FF	PWM Value 0 ~ 255
				
	0x03		0x0000 ~ 0x00B4	Servo Value 0 ~ 180

	0xA0		0x0000			Analog Input Reading Disabled
				0x0001			Analog Input Reading Enabled

	App to read:

	0x0A		0x0000			Digital Input Pin - Off
				0x0001			Digital Input Pin - On

	0x0B		0x0000 ~ 0x03FF	Analog Input Value 0 ~ 1023

