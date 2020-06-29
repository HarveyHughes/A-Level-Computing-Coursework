unit UOptionsmenu;

interface


uses
 Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.DateUtils,
  System.Classes, Vcl.Graphics,udeckpicker,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, generics.collections,
  Vcl.StdCtrls;

 type
 Optionsmenu=class
    Lables: tobjectlist<tlabel>;
    Answer:tcheckbox;
    Edits:tobjectlist<tedit>;
    buttons:tobjectlist<tbutton>;
    constructor create(panel:tpanel);
    Procedure CreateLabel(panel:tpanel;Top, left, Width, height, size: integer;
      caption: string; ali: char);
       Procedure CreateButton(panel:tpanel;Top, left, Width, height: integer; caption: string;
      click: tnotifyevent);
    Procedure CreateEdit(panel: tpanel; Top, left, Width, height: integer;
      caption: string; ali: char);
     destructor free;
     procedure updateanswer(sender:tobject);
     procedure onnamechange(sender:tobject);

 end;

 function getanswer:boolean;

implementation

uses UDM;

function getanswer: boolean;
begin
  with dm.Achievementset do
  begin
    Close;
    CommandText := ('Select Answer from Achievements ');
    open;
    result := FieldValues['Answer']  ;
    close;
  end;
end;

function getname: string;
begin
  with dm.Achievementset do
  begin
    Close;
    CommandText := ('Select * from Achievements ');
    open;
    result := FieldValues['UserID']  ;
    close;
  end;
end;
{ mainstats }

constructor optionsmenu.create(panel: tpanel);
var
numbers:ratingstats;
prog,cards,correctstreak,currentstreak,badges,name:string;
an:boolean;
begin

lables:=tobjectlist<tlabel>.create;
buttons:=tobjectlist<tbutton>.create;
edits:=tobjectlist<tedit>.create;
an:=getanswer;
createlabel(panel,50,30,60,20,10,'Do you want to give answers?','l');
  answer := tcheckbox.create(panel);
  answer.Parent := panel;
  answer.left := 250;
  answer.top := 50;
  answer.Height := 20;
  answer.width := 20;
  answer.caption := '';
  answer.Visible := true;
  answer.checked := an;
  answer.OnClick:=updateanswer;
createlabel(panel,150,30,60,20,10,'User name : ','l');
 name:=getname;
createedit(panel,150,110,100,20,name,'l');
createbutton(panel,150,230,60,20,'Change',onnamechange);

end;

procedure Optionsmenu.CreateButton(panel:tpanel;Top, left, Width, height: integer;
  caption: string; click: tnotifyevent);
 var
  B: tbutton;
begin
  B := tbutton.create(panel);
  buttons.add(B);
  B.Parent := panel;
  B.Top := Top;
  B.left := left;
  B.Width := Width;
  B.height := height;
  B.caption := caption;
  B.Visible := true;
  B.OnClick := click;
end;


procedure Optionsmenu.CreateEdit(panel: tpanel; Top, left, Width,
  height: integer; caption: string; ali: char);
var
  E: tedit;
begin
  E := tedit.create(panel);
  Edits.add(E);
  E.Parent := panel;
  E.Top := Top;
  E.MaxLength := 255;
  if ali = 'l' then
  begin
    E.left := left;
    E.Width := Width;
    E.height := height;
    E.text := caption;
  end
  else if ali = 'c' then
  begin
    E.text := caption;
    E.Width := Width;
    E.height := height;
    E.left := (panel.Width - E.Width) div 2;
  end;
  E.Visible := true;
  E.Enabled := true;
end;

procedure optionsmenu.CreateLabel(panel:tpanel ;Top, left, Width, height, size: integer;
  caption: string; ali: char);      //creates a label
var
  l: tlabel;
begin
  l := tlabel.create(panel);
  Lables.add(l);
  l.Parent := panel;
  l.Top := Top;
  l.Font.Size:=size;
  if ali = 'l' then
  begin
    l.left := left;
    l.Width := Width;
    l.height := height;
    l.caption := caption;
  end
  else if ali = 'c' then
  begin
    l.caption := caption;
    l.left := (panel.Width - l.Width) div 2;
  end;
  l.Visible := true;
end;

destructor optionsmenu.free;
begin
  if lables <> nil then
  begin
    lables.free;
    lables := nil;
  end;
   if buttons <> nil then
  begin
    buttons.free;
    buttons := nil;
  end;
   if edits <> nil then
  begin
    edits.free;
    edits := nil;
  end;
  answer.Free;
  answer:=nil;

end;

procedure Optionsmenu.onnamechange(sender: tobject);
begin
if edits[0].Text<>'' then
begin
 with dm.Achievementset do
  begin
    Close;
    CommandText := ('Select UserID from Achievements ');
    open;
    edit;
    FieldValues['UserID']    :=edits[0].text;
    post;
    close;
  end;
end
else
showmessage('Please Enter a Valid Name');
end;

procedure Optionsmenu.updateanswer(sender: tobject);     //updates the database
var
an:boolean;
begin
an:=(sender as tcheckbox).Checked;
with dm.achievementset do
  begin
    Close;
    CommandText := ('Select Answer,UserID from Achievements ');
    open;
    edit;
    FieldValues['Answer']    :=an;
    post;
    close;
  end;
end;

end.
