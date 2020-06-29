unit UMainProgram;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  generics.collections, ubadges, udeckpicker, uflashcard, ucreatecard,
  umainstats, uoptionsmenu, ugraph,shellapi,
  Data.DB, Vcl.Grids, Vcl.DBGrids;

type

  TMenu = class(TForm)
    BCreatecard: TButton;
    BFlashcard: TButton;
    BTool: TButton;
    BView: TButton;
    Bstats: TButton;
    Boptions: TButton;
    Bexport: TButton;
    BGames: TButton;
    LTitle: TLabel; // test     //
    MainPanel: TPanel;
    Bbadge: TButton;

    procedure BCreatecardClick(Sender: TObject);
    procedure BFlashcardClick(Sender: TObject);
    procedure BViewClick(Sender: TObject);
    procedure BstatsClick(Sender: TObject);
    procedure BToolClick(Sender: TObject);
    procedure BbadgeClick(Sender: TObject);
    procedure BoptionsClick(Sender: TObject);
    procedure BGamesClick(Sender: TObject);
    procedure BexportClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Current: char;
    cardid, pid, did: integer;
    Graph: tgraph;
    cmenu: tcreatemenu;
    statmenu: mainstats;
    Opmenu: Optionsmenu;
    lables: tobjectlist<TLabel>;
    buttons: tobjectlist<TButton>;
    edits: tobjectlist<tedit>;
    Badgearray: tobjectlist<Tbadges>;
    Deckshower: Tdeckdisplay;
    packshower: tpackdisplay;
    nflashcards: tobjectlist<tflashcard>;
    bflashcards: tobjectlist<tflashback>;
    packnames: tlist<string>;
    cardids, lastids: tlist<integer>;
    random: boolean;
    timer:ttimer;
    count:integer;
    Procedure clearpanel;
    Procedure Cleararrays;
    Procedure ClearBoard;
    Procedure CreateLabel(Top, left, Width, height, size: integer;
      caption: string);
    Procedure CreateButton(Top, left, Width, height: integer; caption: string;
      click: tnotifyevent);
    Procedure CreateEdit(Top, left, Width, height: integer; caption: string);
    procedure createbadge(Top, left: integer; Locked: boolean;
      title, prog: string);
    procedure createbadges(page: integer);
    procedure badgepageclick(Sender: TObject);
    procedure flashcardpageclick(Sender: TObject);
    procedure ondeckpick(Sender: TObject);
    procedure onpackpick(Sender: TObject);
    procedure onratingpick(Sender: TObject);
    procedure ondeleteclick(Sender: TObject);
    procedure oneditclick(Sender: TObject);
    procedure oneditcard(Sender: TObject);
    procedure ondeckcreate(Sender: TObject);
    procedure onpackcreate(Sender: TObject);
    procedure newcard;
    function getcardids(packids: tlist<integer>): tlist<integer>;
    procedure displaycards(page: integer);
    procedure addcard(F: tflashcard; B: tflashback);
    procedure newgraph(Sender: TObject);
    procedure addline(Sender: TObject);
    procedure inctime(sender: tobject);
    procedure createtimer;
    procedure resetstats(sender :tobject);
  end;

var
  Menu: TMenu;

implementation

{$R *.dfm}

uses UDM;

procedure TMenu.Cleararrays;
var
  i: integer;
begin
  if lables <> nil then
  begin
    lables.free;
    lables := nil;
  end;

  if Badgearray <> nil then
  begin
    for i := (Badgearray.count - 1) downto 0 do
    begin
      Badgearray[i].free;
    end;
    Badgearray := nil;
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

  if Deckshower <> nil then
  begin
    Deckshower.free;
    Deckshower := nil;
  end;

  if packshower <> nil then
  begin
    packshower.free;
    packshower := nil;
  end;

  if nflashcards <> nil then
  begin
    for i := nflashcards.count - 1 downto 0 do
    begin
      nflashcards[i].free;
    end;
    nflashcards := nil;
  end;

  if bflashcards <> nil then
  begin
    for i := bflashcards.count - 1 downto 0 do
    begin
      bflashcards[i].free;
    end;
    bflashcards := nil;
  end;

  if cmenu <> nil then
  begin
    cmenu.free;
    cmenu := nil;
  end;

  if statmenu <> nil then
  begin
    statmenu.free;
    statmenu := nil;
  end;

  if Opmenu <> nil then
  begin
    Opmenu.free;
    Opmenu := nil;
  end;

  if Graph <> nil then
  begin
    Graph.free;
    Graph := nil;
  end;

  if timer<>nil then
  begin
    timer.Free;
    timer:=nil;
  end;
end;

procedure TMenu.ClearBoard;
begin
  Cleararrays;
  // clearpanel //?  ;

end;

procedure TMenu.clearpanel;
begin
  // removes panel entity
  MainPanel.free;
  MainPanel := nil;
  // creates new one
  MainPanel := TPanel.Create(Menu);
  MainPanel.Parent := self;
  MainPanel.left := 0;
  MainPanel.Width := Width;
  MainPanel.Top := 107; // change to allow variable size?
  MainPanel.height := 600; // change to allow variable size?
  MainPanel.Visible := true;
  MainPanel.color := clwhite;
  MainPanel.ParentBackground := false;
end;

procedure TMenu.CreateButton(Top, left, Width, height: integer; caption: string;
  click: tnotifyevent);
var
  B: TButton;
begin
  B := TButton.Create(MainPanel);
  buttons.add(B);
  B.Parent := MainPanel;
  B.Top := Top;
  B.left := left;
  B.Width := Width;
  B.height := height;
  B.caption := caption;
  B.Visible := true;
  B.onclick := click;

end;

procedure TMenu.CreateEdit(Top, left, Width, height: integer; caption: string);
var
  E: tedit;
begin
  E := tedit.Create(MainPanel);
  edits.add(E);
  E.Parent := MainPanel;
  E.Top := Top;
  E.left := left;
  E.Width := Width;
  E.height := height;
  E.text := caption;
  E.Visible := true;
  E.Enabled := true;

