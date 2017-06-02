unit Picture;

{$MODE Delphi}

interface

uses
  Shapes, Graphics, Classes;

type

  TVectorPicture = class
    private
      //utvary z ktorych sa sklada obrazok, zoradene podla z-indexov
      _objects: array of TShape;
      //pocet utvarov, koli optimalizacii konstant :)
      _n: Integer;
      _currZoom: Real;
      //zoomovanie obrazku
      procedure zoomAll(a: Real);
    public
      //zisti ci obrazok obsahuje zadany utvar
      function contains(shape: TShape): Boolean;
      //prida utvar do obrazku
      procedure addShape(shape: TShape);
      //odstrani, ale neznici, vrati true ak sa cosi odstanilo
      function removeShape(shape: TShape): Boolean;
      //vrati utvar ktory je na mieste kliku (a ma najvyssi z-index)
      function getShape(p: TPoint): TShape;
      //vrati poziciu utvaru (radoby z-index), -1 ak taky shape neexistuje
      function getZIndex(shape: TShape): Integer;
      //posuvanie utvaru po z osi, vracia skutocny pocet posunuti
      function lower(s: TShape): Integer;
      function higher(s: TShape): Integer;
      function toBackground(s: TShape): Integer;
      function toFront(s: TShape): Integer;
      //nakresli obrazok do Canvasu
      procedure draw(C: TCanvas);
      //load & save
      procedure saveToStream(s: TStream);
      constructor LoadFromStream(s: TStream);
      constructor Create();
      destructor Destroy(); override;

      property zoom: Real read _currZoom write zoomAll;
  end;

implementation

//-----------------TVectorPicture----------------

constructor TVectorPicture.Create();
begin
  SetLength(_objects, 50);
  _n := 0;
end;

function TVectorPicture.contains(shape: TShape): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to _n-1 do
    if (_objects[i] = shape) then
    begin
      Result := true;
      break;
    end;
end;

procedure TVectorPicture.addShape(shape: TShape);   //akoze su utriedene podla zindexu
begin
  if (shape = nil) then
    Exit;
  if (shape.created) then
  begin
    _objects[_n] := shape;
    shape.zoom := zoom;
    _n := _n + 1;
    //nafukovanie pola
    if (_n = Length(_objects)) then
    begin
      SetLength(_objects, Length(_Objects) + 50);
    end;
  end;
end;

function TVectorPicture.removeShape(shape: TShape): Boolean;
var
  i, j: Integer;
begin
  Result := false;
  for i := _n-1 downto 0 do
    if (_objects[i] = shape) then
    begin
      for j := i to _n-2 do
        _objects[j] := _objects[j+1];
      _n := _n-1;
      Result := True;
      break;
    end;
end;

procedure TVectorPicture.zoomAll(a: Real);
var
  i: Integer;
begin
  if (a > 0) then
  begin
    _currZoom := a;
    for i := 0 to _n-1 do
      _objects[i].zoom := a;
  end;
end;

function TVectorPicture.getZIndex(shape: TShape): Integer;
var
  i: Integer;
begin
  Result := Low(Integer);
  for i := _n-1 downto 0 do
    if (_objects[i] = shape) then
    begin
      Result := i;
      break;
    end;
end;

function TVectorPicture.lower(s: TShape): Integer;
var
  i, p: Integer;
  pom: TShape;
begin
  Result := 0;
  p := MaxInt;
  for i := 0 to _n-1 do
    if (s = _objects[i]) then
      p := i;
  if (p = MaxInt) then
    Exit;
  if (p > 0) then
  begin
    Result := -1;
    pom := _objects[p-1];
    _objects[p-1] := _objects[p];
    _objects[p] := pom;
  end;
end;

function TVectorPicture.higher(s: TShape):Integer;
var
  i, p: Integer;
  pom: TShape;
