unit nongram ;

interface

uses
  SysUtils, Types, Classes, Variants, QTypes, QGraphics, QControls, QForms,
  QDialogs, QStdCtrls, QExtCtrls, QMenus, QComCtrls,Math ;

type
  Tmainform = class(TForm)
    MainMenu1: TMainMenu;
    Game1: TMenuItem;
    New1: TMenuItem;
    Save1: TMenuItem;
    Load1: TMenuItem;
    OpenDialog1: TOpenDialog;
    Fromfile1: TMenuItem;
    Manual1: TMenuItem;
    pcolour: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    lb1: TListBox;
    Button1: TButton;
    procedure Fromfile1Click(Sender: TObject);
    procedure ActionBoxPaint(Sender: TObject);
    procedure GridBoxPaint(Sender: TObject);
    procedure GridBoxClick(Sender: TObject);
    procedure ActionBoxClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  Function Createeditbox(const BoxName:string; BoxParent:TComponent; Boxcolour:Tcolor; X,Y,W,H: Integer; Thetext:String):TEdit;
  Function Createpaintbox(const PaintboxName:String; PaintboxParent:TComponent; Paintboxcolor:TColor; X,Y,W,H: Integer):TPaintbox;
  Function Getlongest(input:Tstringlist):Integer;
  Function Getsmallestblock(elementNo,smallestSpace,smallestSpacePos:Integer;row:Boolean = true):Integer;
  Function Getnumbers(input:String):Tstringlist;
  Procedure Startgame(name: string; columns,rows:Tstringlist);
  Procedure Loadfile(filename:string);
  Function GetPaintboxByName(name:String):TPaintbox;
  Function Getgrid(x,y:Integer):String;
  Function setgrid(x,y:Integer;data:String):Boolean;
  Function getx(name:String):Integer;
  Function gety(name:String):Integer;
  Function getClearSquareCount:integer;
  Function setClearSquareCount(count:Integer):Boolean;
  Function getFillPattern:String;
  Function setFillPattern(pattern:String):Boolean;
  Function getColumnData(col,box,level:Integer):String;
  Function setColumnData(col,box,level:Integer;Data:String):Boolean;
  Function getRowData(row,box,level:Integer):String;
  Function setRowData(row,box,level:Integer;Data:String):Boolean;
  Function getElementFillLength(elementNo:Integer;Row:Boolean=true):integer;
  Function setBox(x,y:Integer;fillpattern:String;notoggle:Boolean=false):Boolean;
  Function elementIsComplete(elementNo:integer;row:Boolean=true):Boolean;
  Procedure drawActionBoxes;
  Function basicOverlapRow:Integer;
  Function basicOverlapColumn:Integer;
  Function edgeProximityRowFirst:Integer;
  Function edgeProximityRowLast:Integer;
  Function edgeProximityColFirst:Integer;
  Function edgeProximityColLast:Integer;
  Function singleNumberRow:Integer;
  Function singleNumberColumn:Integer;
  Function getPlayable(elementNo:Integer;row:Boolean = true):Integer;
  Function getFirstUncrossed(elementNo:Integer;row:Boolean = true):Integer;
  Function getSmallestSpace(elementNo:integer;row:Boolean = true):TStringlist;
  Function crossSmallSpaces(elementNo:Integer;row:Boolean = true):Boolean;
  Function crossAllSmallSpaces:integer;
  Procedure fillTest(elementNo:Integer;row:boolean=true);
  public
    { Public declarations }
  end;

type
T2DArray = array of array of string;
T3DArray = array of array of array of string;

var
  mainform: Tmainform;
  game: T2DArray;
  columnData: T3DArray;
  rowData: T3DArray;
  testArray: T2DArray;
  selector : array[1..10] of string;
implementation

{$R *.xfm}


Procedure TMainform.loadfile(filename:String);
var
inputfile:textfile;
lineoftext:string;
done:boolean;
collist,rowlist:TStringlist;
rowdata:boolean;
BEGIN
rowdata:=false;
collist:= TStringlist.Create;
rowlist:=Tstringlist.Create;
{accept columns first}
done:=false;
Assignfile(inputfile,opendialog1.FileName);
Reset(inputfile);
  REPEAT
  readln(inputfile,lineoftext);
  {stuff to load the file data here}
  if lineoftext = 'rows' then rowdata := true else
   begin
   if rowdata = false then
   collist.Add(lineoftext) else
   rowlist.Add(lineoftext);
   end;
  IF eof(inputfile)=true THEN done:=true;
  UNTIL  done;
closefile(inputfile);
Startgame(filename,collist,rowlist);
END;

Function TMainform.Getlongest(input:Tstringlist):Integer;
Var
i,length,longest:Integer;
BEGIN
longest:=0;
{finds the longest run of numbers}
IF input.Count>0 THEN
  BEGIN
  for i:=0 to input.Count-1 do
    begin
    length:= getnumbers(input[i]).Count;
    if length > longest then longest:=length;
    end;
  END;
result := longest;
END;

Function Tmainform.Getnumbers(input:String):Tstringlist;
var
commapos:integer;
teststring,substring:String;
resultlist:TStringlist;
BEGIN
resultlist:=Tstringlist.create;
{takes a csv string and finds the number of elements}
teststring:=input;
while length(teststring)>0 do
  BEGIN
  commapos:= pos(',',teststring);
  if commapos>0 then
    begin
    substring:=copy(teststring,1,commapos-1);
    delete(teststring,1,commapos);
    end else
    begin
    substring:=teststring;
    teststring:='';
    end;
  resultlist.Add(substring);
  END;