end;

procedure TMenu.CreateLabel(Top, left, Width, height, size: integer;
  caption: string);
var
  l: TLabel;
begin
  l := TLabel.Create(MainPanel);
  lables.add(l);
  l.Parent := MainPanel;
  l.Top := Top;
  l.left := left;
  l.Width := Width;
  l.height := height;
  l.WordWrap := true;
  l.caption := caption;
  l.Visible := true;
end;

procedure getfavids(cardids: tlist<integer>);
begin
  with dm.Cardset do
  begin
    Close;
    CommandText := ('Select Favourite,CardID  from Card');
    open;
    first;
    while not eof do
    begin
      if FieldValues['Favourite'] = true then
        cardids.add(FieldValues['CardID']);
      next;
    end;
  end;
end;

procedure gettype(id: integer; var typ: char);
var
  l: string;

begin
  with dm.Cardset do
  begin
    Close;
    CommandText := ('Select Cardtype  from Card where Cardid=:ID');
    Close;
    Parameters.ParamByName('ID').value := inttostr(id);
    open;
    l := FieldValues['Cardtype'];
  end;
  typ := l[1];
end;

procedure TMenu.ondeckcreate(Sender: TObject);
// adds new deck to db,and goes back to pack menu
var
  i: integer;
  c:char;
begin
  if edits[0].text = '' then
  begin
    showmessage('Please enter a valid name')
  end
  else
  begin
    with dm.deckset do
    begin
      Close;
      CommandText := ('Select * from deck');
      Close;
      open;
      insert;
      FieldValues['Deckname'] := edits[0].text;
      FieldValues['Packs'] := 0;
      FieldValues['Cards'] := 0;
      FieldValues['Deckcompletion'] := 0;
      FieldValues['Deckknowledge'] := 0;
      FieldValues['Cardsseen'] := 0;
      post;
      Close;
    end;
    with dm.Achievementset do
    begin
      Close;
      CommandText := 'select Decks from Achievements';
      open;
      edit;
      FieldValues['Decks'] := FieldValues['decks'] + 1;
      post;
      Close;
    end;
    if buttons <> nil then
    begin
      for i := (buttons.count - 1) downto 0 do
      begin
        buttons[i].free;
      end;
      buttons := nil;
    end;
    if lables <> nil then
    begin
      for i := (lables.count - 1) downto 0 do
      begin
        lables[i].free;
      end;
      lables := nil;
    end;
    if edits <> nil then
    begin
      for i := (edits.count - 1) downto 0 do
      begin
        edits[i].free;
      end;
      edits := nil;
    end;

    if Deckshower = nil then
    begin
     if (Current = 'f') or (Current = 'v') then
        c := 'f'
      else if Current = 'c' then
        c := 'n';
      Deckshower := Tdeckdisplay.Create(MainPanel, c);
    end;

    Deckshower.furnish(MainPanel); // shows the decks
    Deckshower.choicearray[Deckshower.choicearray.count - 2]
      .choose.checked := true;
    ondeckpick(LTitle);
  end;
end;

procedure tmenu.inctime(sender:tobject);
var
i:integer;
reco:boolean;
begin
lables[0].Caption:=inttostr(strtoint(lables[0].caption)-1); //decreases the times
if StrToInt(lables[0].caption)=0 then   //if timer has stopped
 begin
 reco:=false;
   timer.Free;
   timer:=nil;
     if nflashcards <> nil then
  begin
    for i := nflashcards.count - 1 downto 0 do
    begin
      nflashcards[i].free;
    end;
    nflashcards := nil;
  end;
  lables[0].Top:=mainpanel.Height div 2; //reposisions it
  lables[0].Caption:= 'Well Done You Got ' + inttostr(count) + ' Cards done!';
  with dm.Achievementset do
  begin
    close;
    commandtext:=('select * from achievements');
    open;
    edit;
    if count>fieldvalues['Timed'] then begin fieldvalues['timed']:=count;
    reco:=true;
    end;
    post;
    close;
  end;
  if reco=true then
  showmessage('You beat Your high score');
 end;
end;

procedure tmenu.createtimer;
begin
lables:=tobjectlist<tlabel>.create;
createlabel(mainpanel.Height div 6 *5,mainpanel.Width div 2,100,20,25,'30');
lables[0].Font.size:=20;

              count:=0;
             timer:=ttimer.Create(mainpanel);
             timer.OnTimer:=IncTime;
             timer.Interval:= 1000 ; //30 secs
end;

procedure TMenu.ondeckpick(Sender: TObject);
var
  i, number, id, numberofdecks, currentid, pages: integer;
  mpanel: TPanel;
  c, tyyy: char;
  an: boolean;
  t: tflashcard;
  l: TLabel;

