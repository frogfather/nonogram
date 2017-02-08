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
  Function smallestSpaceCanBeUsed(elementNo,smallestSpace,smallestSpacePos:Integer;row:Boolean = true):Integer;
  Function Getnumbers(input:String):Tstringlist;
  Procedure Startgame(name: string; columns,rows:Tstringlist);
  Procedure Loadfile(filename:string);
  Function GetPaintboxByName(name:String):TPaintbox;
  Function Getgrid(x,y:Integer;level:integer=0):String;
  Function setgrid(x,y:Integer;data:String;level:integer=0):Boolean;
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
  Function basicOverlap(row:Boolean=true):Integer;
  Function edgeProximity(row:boolean=true):Integer;
  Function singleNumberRow(row:boolean = true):Integer;
  Function getPlayable(elementNo:Integer;row:Boolean = true):Integer;
  Function getFirstUncrossed(elementNo:Integer;row:Boolean = true):Integer;
  Function getSmallestSpace(elementNo:integer;row:Boolean = true):TStringlist;
  Function crossSmallSpaces(elementNo:Integer;row:Boolean = true):Boolean;
  Function crossAllSmallSpaces:integer;
  Function fillTest(elementNo,playable:Integer;row:boolean=true):integer;
  Function identifyBlock(elementNo,blockStart,blockLength:integer;blockColour:string;row:boolean):integer;
  Function identifyBlocks(ElementNo:Integer;row:boolean=true):integer;
  Function getBlockCount(ElementNo:integer;row:boolean=true):integer;
  Function getBlockLength(ElementNo,blockNo:integer;row:boolean=true):integer;
  Function getSpaceCount(ElementNo:integer;row:boolean):integer;
  Function getActualBlocks(ElementNo:integer;row:Boolean=true):integer;
  Function spacesThatMustBeCrossed(ElementNo:integer;row:boolean=true):integer;
  Function getActualBlockLength(ElementNo,blockNo:Integer;row:boolean=true):integer;
  public
    { Public declarations }
  end;

type
T2DArray = array of array of string;
T3DArray = array of array of array of string;

var
  mainform: Tmainform;
  game: T3DArray;
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



Function Tmainform.getgrid(x,y:Integer;level:integer=0):String;
BEGIN
result:=game[x,y,level];
END;

Function Tmainform.setgrid(x,y:Integer;data:String;level:integer=0):Boolean;
BEGIN
game[x,y,level]:=data;
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

Function Tmainform.getBlockLength(ElementNo,blockNo:integer;row:boolean=true):integer;
var
maxblocks:integer;
data:string;
BEGIN
if row then maxblocks:=length(rowData[0])-1 else maxblocks := length(columndata[0])-1;
if blockNo <= maxblocks then
  begin
  if row then data:=getRowData(elementNo,blockNo,0)
  else data:= getColumnData(elementNo,blockNo,0);
  if data <> '' then result := strtoint(data) else result:=-1;
  end else result :=-1;
END;

Function Tmainform.getSpaceCount(ElementNo:integer;row:boolean):integer;
var
i,limit,spaceCount:integer;
thisSquare,lastSquare:string;
BEGIN
spaceCount:=0;
if row then limit := length(columndata)-1 else limit:=length(rowdata)-1;
lastSquare:='cross';
for i:=0 to limit do
  begin
  if row then thisSquare:= getgrid(i,elementNo) else thisSquare:= getGrid(elementNo,i);
  if (thisSquare = 'clear')and(lastSquare = 'cross')
  then spaceCount:=spaceCount+1;
  lastSquare:=thisSquare;
  end;
result:=spaceCount;
END;

