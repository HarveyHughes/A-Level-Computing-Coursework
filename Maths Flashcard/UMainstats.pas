unit UMainstats;

interface


uses
 Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.DateUtils,
  System.Classes, Vcl.Graphics,udeckpicker,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, generics.collections,
  Vcl.StdCtrls;

 type
 mainstats=class
    Lables: tobjectlist<tlabel>;
    Card:tdecks;
    constructor create(panel:tpanel);
    Procedure CreateLabel(panel:tpanel;Top, left, Width, height, size: integer;
      caption: string; ali: char);
     destructor free;
    procedure getcardstats(var prog,cards,CORRECTSTREAK,currentstreak,badges,timed:string; var numbers:ratingstats);
 end;

implementation

uses UDM;

{ mainstats }

procedure mainstats.getcardstats(var prog, cards,CORRECTSTREAK,currentstreak,badges,timed: string;
  var numbers: ratingstats);
  var
  n:integer;
begin
with dm.achievementset do
begin
close;
 CommandText := 'Select * from Achievements';
 open;
 prog:=inttostr(fieldvalues['Userknowledge']) +'% Completion';
 cards:=inttostr(fieldvalues['Cardsseen'])+ ' cards seen';
 correctstreak:='Max Correct streak is ' + inttostr(fieldvalues['Correctstreak'])+' cards';
 currentstreak:= 'Current Correct streak is ' + inttostr(fieldvalues['Currentstreak'])+' cards';
 badges:='Achievements unlocked is ' + inttostr(fieldvalues['Achievements']) + ' Badges, out of  ' + inttostr(fieldvalues['badges']) ;   ;
 timed:='High Score for correct flashcards in 30 secs is: ' + inttostr(fieldvalues['timed']) +' Cards' ;
 end;


    for n := 1 to 5 do
     numbers[n]:=0;


    with dm.cardset do
    begin
      Close;
      CommandText := 'Select Userrating from card';
      open;
      first;
      while not eof do
      begin
      n := FieldValues['Userrating'];
      if n <> 0 then
        numbers[n] := numbers[n] + 1;
        next;
      end;
    end;

end;

constructor mainstats.create(panel: tpanel);
var
numbers:ratingstats;
prog,cards,correctstreak,currentstreak,badges,timed:string;
begin
getcardstats(prog,cards,correctstreak,currentstreak,badges,timed,numbers);
card:=tdecks.create(panel,3,2,0,50,'Overall Stats',prog,cards,numbers,'n');
card.choose.Visible:=false;
card.choose.Enabled:=false;
lables:=tobjectlist<tlabel>.create;
createlabel(panel,300,0,0,0,9,badges,'c');
createlabel(panel,350,0,0,0,9,currentstreak,'c');
createlabel(panel,400,0,0,0,9,correctstreak,'c');
createlabel(panel,450,0,0,0,9,timed,'c');

end;

procedure mainstats.CreateLabel(panel:tpanel ;Top, left, Width, height, size: integer;
  caption: string; ali: char);
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

destructor mainstats.free;
begin
  if lables <> nil then
  begin
    lables.free;
    lables := nil;
  end;
  card.free;
  card:=nil;
end;

end.