begin
  t := nil;
  if nflashcards = nil then
    nflashcards := tobjectlist<tflashcard>.Create;
  numberofdecks := Deckshower.numberofdecks;

  number := 0;
  for i := 0 to numberofdecks - 1 do
  begin
    if Deckshower.choicearray[i].choose.checked = true then
      number := number + 1;
  end;
  if (number > 1) or (number = 0) then
  // checks they have selected the correct amount
  begin
    showmessage('Please only select one deck.');
  end
  else // proceds to show the next part of the deck
  begin
    if buttons <> nil then
      buttons[0].Enabled := false;
    for i := 0 to numberofdecks - 1 do
    begin
      if Deckshower.choicearray[i].choose.checked = true then
        id := Deckshower.choicearray[i].id;
      Deckshower.choicearray[i].choose.Enabled := false;
      // makes sure you dont change your option
    end;

    if id <> 0 then
    begin
      if (Current = 'f') or (Current = 'v') or (Current = 'g') then
        c := 'f'
      else if Current = 'c' then
        c := 'n';
      packshower := tpackdisplay.Create(MainPanel, c);
      packshower.furnish(MainPanel, id);
      if buttons = nil then
        buttons := tobjectlist<TButton>.Create;

      CreateButton(560, 330, 50, 20, 'Continue', onpackpick);
    end
    else
    begin
      if cardids <> nil then
      begin
        cardids.free;
        cardids := nil;
      end;
      cardids := tlist<integer>.Create;
      getfavids(cardids); // gets the possible cards
      if (Current = 'f') or (Current = 'g') then
      begin
        if cardids.count > 0 then
        begin
          // run flashcard with ids
          if lastids = nil then
            lastids := tlist<integer>.Create;
          if cardids.count <> 0 then
            currentid := getcard(cardids, lastids); // gets a card id
        end;
        if (t = nil) and (currentid < 50000) then
        // if the flashcard isant existing
        begin
          gettype(currentid, tyyy);
          an := getanswer;
            if current='g' then // for timed game
            an:=true;
          if (tyyy = 'o') or (tyyy = 't') then
            an := false;

          t := tflashcard.Create(MainPanel, MainPanel.Width - 60,
            MainPanel.height div 3 * 2, 30, 30, currentid, onratingpick,
            ondeleteclick, oneditclick, tyyy, an);
        end;
        if currentid < 50000 then
        begin
          nflashcards.add(t);
          if buttons <> nil then
          begin
            for i := (buttons.count - 1) downto 0 do
            begin
              buttons[i].free;
            end;
            buttons := nil;
          end;

          if Deckshower <> nil then
          begin
            Deckshower.free;
            Deckshower := nil;
          end;

          if (Current = 'g') then
            begin
             createtimer;
            end;
        end
        else
          showmessage('There are no Favourites');

      end
      else if Current = 'v' then
      begin
        // run view deck

        if cardids.count > 0 then
        begin
          pages := cardids.count div 2;
          if cardids.count mod 2 = 1 then
            pages := pages + 1; // recorrects pages so its rounded up
          if buttons <> nil then
          begin
            for i := (buttons.count - 1) downto 0 do
            begin
              buttons[i].free;
            end;
            buttons := nil;
          end;

          if Deckshower <> nil then // removes the deck picker
          begin
            Deckshower.free;
            Deckshower := nil;
          end;

          if buttons = nil then
            buttons := tobjectlist<TButton>.Create;
          for i := 1 to pages do
            CreateButton(550, ((700 div (pages + 1)) * i) - 25, 50, 40,
              'Page ' + inttostr(i), flashcardpageclick);
          displaycards(1);
        end
        else
          showmessage('There are no Favourites');

      end
      else if Current = 'c' then // run create deck
      begin
        if Deckshower.choicearray.count >= 6 then
        begin
          showmessage('Sorry but 5 Decks is the Maximum');
          buttons[0].Enabled := true
        end
        else
        begin
          if Deckshower <> nil then // removes the deck picker
          begin
            Deckshower.free;
            Deckshower := nil;
          end;
          if buttons <> nil then
          begin
            for i := (buttons.count - 1) downto 0 do
            begin
              buttons[i].free;
            end;
            buttons := nil;
          end;

          lables := tobjectlist<TLabel>.Create;
          buttons := tobjectlist<TButton>.Create; // creates all the menus
          edits := tobjectlist<tedit>.Create;

          l := TLabel.Create(MainPanel);
          lables.add(l);
          l.Parent := MainPanel;
          l.Top := MainPanel.height div 3;
          l.caption := 'What do you want to call the deck?';
          l.left := (MainPanel.Width - lables[0].Width) div 2;
          l.Visible := true;
          CreateEdit(MainPanel.height div 5 * 2, lables[0].left,
            lables[0].Width, 30, '');
          CreateButton(MainPanel.height div 2, (MainPanel.Width - 30) div 2, 30,
            20, 'Add', ondeckcreate);
        end;
      end;
    end;
  end;

end;

procedure TMenu.ondeleteclick(Sender: TObject);
var
  id, Top, currentid, cardid, count, pages: integer;
  t: tflashcard;
  tyyy: char;
  an: boolean;
  i: integer;
begin
  t := nil;
  Top := (Sender as TButton).Parent.Top;
  if Top < MainPanel.height div 3 then
    id := 0
  else
    id := 1;

  cardid := nflashcards[id].id;
  nflashcards[id].del;
  if nflashcards <> nil then
  begin
    for i := nflashcards.count - 1 downto 0 do
    begin
      nflashcards[i].free;
    end;
    nflashcards := nil;
  end;
  nflashcards := tobjectlist<tflashcard>.Create;

  count := 0; // removes the card fromt he reference
  repeat
    if cardids[count] = cardid then
      cardids.delete(count)
    else
      count := count + 1;
  until count = cardids.count;

  if lastids <> nil then
  begin
    count := 0; // removes the card fromt he reference
    repeat
      if lastids[count] = cardid then
        lastids.delete(count)
      else
        count := count + 1;
    until count = lastids.count;
  end;

  if Current = 'v' then
  begin
    if cardids.count <> 0 then
    begin
      pages := cardids.count div 2; // makes sure pages get corrected
      if cardids.count mod 2 = 1 then
        pages := pages + 1; // recorrects pages so its rounded up
      if buttons <> nil then
      begin
        for i := (buttons.count - 1) downto 0 do
        begin
          buttons[i].free;
        end;
        buttons := nil;
      end;
      if buttons = nil then
        buttons := tobjectlist<TButton>.Create;
      for i := 1 to pages do
        CreateButton(550, ((700 div (pages + 1)) * i) - 25, 50, 40,
          'Page ' + inttostr(i), flashcardpageclick);
      displaycards(1);
    end
    else
    begin
      if nflashcards <> nil then
      begin
        for i := nflashcards.count - 1 downto 0 do
        begin
          nflashcards[i].free;
        end;
        nflashcards := nil;
      end;

      if bflashcards <> nil then
      begin
        for i := bflashcards.count - 1 downto 0 do
        begin
          bflashcards[i].free;
        end;
        bflashcards := nil;
      end;
      if buttons <> nil then
      begin
        for i := (buttons.count - 1) downto 0 do
        begin
          buttons[i].free;
        end;
        buttons := nil;
      end;
      if Deckshower = nil then
        Deckshower := Tdeckdisplay.Create(MainPanel, 'f');
      Deckshower.furnish(MainPanel); // shows the decks
      buttons := tobjectlist<TButton>.Create;
      CreateButton(200, 325, 50, 20, 'Continue', ondeckpick);
    end;
  end
  else if Current = 'f' then // generates a new card
  begin
    if cardids.count <> 0 then // makes sure you haveent deleted them all
    begin
      if random = true then
        generatedcard(cardids, packnames, lastids, currentid)
      else
        currentid := getcard(cardids, lastids); // gets a card id

      if (t = nil) and (currentid < 50000) then
      // if the flashcard isant existing
      begin
        gettype(currentid, tyyy);
        an := getanswer;
        if (tyyy = 'o') or (tyyy = 't') then
          an := false;
        t := tflashcard.Create(MainPanel, MainPanel.Width - 60,
          MainPanel.height div 3 * 2, 30, 30, currentid, onratingpick,
          ondeleteclick, oneditclick, tyyy, an);
      end;
      if currentid < 50000 then
        nflashcards.add(t);
    end
    else
    begin // recreates the menu
      if Deckshower = nil then
        Deckshower := Tdeckdisplay.Create(MainPanel, 'f');
      Deckshower.furnish(MainPanel); // shows the decks
      buttons := tobjectlist<TButton>.Create;
      CreateButton(200, 325, 50, 20, 'Continue', ondeckpick);
    end;
  end;

