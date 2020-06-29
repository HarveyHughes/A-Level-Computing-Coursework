unit Uflashcard;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.DateUtils,
  System.Classes, Vcl.Graphics, ugraph, udeckpicker,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, generics.collections,
  Vcl.StdCtrls;

type

  ratings = class
    Cardid, Userrating, CardRating: integer;
    constructor create;
  end;

  tratinglist = tobjectlist<ratings>;
  prob = array [1 .. 5] of integer;
  crate = array [1 .. 5] of boolean;
  answs = array [1 .. 5] of string;

  Tfav = class
  private

  public
    stat: boolean;
    Cardid: integer;
    Star: timage;
    constructor create(Card: tpanel; state: boolean; width, ID: integer);
    destructor free;
    procedure click(sender: tobject);
    procedure updatefavdb;
  end;

  Tuserrating = class
  private
  public
    Panel: tpanel;
    Titl: tlabel;
    buts: array [1 .. 5] of tbutton;
    constructor create(Card: tpanel; current, width, height: integer;
      click: tnotifyevent);
    destructor free;
  end;

  Toption = class // make word for a lable and a graph
  private
    Panel: tpanel;
  public
    typ: char;
    Option, answe: tlabel;
    Graph: tgraph;
    // choose:tcheckbox;
    choose: tradiobutton; // (make parent the flashcard);
    constructor create(Card: tpanel; ty: char;
      height, width, top, left, number: integer; answer: string);
    destructor free;
  end;

  tcopy = class
    Cardid, did: integer;
    Card: tpanel;
    deckshower: tdeckdisplay;
    packshower: tpackdisplay;
    buttons: tobjectlist<tbutton>;
    title: tlabel;
    constructor create(Panel: tpanel; ID: integer);
    destructor free;
    Procedure CreateButton(top, left, width, height: integer; caption: string;
      click: tnotifyevent);
    procedure ondeckpick(sender: tobject);
    procedure onpackpick(sender: tobject);
  end;

  TFlashcard = class
  private

  public
    Card, mainpanel: tpanel;
    Question, answer: tlabel; // for showing the question and answer
    AnswerBox: tedit; // for inputting the answer
    Fav: Tfav; // shows if its a fav
    Front, an: boolean;
    // front is for the card state, an if for if an answer is needed
    Edit, Delete, Copy: tbutton;
    // allows editing ,deletion and copying of cards
    Rate: Tuserrating; // user raring menu
    ty: char; // shows what the flashcardis beign used for. u for using in pack, v for view
    ID, cur, flips: integer; // shows the current id
    c: tnotifyevent; // tp store the procedure call
    correct: char;
    time1, time2: tdatetime;
    given: string;
    copymenu: tcopy;

    // for options
    num: integer;
    Options: tobjectlist<Toption>;

    // for graph
    Graph: tgraph;
    equation: string;
    constructor create(Panel: tpanel; width, height, top, left, Cardid: integer;
      click, deletee, editt: tnotifyevent; typ: char; answe: boolean);
    destructor free;
    Procedure Flipcard(sender: tobject);
    procedure updatestats(Userrating: integer);
    procedure updatebadges(startid, endid: integer);
    procedure updatepercents(Userrating: integer);
    procedure getaverages(packid: integer; var usercompl, userkno: integer);
    Procedure del;
    procedure copyy(sender: tobject);
  end;

  tcardstats = class
    crating, urating, time1, time2, time3, r, t: tlabel;
    ratingpanel, cp, up, timepanel: tpanel;
    constructor create(Card: tpanel; c, u, t1, t2, t3: integer);
    destructor free;
  end;

  tpan = class
    answers: array [1 .. 5] of tlabel;
    answerpanel: tpanel;
    a: tlabel;
    constructor create(Card: tpanel; an: answs; r: string);
    destructor free;
  end;

  tflashback = class
    Card: tpanel;
    answer: tlabel;
    Stats: tcardstats;
    panswers: tpan;
    constructor create(menu: tpanel; top, left, width, height, Cardid: integer);
    destructor free;
  end;

function getcard(cardids: tlist<integer>; var lastids: tlist<integer>): integer;
procedure generatedcard(cardids: tlist<integer>; typ: tlist<string>;
  var lastids: tlist<integer>; var ID: integer);
procedure addcardtodb(Question, answer, equation: string;
  Options: tlist<string>; cardtype: char; did, pid: integer; Fav: boolean;
  var Cardid: integer);

implementation

uses UDM;


function compareanswer(given, expected: string): boolean;
var
  avg, ave, i: integer;
begin
  result := false;
  given := Uppercase(given);
  expected := Uppercase(expected);
  given:=deletespaces(given);
  expected:=deletespaces(expected);
  if given = expected then
    result := true
  else
  begin
    if given.length > 1 then
    begin
      avg := 0;
      for i := 1 to given.length do
        avg := avg + ord(given[i]);
      avg := avg div given.length;

      ave := 0;
      for i := 1 to expected.length do
        ave := ave + ord(expected[i]);
      ave := ave div expected.length;

      if (ave < 1.001 * avg)  then
        if avg<=ave then
        result := true // if theyre within 1% theyre similar enough
      else if (ave > 0.999 * avg)  then
        if avg>=ave then
        result:=true
    end;
  end;
end;

{ filling a card }

procedure addcardtodb(Question, answer, equation: string;
  Options: tlist<string>; cardtype: char; did, pid: integer; Fav: boolean;
  var Cardid: integer);
var
  temp: string;
  i, statc, statu, count: integer;
begin
  with dm.cardset do // creates a new card
  begin
    Close;
    CommandText := ('Select * from card');
    Close;
    open;
    insert;
    FieldValues['Question'] := Question;
    FieldValues['Answer'] := answer;
    FieldValues['Equation'] := equation;
    FieldValues['Cardtype'] := cardtype;
    FieldValues['Favourite'] := Fav;
    FieldValues['Options'] := Options.count;
    FieldValues['Cardrating'] := 0;
    FieldValues['Userrating'] := 0;
    for i := 1 to Options.count do
    begin
      temp := 'Option' + inttostr(i);
      FieldValues[temp] := Options[i - 1];
    end;
    post;
    Cardid := FieldValues['Cardid']; // gets the card id
    Close;
  end;
  with dm.cardpackset do // adds reference linking pack and card
  begin
    Close;
    CommandText := 'select * from CardPack';
    Close;
    open;
    insert;
    FieldValues['CardID'] := Cardid;
    FieldValues['PackID'] := pid;
    post;
    Close;
  end;
  with dm.packset do // updates number of cards in pack
  begin
    Close;
    CommandText := 'select * from Pack where PackID=:PackID';
    Close;
    Parameters.ParamByName('PackID').value := inttostr(pid);
    open;
    Edit;
    FieldValues['packcompletion'] :=
      (FieldValues['packcompletion'] div (FieldValues['Packsize'] + 1)) *
      FieldValues['Packsize']; // updats the stats
    FieldValues['packknowledge'] :=
      (FieldValues['packknowledge'] div (FieldValues['Packsize'] + 1)) *
      FieldValues['Packsize'];
    FieldValues['Packsize'] := FieldValues['Packsize'] + 1;
    post;
    Close;
  end;
  statc := 0;
  statu := 0;
  count := 0;
  with dm.deckset do // updates number of cards in deck
  begin
    Close;
    CommandText := 'select * from deck where deckid=:deckid';
    Close;
    Parameters.ParamByName('DeckID').value := inttostr(did);
    open;
    Edit;
    FieldValues['deckcompletion'] :=
      (FieldValues['deckcompletion'] div (FieldValues['cards'] + 1)) *
      FieldValues['cards']; // updats the stats
    FieldValues['deckknowledge'] :=
      (FieldValues['deckknowledge'] div (FieldValues['cards'] + 1)) *
      FieldValues['cards'];
    FieldValues['cards'] := FieldValues['cards'] + 1;
    post;
    Close;
    CommandText := 'select cards,deckcompletion,deckknowledge from deck';
    open;
    first;
    while not eof do
    begin
      count := count + 1;
      statc := statc + FieldValues['deckcompletion'];
      statu := statu + FieldValues['deckknowledge'];
      next;
    end;
    Close;
  end;
  statc := statc div count;
  statu := statu div count;
  with dm.achievementset do // updates user stats
  begin
    Close;
    CommandText := 'select * from achievements';
    open;
    Edit;
    FieldValues['usercompletion'] := statc;
    FieldValues['userknowledge'] := statu;
    post;
    Close;
  end;
end;

procedure addcard(list: tobjectlist<ratings>; Card: ratings);
begin
  list.Add(Card)
end;

Function getratings(cardids, lastids: tlist<integer>): tratinglist;
var
  r: ratings;
  i, j, adjust: integer;
  onlast: boolean;
  rl: tratinglist;
