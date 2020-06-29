unit UCreatecard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,uflashcard,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, generics.collections,
  Vcl.StdCtrls;

type
  Tcreatemenu = class
  private
  public
    Menu, favpanel, oppanel: tpanel;
    Typ: array [1 .. 4] of tradiobutton;
    fav: array [1 .. 2] of tradiobutton;
    options: array [1 .. 6] of tradiobutton;
    tt: char;
    pid,did,cid:integer;
    Lables: tobjectlist<tlabel>;
    buttons: tobjectlist<tbutton>;
    Edits: tobjectlist<tedit>;
    constructor create(panel: tpanel;packid,deckid,cardid:integer;tyyyy:char);
    Procedure CreateButton(Top, left, Width, height: integer; caption: string;
      click: tnotifyevent);
    Procedure CreateEdit(panel: tpanel; Top, left, Width, height: integer;
      caption: string; ali: char);
    Procedure CreateLabel(Top, left, Width, height, size: integer;
      caption: string; ali: char);
    procedure createform(sender: tobject);
    procedure oncreate(sender: tobject);
    procedure onedit(sender: tobject);
    procedure questionboxes;
    destructor free;
  end;

implementation

{ Tcreatemenu }

uses UDM;

constructor Tcreatemenu.create(panel: tpanel;packid,deckid,cardid:integer;tyyyy:char);
var
  i: integer;
begin
  Menu := tpanel.create(panel);
  Menu.Parent := panel;
  Menu.left := 50;
  Menu.Width := panel.Width - 100;
  Menu.Top := 50;
  Menu.height := panel.height - 100;
  Menu.Visible := true;
  Menu.Parentbackground := false;
  Menu.Color := clmenu;
  Menu.Visible := true;

  pid:=packid;
  did:=deckid;
  cid:=cardid;

  if Lables = nil then
    Lables := tobjectlist<tlabel>.create;
  if buttons = nil then
    buttons := tobjectlist<tbutton>.create;
  if Edits = nil then
    Edits := tobjectlist<tedit>.create;
  CreateLabel(20, (Menu.Width - 20) div 2, 50, 30, 16, 'Create Card', 'c');
  Lables[0].Font.style := [fsbold];
  CreateLabel(Menu.height div 6 - 20, 30, 70, 20, 9,
    'What Kind of Flashcard?', 'l');
  for i := 1 to 4 do
  begin
    Typ[i] := tradiobutton.create(Menu);
    Typ[i].Parent := Menu;
    Typ[i].height := 20;
    Typ[i].Top := Menu.height div 6 + 5;
    Typ[i].Width := 110;
    Typ[i].left := (Menu.Width div 5) * i - 70;
    Typ[i].Visible := true;
    Typ[i].OnClick := createform;
    case i of
      1:
        Typ[i].caption := 'Regular Card';
      2:
        Typ[i].caption := 'Options Card';
      3:
        Typ[i].caption := 'Graph Card';
      4:
        Typ[i].caption := 'Options Graph Card';
    end;
  end;
  CreateLabel(Menu.height div 6 * 5, 30, 70, 20, 9,
    'Favourite this card?', 'l');
  favpanel := tpanel.create(Menu);
  // so that the fav option is a different radio group
  favpanel.Parent := Menu;
  favpanel.left := 30;
  favpanel.Width := Menu.Width div 4;
  favpanel.Top := Menu.height div 6 * 5 + 25;
  favpanel.height := Menu.height - (favpanel.Top + 30);
  favpanel.Visible := true;
  for i := 1 to 2 do
  begin
    fav[i] := tradiobutton.create(favpanel);
    fav[i].Parent := favpanel;
    fav[i].height := 20;
    fav[i].Top := favpanel.height div 2 - 10;
    fav[i].Width := 40;
    fav[i].left := (favpanel.Width div 3) * i - 20;
    fav[i].Visible := true;
    case i of
      1:
        fav[i].caption := 'Yes';
      2:
        fav[i].caption := 'No';
    end;
  end;
  if tyyyy='c' then
  begin
  CreateButton(Menu.height div 6 * 5 + 25, Menu.Width - 80, 50, 30, 'Create',
    oncreate);
  buttons[0].Enabled := false;
  end
  else if tyyyy='e' then
  begin
   CreateButton(Menu.height div 6 * 5 + 25, Menu.Width - 80, 50, 30, 'Edit',
    onedit);
  end;
  end;

procedure Tcreatemenu.CreateButton(Top, left, Width, height: integer;
  caption: string; click: tnotifyevent);
var
  B: tbutton;
begin
  B := tbutton.create(Menu);
  buttons.add(B);
  B.Parent := Menu;
  B.Top := Top;
  B.left := left;
  B.Width := Width;
  B.height := height;
  B.caption := caption;
  B.Visible := true;
  B.OnClick := click;
end;

procedure Tcreatemenu.CreateEdit(panel: tpanel;
  Top, left, Width, height: integer; caption: string; ali: char);
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
    E.left := (Menu.Width - E.Width) div 2;
  end;
  E.Visible := true;
  E.Enabled := true;