end;

procedure TMenu.oneditcard(Sender: TObject);
var
  i: integer;
  t: tflashcard;
  an: boolean;
  types: char;

begin
  t := nil;
  for i := 1 to 4 do
  begin
    if cmenu.typ[i].checked = true then
    begin
      case i of
        1:
          types := 'f';
        2:
          types := 'o';
        3:
          types := 'g';
        4:
          types := 't';
      end;
    end;
  end;
  cmenu.onedit(LTitle);
  if cmenu.Menu = nil then
  begin
    if nflashcards <> nil then
    begin
      for i := nflashcards.count - 1 downto 0 do
      begin
        nflashcards[i].free;
      end;
      nflashcards := nil;
    end;
    nflashcards := tobjectlist<tflashcard>.Create;

    if Current = 'v' then
      displaycards(1)
    else if Current = 'f' then // generates a new card
    begin
      if (t = nil) and (cardid < 50000) then
      // if the flashcard isant existing
      begin
        an := getanswer;
        if (types = 'o') or (types = 't') then
          an := false;
        t := tflashcard.Create(MainPanel, MainPanel.Width - 60,
          MainPanel.height div 3 * 2, 30, 30, cardid, onratingpick,
          ondeleteclick, oneditclick, types, an);
      end;
      if cardid < 50000 then
        nflashcards.add(t);
    end
  end;
  cmenu := nil;
  if buttons <> nil then
  begin
    for i := 0 to buttons.count - 1 do
      buttons[i].Enabled := true;
  end;
end;

procedure TMenu.oneditclick(Sender: TObject);
var
  id, i, Top, ops, p: integer;
  types: char;
  answer, question, equation: string;
  options: tlist<string>;
  fav, an: boolean;
begin
  Top := (Sender as TButton).Parent.Top;
  if Top < MainPanel.height div 3 then
    id := 0
  else
    id := 1;

  options := tlist<string>.Create;
  cardid := nflashcards[id].id;
  types := nflashcards[id].ty;
  fav := nflashcards[id].fav.stat;
  answer := nflashcards[id].answer.caption;
  question := nflashcards[id].question.caption;
  if types = 'g' then
    equation := nflashcards[id].equation;
  if (types = 'o') or (types = 't') then
  begin
    ops := nflashcards[id].num;
    for i := 0 to ops - 1 do
    begin
      options.add(nflashcards[id].options[i].answe.caption)
    end;
  end;

  cmenu := tcreatemenu.Create(MainPanel, 0, 0, cardid, 'e');
  cmenu.menu.top:=cmenu.menu.top-20;
  // opens up a edit window


  cmenu.buttons[0].onclick := oneditcard;
  // makes the edit window show the corrct data
  case types of
    'f':
      p := 1;
    'g':
      p := 3;
    'o':
      p := 2;
    't':
      p := 4;
  end;
  cmenu.typ[p].checked := true;
  cmenu.createform(cmenu.typ[p]);
  cmenu.edits[0].text := question;
  if fav = true then
    cmenu.fav[1].checked := true
  else
    cmenu.fav[2].checked := true;

  if (types = 'f') or (types = 'g') then
  begin
    cmenu.edits[1].text := answer;
    if types = 'g' then
      cmenu.edits[2].text := equation;
  end
  else
  begin
    cmenu.options[strtoint(answer)].checked := true;
    for i := 1 to ops do
    begin
      cmenu.edits[i].text := options[i - 1];
    end;
  end;

  if buttons <> nil then
  begin
    for i := 0 to buttons.count - 1 do
      buttons[i].Enabled := false;
  end;
end;

function TMenu.getcardids(packids: tlist<integer>): tlist<integer>;
var
  i, j, id: integer;
  r, packs, favcards: tlist<integer>;
begin
  r := tlist<integer>.Create;
  for i := 0 to packids.count - 1 do
    if packids[i] <> 0 then
    begin

      begin
        with dm.cardpackset do
        begin
          Close;
          CommandText := 'Select CardID from CardPack where PackID=:PackID';
          Close;
          Parameters.ParamByName('PackID').value := inttostr(packids[i]);
          open;
          first;
          while not eof do
          begin
            r.add(FieldValues['CardID']);
            next;
          end;
          Close;
        end;
      end;
    end
    else // if fav was selected
    begin
      for j := 0 to Deckshower.numberofdecks - 1 do // gets the deck selected
      begin
        if Deckshower.choicearray[j].choose.checked = true then
          id := Deckshower.choicearray[j].id;
      end;
      packs := tlist<integer>.Create;
      with dm.packdeckset do // gets all the pack ids
      begin
        Close;
        CommandText := 'select PackID from PackDeck where DeckID=:DeckID';
        Close;
        Parameters.ParamByName('DeckID').value := inttostr(id);
        open;
        first;
        while not eof do
        begin
          packs.add(FieldValues['PackID']);
          next;
        end;
        Close
      end;
      favcards := tlist<integer>.Create;
      favcards := getcardids(packs);
      for j := 0 to favcards.count - 1 do
      // checks all the possible cards to find the favs
      begin
        with dm.Cardset do
        begin
          Close;
          CommandText := ('Select Favourite  from Card where Cardid=:ID');
          Close;
          Parameters.ParamByName('ID').value := inttostr(favcards[j]);
          open;
          if FieldValues['Favourite'] = true then
            r.add(favcards[j]);
        end;
      end;
    end;
  result := r;
