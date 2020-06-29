unit UdeckPicker;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, generics.collections,
  Vcl.StdCtrls;

type
  ratingstats = array [1 .. 5] of integer;

  TDecks = class
  private


  public
    ID: integer;
    Card: Tpanel;
    Delete:tbutton;
    typ:char;
    Name, Progress, Cards: tlabel;
    choose: tcheckbox;
    Graph: timage;
    constructor create(mpanel: Tpanel; total, number, IDD, top: integer;
      title, prog, Cards: string; numbers: ratingstats;t:char);
    destructor free;
    procedure del(sender : tobject);
    procedure creategraph(Image: timage; stats: ratingstats; width: integer);
  end;

  Tpackdisplay = class
  private

  public
     ty:char;
    numberofpacks: integer;
    choicearray: tobjectlist<TDecks>;
    constructor create(mpanel: Tpanel;typ:char);
    procedure furnish(mpanel: Tpanel; deckid: integer);
    destructor free;
    procedure createoption(mpanel: Tpanel; total, number, ID, top: integer;
      title, Progress, Cards: string; stats: ratingstats);

  end;

  Tdeckdisplay = class
  private

  public
    ty:char;
    Numberofdecks: integer;
    choicearray: tobjectlist<TDecks>;
    constructor create(mpanel: Tpanel;typ:char);
    procedure furnish(mpanel: Tpanel);
    destructor free;
    procedure createoption(mpanel: Tpanel; total, number, ID, top: integer;
      title, Progress, Cards: string; stats: ratingstats);
  end;


implementation

{ TDecks }

uses UDM;

procedure getratings(ID: integer; var stats: ratingstats);
var
  cardids: tlist<integer>;
  n, j: integer;
begin
  cardids := tlist<integer>.create;
  dm.cardpackset.Close;
  with dm.cardpackset do
  begin
    Close;
    CommandText := 'Select CardID from CardPack where PackID=:PackID';
    Close;
    Parameters.ParamByName('PackID').value := inttostr(ID);
    open;
    first;
    while not eof do
    begin
      cardids.add(FieldValues['CardID']);
      next;
    end;
    Close;
  end;

  for j := 0 to cardids.count - 1 do
  begin
    with dm.cardset do
    begin
      Close;
      CommandText := 'Select Userrating from card where CardID=:CardID';
      Close;
      Parameters.ParamByName('CardID').value := inttostr(cardids[j]);
      open;
      n := FieldValues['Userrating'];
      if n <> 0 then
        stats[n] := stats[n] + 1;
    end;
  end;
  cardids.free;
end;

procedure getpackids(ID: integer; var packids: tlist<integer>);
begin
  dm.Packdeckset.Close;
  with dm.Packdeckset do
  begin
    Close;
    CommandText := 'Select PackID from PackDeck where DeckID=:DID';
    Close;
    Parameters.ParamByName('DID').value := inttostr(ID);
    open;
    first;
    while not eof do
    begin
      packids.add(FieldValues['PackID']);
      next;
    end;
    Close;
  end;
end;

constructor TDecks.create(mpanel: Tpanel; total, number, IDD, top: integer;
  title, prog, Cards: string; numbers: ratingstats;t:char);
var
  width,inrow,rowpos: integer;
begin
typ:=t;
 if total>6 then begin     //if theres more then 6 make 2 rows
 inrow:= total div 2 ;
 if total mod 2 = 1 then  inrow:=inrow+1;   //makes sure its an uneven split

 if number<=inrow then     //if its in row one then move higher
     top:=top-80
   else top:=top+80;     //if its in row 2 then move lower
 end
 else inrow:=total;    //if its one row do nothing
 if number<=inrow then
  rowpos:=number
 else
 rowpos:=number-inrow;

  Card := Tpanel.create(mpanel);
  Card.Parent := mpanel;
  Card.top := top;
  Card.Height := 150;