end;

procedure Tcreatemenu.createform(sender: tobject);
var
  op: string;
  i: integer;
begin
  if Lables.Count > 3 then // removes any exisiting form menus
  begin
    for i := Lables.Count - 1 downto 3 do
      Lables.Delete(i);
  end;
  if buttons.Count > 1 then // removes any exisiting form buttons
  begin
    for i := buttons.Count - 1 downto 1 do
      buttons.Delete(i);
  end;
  if Edits.Count > 0 then // removes any exisiting form edits
  begin
    for i := Edits.Count - 1 downto 0 do
      Edits.Delete(i);
  end;

  if oppanel <> nil then
  begin
    oppanel.free;
    oppanel := nil;
  end;

  buttons[0].Enabled := true;
  op := (sender as tradiobutton).caption;
  if op = 'Regular Card' then
  begin
    tt := 'f';
    questionboxes;
  end
  else if op = 'Options Card' then
  begin
    tt := 'o';
    questionboxes;
  end
  else if op = 'Graph Card' then
  begin
    tt := 'g';
    questionboxes;
  end
  else if op = 'Options Graph Card' then
  begin
    tt := 't';
    questionboxes;
  end;

end;

procedure Tcreatemenu.CreateLabel(Top, left, Width, height, size: integer;
  caption: string; ali: char);
var
  l: tlabel;
begin
  l := tlabel.create(Menu);
  Lables.add(l);
  l.Parent := Menu;
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
    l.left := (Menu.Width - l.Width) div 2;
  end;
  l.Visible := true;
end;

destructor Tcreatemenu.free;
var
i:integer;
begin
   begin
  if lables <> nil then
  begin
    lables.free;
    lables := nil;
  end;
  if buttons <> nil then
  begin
    for i := (buttons.count - 1) downto 0 do
    begin
      buttons[i].free;
    end;
    buttons := nil;
  end;
  if edits <> nil then
  begin
    for i := (edits.count - 1) downto 0 do
    begin
      edits[i].free;
    end;
    edits := nil;
  end;
end;
 if oppanel <> nil then
  begin
    oppanel.free;
    oppanel := nil;
  end;
   if favpanel <> nil then
  begin
    favpanel.free;
    favpanel := nil;
  end;
  menu.Free;
  menu:=nil;

end;

procedure Tcreatemenu.oncreate(sender: tobject);
var
  i, noptions, Opnumber,cardid: integer;
  question, answer, opti, favc, equation, temp: boolean;
  // booleans for checking
  favdb: boolean;
  qdb, adb, edb: string;
  ops: tlist<string>;
  Errormessage: string;
begin
  noptions := 0;
  Opnumber := 0;
  question := false;
  answer := false;
  equation := false;
  opti := false;
  favc := false;
  Errormessage := '';
  ops := tlist<string>.create;
  for i := 1 to 2 do
  begin
    if fav[i].Checked = true then
    begin
      favc := true;
      if i = 1 then
        favdb := true
      else
        favdb := false;
    end;
  end;
  if favc = false then
    Errormessage := 'favourite';

  if Edits[0].text <> '' then
  begin
    question := true;
    qdb := Edits[0].text;
  end;
  if question = false then
    Errormessage := Errormessage + '  question';

  if (tt = 'f') or (tt = 'g') then
  begin
    if Edits[1].text <> '' then
    begin
      answer := true;
      adb := Edits[1].text;
    end;
    if answer = false then
      Errormessage := Errormessage + '  answer';

    if tt = 'g' then
    begin
      if Edits[2].text <> '' then
      begin
        equation := true;
        edb := Edits[2].text;
      end;
      if equation = false then
        Errormessage := Errormessage + '  equation';
    end;
  end
  else
  begin
    for i := 1 to 6 do // checks a number is selected
    begin
      if Edits[i].text <> '' then
      begin
        noptions := noptions + 1;
        ops.add(Edits[i].text);
        temp := true;
      end
      else
        temp := false;
      if temp = true then // only check if its selected if it has text in it
      begin
        if options[i].Checked = true then
        begin
          Opnumber := noptions;
          adb:=inttostr(opnumber);
          opti := true
        end;
      end;
    end;
    if opti = false then
      Errormessage := errormessage + '  correct option';
    if noptions=0 then
      errormessage := errormessage + '  option text';
  end;

if errormessage<>'' then
   showmessage('Sorry but youre missing ' + errormessage)
else
begin
 buttons[0].enabled:=false;
 addcardtodb(qdb,adb,edb,ops,tt,did,pid,favdb,cardid);
 for I := 1 to 4 do
   begin
     if typ[i].Checked=true then
     createform(typ[i]);
   end;


  if (tt='o') or (tt='t') then
  begin
  for I := 1 to 4 do
  if options[i].checked=true then
    options[i].Checked:=false;
  end;
 for i  := 1 to 2 do
 if fav[i].checked=true then
   fav[i].Checked:=false;

