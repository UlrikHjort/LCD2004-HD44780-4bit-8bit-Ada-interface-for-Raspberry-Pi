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
with HD44780;

procedure Main is
   S : constant String := "Hello Ada Pi World! :)";   
   S1 : constant String := "Line # 3 pos 5";
   I : Integer := 0;
   
begin      
   -- Examples of usage of the interface:
   HD44780.Init(HD44780.Bits_4_Lines_4_Dots_5x7);
   HD44780.Set_Cursor_Position(1, 5);
   HD44780.Shift_Cursor_Right(6);   
   HD44780.Home;   
   HD44780.Clear;         
   HD44780.Set_Cursor_Mode(HD44780.BLINK);      
   
   HD44780.Print_String(S);
   HD44780.Print_String_Position(S1,3,5);   
   
   loop
      exit when I = 10;
      delay 1.0;
      HD44780.Print_String_Position(Integer'Image(I),4,10);
      I := I + 1;
   end loop;

end Main;