width := (700 div inrow) - (((inrow + 1) * 12) div inrow);
  // makes the spacing correct
  Card.width := width;
  Card.left := (12 + width) * (rowpos - 1) + 12;
  if (number>inrow) and (total mod 2 =1) then  //makes it central for an uneven second row
     card.Left:=card.Left+ card.Width div 2 + 6  ;
  Card.Visible := true;
  Card.Parentbackground := false;
  Card.Color := clmenu;

  name := tlabel.create(Card);
  name.Parent := Card;
  name.top := 5;
  name.Height := 20;
  name.Visible := true;
  name.WordWrap:=true;
  name.Alignment := tacenter;
  name.Font.Size := 9;
  name.Font.Name := 'Comic sans MS';
  name.Font.style := [fsUnderline];
  name.Font.Style:=[fsbold];
  name.Font.Size:=10;
  name.caption := title;
  name.Left:=(card.Width-name.Width)div 2;

  Progress := tlabel.create(Card);
  Progress.Parent := Card;
  Progress.width := width;
  Progress.left := 5;
  Progress.top := 25;
  Progress.Height := 15;
  Progress.Visible := true;
  Progress.Font.Size := 7;
  Progress.Font.Name := 'Comic sans MS';
  Progress.caption := prog;

  Progress := tlabel.create(Card);
  Progress.Parent := Card;
  Progress.width := width;
  Progress.left := 5;
  Progress.top := 40;
  Progress.Height := 15;
  Progress.Visible := true;
  Progress.Font.Size := 7;
  Progress.Font.Name := 'Comic sans MS';
  Progress.caption := Cards;

  Graph := timage.create(Card);
  Graph.Parent := Card;
  Graph.Height := 75;
  Graph.top := 55;
  Graph.left := 5;
  Graph.width := width - 10;
  Graph.Visible := true;
  if (numbers[3] = 9999) or (numbers[3]=99999) then // changes the size for favs
  begin
    Graph.left := (width - 75) div 2;
    Graph.width := 75;
  end;
  creategraph(Graph, numbers, width);

  choose := tcheckbox.create(Card);
  choose.Parent := Card;
  choose.left := width div 2 - 5;
  choose.top := 130;
  choose.Height := 20;
  choose.width := 20;
  choose.caption := '';
  choose.Visible := true;
  choose.checked := false;
   ID := IDD;
  if (id<>0) then
  begin
  if ((typ='d') and (id<>1)) or ((typ='p') and (id<>2) and (id<>4) and (id<>5)) then   //makes sure u cant delete some packs
  begin
  delete:=tbutton.Create(card);
  delete.parent:=card;
  delete.caption:='X';
  delete.Width:=13;
  delete.Height:=13;
  delete.Left:=card.Width-delete.Width-5;
  delete.Top:=5;
  delete.OnClick:=del;
  delete.Visible:=true;
  end;
  end;



end;

procedure TDecks.creategraph(Image: timage; stats: ratingstats; width: integer);
var
  total, i, Height, max, w, x: integer;
  r: trect;
  p: tpoint;
begin
  if stats[3] = 9999 then // makes it different for favourites
  begin
    Image.Picture.loadfromfile('Star.bmp')
  end
  else if stats[3]=99999 then
    begin
       Image.Picture.loadfromfile('Plus.bmp')
    end
  else
  begin
    // draw the graph
    total := 0;
    max := 0;
    for i := 1 to 5 do
    begin
      total := total + stats[i];
      if stats[i] > max then
        max := stats[i]
    end;
    w := (width - 40) div 5;

    for i := 1 to 5 do
    begin
      if max <> 0 then
      begin
        if stats[i] <> 0 then
          Height := round(75 / (max / stats[i]))
        else
          Height := 0;
        x := (5 + w) * (i - 1) + 5;
        with Image.Canvas do
        begin
          pen.Color := clblack;
          case i of
            1:
              brush.Color := clmaroon;
            2:
              brush.Color := tcolor($008CFF);
            3:
              brush.Color := tcolor($00D7FF);
            4:
              brush.Color := tcolor($98FB98);
            5:
              brush.Color := clgreen;
          end;
          rectangle(x, 75, x + w, 75 - Height);
          floodfill(x + (w div 2), 75 - (Height div 2), clblack, fssurface);
        end;
      end;
    end;
  end;

end;



procedure deletedeck(id:integer);
begin
with dm.Achievementset do
begin
  close;
  commandtext:=('select * from achievements');
  open;     //decreases deck count
  edit;
  fieldvalues['Decks']:=fieldvalues['decks']-1;
  post;
  close;
end;
with dm.deckset do
begin
  close;
  commandtext:=('select * from deck where deckid=:deckid');
    Close;
    Parameters.ParamByName('Deckid').value := inttostr(id);
 open;            //deletes deck
  delete;
  close;
end;
with dm.packdeckset do
begin
  close;
  commandtext:=('select * from packdeck where deckid=:deckid');
    Close;
    Parameters.ParamByName('Deckid').value := inttostr(id);
 open;
 first;
 while not eof do
    begin
     delete;
     next;   //deletes packdeck reference
    end;
  close;
end;
end;

function getcardids(packids:tlist<integer>):tlist<integer>;
var
  I: Integer;
begin
result:=tlist<integer>.create;
for I := 0 to packids.count-1 do
begin
with dm.CardPackset do
begin
  close;
  commandtext:=('select * from cardpack where packid=:packid');
    Close;
    Parameters.ParamByName('packid').value := inttostr(packids[i]);
    open;
    first;
    while not eof do
    begin
    result.add(fieldvalues['cardid']);
    next;
    end;
    close;
end;
end;
end;

procedure deletepack(packids:tlist<integer>);
var
i,did,cards:integer;
begin