end;

procedure TMenu.newcard; // menus for creating new card
begin
  cmenu := tcreatemenu.Create(MainPanel, pid, did, 0, 'c');
end;

procedure TMenu.flashcardpageclick(Sender: TObject);
var
  cap, number: string;
  i: integer;
begin
  cap := (Sender as TButton).caption;
  for i := 6 to length(cap) do
    number := number + cap[i];

  if nflashcards <> nil then // clears the badges
  begin
    for i := (nflashcards.count - 1) downto 0 do
    begin
      nflashcards[i].free;
    end;
    nflashcards := nil;
  end;
  if nflashcards = nil then
    nflashcards := tobjectlist<tflashcard>.Create;
  displaycards(strtoint(number));

end;

procedure TMenu.addcard(F: tflashcard; B: tflashback);
begin
  nflashcards.add(F);
  bflashcards.add(B);
end;

procedure TMenu.displaycards(page: integer);
var
  i, onpage, id, Top: integer;
  t: tflashcard;
  B: tflashback;
  tyyy: char;
  an: boolean;
begin
  if nflashcards <> nil then
  begin
    for i := nflashcards.count - 1 downto 0 do
    begin
      nflashcards[i].free;
    end;
    nflashcards := nil;
  end;

  if bflashcards <> nil then
  begin
    for i := bflashcards.count - 1 downto 0 do
    begin
      bflashcards[i].free;
    end;
    bflashcards := nil;
  end;

  if nflashcards = nil then
    nflashcards := tobjectlist<tflashcard>.Create;
  if bflashcards = nil then
    bflashcards := tobjectlist<tflashback>.Create;

  if page * 2 <= cardids.count then
    onpage := 2
  else
    onpage := 1;
  for i := 1 to onpage do
  // makes sure correct number are created on this page;
  begin
    Top := 20 + (i - 1) * (250 + 20);
    // get correct card;
    id := cardids[(page - 1) * 2 + i - 1];
    gettype(id, tyyy);
    an := getanswer;
    if (tyyy = 'o') or (tyyy = 't') then
      an := false;
    t := tflashcard.Create(MainPanel, 330, 250, Top, 15, id, onratingpick,
      ondeleteclick, oneditclick, tyyy, an);
    t.card.onclick := nil;
    B := tflashback.Create(MainPanel, Top, 360, 330, 250, id);
    addcard(t, B);
  end;
end;

procedure TMenu.onpackcreate(Sender: TObject);
var
  i: integer;
begin
  if edits[0].text = '' then
  begin
    showmessage('Please enter a valid name')
  end
  else
  begin
    with dm.packset do // creates a new pack
    begin
      Close;
      CommandText := ('Select * from pack');
      Close;
      open;
      insert;
      FieldValues['Packname'] := edits[0].text;
      FieldValues['Packsize'] := 0;
      FieldValues['Packcompletion'] := 0;
      FieldValues['PackKnowledge'] := 0;
      FieldValues['Cardsseen'] := 0;
      post;
      pid := FieldValues['Packid']; // gets the pack id
      Close;
    end;
    with dm.deckset do // updates number of packs in deck
    begin
      Close;
      CommandText := 'select * from deck where deckid=:deckid';
      Close;
      Parameters.ParamByName('DeckID').value := inttostr(did);
      open;
      edit;
      FieldValues['Packs'] := FieldValues['Packs'] + 1;
      post;
      Close;
    end;
    with dm.packdeckset do // adds reference linking pack and deck
    begin
      Close;
      CommandText := 'select * from packdeck';
      Close;
      open;
      insert;
      FieldValues['PackID'] := pid;
      FieldValues['DeckID'] := did;
      post;
      Close;
    end;

    if buttons <> nil then
    begin
      for i := (buttons.count - 1) downto 0 do
      begin
        buttons[i].free;
      end;
      buttons := nil;
    end;
    if lables <> nil then
    begin
      for i := (lables.count - 1) downto 0 do
      begin
        lables[i].free;
      end;
      lables := nil;
    end;
    if edits <> nil then
    begin
      for i := (edits.count - 1) downto 0 do
      begin
        edits[i].free;
      end;
      edits := nil;
    end;
    newcard;
  end;
end;

procedure TMenu.onpackpick(Sender: TObject);
var
  i, numberofpacks, c, currentid, pages: integer;
  packids: tlist<integer>;
  fav, an: boolean;
  t: tflashcard;
  tyyy: char;
  temp: string;
  l: TLabel;
