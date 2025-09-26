unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    PaintBox1: TPaintBox;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    CheckBox1: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Math;

procedure TForm1.Button1Click(Sender: TObject);
const
  mapsizex = 400;
  mapsizey = 400;

  procedure _(size: integer);
  var
    posx, posy: integer;
  begin
    posx := Random(mapsizex);
    posy := Random(mapsizey);
    paintbox1.Canvas.Ellipse(posx, posy, posx+size, posy+size);
  end;

var
  i: integer;
begin
  paintbox1.Canvas.Rectangle(0,0,mapsizex,mapsizey);

  for i := 0 to 1 do
  begin
  _(100);
  _(100);
  _(100);
  _(100);

  _(50);
  _(50);
  _(50);
  _(50);
  _(50);
  _(50);
  _(50);
  _(50);

  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  _(25);
  end;
end;

function RandomBetween(a, b: integer): integer;
begin
  result := RandomRange(a,b+1);
end;

function IsInCircle(p, q: TPoint; pr: integer): boolean;
begin
  result := sqrt((p.x-q.x)*(p.x-q.x) + (p.y-q.y)*(p.y-q.y)) <= pr;
end;

procedure TForm1.Button2Click(Sender: TObject);
const
  maxB = 50;
  r = 30;
  maxX = 400;
  maxY = 400;

  procedure _Draw(p: TPoint);
  begin
    paintbox1.Canvas.Ellipse(p.X-r,p.Y-r, p.X+r,p.Y+r);
  end;

  function findRandomOutline(p: TPoint): TPoint;
  var
    yg, xg: integer;
  begin
    xg := RandomBetween(p.X-r, p.X+r);
    if RandomBetween(0,1) = 0 then
      yg := Floor(p.y - sqrt(r*r - (p.x-xg)*(p.x-xg)))
    else
      yg := Floor(p.y + sqrt(r*r - (p.x-xg)*(p.x-xg)));
    result.X := xg;
    result.Y := yg;
  end;

  function CirclesOverlap(p, q: TPoint): boolean;
  begin
    result := (abs(p.x-q.x) < 2*r) and (abs(p.y-q.y) < 2*r);
  end;

var
  Circles: array[0..maxB] of TPoint;
  i, j: integer;
  p: TPoint;
  feck: boolean;
begin
  paintbox1.Canvas.Rectangle(0,0,maxx,maxy);

  Circles[0].X := maxX div 2;
  Circles[0].Y := maxY div 2;
  _Draw(Circles[0]);

  for i := 1 to maxB do
  begin

    repeat
      feck := false;
      p := findRandomOutline(Circles[i-1]);
      for j := 0 to i-2 do
      begin
        if CirclesOverlap(p, Circles[j]) then
        begin
          feck := true;
          break;
        end;
      end;
    until not feck;

    Circles[i] := p;
    _Draw(Circles[i]);
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Randomize;
end;

procedure TForm1.Button3Click(Sender: TObject);
const
  maxB = 50;
  r = 30;
  maxX = 400;
  maxY = 400;
  klebfaktor = 0.9;

  procedure _Draw(p: TPoint);
  begin
    paintbox1.Canvas.Ellipse(p.X-r,p.Y-r, p.X+r,p.Y+r);
  end;

  function findRandomOutline(p: TPoint): TPoint;
  var
    yg, xg: integer;
    newr: integer;
  begin
    newr := Round(1.5*r);
    xg := RandomBetween(p.X-newr, p.X+newr);
    if RandomBetween(0,1) = 0 then
      yg := Floor(p.y - sqrt(newr*newr - (p.x-xg)*(p.x-xg)))
    else
      yg := Floor(p.y + sqrt(newr*newr - (p.x-xg)*(p.x-xg)));
    result.X := xg;
    result.Y := yg;
  end;

  function CirclesOverlap(p, q: TPoint): boolean;
  begin
    result := (abs(p.x-q.x) < 2*r) and (abs(p.y-q.y) < 2*r);
  end;

var
  Circles: array[0..maxB] of TPoint;
  i, j: integer;
  c: integer;
  feck: boolean;
  p: tpoint;
begin
  memo1.lines.clear;
  paintbox1.Canvas.Rectangle(0,0,maxx,maxy);

  Circles[0].X := maxX div 2;
  Circles[0].Y := maxY div 2;
  _Draw(Circles[0]);



  for i := 1 to maxB do
  begin
      c := RandomBetween(0,i-1);

    repeat