Function Tmainform.getBlockCount(ElementNo:integer;row:boolean=true):integer;
var
data:string;
i,blockcount,maxblocks:integer;
BEGIN
{can do this by looking at row and column data}
{easiest way to find size of row/column array level 2}
{and find first non empty}
if row then i :=length(rowData[0])
else i := length(columnData[0]);
maxblocks:=i;
blockcount:=-1;
  while i > 0 do
  begin
  if row then data := getRowData(elementNo,i-1,0)
  else data := getColumnData(elementNo,i-1,0);
  if (data = '')and(blockcount = -1) then
    begin
    blockcount:=maxblocks - i;
    end;
  i := i-1;
  if (i=0)and(blockcount = -1) then blockcount:=maxblocks;
  end;
result:=blockcount;
END;

Function Tmainform.setClearSquareCount(count:Integer):boolean;
BEGIN
selector[3]:=inttostr(count);
result:=true;
END;

Function Tmainform.getActualBlocks(ElementNo:integer;row:Boolean):integer;
var
diff:boolean;
prev,data:string;
i,blocklength,limit,blockcount:integer;
BEGIN
if row then limit:=length(columndata) else limit:=length(rowdata);
blockcount:=0;
blocklength :=0;
prev:='cross';
for i := 0 to limit do
  begin
  if i<limit then
    begin
    if row then data := getgrid(i,elementNo) else data := getgrid(elementNo,i);
    end else data:='cross';
  diff:=(prev<>data);
  if diff then
    begin
    if blocklength > 0 then
      begin
      blockcount:=blockcount+1;
      blocklength:=0;
      end;
    if (data<>'cross')and(data<>'clear')then blocklength:=blocklength+1;
    end else
    begin
    if (data<>'cross')and(data<>'clear')then blocklength:=blocklength+1;
    end;
  prev:=data;
  end;
result:=blockcount;
END;

Function Tmainform.getPlayable(elementNo:Integer;row:boolean):Integer;
var
i:integer;
firstfree,lastfree,clear:integer;
arrayToAnalyse:array of string;
clearfound:boolean;
BEGIN
{finds the number of squares that have not been marked with crosses}
{additionally it should return zero if there are no clear squares}
{because that element is filled}
clearfound:=false;
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
  for clear := firstfree to lastfree do
  if arrayToAnalyse[clear] = 'clear' then
    begin
    clearfound:=true;
    end;
if clearfound = false then result:=0
else result:=lastfree-firstfree+1;
END;

Function Tmainform.identifyBlocks(ElementNo:Integer;row:boolean):integer;
var
testArray:array of string;
i,spaces,blocks:integer;
spacebefore,blocklength,spaceafter:integer;
thisSquare,prevSquare:string;
valid:boolean;
BEGIN
{assemble a copy of the relevant element}
if row then
  begin
  setlength(testArray,length(columndata));
  for i:=0 to length(testArray)-1 do
    begin
    testArray[i]:=getgrid(i,elementNo);
    end;
  end else
  begin
  setlength(testArray,length(rowdata));
  for i:=0 to length(testArray)-1 do
    begin
    testArray[i]:=getgrid(elementNo,i);
    end;
  end;
{we have a clone of the current row - lets analyse it}
spaces := getSpaceCount(ElementNo,row);
blocks := getActualBlocks(ElementNo,row);
if row then
lb1.Items.Add('row '+inttostr(elementNo)+' has '+inttostr(spaces)+' spaces and '+inttostr(blocks)+' blocks')else
lb1.Items.Add('col '+inttostr(elementNo)+' has '+inttostr(spaces)+' spaces and '+inttostr(blocks)+' blocks');
if (blocks > 0)and(spaces>0) then
  begin
  spacebefore:=0;
  blocklength:=0;
  spaceafter:=0;
  valid:=false;
  prevSquare:='cross';
  i:=getfirstuncrossed(elementNo,row);
    repeat
    if i< length(testArray) then thisSquare:=testArray[i] else thisSquare:='cross';

    if thisSquare='clear' then
      begin
      if blocklength=0 then spacebefore:=spacebefore+1 else spaceafter:=spaceafter+1;
      end else
    if thisSquare='cross' then
      begin
      if blocklength=0 then spacebefore:=0 else valid:=true;
      end else
      begin
      if (thisSquare<>prevSquare)then
        begin
        if (prevSquare<>'cross')then
          begin
          if prevsquare='clear' then blocklength:=blocklength+1 else valid:=true;
          end;
        end else blocklength:=blocklength+1;
      end;
    if valid = true then
      begin
      lb1.Items.Add(booltostr(row)+' el '+inttostr(elementNo)+' spaces before: '+inttostr(spacebefore)+' block: '+inttostr(blocklength)+' spaces after '+inttostr(spaceafter));
      spacebefore:=0;
      spaceafter:=0;
      valid:=false;
      prevsquare:='cross';
      blocklength:=0;
      end;
    prevSquare:=thisSquare;  
    i:=i+1;
    until i=length(testArray);
{this will look at the current arrangement of the row}
{try to identify each block in turn}
{not much point trying to do this unless the total}
{block length is greater than playable}
  end;
