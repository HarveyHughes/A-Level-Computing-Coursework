unit UBadges;

interface
uses
Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;
type

TBadges=class
    private

    public
    badge:Tpanel;
    image:timage;
    Name,Progress:tlabel;
    constructor create(mpanel:tpanel; top, left:integer;Locked :boolean;title,prog:string);
    destructor free;
  end;

implementation

{ TBadges }

constructor TBadges.create(mpanel:tpanel; top, left:integer; Locked:boolean;Title, Prog:string );
begin
  badge:=tpanel.Create(mpanel);
  badge.Parent:=mpanel;
  badge.Top:=top;
  badge.Left:=left;
  badge.Height:=150;
  badge.Width:=100;
  badge.Visible:=true;

  Image:=timage.Create(badge);
  Image.Parent:=badge;
  image.Width:=90;
  image.Left:=5;
  image.Top :=16;
  image.Height:=120;
  image.Visible:=true;
  if locked=true then
  begin
  image.Picture.loadfromfile('LockedBadge.bmp');
  badge.parentbackground:=false;
  badge.Color:=clmaroon;
  end;
  if locked=false then
  begin
  image.picture.loadfromfile('Unlockedbadge.bmp');
  badge.Parentbackground:=false;
  badge.Color:=clgreen;
  end;

  name:=tlabel.Create(badge);
  name.Parent:=badge;
  name.Top :=0;
  name.Height:=15;
  name.Visible:=true;
  name.Font.Size:=7;
  name.Font.Color:=clwhite;
  name.Font.Name:='Comic sans MS';
  name.Font.style:=[fsUnderline] ;
  name.caption:=title;
  name.left:=(badge.Width-name.Width) div 2;

  progress:=tlabel.Create(badge);
  progress.Parent:=badge;
  progress.Top :=135;
  progress.Height:=15;
  progress.Visible:=true;
  progress.Font.Size:=8;
  progress.Font.Color:=clwhite;
  progress.Font.Name:='Comic sans MS';
  progress.caption:=prog;
  progress.left:=(badge.Width-progress.Width) div 2;
end;

destructor TBadges.free;
begin
 name.free;
name:=nil;
progress.free;
progress:=nil;
image.free;
image:=nil;
badge.Free;
badge:=nil;

end;

end.