end;


end;

procedure Tcreatemenu.onedit(sender: tobject);
var
  i, noptions, Opnumber: integer;
  question, answer, opti, favc, equation, temp: boolean;
  // booleans for checking
  favdb: boolean;
  qdb, adb, edb,t: string;
  ops: tlist<string>;
  Errormessage: string;
begin
  noptions := 0;
  Opnumber := 0;
  question := false;
  answer := false;
  equation := false;
  opti := false;
  favc := false;
  Errormessage := '';
  ops := tlist<string>.create;
  for i := 1 to 2 do
  begin
    if fav[i].Checked = true then
    begin
      favc := true;
      if i = 1 then
        favdb := true
      else
        favdb := false;
    end;
  end;
  if favc = false then
    Errormessage := 'favourite';

  if Edits[0].text <> '' then
  begin
    question := true;
    qdb := Edits[0].text;
  end;
  if question = false then
    Errormessage := Errormessage + '  question';

  if (tt = 'f') or (tt = 'g') then
  begin
    if Edits[1].text <> '' then
    begin
      answer := true;
      adb := Edits[1].text;
    end;
    if answer = false then
      Errormessage := Errormessage + '  answer';

    if tt = 'g' then
    begin
      if Edits[2].text <> '' then
      begin
        equation := true;
        edb := Edits[2].text;
      end;
      if equation = false then
        Errormessage := Errormessage + '  equation';
    end;
  end
  else
  begin
    for i := 1 to 6 do // checks a number is selected
    begin
      if Edits[i].text <> '' then
      begin
        noptions := noptions + 1;
        ops.add(Edits[i].text);
        temp := true;
      end
      else
        temp := false;
      if temp = true then // only check if its selected if it has text in it
      begin
        if options[i].Checked = true then
        begin
          Opnumber := noptions;
          adb:=inttostr(opnumber);
          opti := true
        end;
      end;
    end;
    if opti = false then
      Errormessage := errormessage + '  correct option';
    if noptions=0 then
      errormessage := errormessage + '  option text';
  end;

if errormessage<>'' then   //the error checking
   showmessage('Sorry but youre missing ' + errormessage)
else
begin

  with dm.cardset do // creates a new card
  begin
    Close;
    CommandText := ('Select * from card where CardID=:ID');
    Close;
    parameters.ParamByName('ID').value:=inttostr(cid);
    open;
    edit;
    FieldValues['Question'] := qdb;
    FieldValues['Answer'] := adb;
    FieldValues['Equation'] := edb;
    FieldValues['Cardtype'] := tt;
    FieldValues['Favourite'] := Favdb;
    FieldValues['Options'] := Ops.count;
    for i := 1 to Ops.count do
    begin
      t := 'Option' + inttostr(i);
      FieldValues[t] := Ops[i - 1];
    end;
    post;
    Close;
  end;
 free;
end;

end;

procedure Tcreatemenu.questionboxes;
var
  i: integer;
begin
  CreateLabel(Menu.height div 4, 0, 0, 0, 9, 'Question', 'c');
  CreateEdit(Menu, Menu.height div 4 + 25, 0, Menu.Width div 2, 70, '', 'c');

  if (tt = 'g') or (tt = 'f') then
  begin
    CreateLabel(Menu.height div 2 + 25, 0, 0, 0, 9, 'Answer', 'c');
    CreateEdit(Menu, Menu.height div 2 + 45, 0, Menu.Width div 2, 70, '', 'c');
    if tt = 'g' then
    begin
      CreateLabel(Menu.height div 5 * 2 + 25, 0, 0, 0, 9,
        'Equation(must be y=...x...)', 'c');
      CreateEdit(Menu, Menu.height div 5 * 2 + 45, 0, Menu.Width div 2,
        20, '', 'c');
    end;
  end
  else if (tt = 't') or (tt = 'o') then
  begin
    CreateLabel(Menu.height div 5 * 2 + 25, 0, 0, 0, 9,
      'Options(1-6, then select answer)', 'c');
    oppanel := tpanel.create(Menu);
    // so that the fav option is a different radio group
    oppanel.Parent := Menu;
    oppanel.left := Menu.Width div 4;
    oppanel.Width := Menu.Width div 2;
    oppanel.Top := Menu.height div 2 - 10;
    oppanel.height := Menu.height div 3;
    oppanel.Visible := true;
    for i := 1 to 6 do
    begin
      options[i] := tradiobutton.create(oppanel);
      options[i].Parent := oppanel;
      options[i].height := 20;
      options[i].Top := oppanel.height div 7 * i - 8;
      options[i].Width := 30;
      options[i].left := 20;
      options[i].Visible := true;
      options[i].caption := inttostr(i);
      CreateEdit(oppanel, oppanel.height div 7 * i - 8, 60, oppanel.Width - 80,
        20, '', 'l');
    end;
  end;
end;

end.