result := 0;
END;


Function Tmainform.identifyBlock(elementNo,blockStart,blockLength:integer;blockColour:string;row:boolean):integer;
BEGIN
{this will eventually identify a block}
result:=-1;
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

Function TMainform.smallestSpaceCanBeUsed(elementNo,smallestSpace,smallestSpacePos:Integer;row:Boolean):Integer;
var
testRowOffset:integer;
elementLength,elementfillLength,blocksize,lastBlocksize:integer;
blockFits,noOverrun,matchFound,newBlockFound,done:boolean;
BEGIN
{This finds the smallest block that will not result}
{in the rest of the row going out of range}
if row then fillTest(elementNo,length(columndata)) else fillTest(elementNo,length(columndata),false);
elementfillLength:=getElementFillLength(elementNo,Row);
if row then elementLength:=length(columndata)
else elementLength:=length(rowData);
{start with the first square of the first block lining up with}
{the first square of the smallest space}
testRowOffset:=smallestSpacePos-1;
blockfits:=false;
noOverrun:=false;
while testRowOffset >= 0 do
  begin
  {will the selected block go into this space?}
  blocksize:=strtoint(testArray[smallestSpacePos-(testRowOffset+1)][1]);
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
    newBlockFound:=false;
      repeat
      testRowOffset:=testRowOffset-1;
      if testRowOffset > 0 then
        begin
        lastBlocksize:=blocksize;
        blocksize:=strtoint(testArray[smallestSpacePos-(testRowOffset+1)][1]);
        newBlockFound:=(lastBlockSize<=0) and (blockSize >0);
        end;
      done:=(testRowOffset<=0) or newBlockFound;
      until done;
    end;
  end;
result:=0;
END;