begin
  Result := 0;
  p := MaxInt;
  for i := 0 to _n-1 do
    if (s = _objects[i]) then
      p := i;
  if (p = MaxInt) then
    Exit;
  if (p < _n-1) then
  begin
    Result := 1;
    pom := _objects[p+1];
    _objects[p+1] := _objects[p];
    _objects[p] := pom;
  end;
end;

function TVectorPicture.toBackground(s: TShape): Integer;
var
  i, p: Integer;
  pom: TShape;
begin
  Result := 0;
  p := MaxInt;
  for i := 0 to _n-1 do
    if (s = _objects[i]) then
      p := i;
  if (p = MaxInt) then
    Exit;
  pom := _objects[p];
  for i := p downto 1 do
    begin
      Result := Result + 1;
      _objects[i] := _objects[i-1];
    end;
  _objects[0] := pom;
  Result := - Result;
end;

function TVectorPicture.toFront(s: TShape): Integer;
var
  i, p: Integer;
  pom: TShape;
begin
  Result := 0;
  p := MaxInt;
  for i := 0 to _n-1 do
    if (s = _objects[i]) then
      p := i;
  if (p = MaxInt) then
    Exit;
  pom := _objects[p];
  for i := p to _n-2 do
    begin
      Result := Result + 1;
      _objects[i] := _objects[i+1];
    end;
  _objects[_n-1] := pom;
end;

function TVectorPicture.getShape(p: TPoint): TShape;
var
  i: Integer;
begin
  Result := nil;
  //hlada sa od najvyssieho po najnizsi
  for i := _n-1 downto 0 do
  begin
    if (_objects[i].clickedOn(p)) then
    begin
      Result := _objects[i];
      break;
    end;
  end;
end;

procedure TVectorPicture.draw(C: TCanvas);
var
  i: Integer;
begin
  //nakreslia sa od najnizsieho po najvyssi
  for i := 0 to _n-1 do
    _objects[i].draw(C);
end;

procedure TVectorPicture.saveToStream(s: TStream);
var
  i, count: Integer;
  p: TBuffer;
  typ: TShapeType;
begin
  s.Write(_n, SizeOf(Integer));
  for i := 0 to _n - 1 do
  begin
    count := _objects[i].saveToBuffer(p);
    typ := _objects[i].getType();
    s.Write(typ, SizeOf(TShapeType));
    s.Write(count, SizeOf(Integer));
    s.Write(p^, count);
    FreeMem(p);
  end;
end;

constructor TVectorPicture.LoadFromStream(s: TStream);
var
  i, count, n: Integer;
  p: TBuffer;
  typ: TShapeType;
begin
  Create();
  s.Read(n, SizeOf(Integer));
  for i := 0 to n - 1  do
  begin
    s.Read(typ, SizeOf(TShapeType));
    s.Read(count, SizeOf(Integer));
    GetMem(p, count);
    s.Read(p^, count);
    case typ of
      stPolyLine:
        addShape(TPolyLine.loadFromBuffer(p, count));
      stSegmentLine:
        addShape(TSegmentLine.loadFromBuffer(p, count));
      stLine:
        addShape(TLine.loadFromBuffer(p, count));
      stBezierCurve:
        addShape(TBezierCurve.loadFromBuffer(p, count));
      stCircle:
        addShape(TCircle.loadFromBuffer(p, count));
      stEllipse:
        addShape(TEllipse.loadFromBuffer(p, count));
      stPolygon:
        addShape(TPolygon.loadFromBuffer(p, count));
      stRectAngle:
        addShape(TRectangle.loadFromBuffer(p, count));
      stGroup:
        addShape(TShapesGroup.loadFromBuffer(p, count));
      end;
    FreeMem(p);
  end;
end;

destructor TVectorPicture.Destroy();
var
  i: Integer;
begin
  for i := 0 to _n-1 do
    _objects[i].Free();
  SetLength(_objects, 0);
end;

//-----------------------------------------------
end.