begin
  t := nil;
  numberofpacks := packshower.numberofpacks;
  packids := tlist<integer>.Create;
  // gets the pack ids chosen
  for i := 0 to numberofpacks - 1 do
  begin
    if packshower.choicearray[i].choose.checked = true then
      packids.add(packshower.choicearray[i].id);
  end;
  if packids.count <> 0 then // makes sure some is selected
  begin
    fav := false;
    for i := 0 to (packids.count - 1) do
    begin
      if packids[i] = 0 then
        fav := true;
    end;

    if ((fav = true) and (packids.count > 1)) or
      ((Current = 'c') and (packids.count > 1)) then
    begin
      if (Current = 'f') or (Current = 'v') or (current='g') then
      begin
        temp := 'favourties'    ;
        showmessage('You cant select ' + temp + ' and another pack');
      end
      else
      begin
        if fav = true then
        begin
          temp := 'New Pack';
          showmessage('You cant select ' + temp + ' and another pack');
        end
        else
          showmessage('You cant add a card to two packs at once');
      end;
    end
    else
    begin
      if (Current = 'f') or (current='g') then
      begin
        // run flashcard with ids
        { 1.Get card ratings
          2.Is it a generated Pack
          3.Dont pick last Card
          4.Pick the card
          5.create the card and remove the menu
          6.updatecards seen in stats and pack ids
          7.calculate new care ratings n pack ratings etc
          8.generate a new card from the same method

        }

        if cardids <> nil then
        begin
          cardids.free;
          cardids := nil;
        end;
        cardids := tlist<integer>.Create;
        cardids := getcardids(packids); // gets the possible cards

        random := false; // is it a randomly generated pack?
        if nflashcards = nil then
          nflashcards := tobjectlist<tflashcard>.Create;
        for i := 0 to Deckshower.choicearray.count - 1 do
        begin
          if (Deckshower.choicearray[i].choose.checked = true) and
            (Deckshower.choicearray[i].id = 1) then
            random := true;
        end;
        if random = true then // yes its random
        begin
          packnames := tlist<string>.Create;
          for i := 0 to packshower.choicearray.count - 1 do
          begin
            if (packshower.choicearray[i].choose.checked = true) and
              (packshower.choicearray[i].Name.caption <> 'Favourites') then
              packnames.add(packshower.choicearray[i].Name.caption)
          end;
          if lastids = nil then
            lastids := tlist<integer>.Create;
          generatedcard(cardids, packnames, lastids, currentid);
          // gets a new card, or a id
        end
        else // if its just a standard pack
        begin
          if cardids.Count>0 then
            begin
          if lastids = nil then
            lastids := tlist<integer>.Create;
          if cardids.count <> 0 then
            currentid := getcard(cardids, lastids); // gets a card id
         end
          else showmessage('There are no Cards');
        end;
        if (t = nil) and (currentid < 50000) and (cardids.Count>0) then
        // if the flashcard isant existing
        begin
          gettype(currentid, tyyy);
          an := getanswer;
           if current='g' then // for times game
            an:=true;
          if (tyyy = 'o') or (tyyy = 't') then
            an := false;
          t := tflashcard.Create(MainPanel, MainPanel.Width - 60,
            MainPanel.height div 3 * 2, 30, 30, currentid, onratingpick,
            ondeleteclick, oneditclick, tyyy, an);
        end;
        if (currentid < 50000) and (cardids.count>0) then
        begin
          nflashcards.add(t);
          if buttons <> nil then
          begin
            for i := (buttons.count - 1) downto 0 do
            begin
              buttons[i].free;
            end;
            buttons := nil;
          end;

          if Deckshower <> nil then
          begin
            Deckshower.free;
            Deckshower := nil;
          end;

          if packshower <> nil then
          begin
            packshower.free;
            packshower := nil;
          end;
        end;
        if (Current = 'g') then
            begin
             createtimer;
            end;
      end
      else if Current = 'v' then
      begin
        // run view deck
        if cardids <> nil then
        begin
          cardids.free;
          cardids := nil;
        end;
        cardids := tlist<integer>.Create;
        cardids := getcardids(packids); // gets the possible cards

        if cardids.count > 0 then
        begin
          pages := cardids.count div 2;
          if cardids.count mod 2 = 1 then
            pages := pages + 1; // recorrects pages so its rounded up
          if buttons <> nil then
          begin
            for i := (buttons.count - 1) downto 0 do
            begin
              buttons[i].free;
            end;
            buttons := nil;
          end;

          if Deckshower <> nil then // removes the deck picker
          begin
            Deckshower.free;
            Deckshower := nil;
          end;

          if packshower <> nil then
          begin
            packshower.free;
            packshower := nil;
          end;
          if buttons = nil then
            buttons := tobjectlist<TButton>.Create;
          for i := 1 to pages do
            CreateButton(550, ((700 div (pages + 1)) * i) - 25, 50, 40,
              'Page ' + inttostr(i), flashcardpageclick);
          displaycards(1);
        end
        else
          showmessage('There are no Cards to display');
      end
      else if Current = 'c' then
      begin
        // run create deck
        pid := packids[0];
        for i := 0 to Deckshower.choicearray.count - 1 do
        begin
          if Deckshower.choicearray[i].choose.checked = true then
            did := Deckshower.choicearray[i].id;
        end;
        if packids[0] = 0 then // if its a new pack
        begin //
          if packshower.choicearray.count >= 12 then
          begin
            showmessage('Sorry but 11 Packs is the Maximum');
            buttons[0].Enabled := true
          end
          else
          begin
            if Deckshower <> nil then // removes the deck picker
            begin
              Deckshower.free;
              Deckshower := nil;
            end;
            if packshower <> nil then // removes the deck picker
            begin
              packshower.free;
              packshower := nil;
            end;
            if buttons <> nil then
            begin
              for i := (buttons.count - 1) downto 0 do
              begin
                buttons[i].free;
              end;
              buttons := nil;
            end;

            lables := tobjectlist<TLabel>.Create;
            buttons := tobjectlist<TButton>.Create; // creates all the menus
            edits := tobjectlist<tedit>.Create;

            l := TLabel.Create(MainPanel);
            lables.add(l);
            l.Parent := MainPanel;
            l.Top := MainPanel.height div 3;
            l.caption := 'What do you want to call the Pack?';
            l.left := (MainPanel.Width - lables[0].Width) div 2;
            l.Visible := true;
            CreateEdit(MainPanel.height div 5 * 2, lables[0].left,
              lables[0].Width, 30, '');
            CreateButton(MainPanel.height div 2, (MainPanel.Width - 30) div 2,
              30, 20, 'Add', onpackcreate);
          end;
        end //
        else
        begin
          newcard; // creates the new card menu
          if Deckshower <> nil then // removes the deck picker
          begin
            Deckshower.free;
            Deckshower := nil;
          end;
          if packshower <> nil then // removes the deck picker
          begin
            packshower.free;
            packshower := nil;
          end;
          if buttons <> nil then
          begin
            for i := (buttons.count - 1) downto 0 do
            begin
              buttons[i].free;
            end;
            buttons := nil;
          end;
        end;
      end;
    end;
  end
  else
  begin // error message for none selected
    showmessage('Please select a pack.');
  end;