Function Tmainform.getActualBlockLength(ElementNo,blockNo:Integer;row:boolean=true):integer;
var
i,blockcount,blocklength,limit:integer;
prev,data:string;
BEGIN
if row then limit:=length(columndata) else limit:=length(rowdata);
blockcount:=-1;
blocklength:=0;
prev:='cross';
  for i:=0 to limit do
  begin
  if i<limit then
    begin
    if row then data:= getgrid(i,elementNo)
    else data:= getgrid(elementNo,i);
    end else data:='cross';
   if (data<>'clear')and(data<>'cross') then
    begin
    {Start counting if there's a change}
    {and this is the block we're looking for}
    if (prev<>data) then
      begin
      blockcount:=blockcount+1;
      end;
    if blockcount = blockno then blocklength:=blocklength+1;
    end;
  prev:=data;
  end;
result := blocklength;
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
  if row then data:=getgrid(i,elementNo) else data:=getgrid(elementno,i);
  if (data='clear')and(startrun) then current:=current+1;
  if (data='cross')or(i=limit) then
    begin
    startrun:=true;
    if (current<>0)and(current<smallest)then
      begin
      smallestpos:=i-current;
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
  if getgrid(i,elementno)='clear' then
    begin
    result:=false;
    exit;
    end;
  end else
for i:=0 to length(rowdata)-1 do
  begin
  if getgrid(elementno,i)='clear' then
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
for i:=0 to blockdatalength-1 do
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
currentboxset:= getgrid(x,y);
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
  setgrid(x,y,newboxset);
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
bottombox:=getpaintboxbyname('c1r'+inttostr(heightofgame-1));
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

Function Tmainform.fillTest(elementNo,playable:Integer;row:Boolean):integer;
var
block,i:integer;
data,fillpattern:String;
blocklength,totalBlockLength,offset:integer;
blockDataLength:integer;
BEGIN
totalBlockLength:=0;
offset:=0;
setLength(testArray,0,0);
if playable = 0 then
  begin
  result:=0;
  exit;
  end;
if row then
  begin
  setLength(testArray,playable,2);
  blockDataLength:=length(rowdata[0])-1;
  end else
  begin
  setLength(testArray,playable,2);
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
    data:=getRowData(elementNo,block,0);
    fillpattern:=getRowData(elementNo,block,1);
    end else
    begin
    data:=getColumnData(elementNo,block,0);
    fillpattern:=getColumnData(elementNo,block,1);
    end;
  if data<>'' then
    begin
    blocklength:=strtoint(data);
    totalBlocklength:=totalBlockLength+blockLength;
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
      totalBlockLength:=totalBlockLength+1;
      end;
    end;
  end;
result:=totalBlockLength;
END;


Procedure Tmainform.Startgame(name: string; columns,rows:Tstringlist);
var
rowcount,colcount,controlno,x,y:integer;
thetext:string;
currentdata:TStringlist;
Begin
{set the dimensions of the game grid}
SetLength(game,columns.Count,rows.count,2);
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
SetLength(rowData,rows.count,rowcount,3);
SetLength(columnData,columns.count,colcount,3);

for x:=0 to columns.Count-1 do
  begin
  currentdata:=getnumbers(columns[x]);
  for y:=0 to colcount-1 do
    begin
    if y >= (colcount-currentdata.Count) then
    thetext:=currentdata[y-(colcount-currentdata.count)]
    else thetext:='';

    Createeditbox('c'+inttostr(x)+'n'+inttostr(y),mainform,clBase,(21*rowcount)+((x)*21),((y)*21),20,20,thetext);
    setcolumnData(x,y,0,thetext);
    setcolumnData(x,y,1,'clBlack');
    setcolumnData(x,y,2,'u');
    end;
  end;

for y:= 0 to rows.Count-1 do
  begin
  currentdata:=getnumbers(rows[y]);
  for x:=0 to rowcount-1 do
    begin
    if x >= (rowcount-currentdata.Count) then
    thetext:=currentdata[x-(rowcount-currentdata.count)]
    else thetext:='';
    Createeditbox('r'+inttostr(x)+'n'+inttostr(y),mainform,clBase,((x)*21),(21*colcount)+((y)*21),20,20,thetext);
    setRowData(y,x,0,thetext);
    setRowData(y,x,1,'clBlack');
    setRowData(y,x,2,'u');
    end;
  end;

for y:= 0 to rows.count-1 do
  begin
  for x:= 0 to columns.count-1 do
    begin
    setgrid(x,y,'clear');
    Createpaintbox('c'+inttostr(x)+'r'+inttostr(y),mainform,clMid,(21*rowcount)+(21*x),(21*colcount)+(21*y),20,20);
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
  contents:=getgrid(x,y);

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
var
i:integer;
begin
lb1.Items.Add('basic overlap-row solved '+inttostr(basicOverlap)+' squares');
lb1.Items.Add('basic overlap-column solved '+inttostr(basicOverlap(false))+' squares');
lb1.Items.Add('edgeproximityrowfirst solved '+inttostr(edgeProximity)+' squares');
lb1.Items.Add('edgeproximitycolfirst solved '+inttostr(edgeProximity(false))+' squares');
lb1.Items.Add('singlenumberrow solved '+inttostr(singlenumberrow)+' squares');
lb1.Items.Add('singlenumbercol solved '+inttostr(singlenumberrow(false))+' squares');
lb1.Items.Add('crossSmallSpaces solved '+inttostr(crossAllSmallSpaces)+' squares');

for i:=0 to length(game[0])-1 do identifyblocks(i);
for i:=0 to length(game)-1 do identifyblocks(i,false);
{lb1.Items.Add('basic overlap-row pass 2 solved '+inttostr(basicOverlap)+' squares');
lb1.Items.Add('basic overlap-column pass 2 solved '+inttostr(basicOverlap(false))+' squares');
}

edit1.Text:=inttostr(getClearSquareCount);

end;

{stuff below here is concerned with solving the problems}
{or trying to anyway...}

Function Tmainform.basicOverlap(row:boolean):Integer;
Var
elementNo,elementLimit,blockDataLength:Integer;
playable,offset,position:Integer;
leftlimit,rightlimit:Array of string;
blockdifference,clearspace:integer;
clearCountBefore,clearCountAfter:Integer;
lastcolourleft,lastcolourright:String;
BEGIN
clearCountBefore:=getClearSquareCount;
if row then elementLimit:= length(rowdata)
else elementLimit:=length(columndata);
for elementNo:=0 to elementLimit-1 do
  begin
  playable:=getPlayable(elementNo,row);
  if playable > 0 THEN
    begin
    blockdatalength:=fillTest(elementNo,playable,row);
    if blockdatalength > playable/2 then
      begin
      setlength(leftlimit,playable);
      setlength(rightlimit,playable);
      offset:=getFirstUncrossed(elementNo-1,row);
      position:=0;
      clearspace:=length(testArray)-blockdatalength;

      while position < length(leftlimit) do
        begin
        leftLimit[position]:=testArray[position][0];
        if position >= (length(testArray)-blockdatalength) then
        rightLimit[position]:=testArray[position-clearspace][0] else
        rightLimit[position]:='clear';
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
          if row then
            begin
            setBox(position+offset,elementNo,leftlimit[position],true);
            end else
            begin
            setBox(elementNo,position+offset,leftlimit[position],true);
            end;
          end;
        position:=position+1;
        end;
      end;
    end;
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;


Function Tmainform.edgeProximity(row:boolean):Integer;
var
elementNo,elementLength,totalBlockLength,limit:integer;
i,firstnumber:integer;
elementData,elementColour,data:String;
clearcountbefore,clearcountafter:integer;
firstFound,done:boolean;
rightlimit:Array of array of string;
BEGIN
clearcountbefore:=getclearsquarecount;
if row then
  begin
  elementLength := length(columndata);
  limit:=length(rowdata);
  end else
  begin
  elementLength := length(rowdata);
  limit:=length(columndata);
  end;

for elementNo:=0 to limit-1 do
  begin
  if row then totalBlockLength := fillTest(elementNo,elementLength)
   else totalBlockLength := fillTest(elementNo,elementLength,false);
  setLength(rightLimit,elementLength,2);
  {set up the right limit array - same data shifted as far right as poss}
  if totalBlockLength < elementLength then
  for i:=0 to elementLength - 1 do
    begin
    if i < (elementLength - totalBlockLength) then
      begin
      rightLimit[i][0] := 'clear';
      rightLimit[i][1] := '-1';
      end else
      begin
      rightLimit[i][0] := testArray[i-elementLength + totalBlockLength][0];
      rightLimit[i][1] := testArray[i-elementLength + totalBlockLength][1];
      end;
    end;

  {get the first element. If it's not filled then the element is blank}
  elementData:=testArray[0][1];
  if elementData <> '' then
    begin
    firstnumber:=strtoint(elementData);
    elementcolour:=testArray[0][0];
    {now see if any squares before length(firstnumber) is filled}
    i:=0;
      repeat
      if row then data := getgrid(i,elementNo)
        else data := getgrid(elementNo,i);
      firstFound := data = elementcolour;
      if not firstFound then i:=i+1;
      done := firstFound or (i >= firstnumber);
      until done;
    if firstFound then
    while i < firstnumber do
      begin
      if row then setbox(i,elementNo,elementcolour,true);
      i:=i+1;
      end;
    end;

  elementData:=rightLimit[elementLength-1][1];
  if elementData <> '' then
    begin
    firstnumber:=elementLength-strtoint(elementData);
    elementcolour:=rightLimit[elementLength-1][0];
    {now see if any squares after length(firstnumber) is filled}
    i:=elementLength-1;
      repeat
      if row then data := getgrid(i,elementNo)
        else data := getgrid(elementNo,i);
      firstFound := data = elementcolour;
      if not firstFound then i:=i-1;
      done := firstFound or (i < firstNumber);
      until done;
    if firstFound then
    while i >= firstnumber do
      begin
      if row then setbox(i,elementNo,elementcolour,true) else
        setbox(elementNo,i,elementcolour,true);
      i:=i-1;
      end;
    end;
  end;

clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

Function Tmainform.spacesThatMustBeCrossed(ElementNo:integer;row:boolean=true):integer;
BEGIN
{}
result:=0;
END;

Function Tmainform.singleNumberRow(row:boolean):Integer;
var
element,i:Integer;
blocklength,squaresfilled:integer;
firstfilled,lastfilled:Integer;
fillpattern:String;
limit,elementlength,lastbox:integer;
clearcountbefore,clearcountafter:Integer;
done:boolean;
BEGIN
clearcountbefore:=getClearSquareCount;
{A special case where there's only one block in a row}
{or column}

if row then limit:=length(rowdata)-1
else limit := length(columndata)-1;
for element:=0 to limit do
  begin
  blocklength:=-1;
  if row then
    begin
    lastbox:=length(rowdata[0])-1;
    if (lastbox=0)or(getrowdata(element,lastbox-1,0)='')
    then blocklength:=strtoint(getrowdata(element,lastbox,0));
    end else
    begin
    lastbox:=length(columndata[0])-1;
    if (lastbox=0)or(getcolumndata(element,lastbox-1,0)='')
    then blocklength:=strtoint(getcolumndata(element,lastbox,0));
    end;
  if blocklength > -1 then
    try
    if row then elementlength:=length(columndata) else elementlength:=length(rowdata);
    squaresFilled:=getActualBlockLength(Element,0,row);
    fillpattern:='clear';
    firstfilled:=-1;
    lastfilled:=-1;
    i:=0;
      repeat
      if row then fillpattern:=getgrid(i,element) else fillpattern:= getgrid(element,i);
      if (fillpattern<>'clear')and(fillpattern<>'cross') then
        begin
        firstfilled:=i;
        lastfilled:=firstfilled+squaresFilled -1;
        end;
      i:=i+1;
      done :=(i=elementlength)or(firstfilled>-1)
      until done;

    if (firstfilled > -1)and(lastfilled > -1) then
    for i:=0 to elementlength do
      begin
      if (i<=(lastfilled - blocklength))or(i>=(firstfilled + blocklength))
      then
        begin
        if i < elementlength then
        if row then
        setBox(i,element,'cross',true)
        else setBox(element,i,'cross',true);
        end;
      end;
    except
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
if smallestSpaceStart > 0 then
  begin
  smallestBlock:=smallestSpaceCanBeUsed(elementNo,smallestSpace,smallestSpaceStart,row);
  if smallestBlock = 0 then
    begin
    for i := smallestSpaceStart to smallestSpaceStart+smallestSpace-1 do
      begin
      if row then setbox(i,elementNo,'cross',true)
      else setbox(elementNo,i,'cross',true)
      end;
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
for rowno:=0 to length(rowdata)-1do
  begin
  if not elementIsComplete(rowno) then
  crossSmallSpaces(rowno);
  end;
for colno:=0 to length(columndata)-1do
  begin
  if not elementIsComplete(colno,false) then
  crossSmallSpaces(colno,false);
  end;
clearcountafter:=getClearSquareCount;
result:=clearcountbefore-clearcountafter;
END;

end.
