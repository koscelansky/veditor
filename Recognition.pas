unit Recognition;

{$MODE Delphi}

interface

uses
  Shapes, Support, Actions, Graphics, Types, Undo, Picture, Controls, SysUtils;

type
  TReco = record
    point: TPoint;
    time: TDateTime;
  end;

  TRecognition = class(TAction)
    private
      _n: Integer;
      _points: array of TReco;
      _color: TColor;
      _width: Integer;
      _BGcolor: TColor;
      _fill: boolean;
      _zoom: Real;
      _mousedown: Boolean;

      procedure addPoint(p: TPoint);
      function recognize(): TShape;
      function tryCircleAndEllipse(var odchylka: Real): TShape;
      function trySegmentLine(var odchylka: Real): TShape;
      function tryPolyLinePolygonAndRectangle(var odchylka: Real): TShape;
      function isRectangle(points: TPoints): Boolean;
    public
      procedure zoom(a: Real); override;
      procedure changeShape(shape: TShape); override;
      function changeWidth(width: Integer): TUndoStrategy; override;
      function changeColor(color: TColor): TUndoStrategy; override;
      function delete(): TUndoStrategy; override; //neunduuje sa;
      function changeBGColor(color: TColor): TUndoStrategy; override;
      function changeBGMode(fill: boolean): TUndoStrategy; override;
      function getActualColor(): TColor; override;
      function getActualWidth(): Integer; override;
      function getActualBGColor(): TColor; override;
      function getActualBGMode(): Boolean; override;

      function mouseDown(args: TMouseArgs): TUndoStrategy; override;
      function mouseMove(args: TMouseArgs): TUndoStrategy; override;
      function mouseUp(args: TMouseArgs): TUndoStrategy; override;

      procedure draw(C: TCanvas); override;

      constructor Create(pic: TVectorPicture; color: TColor = clBlack; width: Integer = 1; backGroundColor: TColor = clWhite; hasBGColor: boolean = false);
      destructor Destroy(); override;
  end;

implementation

//------------------TRecognition-----------------

procedure TRecognition.changeShape(shape: TShape);
begin

end;

function TRecognition.delete(): TUndoStrategy;
begin
  Result := nil;
end;

function TRecognition.tryCircleAndEllipse(var odchylka: Real): TShape;
var
  ellipse: TGeneralEllipseEquation;
  i: Integer;
  p: TPoint;
  minx, maxx, miny, maxy, a, b: Integer;
begin
  p := NilPoint;
  minx := MaxInt;
  miny := MaxInt;
  maxx := - MaxInt;
  maxy := - MaxInt;
  for i := 0 to _n - 1 do
  begin
    if _points[i].point.X > maxx then maxx := _points[i].point.X;
    if _points[i].point.Y > maxy then maxy := _points[i].point.Y;
    if _points[i].point.X < minx then minx := _points[i].point.X;
    if _points[i].point.Y < miny then miny := _points[i].point.Y;
    p.X := p.X + _points[i].point.X;
    p.Y := p.Y + _points[i].point.Y;
  end;
  p.X := round(p.X / _n);
  p.Y := round(p.Y / _n);
  a := round((maxx - minx) / 2);
  b := round((maxy - miny) / 2);
  ellipse := TGeneralEllipseEquation.Create(p.X, p.Y, a, b);
  if (abs(a - b) < 5) then
    Result := TCircle.Create(p, round((a+b)/2), _color, _width)
  else
    Result := TEllipse.Create(p, a, b, _color, _width);
  Result.backgroundColor := _BGcolor;
  Result.bgColorMode := _fill;
  odchylka := 0;
  for i := 0 to _n - 1 do
    odchylka := odchylka + ellipse.pointDistance(_points[i].point);
  odchylka := odchylka / _n;
end;

function TRecognition.trySegmentLine(var odchylka: Real): TShape;
var
  line: TGeneralLineEquation;
  i: Integer;
begin
  line := TGeneralLineEquation.Create(_points[0].point, _points[_n-1].point);
  odchylka := 0;
  for i := 0 to _n - 1 do
    odchylka := odchylka + line.pointDistance(_points[i].point);
  odchylka := odchylka / _n;
  Result := TSegmentLine.Create(_points[0].point, _points[_n-1].point, _color, _width);
  Result.zoom := _zoom;
  Result.backgroundColor := _BGcolor;
  Result.bgColorMode := _fill;
  line.Free;
end;

function TRecognition.isRectangle(points: TPoints): Boolean;
var
  rec: TRect;
begin
  Result := false;
  if Length(points) = 4 then
  begin
    rec := Rect(points[0].X, points[0].Y, points[2].X, points[2].Y);
    if (TSupport.distance(Point(rec.Left, rec.Bottom), points[1]) < 50) and
      (TSupport.distance(Point(rec.Right, rec.Top), points[3]) < 50) then
      Result := true;
    if (TSupport.distance(Point(rec.Left, rec.Bottom), points[3]) < 50) and
      (TSupport.distance(Point(rec.Right, rec.Top), points[1]) < 50) then
      Result := true;
  end;
end;

function TRecognition.tryPolyLinePolygonAndRectangle(var odchylka: Real): TShape;
var
  i, m, j: Integer;
  poi: TPoints;