begin
  rl := tobjectlist<ratings>.create;
  for i := 1 to cardids.count do
  begin
    r := ratings.create;
    with dm.cardset do
    begin
      Close;
      CommandText :=
        ('Select Userrating,Cardrating from Card where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(cardids[i - 1]);
      open;
      r.Cardid := cardids[i - 1];
      r.Userrating := FieldValues['Userrating'];
      r.CardRating := FieldValues['Cardrating'];
      Close;
    end;
    onlast := false;

    if lastids.count > 1 then // checks its at least 2 big
    begin
      adjust := lastids.count div 2; // makes it so at max 6 cards are discarded
      repeat
        adjust := adjust div 2;
      until adjust < 6;;
      for j := (lastids.count - adjust) to (lastids.count - 1) do
      // checks the last half of the cards done or 6 if half is bigger then 15
      begin
        if lastids[j] = r.Cardid then
          onlast := true;
      end;
    end
    else if lastids.count <> 0 then
    begin
      if lastids[0] = r.Cardid then
        onlast := true;
    end;

    if (onlast = false) or (cardids.count = 1) then
    begin
      // only add the card if it hasnt been seen recently, or if it has its the only option
      addcard(rl, r);
      // rl.Add(r);
    end;
  end;
  result := rl;
end;

function getprob(contains: crate): prob;
var
  count, i: integer;
  c: tlist<integer>;
begin
  count := 0;
  c := tlist<integer>.create;
  for i := 1 to 5 do
  begin
    if contains[i] = true then
    begin
      count := count + 1;
      c.Add(i);
    end;
    result[i] := 0;
  end;

  case count of // edits the probs to the correct amount
    1:
      result[c[0]] := 100;
    2:
      begin
        result[c[0]] := 70;
        result[c[1]] := 30;
      end;
    3:
      begin
        result[c[0]] := 50;
        result[c[1]] := 30;
        result[c[2]] := 20;
      end;
    4:
      begin
        result[c[0]] := 35;
        result[c[1]] := 25;
        result[c[2]] := 20;
        result[c[3]] := 10;
      end;
    5:
      begin
        result[1] := 35;
        result[2] := 25;
        result[3] := 20;
        result[4] := 12;
        result[5] := 8;
      end;
  end;
end;

function getcard(cardids: tlist<integer>; var lastids: tlist<integer>): integer;
var
  ra, rc: tratinglist;
  a: ratings;
  i, ID, rando, Rate, rando2: integer;
  contains: crate; // to see if it has different ratings
  chances: prob;
begin
  ra := getratings(cardids, lastids); // gets the rating sof the relevant card
  ID := -1;
  for i := 1 to 5 do // initilises the counter
    contains[i] := false;
  for i := 0 to ra.count - 1 do
  begin
    if (ID = -1) and (ra[i].Userrating = 0) then
    begin
      // looks to see if any are unseen, if they are pick it
      ID := ra[i].Cardid;
    end;
    if ra[i].Userrating <> 0 then // sees what ratings there are
      contains[ra[i].Userrating] := true;
  end;

  if ID = -1 then
  begin
    chances := getprob(contains);
    randomize;
    rando := random(100) + 1;
    if rando <= chances[1] then // gets the rating number
      Rate := 1
    else if rando <= chances[1] + chances[2] then
      Rate := 2
    else if rando <= chances[1] + chances[2] + chances[3] then
      Rate := 3
    else if rando <= chances[1] + chances[2] + chances[3] + chances[4] then
      Rate := 4
    else if rando <= chances[1] + chances[2] + chances[3] + chances[4] +
      chances[5] then
      Rate := 5;

    a := ratings.create;
    rc := tobjectlist<ratings>.create;
    for i := 0 to ra.count - 1 do // fills a new list with the new card options
    begin
      if ra[i].Userrating = Rate then
      begin
        a.Cardid := ra[i].Cardid;
        a.Userrating := ra[i].Userrating;
        a.CardRating := ra[i].CardRating;
        addcard(rc, a);
      end;
    end;
    if rc.count = 1 then
      ID := rc[0].Cardid
    else
    begin
      repeat // loops until a card has been chosen
        rando := random(rc.count); // gets a randomposition
        rando2 := random(100) + 1; // gets a %
        if rando2 >= rc[rando].CardRating then
          // only chooses the card when the random number is higher then the rating, meaning lower ratings are chosen more
          ID := rc[rando].Cardid;
      until (ID <> -1);
    end;
  end;
  result := ID;
  lastids.Add(ID) // adds the new card to last ids
end;

function getlevel(number, avur, avcr, cardsseen: integer): integer;
// out puts what level of card to generate
var
  i,rando: integer;
begin

  result := 1; // its a level one as default few cards have been made
  if (cardsseen > 6) and ((avur <= 3) or (avcr <= 50)) then
  // if more then 6 have been seen but ratings are low
  begin
    i := 1;
    repeat
      i := i + 1;
      if cardsseen <= (7 * i) then
        // gives the level first 6=1, next 7 =level 2, etc
        result := i;
    until (result <> 1) or (i = number);
    if i = number then
      result := number;
  end
  else if (cardsseen > 6) and ((avur <= 4) or (avcr <= 75)) then
  // if they rated slightly better
  begin
    i := 1;
    repeat
      i := i + 1;
      if cardsseen <= 6 + (i - 1) * 4 then
        // gives the level first 6=1, next 4 =level 2, etc
        result := i;
    until (result <> 1) or (i = number);
    if i = number then
      result := number;
  end
  else // rated very high
  begin
    i := 0;
    repeat
      i := i + 1;
      if cardsseen <= 6 + (i - 1) * 2 then
        // gives the level first 6=1, next 2 =level 2,  etc
        result := i;
    until (result <> 1) or (i = number) or (cardsseen < 7);
    if i = number then
      result := number;
  end;
  rando:=random(3);
  if rando=2 then   //33%change to get another lower level
  begin
   result:=result-random(result);
  end;
end;

procedure addpoly(t: tpoly; var polylist: tobjectlist<tpoly>);
begin
  polylist.Add(t);
end;

function generatepoly(number, divisons: integer): tobjectlist<tpoly>;
var
  rando, i, j: integer;
  t: tpoly;
  tempc, tempp: real;

begin
  result := tobjectlist<tpoly>.create;
  rando := random(number) + 1; // gets the size of polynomial
  for i := 1 to rando do
  begin
    tempc := (random(20 * divisons + 1) - 10 * divisons) / divisons;
    // gets a number between -10 and 10 in the correct steps
    if tempc = 0 then
      tempc := 1;
    tempp := (random(20 * divisons + 1) - 10 * divisons) / divisons;
    // gets a number between -10 and 10 in the correct steps
    for j := 0 to result.count - 1 do
    begin
      if result[j].power = tempp then
        tempp := (random(20 * divisons + 1) - 10 * divisons) / divisons;
      // gets a number between -10 and 10 in the correct steps
    end;
    t := tpoly.create(tempc, tempp);
    result.Add(tpoly.create(tempc, tempp));
    t.free;
    t := nil;
  end;
end;

Function Differentiatepoly(polylist: tobjectlist<tpoly>): tobjectlist<tpoly>;
var
  i: integer;
  tempc, tempp: real;
begin
  result := tobjectlist<tpoly>.create;
  for i := 0 to polylist.count - 1 do
  begin
    tempc := polylist[i].coefficent * polylist[i].power;
    tempp := polylist[i].power - 1;
    if tempp <> -1 then
      result.Add(tpoly.create(tempc, tempp));
  end;
end;

function removetrailing0(tempr: string): string;
var
  j, pos: integer;
  temp2: string;
begin
  pos := length(tempr);
  if tempr[pos] = '0' then
  begin
    temp2 := '';
    for j := 1 to length(tempr) - 1 do
      temp2 := temp2 + tempr[j]; // cuts off the trailing 0
    pos := length(tempr) - 1;
    if tempr[pos] = '0' then
    begin
      tempr := '';
      for j := 1 to length(temp2) - 2 do
        tempr := tempr + temp2[j]; // cuts off the second trailing 0  and .
      result := tempr;
    end
    else
      result := temp2;
  end
  else
    result := tempr;
end;

function polytostring(polylist: tobjectlist<tpoly>): string;
var
  i, j: integer;
  tempr, Finalres: string;
begin
  result := '';
  for i := 0 to polylist.count - 1 do
  begin
  if i<>0 then
  begin
    if (polylist[i-1].coefficent<>0) and (polylist[i].coefficent>0) then
    result:=result +' + ';    //adds a plus is its in the middle
  end;
    tempr := floattostrf(polylist[i].coefficent, ffFixed, 4, 2);
    Finalres := removetrailing0(tempr);
    if strtofloat(Finalres) <> 0 then // doesnt add a 0 coefficent poly
    begin
      if i<>0 then result:=result+ ' ' ; //adds a space as requested by user

      result := result + Finalres; // adds the coefficent
      if polylist[i].power <> 0 then // if its not a integer
      begin
        tempr := floattostrf(polylist[i].power, ffFixed, 4, 2);
        // adds the power
        Finalres := removetrailing0(tempr);
        if strtofloat(Finalres) <> 1 then
          result := result + 'X^' + Finalres
        else
          result := result + 'X'; // doesnt ad a power to x^1
      end;
    end;
  end;
end;

function differentiatefunc(f: string; fco: integer;
  apoly: tobjectlist<tpoly>): string;
begin
  if f = 'tan' then
    result := inttostr(fco) + '(' + polytostring(Differentiatepoly(apoly)) + ')'
      + 'sec^2(' + polytostring(apoly) + ')'
  else if f = 'cos' then
    result := inttostr(fco + -1) + '(' + polytostring(Differentiatepoly(apoly))
      + ')' + 'sin(' + polytostring(apoly) + ')'
  else if f = 'sin' then
    result := inttostr(fco) + '(' + polytostring(Differentiatepoly(apoly)) + ')'
      + 'cos(' + polytostring(apoly) + ')'
  else if f = 'ln' then
    result := inttostr(fco) + '(' + polytostring(Differentiatepoly(apoly)) + ')'
      + '/(' + polytostring(apoly) + ')'
  else if f = 'e' then
    result := inttostr(fco) + '(' + polytostring(Differentiatepoly(apoly)) +
      'e^(' + polytostring(apoly) + ')'
end;

procedure generateequation(var b, a: string);
var
  rando, funccoef: integer;
  apoly: tobjectlist<tpoly>;
begin
  funccoef := random(7) - 4;
  if funccoef = 0 then
    funccoef := 1;

  apoly := tobjectlist<tpoly>.create;
  apoly.Add(tpoly.create(random(21) - 10, 1)); // makes a nX^1 polynomial

  rando := random(6);
  case rando of
    0:
      begin // polynomial
        b := polytostring(apoly);
        a := polytostring(Differentiatepoly(apoly));
      end;
    1:
      begin // cos
        b := inttostr(funccoef) + 'cos(' + polytostring(apoly) + ')';
        a := differentiatefunc('cos', funccoef, apoly);
      end;
    2:
      begin // tan
        b := inttostr(funccoef) + 'tan(' + polytostring(apoly) + ')';
        a := differentiatefunc('tan', funccoef, apoly);
      end;
    3:
      begin // sin
        b := inttostr(funccoef) + 'sin(' + polytostring(apoly) + ')';
        a := differentiatefunc('sin', funccoef, apoly);
      end;
    4:
      begin // ln
        b := inttostr(funccoef) + 'ln(' + polytostring(apoly) + ')';
        a := differentiatefunc('ln', funccoef, apoly);
      end;
    5:
      begin // e
        b := inttostr(funccoef) + 'e^(' + polytostring(apoly) + ')';
        a := differentiatefunc('e', funccoef, apoly);
      end;
  end;
end;

Function Createcard(topic: string; avur, avcr, cardsseen: integer): integer;
// makes a new card
var
  answer, Question, equation, tempe, func, funcb1, funcb2, funca1, funca2,
    a: string;
  Options: array [1 .. 6] of string;
  typ: char;
  op, opc, rando, i, j, packid, level, funccoef, xcoef, n, c: integer;
  oplist: tlist<string>;
  qpoly, apoly: tobjectlist<tpoly>;

begin
  answer := '';
  Question := '';
  equation := '';
  for i := 1 to 6 do
  begin
    Options[i] := '';
  end;
  randomize;
  // choose correct format
   if topic = 'Modulus' then
  begin
    packid := 2;
    level := getlevel(2, avur, avcr, cardsseen);
    if level = 1 then
    begin
      apoly := tobjectlist<tpoly>.create;
      apoly.Add(tpoly.create(random(11) - 6, 1)); // makes a nX^1 polynomial
      apoly.Add(tpoly.create(random(7) - 4, 0)); // adds an integer
      n := random(7) - 4; // gets a intger
      a := inttostr(n);
      if n >= 0 then
        a := '+' + a;
      c := random(2);
      if c = 0 then
        c := -1;
      equation := 'y=' + inttostr(c) + '|' + polytostring(apoly) + '|' + a;
      Question := 'Which Graph shows the line ' + equation;
      op := random(5) + 2;
      typ := 't';
      opc := random(op) + 1; // gets the correct posotion;
      answer := inttostr(opc);
      for i := 1 to op do
      begin
        if i = opc then // if its th correct postiton
        begin
          Options[i] := equation;
        end
        else
        begin
          apoly.free;
          apoly := nil;
          apoly := tobjectlist<tpoly>.create;
          apoly.Add(tpoly.create(random(11) - 6, 1)); // makes a nX^1 polynomial
          apoly.Add(tpoly.create(random(7) - 4, 0)); // adds an integer
          n := random(7) - 4; // gets a intger
          a := inttostr(n);
          if n >= 0 then
            a := '+' + a;
          c := random(2);
          if c = 0 then
            c := -1;
          tempe := 'y=' + inttostr(c) + '|' + polytostring(apoly) + '|' + a;
          Options[i] := tempe;
        end;
      end;

    end
    else if level = 2 then
    begin
      apoly := tobjectlist<tpoly>.create;
      apoly.Add(tpoly.create(random(5) - 2, random(3)+2)); // makes a nX^2,3,4 polynomial
      apoly.Add(tpoly.create(random(5) - 2, 1)); // makes a nX^1 polynomial
      apoly.Add(tpoly.create(random(3) - 1, 0)); // adds an integer
      n := random(7) - 4; // gets a intger
      a := inttostr(n);
      if n >= 0 then
        a := '+' + a;
      c := random(2);
      if c = 0 then
        c := -1;
      equation := 'y=' + inttostr(c) + '|' + polytostring(apoly) + '|' + a;
      Question := 'Which Graph shows the line ' + equation;
      op := random(5) + 2;
      typ := 't';
      opc := random(op) + 1; // gets the correct posotion;
      answer := inttostr(opc);
      for i := 1 to op do
      begin
        if i = opc then // if its th correct postiton
        begin
          Options[i] := equation;
        end
        else
        begin
          apoly.free;
          apoly := nil;
          apoly := tobjectlist<tpoly>.create;
          apoly.Add(tpoly.create(random(5) - 2,random(3)+ 2)); // makes a nX^2,3,4 polynomial
          apoly.Add(tpoly.create(random(5) - 2, 1)); // makes a nX^1 polynomial
          apoly.Add(tpoly.create(random(3) - 1, 0)); // adds an integer
          n := random(7) - 4; // gets a intger
          a := inttostr(n);
          if n >= 0 then
            a := '+' + a;
          c := random(2);
          if c = 0 then
            c := -1;
          tempe := 'y=' + inttostr(c) + '|' + polytostring(apoly) + '|' + a;
          Options[i] := tempe;
        end;
      end;
    end ;



    end
    else if topic = 'Differentiation' then
    begin
      packid := 4;
      level := getlevel(3, avur, avcr, cardsseen);
      if level = 1 then // polynomials
      begin
        // qpoly:=tobjectlist<tpoly>.create;
        qpoly := generatepoly(3, 3);
        Question := 'Differentiate: Y=' + polytostring(qpoly) +
          ' with respect to X';
        apoly := Differentiatepoly(qpoly);
        op := random(6) + 1;
        if op = 1 then // if its a normal card
        begin
          typ := 'f';
          answer := polytostring(apoly);
        end
        else // if its a options card
        begin
          typ := 'o';
          opc := random(op) + 1; // gets the correct posotion;
          answer := inttostr(opc);
          for i := 1 to op do
          begin
            if i = opc then // if its th correct postiton
            begin
              Options[i] := polytostring(apoly);
            end
            else
            begin
              Options[i] := polytostring(generatepoly(3, 3));
            end;
          end;

        end;
      end
      else if level = 2 then // ln, trig, e
      begin
        funccoef := random(21) - 10;
        if funccoef = 0 then
          funccoef := 1;
        apoly := generatepoly(2, 1);
        rando := random(3);
        tempe := '';
        if rando = 0 then // trig
        begin
          rando := random(3);
          case rando of
            0:
              func := 'sin';
            1:
              func := 'cos';
            2:
              func := 'tan';
          end;
          tempe := inttostr(funccoef) + func + '(' + polytostring(apoly) + ')';
          Question := 'Differentiate: Y=' + tempe + ' with respect to X';
          tempe := differentiatefunc(func, funccoef, apoly);
          op := random(6) + 1;
          if op = 1 then // if its a normal card
          begin
            typ := 'f';
            answer := tempe;
          end
          else // if its a options card
          begin
            typ := 'o';
            opc := random(op) + 1; // gets the correct posotion;
            answer := inttostr(opc);
            for i := 1 to op do
            begin
              if i = opc then // if its th correct postiton
              begin
                Options[i] := tempe;
              end
              else
              begin
                rando := random(3);
                case rando of
                  0:
                    func := 'sin';
                  1:
                    func := 'cos';
                  2:
                    func := 'tan';
                end;
                Options[i] := differentiatefunc(func,
                  funccoef + (random(21) - 10), generatepoly(2, 1));
              end;
            end;

          end;
        end
        else if rando = 1 then // ln
        begin
          tempe := inttostr(funccoef) + 'ln(' + polytostring(apoly) + ')';
          Question := 'Differentiate: Y=' + tempe + ' with respect to X';
          tempe := differentiatefunc('ln', funccoef, apoly);
          op := random(6) + 1;
          if op = 1 then // if its a normal card
          begin
            typ := 'f';
            answer := tempe;
          end
          else // if its a options card
          begin
            typ := 'o';
            opc := random(op) + 1; // gets the correct posotion;
            answer := inttostr(opc);
            for i := 1 to op do
            begin
              if i = opc then // if its th correct postiton
              begin
                Options[i] := tempe;
              end
              else
              begin
                Options[i] := differentiatefunc('ln',
                  funccoef + (random(21) - 10), generatepoly(2, 1));
              end;
            end;

          end;
        end
        else
        begin // e^
          tempe := inttostr(funccoef) + 'e^(' + polytostring(apoly) + ')';
          Question := 'Differentiate: Y=' + tempe + ' with respect to X';
          tempe := differentiatefunc('e', funccoef, apoly);
          op := random(6) + 1;
          if op = 1 then // if its a normal card
          begin
            typ := 'f';
            answer := tempe;
          end
          else // if its a options card
          begin
            typ := 'o';
            opc := random(op) + 1; // gets the correct posotion;
            answer := inttostr(opc);
            for i := 1 to op do
            begin
              if i = opc then // if its th correct postiton
              begin
                Options[i] := tempe;
              end
              else
              begin
                Options[i] := differentiatefunc('e',
                  funccoef + (random(21) - 10), generatepoly(2, 1));
              end;
            end;

          end;
        end;

      end
      else if level = 3 then // product and quotient rule
      begin
        generateequation(funcb1, funca1);
        generateequation(funcb2, funca2);
        rando := random(2);
        if rando = 0 then // productrule
        begin
          Question := 'Differentiate: Y=(' + funcb1 + ') * (' + funcb2 +
            ') with respect to X';
          tempe := '(' + funca1 + ')(' + funcb2 + ') + (' + funcb1 + ')(' +
            funca2 + ')'; // applying the rule
        end
        else
        begin // quotientrule
          Question := 'Differentiate: Y=(' + funcb1 + ') / (' + funcb2 +
            ') with respect to X';
          tempe := '((' + funca1 + ')(' + funcb2 + ') - (' + funcb1 + ')(' +
            funca2 + ')) / (' + funcb2 + ')^2)';
        end;

        op := random(5) + 2; // no card with 0 option

        begin
          typ := 'o';
          opc := random(op) + 1; // gets the correct posotion;
          answer := inttostr(opc);
          for i := 1 to op do
          begin
            if i = opc then // if its th correct postiton
            begin
              Options[i] := tempe;
            end
            else
            begin
              generateequation(funcb1, funca1);
              generateequation(funcb2, funca2);
              rando := random(2);
              if rando = 0 then // productrule
              begin
                Options[i] := '(' + funca1 + ')(' + funcb2 + ') + (' + funcb1 +
                  ')(' + funca2 + ')';
              end
              else
              begin // quotientrule
                Options[i] := '((' + funca1 + ')(' + funcb2 + ') - (' + funcb1 +
                  ')(' + funca2 + ')) / (' + funcb2 + ')^2)';
              end;
            end;
          end;

        end;

      end;
    end;


    oplist := tlist<string>.create;
    for i := 1 to 6 do
      if Options[i] <> '' then
        oplist.Add(Options[i]);

    addcardtodb(Question, answer, equation, oplist, typ, 1, packid,
      false, result);
    // update db

  end;

  procedure generatedcard(cardids: tlist<integer>; typ: tlist<string>;
    var lastids: tlist<integer>; var ID: integer);
  var
    ra: tratinglist;
    i, countu, countc, r: integer;
    number: prob;
  begin
    ra := getratings(cardids, lastids);
    // gets the ratings of each and removes up to 6 from last ids
    countu := 0;
    countc := 0;
    for i := 1 to 5 do
      number[i] := 0;
    for i := 0 to ra.count - 1 do
    begin
      countu := countu + ra[i].CardRating;
      countc := countc + ra[i].Userrating;
      if ra[i].Userrating <> 0 then
        number[ra[i].Userrating] := number[ra[i].Userrating] + 1;
      // counts the amount of each rating
    end;
    if (countu <> 0) and (ra.count <> 0) then
      countu := countu div ra.count; // gets the average card rating
    if (countu <> 0) and (ra.count <> 0) then
      countc := countc div ra.count;
    if ((countu > 70) and (countc >= 3)) or (countu > 85) or (countc >= 4) or
      (cardids.count < 12) then // make a new card if ratings are high
    begin
      randomize;
      r := random(typ.count);
      ID := Createcard(typ[r], countu, countc, cardids.count);
      lastids.Add(ID); // addsthe new card to lastidsids
      cardids.add(id);
    end
    else // pick an exisiting card
    begin
      ID := getcard(cardids, lastids);
    end;
  end;

  { Tfav }
  procedure Tfav.click(sender: tobject);
  begin
    if stat = true then
    begin
      stat := false;
      Star.Picture.LoadFromFile('Nfav.bmp');
      updatefavdb;
    end
    else
    begin
      stat := true;
      Star.Picture.LoadFromFile('Fav.bmp');
      updatefavdb;
    end;
  end;

  constructor Tfav.create(Card: tpanel; state: boolean; width, ID: integer);
  begin
    Star := timage.create(Card);
    Star.Parent := Card;
    Star.width := 25;
    Star.height := 25;
    Star.top := 5;
    Star.left := width - 30;
    Star.OnClick := click;
    if state = true then
      Star.Picture.LoadFromFile('Fav.bmp')
    else
      Star.Picture.LoadFromFile('Nfav.bmp');

    stat := state;
    Cardid := ID;
  end;

  destructor Tfav.free;
  begin
    Star.free;
    Star := nil;
  end;

  procedure Tfav.updatefavdb;
  begin
    with dm.cardset do
    begin
      Close;
      CommandText := ('Select Favourite,CardID from Card where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(Cardid);
      open;
      Edit;
      FieldValues['Favourite'] := stat;
      post;
      Close;
    end;
  end;

  { Tuserrating }

  constructor Tuserrating.create(Card: tpanel; current, width, height: integer;
    click: tnotifyevent);
  var
    i, w: integer;
  begin

    Panel := tpanel.create(Card);
    Panel.Parent := Card;
    Panel.width := width div 2;
    Panel.height := height div 4;
    Panel.left := width div 4; // places it in the centre
    Panel.top := (height div 8) * 5; // puts it 5/8 of the way down
    Panel.Visible := true;
    Panel.Parentbackground := false;
    case current of // makes the background the correct colour
      0:
        Panel.Color := clwhite;
      1:
        Panel.Color := clmaroon;
      2:
        Panel.Color := tcolor($008CFF);
      3:
        Panel.Color := tcolor($00D7FF);
      4:
        Panel.Color := tcolor($98FB98);
      5:
        Panel.Color := clgreen;
    end;

    Titl := tlabel.create(Panel);
    Titl.Parent := Panel;
    Titl.caption := 'Pick a Rating';
    Titl.top := 5;
    Titl.height := 15;
    Titl.left := (Panel.width - Titl.width) div 2;
    Titl.Visible := true;
    Titl.Font.Size := 10;
    Titl.Font.Style := [fsbold];

    w := ((width DIV 2) - 30) div 5;
    for i := 1 to 5 do // creates the buttons
    begin
      buts[i] := tbutton.create(Panel);
      buts[i].Parent := Panel;
      buts[i].width := w;
      buts[i].height := (height div 4) - 30;
      buts[i].top := 25;
      buts[i].left := (5 + w) * (i - 1) + 5;
      buts[i].caption := inttostr(i);
      case i of
        1:
          buts[i].Font.Color := clmaroon;
        2:
          buts[i].Font.Color := tcolor($008CFF);
        3:
          buts[i].Font.Color := tcolor($00D7FF);
        4:
          buts[i].Font.Color := tcolor($98FB98);
        5:
          buts[i].Font.Color := clgreen;
      end;
      buts[i].Visible := true;
      buts[i].OnClick := click;
    end;

  end;

  destructor Tuserrating.free;
  var
    i: integer;
  begin
    for i := 1 to 5 do
    begin
      buts[i].free;
      buts[i] := nil;
    end;
    Titl.free;
    Titl := nil;
    Panel.free;
    Panel := nil;
  end;

  { Toption }

  constructor Toption.create(Card: tpanel; ty: char;
    height, width, top, left, number: integer; answer: string);
  var
    equation: string;
    yy: ycoef;
  begin
    Panel := tpanel.create(Card);
    Panel.Parent := Card;
    Panel.width := width;
    Panel.height := height;
    Panel.left := left;
    Panel.top := top;
    Panel.Parentbackground := false;
    Panel.Color := clwhite;
    Panel.Visible := true;

    typ := ty;

    if Panel.width > 150 then
    // makes the options not create if its on view deck
    begin
      choose := tradiobutton.create(Panel);
      choose.Parent := Panel;
      choose.height := 20;
      choose.top := Panel.height - 25 + Panel.top;
      choose.width := 20;
      choose.left := (Panel.width div 2) - 10 + Panel.left;;
      choose.Visible := true;
      choose.caption := '';
      choose.Parent := Card;
      choose.Color := clwhite;
    end;

    if typ = 'o' then // if its a regual option;
    begin
      answe := tlabel.create(Panel);
      answe.Parent := Panel;
      answe.WordWrap := true;
      answe.left := 10;
      answe.width := Panel.width - 20;
      answe.Alignment := tacenter;
      answe.caption := answer;
      answe.top := 15;
      answe.Visible := true;
    end
    else if typ = 'g' then // if it s agraph kind
    begin
      answe := tlabel.create(Panel);
      answe.Parent := Panel;
      answe.WordWrap := true;
      answe.left := 10;
      answe.width := Panel.width - 20;
      answe.Alignment := tacenter;
      answe.caption := answer;
      answe.top := 15;
      answe.Visible := false;

      // creategraph
      equation := answer;
      yy := getycoef(equation);
      Graph := tgraph.create(equation, yy, Panel, Panel.width - 6,
        Panel.height - 6, 3, 3);

      if Panel.width > 150 then
      begin
        choose.left := Panel.left;
        choose.top := Panel.top;
      end;

    end;

    Option := tlabel.create(Panel);
    Option.Parent := Panel;
    Option.caption := inttostr(number);
    Option.top := 0;
    Option.height := 15;
    Option.Font.Size := 10;
    Option.left := (Panel.width - Option.width) div 2;
    if typ = 'g' then
    begin
      Option.left := Panel.width - Option.width - 5;
      Option.top := 5;
    end;

  end;

  destructor Toption.free;
  begin
    if typ = 'o' then
    begin
      answe.free;
      answe := nil;
    end;
    if typ = 'g' then
    begin
      Graph.free;
      Graph := nil;
    end;
    Option.free;
    Option := nil;
    choose.free;
    choose := nil;
    Panel.free;
    Panel := nil;
  end;

  { TFlashcard }

  procedure TFlashcard.copyy(sender: tobject);
  var
    packid: integer;
  begin
    copymenu := tcopy.create(mainpanel, ID);
  end;

  constructor TFlashcard.create(Panel: tpanel;
    width, height, top, left, Cardid: integer;
    click, deletee, editt: tnotifyevent; typ: char; answe: boolean);
  var
    questio, result, temp, temp2, temp3: string;
    f: boolean;
    i, opw, oph, opt, opl: integer;
    Optionss: tlist<string>;
    op: Toption;
    yy: ycoef;

  begin
    Card := tpanel.create(Panel);
    Card.Parent := Panel;
    Card.left := left;
    Card.width := width;
    Card.top := top;
    Card.height := height;
    Card.Visible := true;
    Card.Parentbackground := false;
    Card.Color := clmenu;
    Card.Visible := true;
    Card.OnClick := Flipcard;

    mainpanel := Panel;
    an := answe;
    ty := typ;
    Front := true;
    ID := Cardid;
    c := click;
    flips := 0;
    time1 := now;
    correct := 'n';

    with dm.cardset do
    begin
      Close;
      CommandText := ('Select * from Card where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(ID);
      open;
      cur := FieldValues['Userrating'];
      questio := FieldValues['Question'];
      result := FieldValues['Answer'];
      f := FieldValues['Favourite'];
      if (typ = 'o') or (typ = 't') then // gets the data for an options list
      begin
        num := FieldValues['Options'];
        Optionss := tlist<string>.create;
        for i := 1 to num do
        begin
          temp := 'Option' + inttostr(i);
          temp2 := FieldValues[temp];

          Optionss.Add(temp2);
        end;
      end;
      if typ = 'g' then
      begin
        equation := FieldValues['Equation'];
      end;
      Close;
    end;

     Fav := Tfav.create(Card, f, Card.width, ID);

    Edit := tbutton.create(Card);
    Edit.Parent := Card;
    Edit.top := 5;
    Edit.caption := 'Edit Card';
    Edit.left := Card.width - 35 - Edit.width;
    Edit.OnClick := editt;
    Edit.Enabled := true;
    Edit.Visible := true;

    Delete := tbutton.create(Card);
    Delete.Parent := Card;
    Delete.top := 5;
    Delete.caption := 'Delete Card';
    Delete.left := Card.width - 40 - Edit.width - Delete.width;;
    Delete.OnClick := deletee;
    Delete.Enabled := true;
    Delete.Visible := true;

    Copy := tbutton.create(Card);
    Copy.Parent := Card;
    Copy.top := 5;
    Copy.caption := 'Copy';
    Copy.left := Card.width - 45 - Edit.width - Delete.width - Copy.width;;
    Copy.OnClick := copyy;
    Copy.Enabled := true;
    Copy.Visible := true;

    if (typ = 'o') or (typ = 't') then // creates normal options
    begin
      Options := tobjectlist<Toption>.create;
      for i := 0 to num - 1 do
      begin
        opw := (Card.width - 40) div 3;
        oph := ((Card.height div 6) * 5 - 30) div 2;
        if (num = 6) or (num = 3) then // positions the cards
        begin
          opl := (i mod 3) * (opw + 10) + 10;
          if i < 3 then
            opt := Card.height div 5
          else
            opt := Card.height div 5 + oph + 10;
        end;
        if (num = 2) or (num = 4) then
        begin
          opl := (((Card.width) - (2 * opw)) div 3) + (i mod 2) *
            ((((Card.width) - (2 * opw)) div 3) + opw);
          if i < 2 then
          begin
            opt := Card.height div 5;
            if num = 2 then
              opt := Card.height div 3;
          end
          else
            opt := Card.height div 5 + oph + 10;
        end;
        if num = 3 then
        begin
          opl := (i mod 3) * (opw + 10) + 10;
          opt := Card.height div 5 + 5 + (oph div 2);
        end;
        if num = 5 then
        begin
          if i < 3 then
          begin
            opl := (i mod 3) * (opw + 10) + 10;
            opt := Card.height div 5
          end
          else
          begin
            opl := (((Card.width) - (2 * opw)) div 3) + ((i + 1) mod 2) *
              ((((Card.width) - (2 * opw)) div 3) + opw);
            opt := Card.height div 5 + oph + 10;
          end;
        end;
        if num = 1 then
        begin
          opl := Card.width div 2 - (opw div 2);
          opt := Card.width div 3;
        end;
        if typ = 'o' then
          op := Toption.create(Card, 'o', oph, opw, opt, opl, i + 1,
            Optionss[i])
        else
          op := Toption.create(Card, 'g', oph, opw, opt, opl, i + 1,
            Optionss[i]);
        Options.Add(op);
      end;
    end;

    Question := tlabel.create(Card);
    Question.Parent := Card;
    Question.caption := questio;
    if Question.width > Card.width - 60 then
    begin
      Question.WordWrap := true;
      Question.left := 30;
      Question.width := Card.width - 60;
      Question.Alignment := tacenter;
      Question.caption := questio;
    end
    else
    begin
      Question.caption := questio;
      Question.left := (Card.width - Question.width) div 2;
    end;
    Question.top := Card.height div 7;
    Question.Visible := true;
    Question.Font.Size := 10;

    answer := tlabel.create(Card);
    answer.Parent := Card;
    answer.caption := result;
    if answer.width > Card.width - 60 then
    begin
      answer.WordWrap := true;
      answer.left := 30;
      answer.width := Card.width - 60;
      answer.Alignment := tacenter;
      answer.caption := result;
    end
    else
    begin
      answer.caption := result;
      answer.left := (Card.width - answer.width) div 2;
    end;
    answer.Font.Size := 10;
    answer.top := Card.height div 3;
    answer.Visible := false;

    if an = true then // only create the answer box if its neeeded
    begin
      AnswerBox := tedit.create(Card);
      AnswerBox.Parent := Card;
      AnswerBox.width := (Card.width div 3) * 2;
      AnswerBox.left := Card.width DIV 6;
      AnswerBox.height := 30;
      AnswerBox.text := '';
      AnswerBox.Enabled := true;
      AnswerBox.Visible := true;
      AnswerBox.top := (Card.height div 8) * 5;
    end;

    if typ = 'g' then // generates a graph
    begin
      // graph.create(stufff).
      if AnswerBox <> nil then
        AnswerBox.top := Card.height - 40;
      Question.top := 45;

      temp3 := equation;
      yy := getycoef(equation);
      Graph := tgraph.create(equation, yy, Card, Card.width - 20,
        Card.height - 120, 65, 10);
      equation := temp3;
    end;
  end;

  procedure TFlashcard.del;
  var
    pack, deck: tlist<integer>;
    i, n: integer;
  begin

    if pack <> nil then
      pack.free;
    pack := tlist<integer>.create;
    // delets card pack reference
    with dm.cardpackset do
    begin
      Close;
      CommandText := ('Select * from Cardpack where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(ID);
      open;
      n := FieldValues['PackID'];
      pack.Add(n);
      Delete;
      while not eof do
      begin
        next;
        n := FieldValues['PackID'];
        pack.Add(n);
        Delete;
      end;
      Close;
    end;

    with dm.cardset do // deletes the card
    begin
      Close;
      CommandText := ('Select * from Card where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(ID);
      open;
      Delete;
      Close;
    end;
    // reduces number in pack
    for i := 1 to pack.count do
    begin
      with dm.packset do
      begin
        Close;
        CommandText := ('Select Packsize,PackID from Pack where PackID=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(pack[i - 1]);
        open;
        Edit;
        FieldValues['Packsize'] := FieldValues['Packsize'] - 1;
        post;
        Close;
      end;
    end;

    // gets deckids

    if deck <> nil then
      deck.free;
    deck := tlist<integer>.create;
    for i := 1 to pack.count do
    begin
      with dm.packdeckset do
      begin
        Close;
        CommandText := ('Select * from PackDeck where PackID=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(pack[i - 1]);
        open;
        n := FieldValues['DeckID'];
        deck.Add(n);
        while not eof do
        begin
          next;
          n := FieldValues['DeckID'];
          pack.Add(n);
        end;
        Close;
      end;
    end;

    // reduces number in deck
    for i := 1 to deck.count do
    begin
      with dm.packset do
      begin
        Close;
        CommandText := ('Select Cards,DeckID from Deck where DeckID=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(deck[i - 1]);
        open;
        Edit;
        FieldValues['Cards'] := FieldValues['Cards'] - 1;
        post;
        Close;
      end;
    end;

  end;

  procedure TFlashcard.Flipcard(sender: tobject);
  var
    i, cp: integer;
    op: boolean;

  begin
    if Front = true then // if it was on front state
    begin
      if (ty = 'f') or (ty = 'g') then
      begin
        if ((an = true) and (AnswerBox.text <> '')) or (an = false) then
        begin
          flips := flips + 1;
          if flips = 1 then
            time2 := now;
          // check answer
          if an = true then
          begin
            given := AnswerBox.text;
            if compareanswer(given, answer.caption) = true then
              correct := 't'
            else
              correct := 'f';
            if (flips = 1) and (correct = 't') then
              answer.Font.Color := clgreen
            else if (flips = 1) and (correct = 'f') then
              answer.Font.Color := clmaroon;
          end;

          Front := false;
          if ty = 'g' then
          begin
            Graph.g.Visible := false;
            for i := 1 to 21 do
            begin
              if Graph.Y[i] <> nil then
                Graph.Y[i].Visible := false;
              if Graph.x[i] <> nil then
                Graph.x[i].Visible := false;
            end;
          end;
          if AnswerBox <> nil then
          begin
            AnswerBox.Enabled := false;
            AnswerBox.Visible := false;
          end;
          Question.Visible := false;
          answer.Visible := true;

          Rate := Tuserrating.create(Card, cur, Card.width, Card.height, c);
        end;
      end
      else // flipping fot options list
      begin
        op := false;
        for i := 0 to num - 1 do
        begin
          if Options[i].choose.Checked = true then
          begin
            op := true;
            cp := i + 1;
          end;
        end;
        if op = true then
        begin
          flips := flips + 1;
          if flips = 1 then
            time2 := now;
          // check answer
          given := inttostr(cp);
          if compareanswer(given, answer.caption) = true then
            correct := 't'
          else
            correct := 'f';
          if (flips = 1) and (correct = 't') then
            answer.Font.Color := clgreen
          else if (flips = 1) and (correct = 'f') then
            answer.Font.Color := clmaroon;
          Front := false;
          for i := 0 to num - 1 do
          begin
            Options[i].Panel.Visible := false;
            Options[i].Option.Visible := false;
            Options[i].answe.Visible := false;
            Options[i].choose.Visible := false;
            if ty = 't' then
              Options[i].Graph.g.Visible := false;
          end;
          Question.Visible := false;
          answer.Visible := true;
          Rate := Tuserrating.create(Card, cur, Card.width, Card.height, c);
        end;
      end;
    end
    else if Front = false then
    begin // if it was on the back
      Front := true;
      if AnswerBox <> nil then
      begin
        AnswerBox.Enabled := true;
        AnswerBox.Visible := true;
      end;
      if ty = 'g' then
      begin
        Graph.g.Visible := true;
        for i := 1 to 21 do
        begin
          if Graph.Y[i] <> nil then
            Graph.Y[i].Visible := true;
          if Graph.x[i] <> nil then
            Graph.x[i].Visible := true;
        end;
      end;

      if Options <> nil then
      begin
        for i := 0 to num - 1 do
        begin
          Options[i].Panel.Visible := true;
          Options[i].Option.Visible := true;
          Options[i].answe.Visible := true;
          Options[i].choose.Visible := true;
          if ty = 't' then
            Options[i].Graph.g.Visible := true;
        end;
      end;
      Question.Visible := true;
      answer.Visible := false;
      Rate.free;
      Rate := nil;
    end;
  end;

  destructor TFlashcard.free;
  begin
    if AnswerBox <> nil then
    begin
      AnswerBox.free;
      AnswerBox := nil;
    end;
    if Rate <> nil then
    begin
      Rate.free;
      Rate := nil;
    end;
    if Options <> nil then
    begin
      Options.free;
      Options := nil;
    end;
    if Graph <> nil then
    begin
      Graph.free;
      Graph := nil;
    end;
    Fav.free;
    Fav := nil;
    answer.free;
    answer := nil;
    Question.free;
    Question := nil;
    Edit.free;
    Edit := nil;
    Delete.free;
    Delete := nil;
    Copy.free;
    Copy := nil;
    if copymenu <> nil then
    begin
      copymenu.free;
      copymenu := nil;
    end;
    Card.free;
    Card := nil;

  end;

  procedure TFlashcard.updatebadges(startid, endid: integer);
  // updates badges linked to a streak
  var
    i: integer;
    update: boolean;
  begin
    for i := startid to endid do
    begin
      with dm.Badgeset do
      begin
        Close;
        CommandText := ('Select * from Badges where Badgeid=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(i);
        open;
        Edit;
        if FieldValues['completed'] <> true then
        begin
          FieldValues['badgeprogress'] := FieldValues['badgeprogress'] + 1;
          if FieldValues['badgeprogress'] = FieldValues['progressneeded'] then
          begin
            FieldValues['completed'] := true;
            update := true;
          end;
        end;
        post;
        Close;
      end;
    end;
    if update = true then
    begin
      showmessage('You Have Unlocked a Badge Congrats!');
      with dm.achievementset do
      begin
        Close;
        CommandText := ('Select Achievements,UserID from achievements');
        open;
        Edit;
        FieldValues['Achievements'] := FieldValues['Achievements'] + 1;
        post;
        Close;
      end;
    end;
  end;

  procedure TFlashcard.updatepercents(Userrating: integer);
  // makes a new cardrating , and changed all the ratings in deck and pack and user
  var
    newcardrating, time, t, wrong, userkno, usercompl, j, count: integer;
    deckids, packids, cardids: tlist<integer>;
    i: integer;
    temp, temp2: string;
  begin
    time := secondsbetween(time1, time2);
    newcardrating := 0;
    if (an = true) or (ty = 'o') or (ty = 't') then
    // gives points for answer when one was inputted
    begin
      if correct = 't' then
        newcardrating := 50; // 50 points for answer
      newcardrating := newcardrating + Userrating * 8; // 40 points for user
      t := (time + 40) div 5; // so it stats off with 8 secs of free time
      if t <= 8 then
      begin
        newcardrating := newcardrating + 10;
      end
      else if t <= 13 then
      begin
        newcardrating := newcardrating + 7;
      end
      else if t <= 18 then
      begin
        newcardrating := newcardrating + 4;
      end
      else if t <= 23 then
      begin
        newcardrating := newcardrating + 1;
      end
      else if t > 23 then
      begin
        newcardrating := newcardrating;
      end;
    end
    else
    begin
      newcardrating := newcardrating + Userrating * 14; // 70 points for user
      t := (time + 40) div 5; // so it stats off with 8 secs of free time
      if t <= 8 then
      begin
        newcardrating := newcardrating + 30;
      end
      else if t <= 13 then
      begin
        newcardrating := newcardrating + 21;
      end
      else if t <= 18 then
      begin
        newcardrating := newcardrating + 12;
      end
      else if t <= 23 then
      begin
        newcardrating := newcardrating + 3;
      end
      else if t > 23 then
      begin
        newcardrating := newcardrating;
      end;
    end;
    wrong := 0;
    with dm.cardset do // changes previous answers, times, and userrating
    begin
      Close;
      CommandText := ('Select * from Card where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(ID);
      open;
      Edit;
      for i := 2 downto 1 do
      begin
        temp := 'time' + inttostr(i);
        temp2 := 'time' + inttostr(i + 1);
        if (FieldValues[temp2] <> null) and (FieldValues[temp] <> null) then
        begin
          FieldValues[temp2] := FieldValues[temp];
          if FieldValues[temp] > 8 then
            newcardrating := newcardrating - 10;
        end;
      end;
      FieldValues['time1'] := time;
      for i := 4 downto 1 do
      // gets all the previous answrrs and checks theyre not null
      begin
        temp := 'Panswer' + inttostr(i);
        temp2 := 'Panswer' + inttostr(i + 1);
        if (FieldValues[temp2] <> null) and (FieldValues[temp] <> null) then
        begin
          FieldValues[temp2] := FieldValues[temp];
          if compareanswer(FieldValues[temp], answer.caption) = false then
            wrong := wrong + 1;
        end;
      end;
      if an = true then
        newcardrating := newcardrating - wrong * 10;
      FieldValues['Panswer1'] := given;
      if newcardrating < 0 then
        newcardrating := 0;
      FieldValues['cardrating'] := newcardrating;
      post;
      Close;
    end;

    if packids <> nil then
      packids.free;
    packids := tlist<integer>.create;
    if deckids <> nil then
      deckids.free;
    deckids := tlist<integer>.create;

    with dm.cardpackset do // gets the packs the card is in
    begin
      Close;
      CommandText := ('Select * from Cardpack where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(ID);
      open;
      first;
      while not eof do
      begin
        packids.Add(FieldValues['PackID']);
        next;
      end;
      Close;
    end;

    for i := 0 to packids.count - 1 do
    begin
      usercompl := 0;
      userkno := 0;
      getaverages(packids[i], usercompl, userkno);
      with dm.packset do // updates the packids
      begin
        Close;
        CommandText := ('Select * from pack where packid=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(packids[i]);
        open;
        Edit;
        FieldValues['packcompletion'] := usercompl;
        FieldValues['packknowledge'] := userkno;
        post;
        Close;
      end;

      usercompl := 0;
      userkno := 0;

      with dm.packdeckset do // goes up to decks
      begin
        Close;
        CommandText := ('Select * from PackDeck where PackID=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(packids[i]);
        open;
        first;
        while not eof do
        begin
          deckids.Add(FieldValues['DeckID']);
          next;
        end;
        Close;
      end;
    end;

    if packids <> nil then
      packids.free;
    packids := tlist<integer>.create;
    usercompl := 0;
    userkno := 0;

    for i := 0 to deckids.count - 1 do // updates the decks
    begin
      with dm.packdeckset do // gets the packs a deck is in
      begin
        Close;
        CommandText := ('Select * from packdeck where deckid=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(deckids[i]);
        open;
        first;
        while not eof do
        begin
          packids.Add(FieldValues['PackID']);
          next;
        end;
        Close;
      end;
      for j := 0 to packids.count - 1 do // adds up the packids   averages
      begin
        getaverages(packids[j], usercompl, userkno);
      end;
      usercompl := usercompl div packids.count;
      userkno := userkno div packids.count;

      with dm.packset do // updates the decks
      begin
        Close;
        CommandText := ('Select * from deck where deckid=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(deckids[i]);
        open;
        Edit;
        FieldValues['deckcompletion'] := usercompl;
        FieldValues['deckknowledge'] := userkno;
        post;
        Close;
      end;
      usercompl := 0;
      userkno := 0;

    end;
    count := 0;
    with dm.cardset do // updates the user stats
    begin
      Close;
      CommandText := ('Select * from card');
      open;
      first;
      while not eof do
      begin
        usercompl := usercompl + FieldValues['userrating'];
        userkno := userkno + FieldValues['cardrating'];
        count := count + 1;
        next;
      end;
      Close;
    end;

    usercompl := usercompl div count;
    userkno := userkno div count;
    with dm.achievementset do // updates the user stats
    begin
      Close;
      CommandText := ('Select * from achievements');
      open;
      Edit;
      FieldValues['usercompletion'] := usercompl;
      FieldValues['userknowledge'] := userkno;
      post;
      Close;
    end;

  end;

  procedure TFlashcard.getaverages(packid: integer;
    var usercompl, userkno: integer);
  var
    cardids: tlist<integer>;
    j, count: integer;
  begin
    if cardids <> nil then
      cardids.free;
    cardids := tlist<integer>.create;
    with dm.cardpackset do // gets the cardids linked t the pack
    begin
      Close;
      CommandText := ('Select * from Cardpack where packid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(packid);
      open;
      first;
      while not eof do
      begin
        cardids.Add(FieldValues['Cardid']);
        next;
      end;
      Close;
    end;
    for j := 0 to cardids.count - 1 do
    begin
      with dm.cardset do // gets the cardids linked t the pack
      begin
        Close;
        CommandText := ('Select * from Card where cardid=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(cardids[j]);
        open;
        first;
        while not eof do
        begin
          usercompl := usercompl + FieldValues['userrating'];
          userkno := userkno + FieldValues['cardrating'];
          count := count + 1;
          next;
        end;
        Close;
      end;
    end;
    if (count <> 0) and (usercompl <> 0) then
      usercompl := usercompl div count;
    if (count <> 0) and (userkno <> 0) then
      userkno := userkno div count;
  end;

  procedure TFlashcard.updatestats(Userrating: integer);
  var
    pack, deck: tlist<integer>;
    i, n: integer;
  begin
    updatepercents(Userrating);
    if pack <> nil then
      pack.free;
    pack := tlist<integer>.create;

    with dm.cardpackset do // gets the packs the card is in
    begin
      Close;
      CommandText := ('Select * from Cardpack where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(ID);
      open;
      n := FieldValues['PackID'];
      first;
      while not eof do
      begin
        n := FieldValues['PackID'];
        pack.Add(n);
        next;
      end;
      Close;
    end;

    // Increases number in pack seen
    for i := 1 to pack.count do
    begin
      with dm.packset do
      begin
        Close;
        CommandText := ('Select Cardsseen,PackID from Pack where PackID=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(pack[i - 1]);
        open;
        Edit;
        FieldValues['Cardsseen'] := FieldValues['cardsseen'] + 1;
        post;
        Close;
      end;
    end;

    // gets deckids

    if deck <> nil then
      deck.free;
    deck := tlist<integer>.create;
    for i := 1 to pack.count do
    begin
      with dm.packdeckset do
      begin
        Close;
        CommandText := ('Select * from PackDeck where PackID=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(pack[i - 1]);
        open;
        first;
        while not eof do
        begin
          n := FieldValues['DeckID'];
          deck.Add(n);
          next;
        end;
        Close;
      end;
    end;

    // increases number seen in deck
    for i := 1 to deck.count do
    begin
      with dm.deckset do
      begin
        Close;
        CommandText := ('Select Cardsseen,DeckID from Deck where DeckID=:ID');
        Close;
        Parameters.ParamByName('ID').value := inttostr(deck[i - 1]);
        open;
        Edit;
        FieldValues['Cardsseen'] := FieldValues['Cardsseen'] + 1;
        post;
        Close;
      end;
    end;

    with dm.cardpackset do
    begin
      Close;
      CommandText :=
        ('Select Cardsseen,correctstreak,currentstreak,UserID from achievements');
      open;
      Edit;
      FieldValues['Cardsseen'] := FieldValues['Cardsseen'] + 1;
      if correct <> 'n' then
      begin
        if correct = 't' then
        begin
          Edit;
          FieldValues['Currentstreak'] := FieldValues['Currentstreak'] + 1;
          if FieldValues['Currentstreak'] > FieldValues['Correctstreak'] then
          begin
            Edit;
            FieldValues['correctstreak'] := FieldValues['Currentstreak'];
            updatebadges(12, 18); // updates streak stats
          end;
        end
        else
          FieldValues['Currentstreak'] := 0;
      end;
      Edit;
      post;
      Close;
    end;
    // updates the seen stats
    updatebadges(1, 11);
  end;

  { ratings }

  constructor ratings.create;
  begin
    Cardid := 0;
    Userrating := 0;
    CardRating := 0;
  end;

  { tcardstats }

  constructor tcardstats.create(Card: tpanel; c, u, t1, t2, t3: integer);
  var
    g, b, red: real;
  begin
    ratingpanel := tpanel.create(Card);
    ratingpanel.Parent := Card;
    ratingpanel.left := 5;
    ratingpanel.width := (Card.width - 20) div 3;
    ratingpanel.top := Card.height div 2;
    ratingpanel.height := Card.height div 5 * 2;
    ratingpanel.Visible := true;
    ratingpanel.Parentbackground := false;
    ratingpanel.Color := clwhite;
    ratingpanel.Visible := true;

    r := tlabel.create(ratingpanel);
    r.Parent := ratingpanel;
    r.caption := 'Ratings';
    r.left := (ratingpanel.width - r.width) div 2;
    r.top := 5;
    r.Font.Style := [fsbold];
    r.Visible := true;

    up := tpanel.create(ratingpanel);
    up.Parent := ratingpanel;
    up.width := ratingpanel.width - 10;
    up.left := 5;
    up.top := ratingpanel.height div 5;
    up.height := ratingpanel.height div 5 * 2 - 5;
    up.Visible := true;
    up.Parentbackground := false;
    case u of // makes the background the correct colour
      0:
        up.Color := clmenu;
      1:
        up.Color := clmaroon;
      2:
        up.Color := tcolor($008CFF);
      3:
        up.Color := tcolor($00D7FF);
      4:
        up.Color := tcolor($98FB98);
      5:
        up.Color := clgreen;
    end;

    urating := tlabel.create(up);
    urating.Parent := up;
    urating.caption := 'User Rating is ' + inttostr(u);
    urating.Font.Size := 7;
    urating.left := (up.width - urating.width) div 2;
    urating.top := (up.height - urating.height) div 2;
    urating.Visible := true;

    cp := tpanel.create(ratingpanel);
    cp.Parent := ratingpanel;
    cp.width := ratingpanel.width - 10;
    cp.left := 5;
    cp.height := ratingpanel.height div 5 * 2 - 5;
    cp.top := ratingpanel.height div 5 + 5 + cp.height;
    cp.Visible := true;
    cp.Parentbackground := false;
    // calculates the colour for the box
    red := 0.000003 * c * c * c * c - 0.0002 * c * c * c - 0.0988 * c * c + 7.64
      * c + 128;
    if c < 10 then
      red := red + 0.1 * red;
    if red > 255 then
      red := 255;
    if red < 0 then
      red := 0;
    g := -0.00004 * c * c * c * c + 0.0084 * c * c * c - 0.5959 * c * c +
      18.307 * c - 30;
    if g > 255 then
      g := 255;
    if g < 0 then
      g := 0;
    b := -0.2432 * c * c + 36.48 * c - 1216;
    if b > 255 then
      b := 255;
    if b < 0 then
      b := 0;
    cp.Color := rgb(round(red), round(g), round(b));
    // makes it change colour depending upon the rating

    crating := tlabel.create(cp);
    crating.Parent := cp;
    crating.caption := 'Card Rating is ' + inttostr(c) + '%';
    crating.Font.Size := 7;
    crating.left := (cp.width - crating.width) div 2;
    crating.top := (cp.height - crating.height) div 2;
    crating.Visible := true;

    timepanel := tpanel.create(Card);
    timepanel.Parent := Card;
    timepanel.left := ((Card.width - 20) div 3) * 2 + 15;
    timepanel.width := (Card.width - 20) div 3;
    timepanel.top := Card.height div 2;
    timepanel.height := Card.height div 5 * 2;
    timepanel.Visible := true;
    timepanel.Parentbackground := false;
    timepanel.Color := clwhite;
    timepanel.Visible := true;

    t := tlabel.create(timepanel);
    t.Parent := timepanel;
    t.caption := 'Times';
    t.left := (timepanel.width - r.width) div 2;
    t.top := 5;
    t.Font.Style := [fsbold];
    t.Visible := true;

    time1 := tlabel.create(timepanel);
    time1.Parent := timepanel;
    time1.caption := '1: ' + inttostr(t1);
    if t1 = 0 then
      time1.caption := '1: N/A';
    time1.left := (timepanel.width - time1.width) div 2;
    time1.top := timepanel.height div 4;
    time1.Visible := true;

    time2 := tlabel.create(timepanel);
    time2.Parent := timepanel;
    time2.caption := '2: ' + inttostr(t2);
    if t2 = 0 then
      time2.caption := '2: N/A';
    time2.left := (timepanel.width - time2.width) div 2;
    time2.top := timepanel.height div 4 * 2;
    time2.Visible := true;

    time3 := tlabel.create(timepanel);
    time3.Parent := timepanel;
    time3.caption := '3: ' + inttostr(t3);
    if t3 = 0 then
      time3.caption := '3: N/A';
    time3.left := (timepanel.width - time3.width) div 2;
    time3.top := timepanel.height div 4 * 3;
    time3.Visible := true;
  end;

  destructor tcardstats.free;
  begin
    crating.free;
    crating := nil;
    urating.free;
    urating := nil;
    time1.free;
    time1 := nil;
    time2.free;
    time2 := nil;
    time3.free;
    time3 := nil;
    r.free;
    r := nil;
    t.free;
    t := nil;
    cp.free;
    cp := nil;
    up.free;
    up := nil;
    ratingpanel.free;
    ratingpanel := nil;
    timepanel.free;
    timepanel := nil;
  end;

  { tpan }

  constructor tpan.create(Card: tpanel; an: answs; r: string);
  var
    i: integer;
  begin
    answerpanel := tpanel.create(Card);
    answerpanel.Parent := Card;
    answerpanel.left := ((Card.width - 20) div 3) + 10;
    answerpanel.width := (Card.width - 20) div 3;
    answerpanel.top := Card.height div 2;
    answerpanel.height := Card.height div 5 * 2;
    answerpanel.Visible := true;
    answerpanel.Parentbackground := false;
    answerpanel.Color := clwhite;
    answerpanel.Visible := true;

    a := tlabel.create(answerpanel);
    a.Parent := answerpanel;
    a.caption := 'Previous Answers';
    a.left := (answerpanel.width - a.width) div 2 - 8;
    a.top := 5;
    a.Font.Style := [fsbold];
    a.Visible := true;

    for i := 1 to 5 do
    begin
      answers[i] := tlabel.create(answerpanel);
      answers[i].Parent := answerpanel;
      answers[i].caption := inttostr(i) + ': ' + an[i];
      answers[i].Font.Color := clgreen;
      if an[i] = '' then
      begin
        answers[i].caption := inttostr(i) + ': N/A';
        answers[i].Font.Color := clblack;
      end
      else
      begin
        if compareanswer(an[i], r) = false then
          answers[i].Font.Color := clmaroon;
      end;
      answers[i].left := (answerpanel.width - answers[i].width) div 2;
      answers[i].top := answerpanel.height div 6 * i + 5;
      answers[i].Visible := true;
    end;
  end;

  destructor tpan.free;
  var
    i: integer;
  begin
    for i := 1 to 5 do
    begin
      answers[i].free;
      answers[i] := nil;
    end;
    a.free;
    a := nil;
    answerpanel.free;
    answerpanel := nil;
  end;

  { tflashback }

  constructor tflashback.create(menu: tpanel;
    top, left, width, height, Cardid: integer);
  var
    an, temp: string;
    times: array [1 .. 3] of integer;
    ratings: array [1 .. 2] of integer;
    panswerss: answs;
    i: integer;
  begin
    with dm.cardset do
    begin
      Close;
      CommandText := ('Select * from Card where Cardid=:ID');
      Close;
      Parameters.ParamByName('ID').value := inttostr(Cardid);
      open;
      ratings[1] := FieldValues['Userrating'];
      ratings[2] := FieldValues['Cardrating'];
      an := FieldValues['Answer'];
      for i := 1 to 5 do
      // gets all the previous answrrs and checks theyre not null
      begin
        temp := 'Panswer' + inttostr(i);
        if FieldValues[temp] <> null then
          panswerss[i] := FieldValues[temp];
      end;
      for i := 1 to 3 do // gets all the previous times  checks theyre not null
      begin
        temp := 'Time' + inttostr(i);
        if FieldValues[temp] <> null then
          times[i] := FieldValues[temp];
      end;
      Close;
    end;

    Card := tpanel.create(menu);
    Card.Parent := menu;
    Card.left := left;
    Card.width := width;
    Card.top := top;
    Card.height := height;
    Card.Visible := true;
    Card.Parentbackground := false;
    Card.Color := clmenu;
    Card.Visible := true;

    answer := tlabel.create(Card);
    answer.Parent := Card;
    answer.WordWrap := true;
    answer.left := 30;
    answer.caption := an;
    answer.width := Card.width - 60;
    answer.Alignment := tacenter;
    answer.top := Card.height div 3;
    answer.Visible := true;

    Stats := tcardstats.create(Card, ratings[2], ratings[1], times[1], times[2],
      times[3]);
    panswers := tpan.create(Card, panswerss, an);
  end;

  destructor tflashback.free;
  begin
    answer.free;
    answer := nil;
    panswers.free;
    panswers := nil;
    Stats.free;
    Stats := nil;
    Card.free;
    Card := nil;
  end;

  { tcopy }

  constructor tcopy.create(Panel: tpanel; ID: integer);
  begin
    Cardid := ID;
    Card := tpanel.create(Panel);
    Card.Parent := Panel;
    Card.left := 0;
    Card.width := Panel.width;
    Card.top := 0;
    Card.height := Panel.height;
    Card.Visible := true;

    title := tlabel.create(Card);
    title.Parent := Card;
    title.caption := 'Choose a deck to copy into';
    title.Font.Size := 14;
    title.top := 0;
    title.left := (Card.width - title.width) div 2;
    title.Visible := true;

    if deckshower = nil then
      deckshower := tdeckdisplay.create(Panel, 'm');
    deckshower.furnish(Card); // shows the decks

    buttons := tobjectlist<tbutton>.create;
    CreateButton(200, 325, 50, 20, 'Continue', ondeckpick);

  end;

  procedure tcopy.CreateButton(top, left, width, height: integer;
    caption: string; click: tnotifyevent);
  var
    b: tbutton;
  begin
    b := tbutton.create(Card);
    buttons.Add(b);
    b.Parent := Card;
    b.top := top;
    b.left := left;
    b.width := width;
    b.height := height;
    b.caption := caption;
    b.Visible := true;
    b.OnClick := click;

  end;

  destructor tcopy.free;
  var
    i: integer;
  begin
    if deckshower <> nil then
    begin
      deckshower.free;
      deckshower := nil;
    end;
    if packshower <> nil then
    begin
      packshower.free;
      packshower := nil;
    end;
    if title <> nil then
    begin
      title.free;
      title := nil;
    end;
    if buttons <> nil then
    begin
      for i := (buttons.count - 1) downto 0 do
      begin
        buttons[i].free;
      end;
      buttons := nil;
    end;
    if Card <> nil then
    begin
      Card.free;
      Card := nil;
    end;
  end;

  procedure tcopy.ondeckpick(sender: tobject);
  var
    i, number, ID, numberofdecks: integer;
  begin

    numberofdecks := deckshower.numberofdecks;

    number := 0;
    for i := 0 to numberofdecks - 1 do
    begin
      if deckshower.choicearray[i].choose.Checked = true then
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
        if deckshower.choicearray[i].choose.Checked = true then
          ID := deckshower.choicearray[i].ID;
        deckshower.choicearray[i].choose.Enabled := false;
        // makes sure you dont change your option
      end;
      packshower := tpackdisplay.create(Card, 'm');
      packshower.furnish(Card, ID);
      did := ID;
      if buttons = nil then
        buttons := tobjectlist<tbutton>.create;
      CreateButton(560, 330, 50, 20, 'Continue', onpackpick);
    end;
  end;

  procedure tcopy.onpackpick(sender: tobject);
  var
    i, numberofpacks: integer;
    packids: tlist<integer>;
    exisits: boolean;
  begin
    numberofpacks := packshower.numberofpacks;
    packids := tlist<integer>.create;
    // gets the pack ids chosen
    for i := 0 to numberofpacks - 1 do
    begin
      if packshower.choicearray[i].choose.Checked = true then
        packids.Add(packshower.choicearray[i].ID);
    end;

    if packids.count = 0 then
    begin // error message for none selected
      showmessage('Please select a pack.');
    end
    else
    begin
      for i := 0 to packids.count - 1 do
      begin
        exisits := false;
        with dm.cardpackset do // makes sure the card isnt already in that pack
        begin
          Close;
          CommandText := 'select * from CardPack where PackID=:packid';
          Close;
          parameters.ParamByName('packid').value:=inttostr(packids[i]);
          open;
          first;
          while not eof do
          begin
            if FieldValues['CardID'] = Cardid then
              exisits := true;
            next;
          end;
          Close;
        end;
        if exisits = false then
        begin
          with dm.cardpackset do // adds reference linking pack and card
          begin
            Close;
            CommandText := 'select * from CardPack';
            open;
            insert;
            FieldValues['CardID'] := Cardid;
            FieldValues['PackID'] := packids[i];
            post;
            Close;
          end;
          with dm.packset do // updates number of cards in pack
          begin
            Close;
            CommandText := 'select * from Pack where PackID=:PackID';
            Close;
            Parameters.ParamByName('PackID').value := inttostr(packids[i]);
            open;
            Edit;
            FieldValues['Packsize'] := FieldValues['Packsize'] + 1;
            post;
            Close;
          end;
          with dm.deckset do // updates number of cards in deck
          begin
            Close;
            CommandText := 'select * from deck where deckid=:deckid';
            Close;
            Parameters.ParamByName('DeckID').value := inttostr(did);
            open;
            Edit;
            FieldValues['cards'] := FieldValues['cards'] + 1;
            post;
            Close;
          end;
        end;
      end;
    if deckshower <> nil then
    begin
      deckshower.free;
      deckshower := nil;
    end;
    if packshower <> nil then
    begin
      packshower.free;
      packshower := nil;
    end;
    if title <> nil then
    begin
      title.free;
      title := nil;
    end;
    if buttons <> nil then
    begin
      for i := (buttons.count - 1) downto 0 do
      begin
        buttons[i].free;
      end;
      buttons := nil;
    end;
    if Card <> nil then
    begin
      Card.free;
      Card := nil;
    end;

    end;
  end;

end.