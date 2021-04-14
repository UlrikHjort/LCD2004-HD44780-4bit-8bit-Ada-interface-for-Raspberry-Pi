---------------------------------------------------------------------------
--            Raspberry Pi LCD2004 HD44780 interface
-- 
--           Copyright (C) 2021 By Ulrik Hørlyk Hjort
--
--  This Program is Free Software; You Can Redistribute It and/or
--  Modify It Under The Terms of The GNU General Public License
--  As Published By The Free Software Foundation; Either Version 2
--  of The License, or (at Your Option) Any Later Version.
--
--  This Program is Distributed in The Hope That It Will Be Useful,
--  But WITHOUT ANY WARRANTY; Without Even The Implied Warranty of
--  MERCHANTABILITY or FITNESS for A PARTICULAR PURPOSE.  See The
--  GNU General Public License for More Details.
--
-- You Should Have Received A Copy of The GNU General Public License
-- Along with This Program; if not, See <Http://Www.Gnu.Org/Licenses/>.
---------------------------------------------------------------------------
with Gpio_RaspberryPi;
with Interfaces;

package body HD44780 is
   
   package Gpio renames Gpio_RaspberryPi;    
   
   -------------------------------------------------------------
   --
   -- Constants: 
   --
   -------------------------------------------------------------      
   PIN_D0 : constant Integer := 9;
   PIN_D1 : constant Integer := 10;
   PIN_D2 : constant Integer := 22;
   PIN_D3 : constant Integer := 27;
   PIN_D4 : constant Integer := 17;
   PIN_D5 : constant Integer := 4;
   PIN_D6 : constant Integer := 3;
   PIN_D7 : constant Integer := 2;
   
   PIN_RS : constant Integer := 25;   
   PIN_E  : constant Integer := 23;      
   
   LINE_1 : constant Byte := 16#80#;
   LINE_2 : constant Byte := 16#C0#;   
   LINE_3 : constant Byte := 16#94#;      
   LINE_4 : constant Byte := 16#D4#;         
   
   LINE_LENGTH : constant Integer  := 20;
   
   ENABLE_DELAY : constant Duration := 0.0004;
   
   
   -------------------------------------------------------------
   --
   -- HD44780 Commands: 
   --
   -------------------------------------------------------------   
   CMD_ENTRY_MODE                     : constant Byte := 16#06#;
   CMD_BITS_4_LINES_2_DOTS_5X7        : constant Byte := 16#20#;
   CMD_BITS_4_LINES_4_DOTS_5X7        : constant Byte := 16#28#;
   CMD_BITS_8_LINES_2_DOTS_5X7        : constant Byte := 16#30#;
   CMD_BITS_8_LINES_4_DOTS_5X7        : constant Byte := 16#38#;
   CMD_DISPLAY_ON_CURSOR_NO_BLINK     : constant Byte := 16#0E#;      
   CMD_DISPLAY_ON_CURSOR_BLINK        : constant Byte := 16#0F#;            
   CMD_DISPLAY_ON_CURSOR_OFF          : constant Byte := 16#0C#;
   CMD_DISPLAY_OFF_CURSOR_OFF         : constant Byte := 16#08#;   
   CMD_SHIFT_ENTIRE_DISPLAY_LEFT      : constant Byte := 16#18#;   
   CMD_SHIFT_ENTIRE_DISPLAY_RIGHT     : constant Byte := 16#1C#;      
   CMD_CURSOR_HOME                    : constant Byte := 16#02#;            
   CMD_CURSOR_LEFT_ONE_CHAR           : constant Byte := 16#10#;   
   CMD_CURSOR_RIGHT_ONE_CHAR          : constant Byte := 16#14#;         
   CMD_CLEAR_DISPLAY_AND_DRAM_CONTENT : constant Byte := 16#01#;      
   
   -------------------------------------------------------------
   --
   -- Globals:
   --
   -------------------------------------------------------------      
   Mode_Cmd : Byte := CMD_BITS_8_LINES_2_DOTS_5X7;
      
   Mode_8_Bit : Boolean := True;
   
   ---------------------------------------------------------
   -- Local methods:
   ---------------------------------------------------------         
      
   ---------------------------------------------------------
   --
   -- Set D0 .. D7 pins according to the data/command being send
   -- (D4 .. D7 pins in 4 bit mode)
   --
   ---------------------------------------------------------   
   procedure Set_Pins(Data : Byte) is
      
      use Interfaces; -- For operator for interfaces types
      
   begin
      if Mode_8_Bit then
	 Gpio.Digital_Write(PIN_D0,Integer(Data and 16#01#));
	 Gpio.Digital_Write(PIN_D1,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),1) and 16#01#));            
	 Gpio.Digital_Write(PIN_D2,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),2) and 16#01#));      
	 Gpio.Digital_Write(PIN_D3,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),3) and 16#01#));
      
	 Gpio.Digital_Write(PIN_D4,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),4) and 16#01#));                        
	 Gpio.Digital_Write(PIN_D5,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),5) and 16#01#));                        
	 Gpio.Digital_Write(PIN_D6,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),6) and 16#01#));                        
	 Gpio.Digital_Write(PIN_D7,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),7) and 16#01#));    
      else
	 Gpio.Digital_Write(PIN_D4,Integer(Data and 16#01#));
	 Gpio.Digital_Write(PIN_D5,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),1) and 16#01#));            
	 Gpio.Digital_Write(PIN_D6,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),2) and 16#01#));      
	 Gpio.Digital_Write(PIN_D7,Integer(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),3) and 16#01#));	 
      end if;      
   end Set_Pins;
        
   ---------------------------------------------------------
   --
   -- Fetch data from D0 .. D7 pins set by Set_Pins
   --
   ---------------------------------------------------------      
   procedure Write is
     
   begin
      delay ENABLE_DELAY;      
      Gpio.Digital_Write(PIN_E,Gpio.High);
      delay ENABLE_DELAY;
      Gpio.Digital_Write(PIN_E,Gpio.Low);
   end Write;
   
   
   ---------------------------------------------------------
   --
   -- Write a command to the display
   --
   ---------------------------------------------------------      
   procedure Write_Cmd(Cmd : Byte) is
      
   begin
      Gpio.Digital_Write(PIN_RS,Gpio.Low);
      if Mode_8_Bit then
	 Set_Pins(Cmd);
	 Write;                                    	 
      else
	 Set_Pins(Byte(Interfaces.Shift_Right(Interfaces.Unsigned_8(Cmd),4)));	 
	 Write;
	 Set_Pins(16#F# and Cmd); 
	 Write;                                    	 	 		  
      End if;
   end Write_Cmd;
   
   
   ---------------------------------------------------------
   --
   -- Write data to the display
   --
   ---------------------------------------------------------      
   procedure Write_Data(Data : Byte) is      
      
   begin      
      Gpio.Digital_Write(PIN_RS,Gpio.High);      
      if Mode_8_Bit then
	 Set_Pins(Data);
	 Write;                                    	 
      else
	 Set_Pins(Byte(Interfaces.Shift_Right(Interfaces.Unsigned_8(Data),4)));	 
	 Write; 
	 Set_Pins(16#F# and Data); 
	 Write;                                    	 	 		  	 
      End if;      
   end Write_Data;   
   
   ---------------------------------------------------------
   -- Global methods:
   ---------------------------------------------------------         
   
   ---------------------------------------------------------
   --
   -- Init display
   --
   ---------------------------------------------------------      
   procedure Init(Mode : Modes) is

   begin
      
      Gpio.Export(PIN_D0);
      Gpio.Set_Pin_Mode(PIN_D0,Gpio.Mode_Out);    
      
      Gpio.Export(PIN_D1);
      Gpio.Set_Pin_Mode(PIN_D1,Gpio.Mode_Out);    
      
      Gpio.Export(PIN_D2);
      Gpio.Set_Pin_Mode(PIN_D2,Gpio.Mode_Out);    
      
      Gpio.Export(PIN_D3);
      Gpio.Set_Pin_Mode(PIN_D3,Gpio.Mode_Out);    
      
      Gpio.Export(PIN_D4);
      Gpio.Set_Pin_Mode(PIN_D4,Gpio.Mode_Out);    
      
      Gpio.Export(PIN_D5);
      Gpio.Set_Pin_Mode(PIN_D5,Gpio.Mode_Out);    
      
      Gpio.Export(PIN_D6);
      Gpio.Set_Pin_Mode(PIN_D6,Gpio.Mode_Out);    
      
      Gpio.Export(PIN_D7);
      Gpio.Set_Pin_Mode(PIN_D7,Gpio.Mode_Out);          
      
      Gpio.Export(PIN_RS);
      Gpio.Set_Pin_Mode(PIN_RS,Gpio.Mode_Out);          
      
      Gpio.Export(PIN_E);
      Gpio.Set_Pin_Mode(PIN_E,Gpio.Mode_Out);                
            
      Gpio.Digital_Write(PIN_RS,Gpio.Low);
            			
      case Mode is
         when Bits_4_Lines_2_Dots_5x7 => 
	    Mode_Cmd := CMD_BITS_4_LINES_2_DOTS_5X7;
	    Mode_8_Bit := False;
         when Bits_4_Lines_4_Dots_5x7 => 
	    Mode_Cmd := CMD_BITS_4_LINES_4_DOTS_5X7;
	    Mode_8_Bit := False;
         when Bits_8_Lines_2_Dots_5x7 => 
	    Mode_Cmd := CMD_BITS_8_LINES_2_DOTS_5X7;
	    Mode_8_Bit := True;
         when Bits_8_Lines_4_Dots_5x7 => 
	    Mode_Cmd := CMD_BITS_8_LINES_4_DOTS_5X7; 
	    Mode_8_Bit := True;
         when others => null;
      end case;      
      
      if Mode_8_Bit  then
	 Write_Cmd(CMD_ENTRY_MODE);      
	 Write_Cmd(CMD_DISPLAY_ON_CURSOR_BLINK);
	 Write_Cmd(Mode_Cmd);
	 Write_Cmd(CMD_CLEAR_DISPLAY_AND_DRAM_CONTENT);      
      else
	 -- 8 bit mode is set temporary in 4 bit init phase
	 -- to force only one write pr. cmd. 8 bit writing ise used
	 -- but only upper nibble of the command byte is used so it 
	 -- is an safe operation.
	 Mode_8_Bit := True; 
	 
	 -- Init sequence to get into a defined state (see datasheet for details)
	 Write_Cmd(CMD_BITS_8_LINES_2_DOTS_5X7);      
	 delay 0.01;      
	 Write_Cmd(CMD_BITS_8_LINES_2_DOTS_5X7);      
	 delay 0.01;      
	 Write_Cmd(CMD_BITS_8_LINES_2_DOTS_5X7);            
	 delay 0.01;      
	 Write_Cmd(CMD_BITS_4_LINES_2_DOTS_5X7); 
	 
	 -- 4 bit mode ready so we can go into 4 bit writing mode now.
	 Mode_8_Bit := False;
	 Write_Cmd(Mode_Cmd); 
	 Write_Cmd(CMD_CLEAR_DISPLAY_AND_DRAM_CONTENT);      	 
      end if;
   end Init;
   
   
   ---------------------------------------------------------
   --
   -- Print string S on the display
   --
   ---------------------------------------------------------      
   procedure Print_String(S : String) is 
      J : Integer := 0;      
      
   begin
      J := 1;
      Write_Cmd(Line_1);
	for I in S'First .. S'Last loop
	if J = 20 then
	   Write_Cmd(Line_2);
	end if;
	J := J +1;
	 Write_Data(Character'Pos(S(I)));
      end loop;      
   end Print_String;
   
   
   ---------------------------------------------------------
   --
   -- Print string S on the display at position S at line L 
   --
   ---------------------------------------------------------      
   procedure Print_String_Position(S : String; L : Line; Pos : Position) is 
      
   begin
      Set_Cursor_Position(L,Pos);
      for I in S'First .. S'Last loop
         Write_Data(Character'Pos(S(I)));
      end loop;      
   end Print_String_Position;   
   
   
   ---------------------------------------------------------
   --
   -- Set cursor mode (BLINK, NO_BLINK, OFF) 
   --
   ---------------------------------------------------------      
   procedure Set_Cursor_Mode(Cursor : Cursor_Mode) is
      
   begin      
      case Cursor is
         when NO_BLINK => 
	    Write_Cmd(CMD_DISPLAY_ON_CURSOR_NO_BLINK);
         when BLINK => 
	    Write_Cmd(CMD_DISPLAY_ON_CURSOR_BLINK);	    
	 when OFF =>
	    Write_Cmd(CMD_DISPLAY_ON_CURSOR_OFF);
      end case;      
   end Set_Cursor_Mode;
   
   
   ---------------------------------------------------------
   --
   -- Set cursor positon Pos at line L 
   --
   ---------------------------------------------------------      
   procedure Set_Cursor_Position(L : Line; Pos : Position) is
      
   begin
      case L is 
	 when 1 =>
	    Write_Cmd(LINE_1 + Pos); 	 
	 when 2 =>  
	    Write_Cmd(LINE_2 + Pos); 	 	    
	 when 3 =>
	    Write_Cmd(LINE_3 + Pos); 	 
	 when 4 =>  
	    Write_Cmd(LINE_4 + Pos); 	 	    	    
      end case;
   end Set_Cursor_Position;
   
   
   ---------------------------------------------------------
   --
   -- Shift cursor position left N places
   --
   ---------------------------------------------------------      
   procedure Shift_Cursor_Left(N : Natural) is
      
      I : Natural := 0;
   begin
      loop
	 exit when I = N;
	 I := I + 1;
	 Write_Cmd(CMD_CURSOR_LEFT_ONE_CHAR); 	 	    	 
      end loop;      
   end Shift_Cursor_Left;
   
   
   ---------------------------------------------------------
   --
   -- Shift cursor position right N places      
   --
   ---------------------------------------------------------      
   procedure Shift_Cursor_Right(N : Natural) is
      
      I : Natural := 0;            
   begin
      loop
	 exit when I = N;
	 I := I + 1;
	 Write_Cmd(CMD_CURSOR_RIGHT_ONE_CHAR); 	 	    	 
      end loop;      
   end Shift_Cursor_Right;      
   
   
   ---------------------------------------------------------
   --
   -- Set cursor position to "home"
   --
   ---------------------------------------------------------      
   procedure Home is
   begin
      Write_Cmd(CMD_CURSOR_HOME);
   end Home;   
   
   
   ---------------------------------------------------------
   --
   -- Clear display
   --
   ---------------------------------------------------------      
   procedure Clear is
   begin
      Write_Cmd(CMD_CLEAR_DISPLAY_AND_DRAM_CONTENT);      	 
   end Clear;
   
end HD44780;