//      memo1.lines.add(IntTostr(i)+ ' -> ' + inttostr(c));

      Circles[i] := findRandomOutline(Circles[c]);


      feck := false;
      (*
      for j := 1 to i-2 do
      begin
        if CirclesOverlap(Circles[i], Circles[j]) then
        begin
          inc(fc);
          feck := true;
          break;
        end;
      end;

      if fc > 100 then
      begin
        c := RandomBetween(0,i-1);
        fc := 0;
      end;
      *)

//   Application.ProcessMessages;
//    Sleep(500);

    until not feck;
    _Draw(Circles[i]);

          memo1.lines.add('Draw '+IntTostr(i)+ ' based on ' + inttostr(c));

  end;

  exit;

  for i := 1 to maxB do
  begin

    repeat
      feck := false;
      p := findRandomOutline(Circles[i-1]);
      for j := 0 to i-2 do
      begin
        if CirclesOverlap(p, Circles[j]) then
        begin
          feck := true;
          break;
        end;
      end;
    until not feck;

    Circles[i] := p;
    _Draw(Circles[i]);
  end;
end;

procedure TForm1.Button4Click(Sender: TObject);
const
  mapsizex = 400;
  mapsizey = 400;

  procedure _(size: integer);
  var
    posx, posy: integer;
  begin
    posx := Random(mapsizex);
    posy := Random(mapsizey);
    paintbox1.Canvas.Ellipse(posx, posy, posx+size, posy+size);
  end;

var
  i: integer;
begin
  paintbox1.Canvas.Rectangle(0,0,mapsizex,mapsizey);

  for i := 0 to 20 do
  begin
    _(RandomBetween(10,100));
  end;
end;

procedure TForm1.Button5Click(Sender: TObject);
const
  r = 5;
  maxX = 545;
  maxY = 545;
var
  drawnCircles: integer;

  procedure _Draw(p: TPoint);
  begin
    paintbox1.Canvas.Brush.Color := clGray;
    paintbox1.Canvas.Pen.Color := clGray;
    paintbox1.Canvas.Ellipse(p.X-r,p.Y-r, p.X+r,p.Y+r);
    inc(drawnCircles);

//    Sleep(10);
//    application.processmessages;
  end;

  function RandBetween(a, b: integer): integer;
  begin
    result := Random(b-a+1)+a;
  end;

  procedure BeginAdventure(startx, starty, angle, dep: integer);
  const
    maxB = 200;
    flexi = 25;
    maxdep = 2;
    anzahlZweige = 2;
    rand = 2;
    zielBaumZahl = 1000;
  var
    Circles: array[0..maxB] of TPoint;
    Rad: array[0..maxB] of integer;
    i: integer;
    x: integer;
    maxdrawn: integer;
  begin
    if dep > maxdep then exit;
    if drawncircles >= zielBaumZahl then exit;

    Rad[0] := angle;
    Circles[0].X := startx;
    Circles[0].Y := starty;
    _Draw(Circles[0]);

    repeat
    maxdrawn := 0;
    for i := 1 to maxB{ div (dep+1)} do
    begin
      Rad[i] := RandBetween(Rad[i-1]-flexi, Rad[i-1]+flexi);
      Circles[i].X := Circles[i-1].X + round(r*cos(Rad[i]/360*2*pi));
      Circles[i].Y := Circles[i-1].Y + round(r*sin(Rad[i]/360*2*pi));

      if Circles[i].X > maxX-rand*r then break;
      if Circles[i].Y > maxY-rand*r then break;
      if Circles[i].X < rand*r then break;
      if Circles[i].Y < rand*r then break;

      maxdrawn := i;
    end;
    until maxdrawn = maxB div (dep+1);

    for i := 1 to maxdrawn do
    begin
      _Draw(Circles[i]);
    end;

    if maxdrawn > dep*50 then
    for i := 1 to anzahlZweige do
    begin
      x := RandBetween(maxdrawn div 2, maxdrawn);
      if RandBetween(0,1)=0 then
      BeginAdventure(Circles[x].X, Circles[x].Y, Rad[x]-90, dep+1)
      else
      BeginAdventure(Circles[x].X, Circles[x].Y, Rad[x]+90, dep+1);
    end;
  end;

