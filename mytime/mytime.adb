with Ada.Calendar;
with Ada.Calendar.Time_Zones;
with Ada.Calendar.Formatting;

with X11; use X11;
with X11.Label; use X11.Label;
with X11.Window; use X11.Window;
with X11.Button; use X11.Button;
with X11.Text_Box; use X11.Text_Box;
with X11.Panel; use X11.Panel;
with X11.Panel.Layout.Horizontal;
with X11.Panel.Layout.Vertical;
with X11.Panel.Layout.Grid;
with X11.Collections.List;
with X11.Color; use X11.Color;

package body MyTime is
   package Time renames Ada.Calendar;
   package Time_Zones renames Ada.Calendar.Time_Zones;

   win         : Window_Type;
   output      : Text_Box_Type;
   top_row     : Panel_Type;


   procedure Get_Current_Date(object : in out Object_Type'class) is
      current_time : String := Time.Formatting.Image(Time.Clock, Time_Zone => 480);
   begin
      Set_Text(Text_Box_Type(object), current_time);
   end Get_Current_Date;

   procedure Run is
      time_zone_config : Integer := 8;
      time_offset : Time_Zones.Time_Offset := Time_Zones.Time_Offset(60 * time_zone_config);
   begin
      X11.Panel.Layout.Vertical.Manage(win);
      Set_Title(win, "現在時間");

      -- Set up the output display
      Set_Text(output, Time.Formatting.Image(Time.Clock, Time_Zone => time_offset));
      Set_Background(output, White_Color);
      Set_Editable(output, false);
      Set_Alignment(output, Center_Right);
      Add_Timer(Get_Current_Date'Access, output, 1000);
      Add(win, output);

      -- Set up the top row of buttons
      X11.Panel.Layout.Horizontal.Manage(top_row);
      Add(win, top_row);

      Show(win);
      X11.Run;
   end Run;
end MyTime;