end;

procedure TMenu.onratingpick(Sender: TObject);
var
  rating, i, currentid: integer;
  t: tflashcard;
  tyyy: char;
  an: boolean;
begin
if current='g' then
if nflashcards[0].correct='t' then //increases count if it was right
 count:=count+1;

  t := nil;
  cardid := nflashcards[0].id;
  rating := strtoint((Sender as TButton).caption);
  with dm.Cardset do
  begin
    Close;
    CommandText := ('Select CardID,Userrating from Card where Cardid=:ID');
    Close;
    Parameters.ParamByName('ID').value := inttostr(cardid);
    open;
    edit;
    FieldValues['Userrating'] := rating;
    post;
    Close;
  end;
  nflashcards[0].updatestats(rating);

  // free this card
  if nflashcards <> nil then
  begin
    for i := nflashcards.count - 1 downto 0 do
    begin
      nflashcards[i].free;
    end;
    nflashcards := nil;
  end;
  nflashcards := tobjectlist<tflashcard>.Create;

  // generate a new card
  if random = true then
    generatedcard(cardids, packnames, lastids, currentid)
  else
    currentid := getcard(cardids, lastids); // gets a card id

  if (t = nil) and (currentid < 50000) then
  // if the flashcard isant existing
  begin
    gettype(currentid, tyyy);
    an := getanswer;
    if (tyyy = 'o') or (tyyy = 't') then
      an := false;
    t := tflashcard.Create(MainPanel, MainPanel.Width - 60,
      MainPanel.height div 3 * 2, 30, 30, currentid, onratingpick,
      ondeleteclick, oneditclick, tyyy, an);
  end;
  if currentid < 50000 then
    nflashcards.add(t);


  // update tiny picture graph
  // calculate new stats, update all stats and badges
  // free this flashcard
  // select next card

end;

procedure clearstats;
var
i:integer;
temp:string;
begin
with dm.cardset do  //clears card stats
begin
 close;
 commandtext:=('select * from card');
 open;
 edit;
 first;
 while not eof do
  begin
    edit;
    fieldvalues['Cardrating']:=0;
    fieldvalues['Userrating']:=0;
    for i := 1 to 5 do
      // gets all the previous answrrs and makes them null if they arent
      begin
        temp := 'Panswer' + inttostr(i);
        if FieldValues[temp] <> null then
           FieldValues[temp]:=null;
      end;
      for i := 1 to 3 do // gets all the previous times  n makes them null
      begin
        temp := 'Time' + inttostr(i);
        if FieldValues[temp] <> null then
       FieldValues[temp]:=null;
      end;
    post;
    next;
  end;
  close;
end;

with dm.packset do  //clears pack stats
begin
 close;
 commandtext:=('select * from pack');
 open;
 edit;
 first;
 while not eof do
  begin
    edit;
    fieldvalues['Packcompletion']:=0;
    fieldvalues['Packknowledge']:=0;
    fieldvalues['cardsseen']:=0;
    post;
    next;
  end;
  close;
end;

with dm.deckset do  //clears deck stats
begin
 close;
 commandtext:=('select * from deck');
 open;
 edit;
 first;
 while not eof do
  begin
    edit;
    fieldvalues['deckcompletion']:=0;
    fieldvalues['deckknowledge']:=0;
    fieldvalues['cardsseen']:=0;
    post;
    next;
  end;
  close;
end;

with dm.achievementset do  //clears achievement stats
begin
 close;
 commandtext:=('select * from achievements');
 open;
 edit;
    fieldvalues['usercompletion']:=0;
    fieldvalues['userknowledge']:=0;
    fieldvalues['currentstreak']:=0;
    fieldvalues['correctstreak']:=0;
    fieldvalues['cardsseen']:=0;
    fieldvalues['Achievements']:=0;
    fieldvalues['Timed']:=0;
    post;
  close;
end;

with dm.badgeset do  //clears badge stats
begin
 close;
 commandtext:=('select * from badges');
 open;
 edit;
 first;
 while not eof do
  begin
    edit;
    fieldvalues['Badgeprogress']:=0;
    fieldvalues['completed']:=false;
    post;
    next;
  end;
  close;
end;

end;



procedure TMenu.resetstats(sender: tobject);
var
rating:ratingstats;
i:integer;
begin
clearstats;
Bstatsclick(ltitle);
end;


procedure TMenu.createbadge(Top, left: integer; Locked: boolean;
  title, prog: string);
var
  B: Tbadges;
begin
  B := Tbadges.Create(MainPanel, Top, left, Locked, title, prog);
  Badgearray.add(B);
end;

procedure TMenu.createbadges(page: integer);
// creates all the badges in the correct posiiton
var
  i, left, Top, totalbadges, onpage, id: integer;
  title, progress: string;
  unloc: boolean;
begin
  // gettotalbadges from db
  dm.Achievementset.Close;
  dm.Achievementset.CommandText := 'select Badges from Achievements';
  dm.Achievementset.open;
  totalbadges := dm.Achievementset.FieldValues['Badges'];
  if (totalbadges - page * 18) >= 0 then
    onpage := 18
  else
    onpage := totalbadges - ((page - 1) * 18);
  dm.Badgeset.Close;
  dm.Badgeset.CommandText := 'Select * from badges where BadgeID=:BadgeID';
  for i := 0 to onpage - 1 do
  // makes sure correct number are created on this page;
  begin
    left := 5 + (i mod 6) * 116;
    Top := 10 + (i div 6) * 190;
    // get correct badge;
    id := (page - 1) * 18 + i + 1;
    with dm.Badgeset do
    begin
      Parameters.ParamByName('BadgeID').value := inttostr(id);
      open;
      title := FieldValues['BadgeName'];
      unloc := FieldValues['Completed'];
      if unloc = true then
        // makes it work with the colour change and picture change.
        unloc := false
      else
        unloc := true;
      progress := inttostr(FieldValues['BadgeProgress']) + '/' +
        inttostr(FieldValues['Progressneeded']);
      Close;
    end;

    createbadge(Top, left, unloc, title, progress);
  end;