begin
  Randomize;

  memo1.lines.clear;
  drawnCircles := 0;

    paintbox1.Canvas.Brush.Color := clGreen;
    paintbox1.Canvas.Pen.Color := clBlack;
      paintbox1.Canvas.Rectangle(0,0,maxx,maxy);

  BeginAdventure(maxX div 2, maxY div 2, RandBetween(0, 360), 0);
end;

procedure TForm1.Button6Click(Sender: TObject);
const
  r = 5;
  maxX = 545;
  maxY = 545;
  zielBaumZahl = 1000;
var
  drawnCircles: integer;
  Circles: array[0..zielBaumZahl-1] of TPoint;
  Rad: array[0..zielBaumZahl-1] of integer;

  procedure _Draw(p: TPoint);
  begin
    paintbox1.Canvas.Brush.Color := clGray;
    paintbox1.Canvas.Pen.Color := clGray;
    paintbox1.Canvas.Ellipse(p.X-r,p.Y-r, p.X+r,p.Y+r);
    inc(drawnCircles);

//    Sleep(10);
//    application.processmessages;
  end;

  function RandBetween(a, b: integer): integer;
  begin
    result := Random(b-a+1)+a;
  end;

  procedure BeginAdventure(startx, starty, angle: integer);
  const
    maxB = 200;
    flexi = 15;
    rand = 2;
  var
    i: integer;
    x: integer;
    maxdrawn: integer;
    beg: integer;
  begin
    if drawncircles >= zielBaumZahl then exit;

    Rad[0] := angle;
    Circles[0].X := startx;
    Circles[0].Y := starty;
    _Draw(Circles[0]);

    beg := 1;

    while true do
    begin

      maxdrawn := 0;
      for i := beg to beg+maxB do
      begin
        if i > High(Rad) then Exit;

        Rad[i] := RandBetween(Rad[i-1]-flexi, Rad[i-1]+flexi);
        Circles[i].X := Circles[i-1].X + round(r*cos(Rad[i]/360*2*pi));
        Circles[i].Y := Circles[i-1].Y + round(r*sin(Rad[i]/360*2*pi));

        if Circles[i].X > maxX-rand*r then break;
        if Circles[i].Y > maxY-rand*r then break;
        if Circles[i].X < rand*r then break;
        if Circles[i].Y < rand*r then break;

        _Draw(Circles[i]);

        maxdrawn := i;
      end;

      x := RandBetween(0, maxdrawn);
      Circles[maxdrawn+1] := Circles[x]; // virtual tree (not drawn)

      if RandBetween(0,1) = 0 then
        Rad[maxdrawn+1] := Rad[x]-90
      else
        Rad[maxdrawn+1] := Rad[x]+90;

      beg := maxdrawn+2;

    end;
  end;

begin
  Randomize;

  memo1.lines.clear;
  drawnCircles := 0;

    paintbox1.Canvas.Brush.Color := clGreen;
    paintbox1.Canvas.Pen.Color := clBlack;
      paintbox1.Canvas.Rectangle(0,0,maxx,maxy);

  BeginAdventure(maxX div 2, maxY div 2, RandBetween(0, 360));
end;


function TreePos(nTrees, treeRadius, mapX, mapY: integer; memblock: Pointer; debug: boolean): dword; cdecl; external 'd:\tdn\mapgen\mapgen32.dll';

procedure DrawCircle(x, y, r: integer);
begin
  form1.paintbox1.Canvas.Brush.Color := clMaroon;
  form1.paintbox1.Canvas.Pen.Color := clMaroon;
  form1.paintbox1.Canvas.Ellipse(X-r,Y-r, X+r,Y+r);
end;

procedure TForm1.Button7Click(Sender: TObject);
const
  miniature_factor = 20; // only viewer
  treeradius = 100;
  ntrees = 5000;
  mapX = 10000;
  mapY = 10000;
var
  i: integer;
  mb: array[0..ntrees-1, 0..1] of dword;
begin
  paintbox1.Repaint;

  TreePos(ntrees, treeradius, mapx, mapy, @mb[0][0], checkbox1.checked);

  paintbox1.Canvas.Brush.Color := clGreen;
  paintbox1.Canvas.Pen.Color := clBlack;
  paintbox1.Canvas.Rectangle(0,0,mapx div miniature_factor,mapy div miniature_factor);

  for i := 0 to ntrees-1 do
  begin
    DrawCircle(mb[i][0] div miniature_factor, mb[i][1] div miniature_factor, treeradius div miniature_factor);
  end;
end;

end.