begin
  SetLength(poi, 5);
  poi[0] := _points[0].point;
  m := 1;
  for i := 0 to _n - 2 do
  begin
    if (_points[i + 1].time - _points[i].time) > 0.000000185185185188 then
    begin
      poi[m] := _points[i].point;
      m := m + 1;
      if (length(poi) < (m + 3)) then
        SetLength(poi, Length(poi) + 5);
    end;
  end;
  poi[m] := _points[_n - 1].point;
  m := m + 1;
  i := 0;
  while i <= m - 2 do
  begin
    if TSupport.distance(poi[i], poi[i+1]) < 20 then
    begin
      for j := i to m - 2 do
        poi[j] := poi[j+1];
      m := m - 1;
    end
    else
      i := i + 1;
  end;
  SetLength(poi, m);
  if Length(poi) < 2 then
  begin
    Result := nil;
    odchylka := MaxInt;
    Exit;
  end;
  if (TSupport.distance(poi[0], poi[m - 1])) < 15 then
  begin
    SetLength(poi, m - 1);
    if isRectangle(poi) then
      Result := TRectangle.Create(Rect(poi[0].X, poi[0].Y, poi[2].X, poi[2].Y), _color, _width)
    else
      Result := TPolygon.Create(poi, _color, _width);
  end
  else
    Result := TPolyLine.Create(poi, _color, _width);
  Result.backgroundColor := _BGcolor;
  Result.bgColorMode := _fill;
  odchylka := 0;
  for i := 0 to _n - 1 do
    odchylka := odchylka + Result.distance(_points[i].point);
  odchylka := odchylka / _n;
end;

function TRecognition.recognize(): TShape;
var
  s: TShape;
  odchylka, min: Real;
  i: Integer;
begin
  if _n < 5 then
  begin
    Result := nil;
    Exit;
  end;
  if not(hasPicture) then
    Exit;
  for i := 0 to _n - 1 do
  begin
    _points[i].point.X := round(_points[i].point.X / _zoom);
    _points[i].point.Y := round(_points[i].point.Y / _zoom);
  end;
  Result := tryPolyLinePolygonAndRectangle(odchylka);
  min := odchylka;
//segment line
  s := trySegmentLine(odchylka);
  if odchylka < min then
  begin
    if Result <> nil then
      Result.Free;
    min := odchylka;
    Result := s;
  end;
//ellipse & circle
  s := tryCircleAndEllipse(odchylka);
  if (odchylka < min) then
  begin
    min := odchylka;
    Result.Free;
    Result := s;
  end;
  if min > 20 then
    FreeAndNil(Result);
//
end;

procedure TRecognition.zoom(a: Real);
begin
  _zoom := a;
  _mousedown := false;
  _n := 0;
end;

function TRecognition.changeWidth(width: Integer): TUndoStrategy;
begin
  Result := nil;
  _width := width;
end;

function TRecognition.changeColor(color: TColor): TUndoStrategy;
begin
  Result := nil;
  _color := color;
end;

function TRecognition.changeBGColor(color: TColor): TUndoStrategy;
begin
  Result := nil;
  _BGcolor := color;
end;

function TRecognition.changeBGMode(fill: boolean): TUndoStrategy;
begin
  Result := nil;
  _fill := fill;
end;

function TRecognition.getActualColor(): TColor;
begin
  Result := _color;
end;

function TRecognition.getActualWidth(): Integer;
begin
  Result := _width;
end;

function TRecognition.getActualBGColor(): TColor;
begin
  Result := _BGcolor;
end;

function TRecognition.getActualBGMode(): Boolean;
begin
  Result := _fill;
end;

function TRecognition.mouseUp(args: TMouseArgs): TUndoStrategy;
var
  s: TShape;
begin
  Result := nil;
  if (args.button = mbLeft) and _mousedown then
  begin
    _mousedown := false;
    s := recognize();
    if s <> nil then
    begin
      _picture.addShape(s);
      Result := TUndoCreate.Create(s, _picture, _picture.getZIndex(s));
    end;
    SetLength(_points, 100);
    _n := 0;
  end;
end;

procedure TRecognition.draw(C: TCanvas);
var
  i: Integer;
begin
  C.MoveTo(_points[0].point.X, _points[0].point.Y);
  C.Pen.Color := clGray;
  C.Pen.Width := round(_width * _zoom);
  for i := 0 to _n - 1 do
    if ((i mod 2) = 0) then
      C.LineTo(_points[i].point.X, _points[i].point.Y);
end;

function TRecognition.mouseMove(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if _mousedown then
    addPoint(args.point);
end;

function TRecognition.mouseDown(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if (args.button = mbLeft) then
  begin
    _mousedown := true;
    addPoint(args.point);
  end;
end;

procedure TRecognition.addPoint(p: TPoint);
begin
  _points[_n].point := p;
  _points[_n].time := Time();
  _n := _n + 1;
  if (_n > Length(_points) - 1) then
    SetLength(_points, Length(_points) + 50);
end;

constructor TRecognition.Create(pic: TVectorPicture; color: TColor = clBlack; width: Integer = 1; backGroundColor: TColor = clWhite; hasBGColor: boolean = false);
begin
  _group := nil;
  _shape := nil;
  _picture := pic;
  _color := color;
  _width := width;
  _mousedown := false;
  _BGcolor := backGroundColor;
  _fill := hasBGColor;
  if (hasPicture) then
    _zoom := _picture.zoom
  else
    _zoom := 1;
  SetLength(_points, 100);
  _n := 0;
end;

destructor TRecognition.Destroy();
begin

end;

//-----------------------------------------------

end.