end;

procedure TMenu.badgepageclick(Sender: TObject);
var
  cap, number: string;
  i: integer;
begin
  cap := (Sender as TButton).caption;
  for i := 6 to length(cap) do
    number := number + cap[i];

  if Badgearray <> nil then // clears the badges
  begin
    for i := (Badgearray.count - 1) downto 0 do
    begin
      Badgearray[i].free;
    end;
    Badgearray := nil;
  end;
  if Badgearray = nil then
    Badgearray := tobjectlist<Tbadges>.Create;
  createbadges(strtoint(number));
end;

procedure TMenu.BbadgeClick(Sender: TObject); // sets board to displayed badges
var
  i, totalbadges, pages: integer;
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Badges';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  if Badgearray = nil then
    Badgearray := tobjectlist<Tbadges>.Create;

  // get total badges from db
  dm.Achievementset.Close;
  dm.Achievementset.CommandText := 'select Badges from Achievements';
  dm.Achievementset.open;
  totalbadges := dm.Achievementset.FieldValues['Badges'];

  createbadges(1);
  buttons := tobjectlist<TButton>.Create;
  pages := (totalbadges div 18) + 1;
  if totalbadges = 18 then
    pages := 1;
  if totalbadges = 36 then
    pages := 2;
  if totalbadges = 54 then
    pages := 3;
  for i := 1 to pages do
    CreateButton(550, ((700 div (pages + 1)) * i) - 25, 50, 40,
      'Page ' + inttostr(i), badgepageclick);
end;

procedure TMenu.BCreatecardClick(Sender: TObject);
// sets board to create card menu
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Create Cards';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  Current := 'c'; // sets the thing so it knows what flashcard mode its in
  if Deckshower = nil then
    Deckshower := Tdeckdisplay.Create(MainPanel, 'n');
  Deckshower.furnish(MainPanel); // shows the decks
  buttons := tobjectlist<TButton>.Create;
  CreateButton(200, 325, 50, 20, 'Continue', ondeckpick);
end;

procedure TMenu.BFlashcardClick(Sender: TObject);
// sets board to flashcard choosing menu
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Flashcards';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  Current := 'f';
  if Deckshower = nil then
    Deckshower := Tdeckdisplay.Create(MainPanel, 'f');
  Deckshower.furnish(MainPanel); // shows the decks
  buttons := tobjectlist<TButton>.Create;
  CreateButton(200, 325, 50, 20, 'Continue', ondeckpick);
end;

procedure TMenu.BoptionsClick(Sender: TObject); // opens options menu
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Options';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  Opmenu := Optionsmenu.Create(MainPanel);
end;

procedure TMenu.BstatsClick(Sender: TObject); // opens stats board
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Statistics';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  statmenu := mainstats.Create(MainPanel);
  buttons:=tobjectlist<tbutton>.create;
  createbutton(500,(mainpanel.Width-25) div 2, 50,20,'Reset',resetstats);
end;

procedure TMenu.BToolClick(Sender: TObject); // opens maths tool selector
var
  yy: ycoef;
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Graph';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  yy[1] := 1; //
  yy[2] := 0;
  Graph := tgraph.Create('-', yy, MainPanel, MainPanel.Width - 40,
    MainPanel.height - 140, 20, 20);
  edits := tobjectlist<tedit>.Create;
  CreateEdit(MainPanel.height - 70, 20, 450, 20, '');
  buttons := tobjectlist<TButton>.Create;
  CreateButton(MainPanel.height - 70, 490, 85, 20, 'Add Line', addline);
  CreateButton(MainPanel.height - 70, 595, 85, 20, 'New Graph', newgraph);
end;

procedure TMenu.newgraph(Sender: TObject);
var
  yy: ycoef;
begin
  Graph.free;
  Graph := nil;
  yy[1] := 1; // delete later
  yy[2] := 0;
  Graph := tgraph.Create('-', yy, MainPanel, MainPanel.Width - 40,
    MainPanel.height - 140, 20, 20);
end;

procedure TMenu.addline(Sender: TObject);
var
  yy: ycoef;
  equation: string;
begin
  if edits[0].text <> '' then
  begin
    equation := edits[0].text;
    yy := getycoef(equation);
    Graph.draw(equation, yy)
  end;

end;

procedure TMenu.BViewClick(Sender: TObject); // set board to viewing a deck
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Decks';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  Current := 'v';
  if Deckshower = nil then
    Deckshower := Tdeckdisplay.Create(MainPanel, 'f');
  Deckshower.furnish(MainPanel); // shows the decks
  buttons := tobjectlist<TButton>.Create;
  CreateButton(200, 325, 50, 20, 'Continue', ondeckpick);
end;

procedure TMenu.BGamesClick(Sender: TObject);
var
  a: tuserrating;
  // sets board to games choosing board
begin
  ClearBoard; // deletes all the entities from the last action.
  LTitle.caption := 'Timed Flashcards';
  LTitle.left := (MainPanel.Width - LTitle.Width) div 2;
  Current := 'g';
  if Deckshower = nil then
    Deckshower := Tdeckdisplay.Create(MainPanel, 'f');
  Deckshower.furnish(MainPanel); // shows the decks
  buttons := tobjectlist<TButton>.Create;
  CreateButton(200, 325, 50, 20, 'Continue', ondeckpick);
end;

procedure TMenu.BexportClick(Sender: TObject);
// Opens the user Manual
begin
  ShellExecute(Handle, 'open', PChar(Extractfilepath('UserManual.docx')+'UserManual.docx'), nil, nil, SW_SHOW);
end;

end.