for I := 0 to packids.Count-1 do
begin
  with dm.packdeckset do
begin
  close;
  commandtext:=('select * from packdeck where packid=:packid');
    Close;
    Parameters.ParamByName('packid').value := inttostr(packids[i]);
 open;
 if fieldvalues['deckid']<>null then
 did:=fieldvalues['deckid']  //gets the deck its in
 else did:=-1 ;
  close;
end;

with dm.packset do
begin
  close;
  commandtext:=('select * from pack where packid=:packid');
    Close;
    Parameters.ParamByName('packid').value := inttostr(packids[i]);
 open;
 cards:=fieldvalues['packsize'];//gets the numbe rof cards deleted
  delete;
  close;
end;

 if did<>-1 then
begin
 with dm.deckset do
begin
  close;
  commandtext:=('select * from deck where deckid=:deckid');
    Close;
    Parameters.ParamByName('Deckid').value := inttostr(did);
 open;         //changes no.packs
  edit;
  fieldvalues['packs']:=fieldvalues['packs']-1 ;  //lowers numbe rof packs
  fieldvalues['cards']:=fieldvalues['cards']-cards;//lowers numbe rof cards
  post;
  close;
end;
end;



with dm.cardpackset do
begin
  close;
  commandtext:=('select * from cardpack where packid=:packid');
    Close;
    Parameters.ParamByName('packid').value := inttostr(packids[i]);
 open;
 first;
 while not eof do
    begin
     next;
       delete;
    end;
  close;
end;
end;
end;

function ammendcardids(var cardids:tlist<integer>):tlist<integer>;
var
i:integer;      //removes any card ids that still have cards
begin
result:=tlist<integer>.create;
for I := 0 to cardids.Count-1 do
with dm.CardPackset do
begin
  close;
  commandtext:=('select * from cardpack where cardid=:cardid');
    Close;
    Parameters.ParamByName('cardid').value := inttostr(cardids[i]);
    open;
   if  fields[0].IsNull=true  then result.Add(cardids[i])      ; //adds the card if its not in there
   close;
end;
end;

procedure deletecards(cardids:tlist<integer>);
var
i:integer;
begin
for i  := 0 to cardids.Count-1 do
begin
with dm.cardset do
begin
  close;
  commandtext:=('select * from card where cardid=:cardid');
    Close;
    Parameters.ParamByName('cardid').value := inttostr(cardids[i]);
 open;
  delete;
  close;
end;
end;
end;

procedure TDecks.del(sender: tobject);
var
i,numberofpacks:integer;
packids,cardids:tlist<integer>;
begin

packids := tlist<integer>.create;
if typ='d' then
begin
// gets all the pack ids within the deck
  getpackids(id, packids);
  deletedeck(id);
end
else
packids.add(id);   //add ths single pack if a pack is selected
cardids:=getcardids(packids);
deletepack(packids);
cardids:=ammendcardids(cardids); //makes sure a card thats in another deck isnt deleted
deletecards(cardids); //removes the cards

choose.Enabled:=false;
name.Caption:='Deleted';
graph.Visible:=false;
progress.Visible:=false;
if cards<>nil then
cards.Visible:=false;
Card.Color := clgray;
delete.Enabled:=false;

end;


destructor TDecks.free;
begin
  name.free;
  name := nil;
  Progress.free;
  Progress := nil;
  Cards.free;
  Cards := nil;
  Graph.free;
  Graph := nil;
  Card.free;
  Card := nil;
end;

{ Tpackdisplay }

constructor Tpackdisplay.create(mpanel: Tpanel;typ:char);
begin
  ty:=typ;
  choicearray := tobjectlist<TDecks>.create;

end;

procedure Tpackdisplay.createoption(mpanel: Tpanel;
  total, number, ID, top: integer; title, Progress, Cards: string;
  stats: ratingstats);
var
  o: TDecks;
begin
  o := TDecks.create(mpanel, numberofpacks, number, ID, top, title, Progress,
    Cards, stats,'p');
  choicearray.add(o);
end;

destructor Tpackdisplay.free;
var
  i: integer;
begin
  if choicearray <> nil then
  begin
    for i := (choicearray.count - 1) downto 0 do
    begin
      choicearray[i].free;
    end;
    choicearray := nil;
  end;

end;

procedure Tpackdisplay.furnish(mpanel: Tpanel; deckid: integer);
var
  i, j, n, ID: integer;
  packids, cardids: tlist<integer>;
  title, Progress, Cards: string;
  stats: ratingstats;
