# 4bit/8bit HD44780 LCD2004 Ada interface for Raspberry Pi

Ada Interface for Raspberry Pi for controlling a LCD2004 HD44780 (4 lines of 20 5*7 characters) display.


## Hardware:
* Raspberry Pi 3 Model B v1.2
* LCD2004 HD44780 4x20 5x7 LCD display

## Wiring:
| LCD2004 HD44780 PIN  |  Raspberry Pi PIN |
| --- | --- |
|D0 | GPIO9 |
|D1 | GPIO10 |
|D2 | GPIO22 |
|D3 | GPIO27 |
|D4 | GPIO17 (See note 1. below) |
|D5 | GPIO4  (See note 1. below) |
|D6 | GPIO3  (See note 1. below) |
|D7 | GPIO2  (See note 1. below) |
|E  (Clock Enable )| GPIO23 |
|RS (Register Select ) | GPIO25 |
|RW (Read/Write  ) | GND (See note 2. below)|
|VCC   | +5V from Raspberry Pi (See note 3. below)|



* Note1: In 4 bit mode only pins D4 .. D7 on HD44780 are used.
* Note2: RW Pulled low to GND since we only write to the display.
* Note3: Display VCC is +5V from Raspberry Pi but interface voltage is +3.3V (No level converting is needed)

## Usage:
* See HD44780 spec (hd44780.ads) for interface description
* See main.adb for examlpes of usage
* See HD44780 datasheet for detailed information about commands etc.
* Use Gnat Ada version >= Ada2012
