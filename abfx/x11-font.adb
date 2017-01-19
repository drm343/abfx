
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Unchecked_Deallocation;

with Interfaces.C; use Interfaces.C;
with Interfaces.C.Strings; use Interfaces.C.Strings;

with Bindings.X11.Functions; use Bindings.X11.Functions;
with Bindings.XFT.Functions; use Bindings.XFT.Functions;
with Bindings.XRender.Types; use Bindings.XRender.Types;

package body X11.Font is

   Default_Font : constant String := "NotoSansCJKtc-16:Regular";

   procedure Free is new Ada.Unchecked_Deallocation(
      Font_Node, Font_Node_Pointer);

   procedure Prepare(node : in Font_Node_Pointer);

   procedure Prepare(node : in Font_Node_Pointer) is
      c_str : chars_ptr;
   begin
      if node.font = null then
         c_str := New_String(Default_Font);
         node.font := XftFontOpenName(display, screen, c_str);
         Free(c_str);
      end if;
   end Prepare;

   procedure Initialize(font : in out Font_Type) is
   begin
      font.node := new Font_Node;
   end Initialize;

   procedure Finalize(font : in out Font_Type) is
   begin
      if font.node /= null then
         font.node.count := font.node.count - 1;
         if font.node.count = 0 then
            if font.node.font /= null then
               XftFontClose(display, font.node.font);
            end if;
            Free(font.node);
         end if;
         font.node := null;
      end if;
   end Finalize;

   procedure Adjust(font : in out Font_Type) is
   begin
      font.node.count := font.node.count + 1;
   end Adjust;

   function Get_Width(font : Font_Type; str : String) return Natural is
       function strlenUTF8(item: string) return Integer is
           source_char : Integer;
           skip : Integer := 0;
           count : Integer := 0;
       begin
           for i in Integer range 1 .. item'Length loop
               source_char := Character'Pos(item(i));
               if skip >= 1 then
                   skip := skip - 1;
                   goto Continue;
               end if;

               if source_char >= 2#1111_1100# then
                   skip := 5;
               elsif source_char >= 2#1111_1000# then
                   skip := 4;
               elsif source_char >= 2#11110000# then
                   skip := 3;
               elsif source_char >= 2#11100000# then
                   skip := 2;
               elsif source_char >= 2#11000000# then
                   skip := 1;
               elsif source_char < 2#10000000# then
                   skip := 0;
                   count := count - 1;
               end if;
               count := count + 2;
               <<Continue>>
           end loop;

           return count;
       end strlenUTF8;

      c_str   : chars_ptr;
      extents : aliased XGlyphInfo_Type;
   begin
      Prepare(font.node);
      c_str := New_String(str);
      XftTextExtents8(display, font.node.font, c_str, int(strlenUTF8(str)),
         extents'unrestricted_access);
      Free(c_str);
      return Natural(extents.width);
   end Get_Width;

   function Get_Height(font : Font_Type) return Natural is
   begin
      Prepare(font.node);
      return Natural(font.node.font.ascent) + Natural(font.node.font.descent);
   end Get_Height;

   function Get_Ascent(font : Font_Type) return Natural is
   begin
      Prepare(font.node);
      return Natural(font.node.font.ascent);
   end Get_Ascent;

   function Get_Descent(font : Font_Type) return Natural is
   begin
      Prepare(font.node);
      return Natural(font.node.font.descent);
   end Get_Descent;

   function Get_Font_Data(font : Font_Type) return XftFont_Pointer is
   begin
      Prepare(font.node);
      return font.node.font;
   end Get_Font_Data;

end X11.Font;