begin
  with dm.deckset do
  begin
    // getnumberofpacks
    Close;
    CommandText := 'select Packs from Deck where DeckID=:DeckID';
    Close;
    Parameters.ParamByName('DeckID').value := inttostr(deckid);
    open;
    numberofpacks := FieldValues['Packs'];
    numberofpacks := numberofpacks + 1; // accounts for favourites
      if ((ty='n') and (deckid=1)) or (ty='m') then  //so you cant add a pack to random gen cards , or to copying one
      numberofpacks:=numberofpacks-1;
  end;

  // gets all the pack ids within the deck
  packids := tlist<integer>.create;
  getpackids(deckid, packids);

  dm.packset.Close;
  dm.packset.CommandText := 'Select * from Pack where PackID=:PackID';

  for i := 1 to numberofpacks do
  begin
    if (i <> numberofpacks) or ((ty='n') and (deckid=1)) or (ty='m')then // for fav,and copy card
    begin
      with dm.packset do
      begin
        Close;
        Parameters.ParamByName('PackID').value := inttostr(packids[i - 1]);
        open;
        title := FieldValues['Packname'];
        Progress := inttostr(FieldValues['PackKnowledge']) + '%';
        Cards := inttostr(FieldValues['Packsize']) + ' cards';
      end;
      ID := packids[i - 1];

      // fill ratings
      for j := 1 to 5 do
      begin
        stats[j] := 0;
      end;
      getratings(ID, stats);

    end
    else if ((ty<>'n') or (deckid<>1)) then// start of fav or newcard
    begin
    if ty='f' then
     begin
      title := 'Favourites';
      Progress := '';
      Cards := '';
      ID := 0;
      stats[3] := 9999; // so i can distinguish
      end
     else if ty='n' then
      begin
      title := 'New Pack';
      Progress := '';
      Cards := '';
      ID := 0;
      stats[3] := 99999; // so i can distinguish
      end;
    end;
    createoption(mpanel, numberofpacks, i, ID, 325, title, Progress,
      Cards, stats);
  end;
end;

{ Tdeckdisplay }

constructor Tdeckdisplay.create(mpanel: Tpanel;typ:char);
begin
  ty:=typ;
  choicearray := tobjectlist<TDecks>.create;
end;

procedure Tdeckdisplay.createoption(mpanel: Tpanel;
  total, number, ID, top: integer; title, Progress, Cards: string;
  stats: ratingstats);
var
  o: TDecks;
begin
  o := TDecks.create(mpanel, Numberofdecks, number, ID, top, title, Progress,
    Cards, stats,'d');
  choicearray.add(o);
end;

destructor Tdeckdisplay.free;
var
  i: integer;
begin
  if choicearray <> nil then
  begin
    for i := (choicearray.count - 1) downto 0 do
    begin
      choicearray[i].free;
    end;
    choicearray := nil;
  end;

end;

procedure Tdeckdisplay.furnish(mpanel: Tpanel);
var
  i, j, ID: integer;
  title, Progress, Cards: string;
  stats: ratingstats;
  packids,deckids: tlist<integer>;
begin

  with dm.Achievementset do
  begin
    Close;
    CommandText := 'select Decks from Achievements';
    open;
    Numberofdecks := FieldValues['Decks'];
    Numberofdecks := Numberofdecks + 1; // accounts for favourites
    if ty='m' then
    numberofdecks:=numberofdecks -1; //for copying cards
  end;
    deckids:=tlist<integer>.create;
    with dm.deckset do
      begin
        Close;
        CommandText := 'Select DeckID from Deck';
        open;
        first;
        while not eof do
        begin
        deckids.Add(fieldvalues['DeckID']);
        next;
        end;
        Close;
      end;

  for i := 1 to Numberofdecks do
  begin
    if (i <> Numberofdecks) or (ty='m') then
    begin
      with dm.deckset do
      begin
        Close;
        CommandText := 'Select * from Deck where DeckID=:DeckID';
        Close;
        Parameters.ParamByName('DeckID').value := inttostr(deckids[i-1]);
        open;
        title := FieldValues['Deckname'];
        Progress := inttostr(FieldValues['Deckknowledge']) + '%';
        Cards := inttostr(FieldValues['cards']) + ' cards';
        Close;
      end;
      ID := deckids[i-1];

      for j := 1 to 5 do
        stats[j] := 0;
      // gets pack ids for the graph
      if packids <> nil then
        packids.free;
      packids := tlist<integer>.create;
      getpackids(ID, packids);

      for j := 0 to packids.count - 1 do
      begin
        getratings(packids[j], stats); // gets ratings from all packs for graph
      end;

    end
    else
    begin
    if ty='f' then
     begin
      title := 'Favourites';
      Progress := '';
      ID := 0;
      stats[3] := 9999;
      Cards := '';
     end
     else if ty='n' then
     begin
       title := 'New Deck';
      Progress := '';
      ID := 0;
      stats[3] := 99999;
      Cards := '';
     end;
    end;
    createoption(mpanel, Numberofdecks, i, ID, 25, title, Progress,
      Cards, stats);
  end;

end;

end.