result:=resultlist;
END;

Function Tmainform.GetPaintboxByName(name:String):TPaintbox;
Var
i:Integer;
Begin
for i:=0 to mainform.ControlCount-1 do
  begin
  if mainform.Controls[i].Name = name then
    begin
    result:=mainform.controls[i] as TPaintbox;
    exit;
    end;
  end;
for i:=0 to pcolour.ControlCount-1 do
  begin
  if pcolour.Controls[i].Name = name then
    begin
    result:=pcolour.controls[i] as TPaintbox;
    exit;
    end;
  end;
result:=nil;
End;



Function Tmainform.getgrid(x,y:Integer):String;
BEGIN
result:=game[x,y];
END;

Function Tmainform.setgrid(x,y:Integer;data:String):Boolean;

BEGIN
game[x,y]:=data;
result:=true;
END;

Function Tmainform.getColumnData(col,box,level:Integer):String;
  BEGIN
  result:=columnData[col,box,level];
  END;

Function Tmainform.setColumnData(col,box,level:Integer;Data:String):Boolean;
  BEGIN
  columndata[col,box,level]:=data;
  result:=true;
  END;

Function Tmainform.getRowData(row,box,level:Integer):String;
  BEGIN
  result:=rowData[row,box,level];
  END;

Function Tmainform.setRowData(row,box,level:Integer;Data:String):Boolean;
  BEGIN
  rowdata[row,box,level]:=data;
  result:=true;
  END;

Function Tmainform.getx(name:String):Integer;
Var
input:String;
ystring:String;
rpos:integer;
toReturn:integer;
BEGIN
input := name;
rpos:= pos('r',input);
if rpos > 0 then
  begin
  ystring:=copy(input,2,rpos-2);
    try
    toReturn:=strtoint(ystring);
    except
    toReturn:=0;
    end;
  end else toReturn :=0;
result:=toReturn;
END;

Function Tmainform.gety(name:String):Integer;
Var
input:String;
ystring:String;
rpos:integer;
toReturn:integer;
BEGIN
input := name;
rpos:= pos('r',input);
if rpos>0 then
  begin
  ystring:=copy(input,rpos+1,length(input)-rpos);
    try
    toReturn:=strtoint(ystring);
    except
    toReturn:=0;
    end;
  end else toReturn:=0;
result:=toReturn;
END;

Function Tmainform.getClearSquareCount:integer;
BEGIN
try
result:=StrtoInt(selector[3]);
except
setClearSquareCount(0);
result:=0;
end;
END;

Function Tmainform.setClearSquareCount(count:Integer):boolean;
BEGIN
selector[3]:=inttostr(count);
result:=true;
END;

Function Tmainform.getPlayable(elementNo:Integer;row:boolean):Integer;
var
i:integer;
firstfree,lastfree:integer;
arrayToAnalyse:array of string;
BEGIN
{finds the number of squares that have not been marked with crosses}
if row then
  begin
  setLength(arrayToAnalyse,length(game));
  for i:=0 to length(arrayToAnalyse)-1 do
    arrayToAnalyse[i]:=getGrid(i,elementNo);
  end
else
  begin
  setLength(arrayToAnalyse,length(game[0]));
  for i:=0 to length(arrayToAnalyse)-1 do
    arrayToAnalyse[i]:=getGrid(elementNo,i);
  end;
{now just find the first instance of a square that isn't 'cross'}
firstfree:=0;
  while  (arrayToAnalyse[firstfree]= 'cross') do
    begin
    if firstfree < length(arrayToAnalyse) then
    firstfree:=firstfree+1
    else
      begin
      result:=0;
      exit;
      end;
    end;

lastfree:=length(arrayToAnalyse)-1;
  while  (arrayToAnalyse[lastfree]= 'cross') do
    begin
    if lastfree > 0 then
    lastfree:=lastfree-1
    else
      begin
      result:=0;
      exit;
      end;
    end;
result:=lastfree-firstfree+1;
END;


Function TMainform.getFirstUncrossed(elementNo:Integer;row:Boolean = true):Integer;
var
i:integer;
BEGIN
i:=0;
if row then
  while getGrid(i,elementno) ='cross' do
    begin
    if i<length(game) then i:=i+1 else
      begin
      result:=i;
      exit;
      end;
    end
else
  begin
  while (getGrid(elementno,i)='cross') do
    begin
    if i<length(game[0]) then i:=i+1 else
      begin
      result:=i;
      exit;
      end;
    end;
  end;
result:=i;
END;

Function TMainform.Getsmallestblock(elementNo,smallestSpace,smallestSpacePos:Integer;row:Boolean):Integer;
var
testRowOffset:integer;
elementLength,elementfillLength,blocksize,lastBlocksize:integer;
blockFits,noOverrun,matchFound,newBlockFound,done:boolean;
BEGIN
{This finds the smallest block that will not result}
{in the rest of the row going out of range}
if row then fillTest(elementNo) else fillTest(elementNo,false);
elementfillLength:=getElementFillLength(elementNo,Row);
if row then elementLength:=length(columndata)
else elementLength:=length(rowData);
{start with the first square of the first block lining up with}
{the first square of the smallest space}
testRowOffset:=smallestSpacePos;
blockfits:=false;
noOverrun:=false;
while testRowOffset >= 0 do
  begin
  {will the selected block go into this space?}
  blocksize:=strtoint(testArray[smallestSpacePos-testRowOffset][1]);
  if blocksize>0 THEN
    BEGIN
    blockFits:=(blocksize <= smallestspace);
    noOverrun:=(testRowOffset+elementFillLength-1 <= elementLength);
    END;
  matchfound:= blockFits and noOverrun;
  if matchfound then
    begin
    result:=blocksize;
    exit;
    end else
    begin
    {move to the start of the next block}
    {either the second level of the array is < 1 }
    {or the offset drops to zero}
      repeat
      testRowOffset:=testRowOffset-1;
      lastBlocksize:=blocksize;
      blocksize:=strtoint(testArray[smallestSpacePos-testRowOffset][1]);
      newBlockFound:=(lastBlockSize<=0) and (blockSize >0);
      done:=(testRowOffset=0) or newBlockFound;
      until done;
    end;
  end;
result:=0;
END;

Function TMainform.getSmallestSpace(elementNo:integer;row:Boolean = true):TStringlist;
var
i,limit:integer;
current,smallest,smallestpos:integer;
data:string;
startrun:boolean;
resultlist:TStringlist;
BEGIN
{smallest space bounded either by 'cross' squares or the limits of the game}
resultlist:=TStringlist.Create;
current:=0;
startrun:=true;
smallestpos:=-1;
if row then smallest:=length(columndata)
  else smallest:=length(rowdata);
limit:=smallest-1;
for i:=0 to limit do
  begin
  if row then data:=getgrid(i,elementNo-1) else data:=getgrid(elementno-1,i);
  if (data='clear')and(startrun) then current:=current+1;
  if (data='cross')or(i=limit) then
    begin
    startrun:=true;
    if (current<>0)and(current<smallest)then
      begin
      smallestpos:=i+1-current;
      if i=limit then smallestpos:=smallestpos+1;
      smallest:=current;
      end;
    end;
  if data <> 'clear' then
    begin
    current:=0;
    if data <> 'cross' then startrun:=false;
    end;
  end;
resultlist.Add(inttostr(smallest));
resultlist.Add(inttostr(smallestpos));
result:=resultlist;
END;

Function Tmainform.elementIsComplete(elementNo:integer;row:Boolean=true):Boolean;
var
i:integer;
BEGIN
if row then
for i:=0 to length(columndata)-1 do
  begin
  if getgrid(i,elementno-1)='clear' then
    begin
    result:=false;
    exit;
    end;
  end else
for i:=0 to length(rowdata)-1 do
  begin
  if getgrid(elementno-1,i)='clear' then
    begin
    result:=false;
    exit;
    end;
  end;
result:=true;
END;

Function Tmainform.getFillPattern:String;
BEGIN
result:=selector[1];
END;

Function Tmainform.setFillPattern(pattern:String):Boolean;
BEGIN
selector[1]:=pattern;
result:=true;
END;

Function TMainform.getElementFillLength(elementNo:Integer;Row:Boolean=true):integer;
var
blockDataLength:integer;
i,elementLength:integer;
data:string;
BEGIN
elementlength:=0;
if (row) then blockDataLength:=length(rowdata[0])-1
else blockdatalength:=length(columndata[0])-1;
for i:=0 to blockdatalength do
  begin
  if row then data:=getRowData(elementNo,i,0)
  else data:=getColumnData(elementNo,i,0);
  if data <> '' then
    begin
    elementlength:=elementlength+strtoint(data);
    if i < blockdatalength then
      begin
      elementlength:=elementlength+1;
      end;
    end;
  end;
result:=elementlength;  
END;

Function Tmainform.setBox(x,y:Integer;fillpattern:String;notoggle:boolean):Boolean;
Var
currentboxset,newboxset:String;
clearsquarecount:integer;
Currentbox:TPaintbox;
BEGIN
currentboxset:= getgrid(x-1,y-1);
if currentboxset = 'clear' then
  begin
  newboxset:=fillpattern;
  end else
  begin
  if currentboxset = fillpattern then
    begin
    if notoggle = false then
    newboxset:='clear' else newboxset:=fillpattern;
    end
  else newboxset:=fillpattern;
  end;

if (currentboxset <> newboxset) then
  begin
  clearsquarecount:=getClearSquareCount;
  if currentboxset = 'clear' then clearsquarecount := clearsquarecount -1 else
  if newboxset = 'clear' then clearsquarecount := clearsquarecount +1;
  setClearSquareCount(clearsquarecount);
  setgrid(x-1,y-1,newboxset);
  currentbox:=getpaintboxbyname('c'+inttostr(x)+'r'+inttostr(y));
  if currentbox <> nil then
    with currentbox do
    begin
    repaint;
    end;
  end;

result:=true;
END;

Procedure Tmainform.drawActionBoxes;
Var
xpos,ypos:integer;
heightofgame:Integer;
bottombox:TPaintbox;
BEGIN
{at minimum we want a selector for cross, black and clear}
{at the bottom of the grid}
heightofgame:=length(game[0]);
xpos:=0;
ypos:=0;
bottombox:=getpaintboxbyname('c1r'+inttostr(heightofgame));
if bottombox <> nil then
  begin
  xpos:=bottombox.Left-pcolour.left;
  ypos:= 10;
  end;

createpaintbox('clear',pcolour,clMid,xpos,ypos,20,20);
xpos:=xpos+25;
createpaintbox('cross',pcolour,clMid,xpos,ypos,20,20);
xpos:=xpos+25;
createpaintbox('clBlack',pcolour,clMid,xpos,ypos,20,20);
END;

Procedure Tmainform.fillTest(elementNo:Integer;row:Boolean);
var
block,i:integer;
data,fillpattern:String;
blocklength,offset:integer;
blockDataLength:integer;
BEGIN
offset:=0;
setLength(testArray,0,0);
if row then
  begin
  setLength(testArray,length(columndata),2);
  blockDataLength:=length(rowdata[0])-1;
  end else
  begin
  setLength(testArray,length(rowdata),2);
  blockDataLength:=length(columndata[0])-1;
  end;
for i:=0 to length(testArray)-1 do
  begin
  testArray[i][0]:='clear';
  testArray[i][1]:='-1';
  end;
for block:=0 to blockDataLength do
  begin
  if row then
    begin
    data:=getRowData(elementNo-1,block,0);
    fillpattern:=getRowData(elementNo-1,block,1);
    end else
    begin
    data:=getColumnData(elementNo-1,block,0);
    fillpattern:=getColumnData(elementNo-1,block,1);
    end;
  if data<>'' then
    begin
    blocklength:=strtoint(data);
    for i:=offset to offset+blocklength-1 do
      begin
      testArray[i][0]:=fillpattern;
      testArray[i][1]:=inttostr(blocklength);
      end;
    offset:=offset+blocklength;
    if block < blockDataLength then
      begin
      testArray[offset][0]:='cross';
      testArray[offset][1]:='0';
      offset:=offset+1;
      end;
    end;
  end;
END;


Procedure Tmainform.Startgame(name: string; columns,rows:Tstringlist);
var
rowcount,colcount,controlno,x,y:integer;
thetext:string;
currentdata:TStringlist;
Begin
{set the dimensions of the game grid}
SetLength(game,columns.Count,rows.count);
{initialise the selector}
{**change this - no need to have two elements for the current setting}
selector[1]:='clear';
selector[2]:='clBlack';
selector[3]:=inttostr(columns.Count * rows.count);

{first we need to find the numbers of columns and rows}
colcount := getlongest(columns);
rowcount :=getlongest(rows);

{now set up the row and column data}
{these are 3d arrays with row,box,level}
{and col,box,level}
SetLength(rowData,rows.count,rowcount,2);
SetLength(columnData,columns.count,colcount,2);

for x:=1 to columns.Count do
  begin
  currentdata:=getnumbers(columns[x-1]);
  for y:=1 to colcount do
    begin
    if y > (colcount-currentdata.Count) then
    thetext:=currentdata[y-(colcount+1-currentdata.count)]
    else thetext:='';

    Createeditbox('c'+inttostr(x)+'n'+inttostr(y),mainform,clBase,(21*rowcount)+((x-1)*21),((y-1)*21),20,20,thetext);
    setcolumnData(x-1,y-1,0,thetext);
    setcolumnData(x-1,y-1,1,'clBlack');
    end;
  end;

for y:= 1 to rows.Count do
  begin
  currentdata:=getnumbers(rows[y-1]);
  for x:=1 to rowcount do
    begin
    if x > (rowcount-currentdata.Count) then
    thetext:=currentdata[x-(rowcount+1-currentdata.count)]
    else thetext:='';
    Createeditbox('r'+inttostr(x)+'n'+inttostr(y),mainform,clBase,((x-1)*21),(21*colcount)+((y-1)*21),20,20,thetext);
    setRowData(y-1,x-1,0,thetext);
    setRowData(y-1,x-1,1,'clBlack');
    end;
  end;

for y:= 1 to rows.count do
  begin
  for x:= 1 to columns.count do
    begin
    setgrid(x-1,y-1,'clear');
    Createpaintbox('c'+inttostr(x)+'r'+inttostr(y),mainform,clMid,(21*rowcount)+(21*(x-1)),(21*colcount)+(21*(y-1)),20,20);
    end;
  end;

drawActionBoxes;

for controlno:=0 to mainform.ControlCount-1 do
  begin
  if mainform.Controls[controlno] is TEdit then
  with mainform.Controls[controlno] as TEdit do
    begin
    Show;
    end else
  if mainform.Controls[controlno] is TPaintbox then
  with mainform.controls[controlno] as TPaintbox do
    begin
    mainform.Controls[controlno].Show;
    end;
  end;
End;


Function TMainform.Createpaintbox(const PaintboxName:String; PaintboxParent:TComponent; Paintboxcolor:TColor; X,Y,W,H: Integer):TPaintbox;
  Var
  i:Integer;
  newname:String;
  Begin
  newname:=paintboxname;
  Result:=TPaintbox.create(paintboxparent);
  With result do
    BEGIN
    Parent:=paintboxparent as TWidgetControl ;
    IF length(newname)>0 THEN
      BEGIN
      i:=1;
        REPEAT
        IF i<=length(newname) THEN
          BEGIN
          IF newname[i]=' 'THEN Delete(newname,i,1) ELSE i:=i+1;
          END;
        UNTIL i>length(newname);
      END;
    Name:=newname;
    Setbounds(X,Y,W,H);
    Visible:=true;
    color:=paintboxcolor;
    if parent = pcolour then
      begin
      onpaint:=actionboxpaint;
      onclick:=actionboxclick;
      end else
      begin
      onpaint:=gridboxpaint;
      onclick:=gridboxclick;
      end;

    END;
  End;


  Function TMainform.Createeditbox(const BoxName:string; BoxParent:TComponent; Boxcolour:Tcolor; X,Y,W,H: Integer; Thetext:String):TEdit;
  Var
  i:Integer;
  newname:String;
  Begin
  newname:=Boxname;
  Result:=TEdit.create(mainform);
  With result do
    BEGIN
    Parent:=mainform;
    IF length(newname)>0 THEN
      BEGIN
      i:=1;
        REPEAT
        IF i<=length(newname) THEN
          BEGIN
          IF newname[i]=' 'THEN Delete(newname,i,1) ELSE i:=i+1;
          END;
        UNTIL i>length(newname);
      END;
    Name:=newname;
    Text:=thetext;
    Borderstyle:=bsNone;
    Setbounds(X,Y,W,H);
    Visible:=true;
    color:=boxcolour;
    {add onclick}
    END;
  End;

procedure Tmainform.Fromfile1Click(Sender: TObject);
begin
If opendialog1.Execute then
  begin
  loadfile(opendialog1.FileName);
  end;
end;

procedure Tmainform.ActionBoxPaint(Sender: TObject);
var
thisRect:TRect;
boxname:String;
begin
if sender is TPaintbox then
with sender as TPaintbox do
  begin
  boxname:=name;
  canvas.Pen.Color:=clBlack;
  canvas.Brush.color:=clBackground;
  if ((boxname <> 'clear') and (boxname <> 'cross')) then
    begin
      try
      canvas.Brush.color:=stringtocolor(boxname);
      except
      canvas.Brush.color:=clBackground;
      end;
    end;
  thisRect.Top:=1;
  thisRect.Left:=1;
  thisRect.Bottom:=height;
  thisRect.Right:=width;
  canvas.FillRect(thisRect);
  if boxname = getfillpattern then
  canvas.Pen.Color:=clRed;
  canvas.Rectangle(1,1,width,height);
  canvas.Pen.Color:=clBlack;
  if boxname = 'cross' then
    begin
    canvas.MoveTo(1,1);
    canvas.LineTo(width,height);
    canvas.MoveTo(width,1);
    canvas.LineTo(1,height);
    end;
  end;
end;

procedure Tmainform.GridBoxPaint(Sender: TObject);
var
thisRect:TRect;
boxname,contents:String;
x,y:Integer;
fillcolour:Tcolor;
begin
if sender is TPaintbox then
with sender as TPaintbox do
  begin
  {repaints a single shape from the game grid}
  boxname:=name;


  x:=getx(boxname);
  y:=gety(boxname);
  contents:=getgrid(x-1,y-1);

  {test}
  if boxname = 'c1r1' then edit2.Text:='curr '+contents;


  if (contents = 'cross') or (contents = 'clear') then fillcolour:=clBackground else
    try
    fillcolour:=Stringtocolor(contents);
    except
    fillcolour:=clBackground;
    end;
  thisrect.Left:=1;
  thisrect.Top:=1;
  thisrect.right:=width-1;
  thisrect.Bottom:=height-1;
  canvas.brush.Color:=fillcolour;
  canvas.FillRect(thisrect);
  canvas.pen.Color:=clBlack;
  canvas.rectangle(1,1,width,height);

  if contents = 'cross' then
    begin
    canvas.MoveTo(1,1);
    canvas.LineTo(width,height);
    canvas.MoveTo(width,1);
    canvas.LineTo(1,height);
    end;
  end;
end;

procedure Tmainform.GridBoxClick(Sender: TObject);
var
boxname:string;
boxx,boxy:integer;
begin
if Sender is TPaintbox then
with sender as TPaintbox do
  begin
  boxname:=name;
  boxx:=getx(boxname);
  boxy:=gety(boxname);
  if (boxx > 0)and(boxy > 0) then setBox(boxx,boxy,getfillpattern);
  end;
edit1.Text:=inttostr(getClearSquareCount);
end;




procedure Tmainform.ActionBoxClick(Sender: TObject);
var
boxname:String;
begin
if Sender is TPaintbox then
with sender as TPaintbox do
  begin
  boxname:=name;
  setFillPattern(boxname);
  Edit1.text:='fill '+getFillPattern;
  pcolour.Repaint;
  end;
end;

procedure Tmainform.Button1Click(Sender: TObject);
begin
{read the data from the column and row data arrays}
{for col:=0 to length(columnData)-1 do
 for box:=0 to length(columnData[0])-1 do
   begin
   lb1.Items.add('c '+inttostr(col)+' b '+inttostr(box)+' level 0 '+getcolumndata(col,box,0));
   lb1.Items.add('c '+inttostr(col)+' b '+inttostr(box)+' level 1 '+getcolumndata(col,box,1));
   end;

for row:=0 to length(rowData)-1 do
 for box:=0 to length(rowData[0])-1 do
   begin
   lb1.Items.add('r '+inttostr(row)+' b '+inttostr(box)+' level 0 '+getrowdata(row,box,0));
   lb1.Items.add('r '+inttostr(row)+' b '+inttostr(box)+' level 1 '+getrowdata(row,box,1));
   end;}

lb1.Items.Add('basic overlap-row solved '+inttostr(basicOverlapRow)+' squares');
lb1.Items.Add('basic overlap-column solved '+inttostr(basicOverlapColumn)+' squares');
lb1.Items.Add('edgeproximityrowfirst solved '+inttostr(edgeProximityRowFirst)+' squares');
lb1.Items.Add('edgeproximityrowlast solved '+inttostr(edgeProximityRowLast)+' squares');
lb1.Items.Add('edgeproximitycolfirst solved '+inttostr(edgeProximityColFirst)+' squares');
lb1.Items.Add('edgeproximitycollast solved '+inttostr(edgeProximityColLast)+' squares');
lb1.Items.Add('singlenumberrow solved '+inttostr(singlenumberrow)+' squares');
lb1.Items.Add('singlenumbercol solved '+inttostr(singlenumbercolumn)+' squares');
lb1.Items.Add('crossSmallSpaces solved '+inttostr(crossAllSmallSpaces)+' squares');

{lb1.Items.Add('basic overlap-row pass 2 solved '+inttostr(basicOverlapRow)+' squares');
lb1.Items.Add('basic overlap-column pass 2 solved '+inttostr(basicOverlapColumn)+' squares');}


edit1.Text:=inttostr(getClearSquareCount);

end;

{stuff below here is concerned with solving the problems}
{or trying to anyway...}

Function Tmainform.basicOverlapRow:Integer;
Var
rowNo,blockNo,blockLength,blockDataLength:Integer;
playable,offset,position:Integer;
leftlimit,rightlimit:Array of string;
blockdifference,clearspace:integer;
clearCountBefore,clearCountAfter:Integer;
blockData,blockColour:String;
lastcolourleft,lastcolourright:String;
BEGIN
clearCountBefore:=getClearSquareCount;
for rowno:=1 to length(rowdata) do
  begin
  playable:=getPlayable(rowno-1);
  if playable > 0 THEN
    begin
    setlength(leftlimit,playable);
    setlength(rightlimit,playable);
    lb1.Items.add('playable on row '+inttostr(rowno)+' is '+inttostr(length(leftlimit)));
    offset:=getFirstUncrossed(rowno-1);
    position:=0;
    blockdatalength:=0;
    {fill the two arrays with the data from this row}
    {one with the blocks as far left as they'll go}
    {and the other with them as far right as they'll go}
    for blockNo:=1 to length(rowdata[0]) do
      begin
      blockData:=getRowData(rowno-1,blockno-1,0);
      if blockData <>'' then
        try
        blocklength:=strtoInt(blockdata); {current block}
        blockdatalength:=blockdatalength+blocklength; {overall length of the data inc spaces}
        blockColour:=getRowData(rowno-1,blockno-1,1);
          repeat
          leftLimit[position]:=blockcolour;
          blocklength:=blocklength-1;
          position:=position+1;
          until blocklength =0;

        {at the moment only doing black and}
        {white puzzles which always have a clear}
        {space between blocks}
        if blockno < length(rowdata[0]) then
          begin
          leftlimit[position]:='cross';
          position:=position+1;
          blockdatalength:=blockdatalength+1;
          end;
        except
        {oops!}
        end;
      end;
    {fill any remaining spaces with 'clear'}
    while position < (length(leftlimit)) do
      begin
      leftLimit[position]:='clear';
      position:=position+1;
      end;
    {rightlimit is the same data shifted to the right}
    {so difference between blockdatalength and length of the test arrays}
    {will give clear spaces at start}
    position:=0;
    clearspace:=length(leftlimit)-blockdatalength;
    while position < clearspace do
      begin
      rightLimit[position]:='clear';
      position:=position+1;
      end;
    while position < length(leftlimit) do
      begin
      rightLimit[position]:=leftlimit[position-clearspace];
      position:=position+1;
      end;
  {now compare these two arrays}
  {could be separate method - same for rows and columns}
  {for the moment put it here}
  position:=0;
  blockdifference:=0;
  lastcolourleft:='clear';
  lastcolourright:='clear';
  while position < length(leftlimit) do
    begin
    if leftlimit[position]<>lastcolourleft then
      begin
      lastcolourleft:=leftlimit[position];
      blockdifference:=blockdifference-1;
      end;
      if rightlimit[position]<>lastcolourright then
        begin
        lastcolourright:=rightlimit[position];
        blockdifference:=blockdifference+1;
        end;

      if (blockdifference=0)
      and (leftlimit[position] = rightlimit[position])
      and (leftlimit[position]<> 'clear') then
        begin
        {we have an overlap. Set the space to the specified colour}
        setBox(position+offset+1,rowno,leftlimit[position],true);
        lb1.Items.add('row found overlap '+inttostr(position+offset+1)+' '+inttostr(rowno));
        end;
      position:=position+1;
      end;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.basicOverlapColumn:Integer;
Var
colNo,blockNo,blockLength,blockDataLength:Integer;
position,playable,offset:Integer;
leftlimit,rightlimit:Array of string;
blockdifference,clearspace:integer;
clearCountBefore,clearCountAfter:Integer;
blockData,blockColour:String;
lastcolourleft,lastcolourright:String;
BEGIN
setlength(leftlimit,length(game[0]));
setlength(rightlimit,length(game[0]));
clearCountBefore:=getClearSquareCount;
for colno:=1 to length(columndata) do
  begin
  playable:=getPlayable(colno-1,false);
  setlength(leftlimit,playable);
  setlength(rightlimit,playable);
  lb1.Items.add('playable on col '+inttostr(colno)+' is '+inttostr(playable));
  position:=0;
  offset:=getFirstUncrossed(colno-1,false);
  blockdatalength:=0;
  {fill the two arrays with the data from this row}
  {one with the blocks as far left as they'll go}
  {and the other with them as far right as they'll go}
    for blockNo:=1 to length(columndata[0]) do
      begin
      blockData:=getcolumnData(colno-1,blockno-1,0);
      if blockData <>'' then
        try
        blocklength:=strtoInt(blockdata); {current block}
        blockdatalength:=blockdatalength+blocklength; {overall length of the data inc spaces}
        blockColour:=getColumnData(colno-1,blockno-1,1);
          repeat
          leftLimit[position]:=blockcolour;
          blocklength:=blocklength-1;
          position:=position+1;
          until blocklength =0;

        {at the moment only doing black and}
        {white puzzles which always have a clear}
        {space between blocks}
        if blockno < length(columndata[0]) then
          begin
          leftlimit[position]:='cross';
          position:=position+1;
          blockdatalength:=blockdatalength+1;
          end;
        except
        {oops!}
        end;
      end;
    {fill any remaining spaces with 'clear'}
    while position < (length(leftlimit)) do
      begin
      leftLimit[position]:='clear';
      position:=position+1;
      end;
    {rightlimit is the same data shifted to the right}
    {so difference between blockdatalength and length(leftlimit) will give clear spaces at start}
    position:=0;
    clearspace:=length(leftlimit)-blockdatalength;
    while position < clearspace do
      begin
      rightLimit[position]:='clear';
      position:=position+1;
      end;
    while position < length(leftlimit) do
      begin
      rightLimit[position]:=leftlimit[position-clearspace];
      position:=position+1;
      end;
  {now compare these two arrays}
  {could be separate method - same for rows and columns}
  {for the moment put it here}

  position:=0;
  blockdifference:=0;
  lastcolourleft:='clear';
  lastcolourright:='clear';
  while position < length(leftlimit) do
    begin
    if leftlimit[position]<>lastcolourleft then
      begin
      lastcolourleft:=leftlimit[position];
      blockdifference:=blockdifference-1;
      end;
    if rightlimit[position]<>lastcolourright then
      begin
      lastcolourright:=rightlimit[position];
      blockdifference:=blockdifference+1;
      end;

    if (blockdifference=0)
    and (leftlimit[position] = rightlimit[position])
    and (leftlimit[position]<> 'clear') then
      begin
      {we have an overlap. Set the space to the specified colour}
      setBox(colno,position+offset+1,leftlimit[position],true);
      lb1.Items.add('col found overlap '+inttostr(colno)+' '+inttostr(position+offset+1));
      end;
    position:=position+1;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.edgeProximityRowFirst:Integer;
var
rowno,colno:integer;
blockno,firstnumber:integer;
firstcolour:String;
clearcountbefore,clearcountafter:integer;
BEGIN
{if first filled square is nearer the edge than the length}
{of the first block then all squares from first filled square}
{to length of first block must be filled in}
{find first number - start with rows}
clearcountbefore:=getclearsquarecount;
for rowNo:=1 to length(rowdata) do
  begin
  blockno:=1;
  while getRowData(rowno-1,blockno-1,0)= '' do
    begin
    blockno:=blockno+1;
    end;
  firstnumber:=strtoint(getRowdata(rowno-1,blockno-1,0));
  firstcolour:=getRowdata(rowno-1,blockno-1,1);
  {now see if any squares before length(firstnumber) is filled}
  colno:=1;
  while (getgrid(colno-1,rowno-1)<>firstcolour)and(colno<=firstnumber) do
    begin
    colno:=colno+1;
    end;
  if colno<firstnumber then
  while colno <= firstnumber do
    begin
    setbox(colno,rowno,firstcolour,true);
    colno:=colno+1;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.edgeProximityRowLast:Integer;
var
rowno,colno:integer;
blockno,lastnumber:integer;
lastcolour:String;
clearcountbefore,clearcountafter:integer;
BEGIN
{if last filled square is nearer the end than the length}
{of the last block then all squares from last filled square}
{back to length of last block must be filled in}
{find last number - easy}
clearcountbefore:=getclearsquarecount;
for rowNo:=1 to length(rowdata) do
  begin
  blockno:=length(rowdata[0]);
  lastnumber:=strtoint(getRowdata(rowno-1,blockno-1,0));
  lastcolour:=getRowdata(rowno-1,blockno-1,1);
  {now see if any squares nearer end than length(firstnumber) is filled}
  colno:=length(game);
  while (getgrid(colno-1,rowno-1)<>lastcolour)and(colno > (1+length(game)-lastnumber)) do
    begin
    colno:=colno-1;
    end;
  if colno > (1+length(game)-lastnumber) then
  while colno > (1+length(game)-lastnumber) do
    begin
    setbox(colno,rowno,lastcolour,true);
    colno:=colno-1;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.edgeProximityColFirst:Integer;
var
rowno,colno:integer;
blockno,firstnumber:integer;
firstcolour:String;
clearcountbefore,clearcountafter:integer;
BEGIN
{if first filled square is nearer the edge than the length}
{of the first block then all squares from first filled square}
{to length of first block must be filled in}
{find first number - start with rows}
clearcountbefore:=getclearsquarecount;
for ColNo:=1 to length(columndata) do
  begin
  blockno:=1;
  while getColumnData(colno-1,blockno-1,0)= '' do
    begin
    blockno:=blockno+1;
    end;
  firstnumber:=strtoint(getColumndata(colno-1,blockno-1,0));
  firstcolour:=getColumndata(colno-1,blockno-1,1);
  {now see if any squares before length(firstnumber) is filled}
  rowno:=1;
  while (getgrid(colno-1,rowno-1)<>firstcolour)and(rowno<=firstnumber) do
    begin
    rowno:=rowno+1;
    end;
  if rowno<firstnumber then
  while rowno <= firstnumber do
    begin
    setbox(colno,rowno,firstcolour,true);
    rowno:=rowno+1;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.edgeProximityColLast:Integer;
var
rowno,colno:integer;
blockno,lastnumber:integer;
lastcolour:String;
clearcountbefore,clearcountafter:integer;
BEGIN
{if last filled square is nearer the end than the length}
{of the last block then all squares from last filled square}
{back to length of last block must be filled in}
{find last number - easy}
clearcountbefore:=getclearsquarecount;
for colNo:=1 to length(Columndata) do
  begin
  blockno:=length(columndata[0]);
  lastnumber:=strtoint(getColumndata(Colno-1,blockno-1,0));
  lastcolour:=getColumndata(colno-1,blockno-1,1);
  {now see if any squares nearer end than length(firstnumber) is filled}
  rowno:=length(rowdata);
  while (getgrid(colno-1,rowno-1)<>lastcolour)and(rowno > (1+length(rowdata)-lastnumber)) do
    begin
    rowno:=rowno-1;
    end;
  if rowno > (1+length(rowdata)-lastnumber) then
  while rowno > (1+length(rowdata)-lastnumber) do
    begin
    setbox(colno,rowno,lastcolour,true);
    rowno:=rowno-1;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.singleNumberRow:Integer;
var
row,col:Integer;
lastbox:Integer;
blocklength:integer;
firstfilled:Integer;
fillpattern:String;
clearcountbefore,clearcountafter:Integer;
BEGIN
clearcountbefore:=getClearSquareCount;
{A special case where there's only one block in a row}
{or column}
for row:=1 to length(rowdata) do
  begin
  lastbox:= length(rowdata[0]);
  if (lastbox=1)OR(getrowdata(row-1,lastbox-2,0)='') then
    try
    blocklength:=strtoint(getrowdata(row-1,lastbox-1,0));
    {find the first filled in square ignoring crosses}
    col:=0;
    fillpattern:='clear';
    while ((fillpattern = 'clear') or (fillpattern = 'cross')) and (col<=length(columndata)) do
      begin
      col:=col+1;
      if col<=length(columndata)
       then fillpattern:=getgrid(col-1,row-1);
      end;
    if col<=length(game) then
      begin
      firstfilled:=col;
      {now, any squares before firstfilled - length(block) must be crosses}
      if firstfilled+blocklength-1 < length(columndata) then
        for col:=firstfilled+blocklength to length(columndata) do
        begin
        setBox(col,row,'cross',true);
        end;

      col:=firstfilled;
      while (col<length(columndata))
      and (getgrid(col,row-1)=getgrid(col-1,row-1)) do
        begin
        col:=col+1;
        end;
      firstfilled:=col;


      if (firstfilled-blocklength>0) then
        for col:=1 to (firstfilled-blocklength) do
        begin
        setBox(col,row,'cross',true);
        end;

      end;
    except
    {assume blank row?}
    if getrowdata(row-1,lastbox-1,0)='' then
      begin
      for col:=1 to length(columndata) do
        begin
        setBox(col,row,'cross',true);
        end;
      end;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.singleNumberColumn:Integer;
var
row,col:Integer;
lastbox:Integer;
blocklength:integer;
firstfilled:Integer;
fillpattern:String;
clearcountbefore,clearcountafter:Integer;
BEGIN
clearcountbefore:=getClearSquareCount;
{A special case where there's only one block in a row}
{or column}
for col:=1 to length(columndata) do
  begin
  lastbox:= length(columndata[0]);
  if (lastbox=1)OR(getcolumndata(col-1,lastbox-2,0)='') then
    try
    blocklength:=strtoint(getcolumndata(col-1,lastbox-1,0));
    {find the first filled in square ignoring crosses}
    row:=0;
    fillpattern:='clear';
    while ((fillpattern = 'clear') or (fillpattern = 'cross')) and (row<=length(rowdata)) do
      begin
      row:=row+1;
      if row<= length(rowdata)
        then fillpattern:=getgrid(col-1,row-1);
      end;
    if row<=length(rowdata) then
      begin
      firstfilled:=row;
      {now, any squares before firstfilled - length(block) must be crosses}
      if firstfilled+blocklength-1 < length(rowdata) then
        for row:=firstfilled+blocklength to length(rowdata) do
        begin
        setBox(col,row,'cross',true);
        end;

      {now move firstfilled to be the first counting from the right}
      row:=firstfilled;
      while (row<length(rowdata))
      and (getgrid(col-1,row)=getgrid(col-1,row-1)) do
        begin
        row:=row+1;
        end;
      firstfilled:=row;

      if (firstfilled-blocklength>0) then
        for row:=1 to (firstfilled-blocklength) do
        begin
        setBox(col,row,'cross',true);
        end;
      end;
    except
    if getcolumndata(col-1,lastbox-1,0)='' then
      begin
      for row:=1 to length(rowdata) do
        begin
        setBox(col,row,'cross',true);
        end;
      end;

    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;


Function TMainform.crossSmallSpaces(elementNo:Integer;row:Boolean = true):Boolean;
var
i:integer;
smallestSpaceList:TStringlist;
smallestSpace,smallestSpaceStart,smallestBlock:Integer;
BEGIN
smallestSpaceList:=getSmallestSpace(elementNo,row);
smallestSpace:=strtoint(smallestspacelist[0]);
smallestSpaceStart:=strtoint(smallestspacelist[1]);
{the smallest block depends on the position of the smallest space}
smallestBlock:=getSmallestBlock(elementNo,smallestSpace,smallestSpaceStart,row);
if smallestSpace < smallestBlock then
  begin
  for i := smallestSpaceStart to smallestSpaceStart+smallestSpace-1 do
    begin
    if row then setbox(i,elementNo,'cross',true)
    else setbox(elementNo,i,'cross',true)
    end;
  end;
result:=true;
END;

Function Tmainform.crossAllSmallSpaces:integer;
var
clearcountbefore,clearcountafter:Integer;
colno,rowno:integer;
BEGIN
clearcountbefore:=getClearSquareCount;
for rowno:=1 to length(rowdata)do
  begin
  if not elementIsComplete(rowno) then
  crossSmallSpaces(rowno);
  end;
for colno:=1 to length(columndata)do
  begin
  if not elementIsComplete(colno,false) then
  crossSmallSpaces(colno,false);
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

end.
