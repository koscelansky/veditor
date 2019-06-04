unit Shapes;

{$MODE Delphi}

interface

uses
  Types, Graphics, SysUtils, Math, Support;

const
  BEZIER_PRECISION = 0.01;

type

  TBuffer = Pointer;

  TShapeType = (stSegmentLine, stPolyLine, stBezierCurve, stCircle,
                stEllipse, stPolygon, stRectAngle, stGroup);

  TShape = class(TObject)
    private
      _rotatePoint: TPrecisePoint;
      _active: boolean;
      _color: TColor;
      _background: TColor;
      _hasBGColor: Boolean;
      _width: Integer;
      _zoom: Real;
    protected
      function getCreated(): boolean; virtual; abstract;
      procedure setRotatePoint(a: TPrecisePoint); virtual;
      function getRotatePoint(): TPrecisePoint; virtual;
      procedure setColor(color: TColor); virtual;
      function getColor(): TColor; virtual;
      function getBGColor(): TColor; virtual;
      procedure setWidth(width: Integer); virtual;
      procedure setBGMode(fill: Boolean); virtual;
      function getBGMode(): Boolean; virtual;
      function getWidth(): Integer; virtual;
      procedure changeZoom(a: Real); virtual; abstract;  //mierka
      property rotatePoint: TPrecisePoint read getRotatePoint write setRotatePoint;
    public
      function distance(a: TPoint): Integer; virtual; abstract;
      //------move--------
      procedure move(x, y: Integer); virtual; abstract;
      procedure drawMoveControls(C: TCanvas); virtual; abstract;
      //------rotate------
      procedure rotate(h: Real); virtual; abstract;
      procedure resetRotatePoint(p: TPoint); virtual; abstract; //resetne rototate point, pretoze sa nedaju spravit implicitne parametre na zaznami, musi bod p byt povinny :-!, niektore utvary ho ale aj tak neberu do ubahy
      function getRotateControls(): TPoints; virtual; abstract;
      procedure drawRotateControls(C: TCanvas); virtual;
      procedure moveRotatePoint(x, y: Integer); virtual;
      procedure moveRotatePointTo(a: TPoint); virtual;
      //------resize-----
      procedure movePoint(i: Integer; p: TPoint); virtual; abstract;
      function removePoint(i: Integer): boolean; virtual; abstract;  //odstrani bod, vrati true ak bolo nieco odstranene
      procedure drawResizeControls(C: TCanvas); virtual; abstract;
      function getResizeControls(): TPoints; virtual; abstract;
      //-----create------
      function addPoint(a: TPoint; where: Integer=-1): boolean; virtual; abstract;
      function clone(): TShape; virtual; abstract;  //funguje trochu inak ako by sa mohlo zdat, vrati "prazdny objekt daneho typu"
      procedure drawCreatePreview(C: TCanvas; p: TPoint); virtual; abstract;
      //-----fill---------
      procedure fill(color: TColor); virtual;
      procedure unfill(); virtual;

      procedure draw(C: TCanvas); virtual; abstract;
      procedure drawIfActive(C: TCanvas);

      procedure activate(); virtual;
      procedure deactivate(); virtual;

      function clickedOn(a: TPoint): boolean; overload; virtual; abstract;
      function clickedOn(x, y: Integer): boolean; overload; virtual; abstract;
      function toString(): AnsiString; override; abstract;

      function getType(): TShapeType; virtual; abstract;
      function saveToBuffer(var buff: TBuffer): Integer; virtual; abstract;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); virtual; abstract;

      property created: boolean read getCreated;
      property active: boolean read _active;
      property color: TColor read getColor write setColor;
      property backgroundColor: TColor read getBGColor write fill;
      property bgColorMode: Boolean read getBGMode write setBGMode;
      property width: Integer read getWidth write setWidth;
      property zoom: Real read _zoom write changeZoom;
  end;

  TShapesGroup = class(TShape)
    private
      _shapes: array of TShape;
      _n: Integer;
      function getItem(i: Integer): TShape;
    protected
      function getCreated(): boolean; override;
      procedure changeZoom(a: Real); override;
      procedure setColor(color: TColor); override;
      function getColor(): TColor; override;
      function getBGColor(): TColor; override;
      function getWidth(): Integer; override;
      procedure setWidth(width: Integer); override;
      procedure setBGMode(fill: Boolean); override;
      function getBGMode(): Boolean; override;
      procedure setRotatePoint(a: TPrecisePoint); override;
    public
      function distance(a: TPoint): Integer; override;
      //------move-------
      procedure move(x, y: Integer); override;
      procedure drawMoveControls(C: TCanvas); override;
      //-----rotate------
      procedure rotate(h: Real); override;
      procedure resetRotatePoint(p: TPoint); override;
      function getRotateControls(): TPoints; override;
      procedure drawRotateControls(C: TCanvas); override;
      //------resize-----
      procedure movePoint(i: Integer; p: TPoint); override;
      function removePoint(i: Integer): boolean; override;
      procedure drawResizeControls(C: TCanvas); override;
      function getResizeControls(): TPoints; override;
      //------create-----
      function addPoint(a: TPoint; where: Integer=-1): boolean; override;
      procedure drawCreatePreview(C: TCanvas; p: TPoint); override;
      function clone(): TShape; override;

      procedure fill(color: TColor); override;
      procedure unfill(); override;

      procedure add(shape: TShape);
      procedure remove(shape: TShape);
      function count(): Integer;
      function contains(shape: TShape): boolean;

      procedure draw(C: TCanvas); override;
      function toString(): string; override;

      function getType(): TShapeType; override;

      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;

      function clickedOn(a: TPoint): boolean; override;
      function clickedOn(x, y: Integer): boolean; override;

      constructor Create();
      destructor Destroy; overload; override;
      destructor DestroyWithoutShapes; overload;

      property Items[i: Integer]: TShape read getItem; default;
  end;

  TPolyLine = class(TShape)
    private
      _n: Integer;
      _actionPoint: TPrecisePoint; //akcny bod na vytvorenie rotovacich kontrolnych bodov
      _points: array of TPrecisePoint;
    protected
      function getCreated(): boolean; override;
      procedure changeZoom(a: Real); override;
    public
      function distance(a: TPoint): Integer; override;
      //------move-------
      procedure move(x, y: Integer); override;
      procedure drawMoveControls(C: TCanvas); override;
      //-----rotate------
      procedure rotate(h: Real); override;
      procedure resetRotatePoint(p: TPoint); override;
      function getRotateControls(): TPoints; override;
      procedure drawRotateControls(C: TCanvas); override;
      //------resize-----
      procedure movePoint(i: Integer; p: TPoint); override;
      function removePoint(i: Integer): boolean; override;
      procedure drawResizeControls(C: TCanvas); override;
      function getResizeControls(): TPoints; override;
      //------create-----
      function addPoint(a: TPoint; where: Integer=-1): boolean; override;
      procedure drawCreatePreview(C: TCanvas; p: TPoint); override;
      function clone(): TShape; override;

      procedure draw(C: TCanvas); override;
      function toString(): string; override;

      function getType(): TShapeType; override;
      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;

      function clickedOn(a: TPoint): boolean; override;
      function clickedOn(x, y: Integer): boolean; override;

      constructor Create(); overload;
      constructor Create(a: TPoints; color: TColor = clBlack; width: Integer = 1); overload;
      destructor Destroy; override;
  end;

  TSegmentLine = class(TPolyLine)
    protected
      function getCreated(): boolean; override;
    public
      //------resize-----
      function removePoint(i: Integer): boolean; override;
      procedure drawResizeControls(C: TCanvas); override;
      procedure movePoint(i: Integer; p: TPoint); override;
      //------create-----
      function addPoint(a: TPoint; where: Integer=-1): boolean; override;
      procedure drawCreatePreview(C: TCanvas; p: TPoint); override;
      function clone(): TShape; override;

      procedure draw(C: TCanvas); override;
      function getType(): TShapeType; override;

      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;
      
      constructor Create(); overload;
      constructor Create(a, b: TPoint; color: TColor = clBlack; width: Integer = 1); overload;
  end;

  TBezierCurve = class(TPolyLine)
    public
      function distance(a: TPoint): Integer; override;
      procedure draw(C: TCanvas); override;
      function getType(): TShapeType; override;

      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;

      function clone(): TShape; override;

      constructor Create();
  end;

  TCircle = class(TShape)
    private
      _middle: TPrecisePoint;
      _actionPoint: TPrecisePoint;
      _radius: Real;
      _n: Integer; //na vytvaranie
    protected
      function getCreated(): boolean; override; 
      procedure changeZoom(a: Real); override;
    public
      function distance(a: TPoint): Integer; override;
      //-----move------
      procedure move(x, y: Integer); override;
      procedure drawMoveControls(C: TCanvas); override;
      //------rotate----
      procedure rotate(h: Real); override;
      procedure resetRotatePoint(p: TPoint); override;
      function getRotateControls(): TPoints; override;
      procedure drawRotateControls(C: TCanvas); override;
      //------resize-----
      procedure movePoint(i: Integer; p: TPoint); override;
      function removePoint(i: Integer): boolean; override; //v tomto pripade ma zmysel iba pri vytvarani, a mozno ani tam ho nepouzijem :)
      procedure drawResizeControls(C: TCanvas); override;
      function getResizeControls(): TPoints; override;
      //------create-----
      function addPoint(a: TPoint; where: Integer=-1): boolean; override; //v tomto pripade ma zmysel iba pri vytvarani
      function clone(): TShape; override;
      procedure drawCreatePreview(C: TCanvas; p: TPoint); override;

      procedure draw(C: TCanvas); override;
      function toString(): string; override;
      function getType(): TShapeType; override;

      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;

      function clickedOn(a: TPoint): boolean; override;
      function clickedOn(x, y: Integer): boolean; override;

      constructor Create(); overload;
      constructor Create(a: TPoint; rad: Real; color: TColor = clBlack; width: Integer = 1); overload;

      destructor Destroy; override;
  end;

  TEllipse = class(TShape)
    private
      _e: TGeneralEllipseEquation;
      _actionPoint: TPrecisePoint;
      _h: Real; //natocenie
      _n: Integer; //na vytvaranie
    protected
      function getCreated(): boolean; override;
      procedure changeZoom(a: Real); override;
    public
      function distance(a: TPoint): Integer; override;
      //-----move------
      procedure move(x, y: Integer); override;
      procedure drawMoveControls(C: TCanvas); override;
      //------rotate----
      procedure rotate(h: Real); override;
      procedure resetRotatePoint(p: TPoint); override;
      function getRotateControls(): TPoints; override;
      procedure drawRotateControls(C: TCanvas); override;
      //------resize-----
      procedure movePoint(i: Integer; p: TPoint); override;
      function removePoint(i: Integer): boolean; override; //v tomto pripade ma zmysel iba pri vytvarani, a mozno ani tam ho nepouzijem :)
      procedure drawResizeControls(C: TCanvas); override;
      function getResizeControls(): TPoints; override;
      //------create-----
      function addPoint(a: TPoint; where: Integer=-1): boolean; override; //v tomto pripade ma zmysel iba pri vytvarani
      function clone(): TShape; override;
      procedure drawCreatePreview(C: TCanvas; p: TPoint); override;

      procedure draw(C: TCanvas); override;
      function toString(): string; override;
      function getType(): TShapeType; override;

      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;

      function clickedOn(a: TPoint): boolean; override;
      function clickedOn(x, y: Integer): boolean; override;

      constructor Create(); overload;   
      constructor Create(a: TPoint; major, minor: Real; color: TColor = clBlack; width: Integer = 1); overload;

      destructor Destroy; override;
  end;

  TPolygon = class(TPolyLine)
    public
      function distance(a: TPoint): Integer; override;
      //------move-------
      procedure drawMoveControls(C: TCanvas); override;
      //------rotate-----
      procedure drawRotateControls(C: TCanvas); override;
      //-----resize------
      procedure drawResizeControls(C: TCanvas); override;
      //----create------
      function clone(): TShape; override;

      procedure draw(C: TCanvas); override;
      function getType(): TShapeType; override;

      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;

      function clickedOn(a: TPoint): boolean; override;
      function clickedOn(x, y: Integer): boolean; override;

      constructor Create(a: TPoints; color: TColor = clBlack; width: Integer = 1); overload;
      constructor Create(); overload;
  end;

  TRectangle = class(TPolygon)
    private
      _h: Real; //natocenie vyhladom na kladnu polos x
    protected
      function getCreated(): boolean; override;
    public
      //----create------
      function addPoint(a: TPoint; where: Integer=-1): boolean; override;
      function removePoint(i: Integer): boolean; override;
      function clone(): TShape; override;
      procedure drawCreatePreview(C: TCanvas; p: TPoint); override;
      //----rotate------
      procedure rotate(h: Real); override;
      //----resize------
      procedure movePoint(i: Integer; p: TPoint); override;

      function saveToBuffer(var buff: TBuffer): Integer; override;
      constructor loadFromBuffer(var p: TBuffer; count: Integer); override;

      function getType(): TShapeType; override;

      constructor Create(rect: TRect; color: TColor=clBlack; width: Integer=1); overload;
      constructor Create(); overload;
  end;

  TShapes = array of TShape;

implementation

//------------------TShape-------------------

procedure TShape.fill(color: TColor);
begin
  _background := color;
end;

procedure TShape.unfill();
begin
  _hasBGColor := false;
end;

procedure TShape.setBGMode(fill: Boolean);
begin
  _hasBGColor := fill;
end;

function TShape.getBGMode(): Boolean;
begin
  Result := _hasBGColor;
end;

procedure TShape.drawIfActive(C: TCanvas);
begin
  if (active) then
    draw(C);
end;

function TShape.getColor(): TColor;
begin
  Result := _color;
end;

function TShape.getBGColor(): TColor;
begin
  Result := _background;
end;

procedure TShape.setColor(color: TColor);
begin
  _color := color;
end;

function TShape.getWidth(): Integer;
begin
  Result := round(zoom*_width);
end;

procedure TShape.setRotatePoint(a: TPrecisePoint);
begin
  if (_rotatePoint <> nil) then
    _rotatePoint.Free;
  _rotatePoint := a;
end;   

procedure TShape.moveRotatePoint(x, y: Integer);
begin
  moveRotatePointTo(Point(rotatePoint.point.X + x, rotatePoint.point.Y + y));
end;

procedure TShape.moveRotatePointTo(a: TPoint);
begin
  if (rotatePoint <> nil) then
    FreeAndNil(_rotatePoint);
  rotatePoint := TPrecisePoint.Create(a);
end;


function TShape.getRotatePoint(): TPrecisePoint;
begin
  Result := _rotatePoint;
end;

procedure TShape.setWidth(width: Integer);
begin
  if (width < 0) then
    raise Exception.Create('Šírka musí by nezáporné èíslo.');
  _width := width;
end;

procedure TShape.activate();
begin
  _active := true;
end;

procedure TShape.deactivate();
begin
  _active := false;
end;

procedure TShape.drawRotateControls(C: TCanvas);
begin
  C.Pen.Color := clRed;
  C.Pen.Mode := pmMaskPenNot;
  C.Pen.Width := 1;
  //nakresli riadiaci bod okolo ktoreho sa otaca s negovanym pozadim
  C.Pen.Style := psSolid;
  C.Brush.Style := bsClear;
  C.Rectangle(round(rotatePoint.x) - 5,
              round(rotatePoint.y) - 5,
              round(rotatePoint.x) + 5,
              round(rotatePoint.y) + 5);
end;

//---------------TPolyLine-------------------

function TPolyLine.getCreated(): Boolean;
begin
  Result := _n > 0;
end;

function TPolyLine.saveToBuffer(var buff: TBuffer): Integer;
var
  p: Pointer;
  i: Integer;
begin
  Result := SizeOf(TColor) + 2 * SizeOf(Integer) + 2 * _n * SizeOf(Real);
  GetMem(buff, Result);
  p := buff;
  System.Move(_color, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_width, p^, SizeOf(Integer));
  p := Pointer(Cardinal(p) + SizeOf(Integer));
  System.Move(_n, p^, SizeOf(Integer));
  p := Pointer(Cardinal(p) + SizeOf(Integer));
  for i := 0 to _n - 1 do
  begin
    System.Move(_points[i].x, p^, SizeOf(Real));
    p := Pointer(Cardinal(p) + SizeOf(Real));
    System.Move(_points[i].y, p^, SizeOf(Real));
    p := Pointer(Cardinal(p) + SizeOf(Real));
  end;
end;

constructor TPolyLine.loadFromBuffer(var p: TBuffer; count: Integer);
var
  buff: Pointer;
  i, n: Integer;
  int: Integer;
  col: TColor;
  float: Real;
begin
  Create();
  buff := p;
  System.Move(buff^, col, SizeOf(TColor));
  color := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, int, SizeOf(Integer));
  width := int;
  buff := Pointer(Cardinal(buff) + SizeOf(Integer));
  System.Move(buff^, n, SizeOf(Integer));
  buff := Pointer(Cardinal(buff) + SizeOf(Integer));
  for i := 0 to n - 1 do
  begin
    addPoint(nilPoint);
    System.Move(buff^, float, SizeOf(Real));
    _points[i].x := float;
    buff := Pointer(Cardinal(buff) + SizeOf(Real));
    System.Move(buff^, float, SizeOf(Real));
    _points[i].y := float;
    buff := Pointer(Cardinal(buff) + SizeOf(Real));
  end;
end;

function TPolyLine.addPoint(a: TPoint; where: Integer=-1): boolean;
var
  i: Integer;
begin
  Result := true;
  _n := _n + 1;
  if (_n > high(_points)-1) then
    SetLength(_points, length(_points) + 10);
  if (where in [0.._n-1]) then
  begin
    for i := _n-1 downto where+1 do
      _points[i] := _points[i-1];
    _points[where] := TPrecisePoint.Create(a);
  end
  else
    _points[_n-1] := TPrecisePoint.Create(a);
end;

function TPolyLine.removePoint(i: Integer): boolean;
var
  j: integer;
begin
  Result := false;
  if ((_n > 1) and (i in [0.._n-1])) then
  begin
    Result := true;
    _points[i].Free;
    for j := i to _n-2 do
      _points[j] := _points[j+1];
    _n := _n - 1;
  end;
end;

function TPolyLine.distance(a: TPoint): Integer;
var
  p, h1, h2: TGeneralLineEquation;
  i: Integer;
begin
  Result := MaxInt;
  if (_n = 0) then
  begin
    Exit;
  end;

  if (_n = 1) then
  begin
    Result := Round(TSupport.distance(a, _points[0].point));
    Exit;
  end;

  for i := 0 to _n-2 do
  begin
    p := TGeneralLineEquation.Create(_points[i], _points[i+1]);
    h1 := TGeneralLineEquation.Create(_points[i], p.controlVector);
    h1.perpendicular(_points[i]);
    h2 := TGeneralLineEquation.Create(_points[i+1], p.controlVector);
    h2.perpendicular(_points[i+1]);
    if (((h1.solve(a) <= 0) and (h2.solve(a) >= 0)) or
      ((h1.solve(a) >= 0) and (h2.solve(a) <= 0))) then
    begin
      Result := Min(Result, p.pointDistance(a));
    end
    else
    begin
      Result := Min(Result, Round(TSupport.distance(_points[i].point, a)));
      Result := Min(Result, Round(TSupport.distance(_points[i+1].point, a)));
    end;
    h1.Free;
    h2.Free;
    p.Free;
  end;
end;

procedure TPolyLine.move(x, y: Integer);
var
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  for i := 0 to _n - 1 do
  begin
    _points[i].x := _points[i].x + x;
    _points[i].y := _points[i].y + y;
  end;
end;

procedure TPolyLine.drawMoveControls(C: TCanvas);
var
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  C.Pen.Mode := pmNot;
  C.Pen.Width := 1;
  C.Pen.Style := psDashDotDot;
  C.Brush.Style := bsClear;
  C.MoveTo(_points[0].point.X + 1, _points[0].point.Y);
  for i := 0 to _n-1 do
    C.LineTo(_points[i].point.X, _points[i].point.Y);
end;

procedure TPolyLine.resetRotatePoint(p: TPoint);
var
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  p := NilPoint;
  for i := 0 to _n-1 do
  begin
    p.X := p.X + _points[i].point.X;
    p.Y := p.Y + _points[i].point.Y;
  end;
  p.X := round(p.X / _n);
  p.Y := round(p.Y / _n);
  moveRotatePointTo(p);
  FreeAndNil(_actionPoint);
  if ((_n = 1) or ((_points[_n-2].point.X = _points[_n-1].point.X)
    and (_points[_n-2].point.Y = _points[_n-1].point.Y))) then
  begin
    _actionPoint := _points[_n-1].clone();
    _actionPoint.X := _actionPoint.X + 10;
  end
  else
    _actionPoint := _points[_n-2].clone();
end;

procedure TPolyLine.rotate(h: Real);
var
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  for i := 0 to _n-1 do
    _points[i] := TSupport.rotate(_points[i], rotatePoint, h);
  _actionPoint := TSupport.rotate(_actionPoint, rotatePoint, h);
end;

function TPolyLine.getRotateControls(): TPoints;
var
  line: TGeneralLineEquation;
begin
  if (not created) then
    Exit;
  line := TGeneralLineEquation.Create(_actionPoint, _points[_n-1]);
  SetLength(Result, 2);
  Result[0] := rotatePoint.point;
  Result[1].X := round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80);
  Result[1].Y := round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80);
  line.Free;
end;

procedure TPolyLine.drawRotateControls(C: TCanvas);
var
  line: TGeneralLineEquation;
begin
  if (not created) then
    Exit;
  line := TGeneralLineEquation.Create(_actionPoint, _points[_n-1]);
  drawMoveControls(C);
  inherited drawRotateControls(C);
  //riadacia ciara
  C.Pen.Style := psDot;
  C.MoveTo(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 10),
           round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 10));
  C.LineTo(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 60),
           round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 60));

  //riadiaci bod
  C.Pen.Style := psSolid;
  C.Ellipse(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80) - 5,
            round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80) - 5,
            round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80) + 5,
            round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80) + 5);
  line.Free;
end;

procedure TPolyLine.movePoint(i: Integer; p: TPoint);
begin
  if ((_n = 0) or (i > _n-1)) then
    Exit;
  _points[i].x := p.X;
  _points[i].y := p.Y;
end;

procedure TPolyLine.drawResizeControls(C: TCanvas);
var
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  drawMoveControls(C);
  C.Pen.Style := psSolid;
  for i := 0 to _n-2 do
    C.Rectangle(_points[i].point.x - 5,
                _points[i].point.y - 5,
                _points[i].point.x + 5,
                _points[i].point.y + 5);
  C.Pen.Mode := pmMaskPenNot;
  C.Pen.Color := clRed;
  C.Rectangle(_points[_n-1].point.x - 5,
              _points[_n-1].point.y - 5,
              _points[_n-1].point.x + 5,
              _points[_n-1].point.y + 5);
end;

function TPolyLine.getResizeControls(): TPoints;
var
  i: Integer;
begin
  if (not created) then
  begin
    Result := nil;
    Exit;
  end;
  SetLength(Result, _n);
  for i := 0 to _n-1 do
    Result[i] := _points[i].point;
end;

procedure TPolyLine.drawCreatePreview(C: TCanvas; p: TPoint);
begin
  _points[_n] := TPrecisePoint.Create(p);
  _n := _n+1;
  draw(C);
  drawResizeControls(C);
  _points[_n-1].Free;
  _n := _n-1;
end;

function TPolyLine.clone(): TShape;
begin
  Result := TPolyLine.Create();
end;

procedure TPolyLine.draw(C: TCanvas);
var
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  C.Pen.Mode := pmCopy;
  C.Pen.Color := color;
  C.Pen.Width := width;
  C.Pen.Style := psSolid;
  C.MoveTo(_points[0].point.X+1, _points[0].point.Y);
  for i := 0 to _n-1 do
    C.LineTo(_points[i].point.X, _points[i].point.Y);
end;

function TPolyLine.getType(): TShapeType;
begin
  Result := stPolyLine;
end;

procedure TPolyLine.changeZoom(a: Real);
var
  i: Integer;
begin
  if (a > 0) then
  begin
    for i := 0 to _n-1 do
    begin
      _points[i].x := _points[i].x*a/zoom;
      _points[i].y := _points[i].y*a/zoom;
    end;
    _zoom := a;
  end;
end;

function TPolyLine.toString(): string;
var
  i: Integer;
begin
  Result := 'PolyLine: ';
  if (_n = 0) then
  begin
    Result := Result + 'empty';
    Exit;
  end;
  for i := 0 to _n-1 do
    Result := Result + IntToStr(i)+' '+_points[i].toString+' ';
end;

function TPolyLine.clickedOn(a: TPoint): boolean;
begin
  Result := distance(a) <= (width div 2)+1;
end;

function TPolyLine.clickedOn(x, y: Integer): boolean;
var
  p: TPoint;
begin
  p.X := x;
  p.Y := y;
  Result := clickedOn(p);
end;

constructor TPolyLine.Create();
begin
  _n := 0;
  SetLength(_points, 10);
  rotatePoint := TPrecisePoint.Create(NilPoint);
  _actionPoint := TPrecisePoint.Create(NilPoint);
  _zoom := 1;
  deactivate();
  _hasBGColor := false;
end;

constructor TPolyLine.Create(a: TPoints; color: TColor = clBlack; width: Integer = 1);
var
  i: Integer;
begin
  if (Length(a) = 0) then
    raise EInvalidArgument.Create('Array of TPoints must contains at least one Point.');
  SetLength(_points, length(a));
  _n := length(a);
  for i := 0 to high(a) do
    begin
    _points[i] := TPrecisePoint.Create(a[i]);
    end;
  Self.rotatePoint := _points[0].clone();
  Self.color := color;
  Self.width := width;
  _zoom := 1;
  _actionPoint := TPrecisePoint.Create(NilPoint);
  _hasBGColor := false;
  deactivate();
end;

destructor TPolyLine.Destroy;
var
  i: Integer;
begin
  if (_actionPoint <> nil) then
    _actionPoint.Free();
  if (rotatePoint <> nil) then
    rotatePoint.Free();
  if (length(_points) = 0) then
    Exit;
  for i := 0 to _n-1 do
    if (_points[i] <> nil) then
      _points[i].Free;
  SetLength(_points, 0);
end;

//---------------TSegmentLine----------------

function TSegmentLine.getCreated(): boolean;
begin
  Result := _n >= 2;
end;

procedure TSegmentLine.movePoint(i: Integer; p: TPoint);
begin
  if (i in [0..1]) then
    inherited movePoint(i, p);
end;

function TSegmentLine.saveToBuffer(var buff: TBuffer): Integer;
begin
  Result := inherited saveToBuffer(buff);
end;

constructor TSegmentLine.loadFromBuffer(var p: TBuffer; count: Integer);
begin
  Create();
  inherited loadFromBuffer(p, count);
end;

function TSegmentLine.addPoint(a: TPoint; where: Integer=-1): boolean;
begin
  Result := false;
  if (_n < 2) then
  begin
    Result := inherited addPoint(a);
  end;
end;

procedure TSegmentLine.drawResizeControls(C: TCanvas);
begin
  if (_n = 0) then
    Exit;
  drawMoveControls(C);
  C.Pen.Style := psSolid;
  C.Rectangle(_points[0].point.x - 5,
              _points[0].point.y - 5,
              _points[0].point.x + 5,
              _points[0].point.y + 5);
  if (_n = 2) then
    C.Rectangle(_points[_n-1].point.x - 5,
                _points[_n-1].point.y - 5,
                _points[_n-1].point.x + 5,
                _points[_n-1].point.y + 5);
end;

procedure TSegmentLine.drawCreatePreview(C: TCanvas; p: TPoint);
begin
  if (not created) then
    inherited drawCreatePreview(C, p)
  else
  begin
    draw(C);
    drawResizeControls(C);
  end;
end;

function TSegmentLine.getType(): TShapeType;
begin
  Result := stSegmentLine;
end;

function TSegmentLine.removePoint(i: Integer): boolean;
begin
  Result := false;
  if (not created) then
    inherited removePoint(i);
end;

constructor TSegmentLine.Create();
begin
  _n := 0;
  _zoom := 1;
  SetLength(_points, 2);
  _actionPoint := TPrecisePoint.Create(NilPoint);
  deactivate();
end;

constructor TSegmentLine.Create(a, b: TPoint; color: TColor = clBlack; width: Integer = 1);
var
  p: TPoint;
begin
  SetLength(_points, 2);
  _n := 2;
  _zoom := 1;
  _points[0] := TPrecisePoint.Create(a);
  _points[1] := TPrecisePoint.Create(b);
  p.X := round((a.X + b.X) / 2);
  p.Y := round((a.Y + b.Y) / 2);
  Self.rotatePoint := TPrecisePoint.Create(b);
  Self.color := color;
  Self.width := width;
  _actionPoint := TPrecisePoint.Create(NilPoint);
  deactivate();
  _hasBGColor := false;
end;

function TSegmentLine.clone(): TShape;
begin
  Result := TSegmentLine.Create();
end;

procedure TSegmentLine.draw(C: TCanvas);
begin
  C.Pen.Mode := pmCopy;
  C.Pen.Color := color;
  C.Pen.Width := width;
  C.Pen.Style := psSolid;
  if (_points[0] <> nil) then
  begin
    C.MoveTo(_points[0].point.X, _points[0].point.Y);
    if (_points[1] <> nil) then
      C.LineTo(_points[1].point.X, _points[1].point.Y)
    else
      C.LineTo(_points[0].point.X, _points[0].point.Y+1);
  end;
end;

//-----------------TCircle-------------------

function TCircle.distance(a: TPoint): Integer;
var
  p: TPrecisePoint;
begin
  p := TPrecisePoint.Create(a);
  Result := round(abs(TSupport.distance(p, _middle) - _radius));
  p.Free;
end;

function TCircle.getCreated(): boolean;
begin
  Result := _n >= 2;
end;

procedure TCircle.changeZoom(a: Real);
begin
  if (a > 0) then
  begin
    if (_middle <> nil) then
    begin
      _middle.x := _middle.x*a/zoom;
      _middle.y := _middle.y*a/zoom;
    end;
    if (_radius > 0) then
      _radius := _radius*a/zoom;
    _zoom := a;
  end;
end;

procedure TCircle.move(x, y: Integer);
begin
  _middle.x := _middle.x + x;
  _middle.y := _middle.y + y;
end;

procedure TCircle.drawMoveControls(C: TCanvas);
begin
  C.Pen.Mode := pmNot;
  C.Pen.Width := 1;
  C.Pen.Style := psDashDotDot;
  C.Brush.Style := bsClear;
  C.Ellipse(round(_middle.X - _radius), round(_middle.Y - _radius),
            round(_middle.X + _radius), round(_middle.Y + _radius));
end;

procedure TCircle.rotate(h: Real);
begin
  _actionPoint := TSupport.rotate(_actionPoint, rotatePoint, h);
  _middle := TSupport.rotate(_middle, rotatePoint, h);
end;

function TCircle.saveToBuffer(var buff: TBuffer): Integer;
var
  p: Pointer;
begin
  Result := 2 * SizeOf(TColor) + SizeOf(Boolean) + SizeOf(Integer) + 3 * SizeOf(Real);
  GetMem(buff, Result);
  p := buff;
  System.Move(_color, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_background, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_hasBGColor, p^, SizeOf(Boolean));
  p := Pointer(Cardinal(p) + SizeOf(Boolean));
  System.Move(_width, p^, SizeOf(Integer));
  p := Pointer(Cardinal(p) + SizeOf(Integer));
  System.Move(_middle.x, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_middle.y, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_radius, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
end;

constructor TCircle.loadFromBuffer(var p: TBuffer; count: Integer);
var
  buff: Pointer;
  int: Integer;
  col: TColor;
  float: Real;
  bool: Boolean;
begin
  Create();
  _n := 2;
  _middle := TPrecisePoint.Create(NilPoint);
  buff := p;
  System.Move(buff^, col, SizeOf(TColor));
  color := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, col, SizeOf(TColor));
  backgroundColor := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, bool, SizeOf(Boolean));
  bgColorMode := bool;
  buff := Pointer(Cardinal(buff) + SizeOf(Boolean));
  System.Move(buff^, int, SizeOf(Integer));
  width := int;
  buff := Pointer(Cardinal(buff) + SizeOf(Integer));
  System.Move(buff^, float, SizeOf(Real));
  _middle.x := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  _middle.y := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  _radius := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
end;

procedure TCircle.resetRotatePoint(p: TPoint);
begin
  _rotatePoint := _middle.clone();
  FreeAndNil(_actionPoint);
  _actionPoint := TPrecisePoint.Create(_middle.x + 10, _middle.y);
end;

function TCircle.getRotateControls(): TPoints;
var
  line: TGeneralLineEquation;
begin
  if (not created) then
    Exit;
  line := TGeneralLineEquation.Create(_actionPoint, _middle);
  SetLength(Result, 2);
  Result[0] := rotatePoint.point;
  Result[1].X := round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80);
  Result[1].Y := round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80);
  line.Free;
end;

procedure TCircle.drawRotateControls(C: TCanvas);
var
  line: TGeneralLineEquation;
begin
  if (not created) then
    Exit;
  line := TGeneralLineEquation.Create(_actionPoint, _middle);
  drawMoveControls(C);
  inherited drawRotateControls(C);
  //riadacia ciara
  C.Pen.Style := psDot;
  C.MoveTo(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 10),
           round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 10));
  C.LineTo(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 60),
           round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 60));
  //riadiaci bod
  C.Pen.Style := psSolid;
  C.Ellipse(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80) - 5,
            round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80) - 5,
            round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80) + 5,
            round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80) + 5);
  line.Free;
end;

procedure TCircle.movePoint(i: Integer; p: TPoint);
begin
  if (i = 4) then //bol chyteny stred
  begin
    _middle.x := p.X;
    _middle.y := p.Y;
  end;
  if (i in [0..3]) then //bol chyteny menic polomeru
    _radius := TSupport.distance(_middle.point, p);
end;

function TCircle.removePoint(i: Integer): boolean;
begin
  Result := False;
end;

procedure TCircle.drawResizeControls(C: TCanvas); //stred a 4 body na resizovanie
var
  rad: Integer;
begin
  if (_middle = nil) then
    Exit;
  rad := round(_radius);
  drawMoveControls(C);
  C.Pen.Style := psSolid;
  C.Rectangle(_middle.point.x - 5,
              _middle.point.y - 5,
              _middle.point.x + 5,
              _middle.point.y + 5);
  C.Rectangle(_middle.point.x - 5 - rad,
              _middle.point.y - 5,
              _middle.point.x + 5 - rad,
              _middle.point.y + 5);
  C.Rectangle(_middle.point.x - 5 + rad,
              _middle.point.y - 5,
              _middle.point.x + 5 + rad,
              _middle.point.y + 5);
  C.Rectangle(_middle.point.x - 5,
              _middle.point.y - 5 - rad,
              _middle.point.x + 5,
              _middle.point.y + 5 - rad);
  C.Rectangle(_middle.point.x - 5,
              _middle.point.y - 5 + rad,
              _middle.point.x + 5,
              _middle.point.y + 5 + rad);
end;

function TCircle.getResizeControls(): TPoints;
var
  rad: Integer;
begin
  if (not created) then
    Exit;
  rad := round(_radius);
  SetLength(Result, 5);
  Result[0].X := _middle.point.X - rad;
  Result[0].Y := _middle.point.Y;
  Result[1].X := _middle.point.X + rad;
  Result[1].Y := _middle.point.Y;
  Result[2].X := _middle.point.X;
  Result[2].Y := _middle.point.Y - rad;
  Result[3].X := _middle.point.X;
  Result[3].Y := _middle.point.Y + rad;
  Result[4] := _middle.point;
end;

function TCircle.addPoint(a: TPoint; where: Integer=-1): boolean;
begin
  Result := false;
  if (not created) then
  begin
    Result := true;
    if (_n = 0) then
    begin
      FreeAndNil(_middle);
      _middle := TPrecisePoint.Create(a);
      _radius := 1;
      _n := 1;
    end
    else
      if (_n = 1) then
      begin
        _radius := max(TSupport.distance(_middle.point, a), 1);
        _n := 2;
      end;
  end;
end;

function TCircle.clone(): TShape;
begin
  Result := TCircle.Create;
end;

procedure TCircle.drawCreatePreview(C: TCanvas; p: TPoint);
begin
  if (not created) then
  begin
    if (_n = 0) then
    begin
      FreeAndNil(_middle);
      _radius := 1;
      _middle := TPrecisePoint.Create(p);
    end;
    if (_n = 1) then
      _radius := max(TSupport.distance(_middle.point, p), 1);
    draw(C);
    drawResizeControls(C);
  end
  else
  begin
    draw(C);
    drawResizeControls(C);
  end;
end;

procedure TCircle.draw(C: TCanvas);
begin
  C.Pen.Mode := pmCopy;
  C.Pen.Color := color;
  C.Pen.Width := width;
  C.Pen.Style := psSolid;
  if bgColorMode then
  begin
    C.Brush.Style := bsSolid;
    C.Brush.Color := backgroundColor;
  end
  else
    C.Brush.Style := bsClear;
  C.Ellipse(round(_middle.X - _radius), round(_middle.Y - _radius),
            round(_middle.X + _radius), round(_middle.Y + _radius));
end;

function TCircle.getType(): TShapeType;
begin
  Result := stCircle;
end;

function TCircle.toString(): string;
begin
  Result := 'Circle centre: '+_middle.toString()+' radius: '+IntToStr(round(_radius));
end;

function TCircle.clickedOn(a: TPoint): boolean;
begin
  if not bgColorMode then
    Result := distance(a) <= (width / 2)
  else
    Result := TSupport.distance(a, _middle.point) <= (_radius + (width / 2));
end;

function TCircle.clickedOn(x, y: Integer): boolean;
begin
  Result := clickedOn(Point(x, y));
end;

constructor TCircle.Create();
begin
  _middle := nil;
  _radius := 0;
  _zoom := 1;
  _n := 0;
  _rotatePoint := TPrecisePoint.Create(NilPoint);
  _actionPoint := TPrecisePoint.Create(NilPoint);
  _hasBGColor := false;
end;

constructor TCircle.Create(a: TPoint; rad: Real; color: TColor = clBlack; width: Integer = 1);
begin
  _middle := TPrecisePoint.Create(a);
  _radius := rad;
  _zoom := 1;
  Self.color := color;
  Self.width := width;
  _n := 2;
  _hasBGColor := false;
  _rotatePoint := _middle.clone();
  _actionPoint := TPrecisePoint.Create(NilPoint);
end;

destructor TCircle.Destroy;
begin
  if (_middle <> nil) then
    _middle.Free;
  if (_actionPoint <> nil) then
    _actionPoint.Free;
  if (rotatePoint <> nil) then
    rotatePoint.Free();
end;

//---------------TEllipse--------------------

function TEllipse.distance(a: TPoint): Integer;
begin
  a := TSupport.rotate(a, _e.centre, -_h);
  Result := _e.pointDistance(a);
end;

function TEllipse.getCreated(): boolean;
begin
  Result := _n >= 3;
end;

procedure TEllipse.changeZoom(a: Real);
begin
  if (a > 0) then
  begin
    if (_e <> nil) then
    begin
      if (_e.centre <> nil) then
      begin
        _e.centre.x := _e.centre.x*a/zoom;
        _e.centre.y := _e.centre.y*a/zoom;
      end;
      if (_e.a > 0) then
        _e.a := _e.a*a/zoom;
      if (_e.b > 0) then
        _e.b := _e.b*a/zoom;
    end;
    _zoom := a;
  end;
end;

procedure TEllipse.move(x, y: Integer);
begin
  _e.centre.x := _e.centre.x + x;
  _e.centre.y := _e.centre.y + y;
end;

procedure TEllipse.drawMoveControls(C: TCanvas);  
var
  pom: TPoints;
  i: Integer;
begin
  if (_e = nil) then
    Exit;
  C.Pen.Mode := pmNot;
  C.Pen.Width := 1;
  C.Pen.Style := psDashDotDot;
  C.Brush.Style := bsClear;
  pom := _e.getPoints();
  for i := 0 to high(pom) do
    pom[i] := TSupport.rotate(pom[i], _e.centre, _h);
  C.MoveTo(pom[0].X, pom[0].Y);
  C.Polygon(pom);
  SetLength(pom, 0);
end;

procedure TEllipse.rotate(h: Real);
begin
  _h := _h + h;
  if (_h > 360) then
    _h := _h - 360;
  _actionPoint := TSupport.rotate(_actionPoint, rotatePoint, h);
  _e.centre := TSupport.rotate(_e.centre, rotatePoint, h);
end;

procedure TEllipse.resetRotatePoint(p: TPoint);
begin
  _rotatePoint := _e.centre.clone();
  FreeAndNil(_actionPoint);
  _actionPoint := TPrecisePoint.Create(_e.centre.x + 10, _e.centre.y);
end;

function TEllipse.saveToBuffer(var buff: TBuffer): Integer;
var
  p: Pointer;
begin
  Result := 2 * SizeOf(TColor) + SizeOf(Boolean) + SizeOf(Integer) + 5 * SizeOf(Real);
  GetMem(buff, Result);
  p := buff;
  System.Move(_color, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_background, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_hasBGColor, p^, SizeOf(Boolean));
  p := Pointer(Cardinal(p) + SizeOf(Boolean));
  System.Move(_width, p^, SizeOf(Integer));
  p := Pointer(Cardinal(p) + SizeOf(Integer));
  System.Move(_e.centre.x, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_e.centre.y, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_e.a, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_e.b, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_h, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
end;

constructor TEllipse.loadFromBuffer(var p: TBuffer; count: Integer);
var
  buff: Pointer;
  int: Integer;
  col: TColor;
  float: Real;
  bool: Boolean;
begin
  Create();
  _e := TGeneralEllipseEquation.Create(0, 0, 0, 0);
  _n := 3;
  buff := p;
  System.Move(buff^, col, SizeOf(TColor));
  color := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, col, SizeOf(TColor));
  backgroundColor := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, bool, SizeOf(Boolean));
  bgColorMode := bool;
  buff := Pointer(Cardinal(buff) + SizeOf(Boolean));
  System.Move(buff^, int, SizeOf(Integer));
  width := int;
  buff := Pointer(Cardinal(buff) + SizeOf(Integer));
  System.Move(buff^, float, SizeOf(Real));
  _e.centre.x := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  _e.centre.y := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  _e.a := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  _e.b := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  _h := float;
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
end;

function TEllipse.getRotateControls(): TPoints;
var
  line: TGeneralLineEquation;
begin
  if (not created) then
    Exit;
  line := TGeneralLineEquation.Create(_actionPoint, _e.centre);
  SetLength(Result, 2);
  Result[0] := rotatePoint.point;
  Result[1].X := round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80);
  Result[1].Y := round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80);
  line.Free;
end;

procedure TEllipse.drawRotateControls(C: TCanvas);
var
  line: TGeneralLineEquation;
begin
  if (not created) then
    Exit;
  line := TGeneralLineEquation.Create(_actionPoint, _e.centre);
  drawMoveControls(C);
  inherited drawRotateControls(C);
  //riadacia ciara
  C.Pen.Style := psDot;
  C.MoveTo(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 10),
           round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 10));
  C.LineTo(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 60),
           round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 60));
  //riadiaci bod
  C.Pen.Style := psSolid;
  C.Ellipse(round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80) - 5,
            round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80) - 5,
            round(rotatePoint.x + (line.controlVector.x/line.controlVector.getLength) * 80) + 5,
            round(rotatePoint.y + (line.controlVector.y/line.controlVector.getLength) * 80) + 5);
  line.Free;
end;

procedure TEllipse.movePoint(i: Integer; p: TPoint);
begin
  if (i = 4) then
  begin
    _e.centre.x := p.X;
    _e.centre.Y := p.Y;
    Exit;
  end;
  p := TSupport.rotate(p, _e.centre, -_h);
  if (i in [0..1]) then
    _e.b := abs(_e.centre.y - p.Y);
  if (i in [2..3]) then
    _e.a := abs(_e.centre.x - p.x);
end;

function TEllipse.removePoint(i: Integer): boolean;
begin
  Result := False;  //nema moc zmysel
end;

procedure TEllipse.drawResizeControls(C: TCanvas);
var
  pom: TPrecisePoint;
begin
  drawMoveControls(C);
  C.Pen.Style := psSolid;
  C.Rectangle(_e.centre.point.x - 5,
              _e.centre.point.y - 5,
              _e.centre.point.x + 5,
              _e.centre.point.y + 5);
  pom := TPrecisePoint.Create(_e.centre.x + _e.a, _e.centre.y); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  C.Rectangle(round(pom.x - 5), round(pom.y - 5), round(pom.x + 5), round(pom.y + 5));
  pom.Free;
  pom := TPrecisePoint.Create(_e.centre.x - _e.a, _e.centre.y); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  C.Rectangle(round(pom.x - 5), round(pom.y - 5), round(pom.x + 5), round(pom.y + 5));
  pom.Free;
  pom := TPrecisePoint.Create(_e.centre.x, _e.centre.y + _e.b); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  C.Rectangle(round(pom.x - 5), round(pom.y - 5), round(pom.x + 5), round(pom.y + 5));
  pom.Free;
  pom := TPrecisePoint.Create(_e.centre.x, _e.centre.y - _e.b); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  C.Rectangle(round(pom.x - 5), round(pom.y - 5), round(pom.x + 5), round(pom.y + 5));
  pom.Free;
end;

function TEllipse.getResizeControls(): TPoints;
var
  pom: TPrecisePoint;
begin
  if (_e = nil) then
    Exit;
  SetLength(Result, 5);
  Result[4] := _e.centre.point;
  pom := TPrecisePoint.Create(_e.centre.x + _e.a, _e.centre.y); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  Result[2] := pom.point;
  pom.Free;
  pom := TPrecisePoint.Create(_e.centre.x - _e.a, _e.centre.y); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  Result[3] := pom.point;
  pom.Free;
  pom := TPrecisePoint.Create(_e.centre.x, _e.centre.y + _e.b); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  Result[0] := pom.point;
  pom.Free;
  pom := TPrecisePoint.Create(_e.centre.x, _e.centre.y - _e.b); //cos a sin ani nepisem
  pom := TSupport.rotate(pom, _e.centre, _h);
  Result[1] := pom.point;
  pom.Free;
end;

function TEllipse.addPoint(a: TPoint; where: Integer=-1): boolean;
begin
  Result := false;
  if (not created) then
  begin
    if (_n = 0) then
    begin
      FreeAndNil(_e);
      _e := TGeneralEllipseEquation.Create(a.X, a.Y, 1, 1);
      _n :=  1;
      Exit;
    end;
    if (_n = 1) then
    begin
      _e.a := max(abs(_e.centre.x - a.X), 1);
      _n := 2;
      Exit;
    end;
    if (_n = 2) then
    begin
      _e.b := max(abs(_e.centre.y - a.y), 1);
      _n := 3;
      Exit;
    end;
  end;
end;

function TEllipse.clone(): TShape;
begin
  Result := TEllipse.Create;
end;

function TEllipse.getType(): TShapeType;
begin
  Result := stEllipse;
end;

procedure TEllipse.drawCreatePreview(C: TCanvas; p: TPoint);
begin
  if (not created) then
  begin
    if (_n = 0) then
    begin
      FreeAndNil(_e);
      _e := TGeneralEllipseEquation.Create(p.X, p.Y, 1, 1);
    end;
    if (_n = 1) then
      _e.a := max(abs(_e.centre.x - p.X), 1);
    if (_n = 2) then
      _e.b := max(abs(_e.centre.y - p.y), 1);
    draw(C);
    drawResizeControls(C);
  end
  else
  begin
    draw(C);
    drawResizeControls(C);
  end;
end;

procedure TEllipse.draw(C: TCanvas);
var
  pom: TPoints;
  i: Integer;
begin
  C.Pen.Mode := pmCopy;
  C.Pen.Width := width;
  C.Pen.Color := color;
  C.Pen.Style := psSolid;
  if bgColorMode then
  begin
    C.Brush.Style := bsSolid;
    C.Brush.Color := backgroundColor;
  end
  else
    C.Brush.Style := bsClear;
  pom := _e.getPoints();
  for i := 0 to high(pom) do
    pom[i] := TSupport.rotate(pom[i], _e.centre, _h);
  C.MoveTo(pom[0].X, pom[0].Y);
  C.Polygon(pom);
  SetLength(pom, 0);
end;

function TEllipse.toString(): string;
begin
  Result := _e.toString();
end;

function TEllipse.clickedOn(a: TPoint): boolean;
var
  p: TGeneralEllipseEquation;
begin
  if not bgColorMode then
    Result := distance(a) <= (width div 2) + 2
  else
  begin
    a := TSupport.rotate(a, _e.centre, -_h);
    p := TGeneralEllipseEquation.Create(_e.centre.x, _e.centre.y, _e.a + (width/2), _e.b + (width/2));
    Result := p.pointInEllipse(a);
    p.Free;
  end;
end;

function TEllipse.clickedOn(x, y: Integer): boolean;
begin
  Result := clickedOn(Point(x, y));
end;

constructor TEllipse.Create();
begin
  _e := nil;
  _h := 0;
  _n := 0;
  _zoom := 1;
  _hasBGColor := false;
  _actionPoint := TPrecisePoint.Create(NilPoint);
  rotatePoint := TPrecisePoint.Create(NilPoint);
end;

constructor TEllipse.Create(a: TPoint; major, minor: Real; color: TColor = clBlack; width: Integer = 1);
begin
  _e := TGeneralEllipseEquation.Create(a.X, a.Y, major, minor);
  _h := 0;
  _n := 3;
  _zoom := 1;
  _hasBGColor := false;
  Self.color := color;
  Self.width := width;
  _actionPoint := TPrecisePoint.Create(NilPoint);
  rotatePoint := _e.centre.clone();
end;

destructor TEllipse.Destroy;
begin
  if (_e <> nil) then
    _e.Free;
  if (_actionPoint <> nil) then
    _actionPoint.Free;
  if (rotatePoint <> nil) then
    rotatePoint.Free();
end;

//----------------TPolygon-------------------

function TPolygon.distance(a: TPoint): Integer;
var
  p, h1, h2: TGeneralLineEquation;
  i: Integer;
begin
  Result := MaxInt;
  if (_n = 0) then
  begin
    Exit;
  end;

  if (_n = 1) then
  begin
    Result := Round(TSupport.distance(a, _points[0].point));
    Exit;
  end;

  for i := 0 to _n-1 do
  begin
    p := TGeneralLineEquation.Create(_points[i], _points[(i+1) mod _n]);
    h1 := TGeneralLineEquation.Create(_points[i], p.controlVector);
    h1.perpendicular(_points[i]);
    h2 := TGeneralLineEquation.Create(_points[(i+1) mod _n], p.controlVector);
    h2.perpendicular(_points[(i+1) mod _n]);
    if (((h1.solve(a) <= 0) and (h2.solve(a) >= 0)) or
      ((h1.solve(a) >= 0) and (h2.solve(a) <= 0))) then
    begin
      Result := Min(Result, p.pointDistance(a));
    end
    else
    begin
      Result := Min(Result, Round(TSupport.distance(_points[i].point, a)));
      Result := Min(Result, Round(TSupport.distance(_points[(i+1) mod _n].point, a)));
    end;
    h1.Free;
    h2.Free;
    p.Free;
  end;
end;

procedure TPolygon.drawMoveControls(C: TCanvas);
begin
  inherited drawMoveControls(C);
  if (_n > 1) then
    C.LineTo(_points[0].point.X, _points[0].point.Y);
end;

procedure TPolygon.drawRotateControls(C: TCanvas);
begin
  inherited drawRotateControls(C);
  if (_n > 1) then
  begin
    C.Pen.Mode := pmNot;
    C.MoveTo(_points[_n-1].point.X, _points[_n-1].point.Y);
    C.LineTo(_points[0].point.X, _points[0].point.Y);
  end;
end;

procedure TPolygon.drawResizeControls(C: TCanvas);
begin
  inherited drawResizeControls(C);
  if (_n > 1) then
    C.LineTo(_points[0].point.X, _points[0].point.Y);
end;

procedure TPolygon.draw(C: TCanvas);
var
  p: TPoints;
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  if bgColorMode then
  begin
    C.Brush.Style := bsSolid;
    C.Brush.Color := backgroundColor;
  end
  else
    C.Brush.Style := bsClear;
  C.Pen.Mode := pmCopy;
  C.Pen.Color := color;
  C.Pen.Width := width;
  C.Pen.Style := psSolid;
  C.MoveTo(_points[0].point.X+1, _points[0].point.Y);
  if (_n = 1) then
  begin
    C.LineTo(_points[0].point.X, _points[0].point.Y);
    Exit;
  end;
  SetLength(p, _n);
  for i := 0 to _n - 1 do
    p[i] := _points[i].point;
  C.Polygon(p);
  SetLength(p, 0);
end;

function TPolygon.getType(): TShapeType;
begin
  Result := stPolygon;
end;

function TPolygon.clickedOn(a: TPoint): boolean;
var
  bmp: TBitmap;
  c1, c2: TColor;
  i: Integer;
  x, y: Real; 
begin
  bmp := TBitmap.Create;
  x := 0;
  y := 0;
  for i := 0 to _n - 1 do
  begin
    if (_points[i].x > x) then x := _points[i].x;
    if (_points[i].y > y) then y := _points[i].y;
  end;
  bmp.Width := Round(x) + width;
  bmp.Height := Round(y) + width;
  c1 := color;
  c2 := backgroundColor;
  color := clBlack;
  backgroundColor := clBlack;
  bmp.Canvas.Brush.Color := clWhite;
  bmp.Canvas.FillRect(Rect(0,0,bmp.Height, bmp.Width));
  draw(bmp.Canvas);
  if (bmp.Canvas.Pixels[a.X, a.Y] = clBlack) then
    Result := true
  else
    Result := false;
  color := c1;
  backgroundColor := c2;
  bmp.Free;
end;

function TPolygon.clickedOn(x, y: Integer): boolean;
begin
  Result := clickedOn(Point(x, y));
end;

function TPolygon.clone(): TShape;
begin
  Result := TPolygon.Create;
end;

function TPolygon.saveToBuffer(var buff: TBuffer): Integer;
var
  p: Pointer;
  i: Integer;
begin
  Result := 2* SizeOf(TColor) + SizeOf(Boolean) + 2 * SizeOf(Integer) + 2 * _n * SizeOf(Real);
  GetMem(buff, Result);
  p := buff;
  System.Move(_color, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_background, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_hasBGColor, p^, SizeOf(Boolean));
  p := Pointer(Cardinal(p) + SizeOf(Boolean));
  System.Move(_width, p^, SizeOf(Integer));
  p := Pointer(Cardinal(p) + SizeOf(Integer));
  System.Move(_n, p^, SizeOf(Integer));
  p := Pointer(Cardinal(p) + SizeOf(Integer));
  for i := 0 to _n - 1 do
  begin
    System.Move(_points[i].x, p^, SizeOf(Real));
    p := Pointer(Cardinal(p) + SizeOf(Real));
    System.Move(_points[i].y, p^, SizeOf(Real));
    p := Pointer(Cardinal(p) + SizeOf(Real));
  end;
end;

constructor TPolygon.loadFromBuffer(var p: TBuffer; count: Integer);
var
  buff: Pointer;
  i, n: Integer;
  int: Integer;
  col: TColor;
  float: Real;
  bool: Boolean;
begin
  Create();
  buff := p;
  System.Move(buff^, col, SizeOf(TColor));
  color := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, col, SizeOf(TColor));
  backgroundColor := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, bool, SizeOf(Boolean));
  bgColorMode := bool;
  buff := Pointer(Cardinal(buff) + SizeOf(Boolean));
  System.Move(buff^, int, SizeOf(Integer));
  width := int;
  buff := Pointer(Cardinal(buff) + SizeOf(Integer));
  System.Move(buff^, n, SizeOf(Integer));
  buff := Pointer(Cardinal(buff) + SizeOf(Integer));
  for i := 0 to n - 1 do
  begin
    addPoint(nilPoint);
    System.Move(buff^, float, SizeOf(Real));
    _points[i].x := float;
    buff := Pointer(Cardinal(buff) + SizeOf(Real));
    System.Move(buff^, float, SizeOf(Real));
    _points[i].y := float;
    buff := Pointer(Cardinal(buff) + SizeOf(Real));
  end;
end;

constructor TPolygon.Create(a: TPoints; color: TColor = clBlack; width: Integer = 1);
begin
  inherited Create(a, color, width);
end;

constructor TPolygon.Create();
begin
  inherited Create();
end;

//---------------TRectAngle------------------

function TRectangle.getCreated(): boolean;
begin
  Result := _n = 4;
end;

function TRectangle.clone(): TShape;
begin
  Result := TRectangle.Create();
end;

function TRectangle.getType(): TShapeType;
begin
  Result := stRectAngle;
end;

procedure TRectangle.rotate(h: Real);
begin
  _h := _h + h;
  inherited rotate(h);
end;

procedure TRectangle.movePoint(i: Integer; p: TPoint);
begin
  if (created and (i in [0..3])) then
  begin
    resetRotatePoint(NilPoint);
    TSupport.rotate(_points[0], rotatePoint, -_h);
    TSupport.rotate(_points[1], rotatePoint, -_h);
    TSupport.rotate(_points[2], rotatePoint, -_h);
    TSupport.rotate(_points[3], rotatePoint, -_h);
    p := TSupport.rotate(p, rotatePoint.point, -_h);
    case i of
      0:
      begin
        _points[0].x := p.X;
        _points[0].y := p.Y;
        _points[3].x := _points[0].x;
        _points[1].y := _points[0].y;
      end;
      1:
      begin
        _points[1].x := p.X;
        _points[1].y := p.Y;
        _points[2].x := _points[1].x;
        _points[0].y := _points[1].y;
      end;
      2:
      begin
        _points[2].x := p.X;
        _points[2].y := p.Y;
        _points[1].x := _points[2].x;
        _points[3].y := _points[2].y;
      end;
      3:
      begin
        _points[3].x := p.X;
        _points[3].y := p.Y;
        _points[0].x := _points[3].x;
        _points[2].y := _points[3].y;
      end;
    end;
    TSupport.rotate(_points[0], rotatePoint, _h);
    TSupport.rotate(_points[1], rotatePoint, _h);
    TSupport.rotate(_points[2], rotatePoint, _h);
    TSupport.rotate(_points[3], rotatePoint, _h);
  end;
end;

procedure TRectangle.drawCreatePreview(C: TCanvas; p: TPoint);
begin
  if (_n = 0) then
  begin
    _points[0] := TPrecisePoint.Create(p);
    _n := 1;
    draw(C);
    drawResizeControls(C);
    _points[0].Free;
    _n := 0;
    Exit;
  end;
  if (_n = 1) then
  begin
    _points[1] := TPrecisePoint.Create(p.X, _points[0].y);
    _points[2] := TPrecisePoint.Create(p);
    _points[3] := TPrecisePoint.Create(_points[0].x, p.y);
    _n := 4;
    draw(C);
    drawResizeControls(C);
    _points[1].Free;
    _points[2].Free;
    _points[3].Free;
    _n := 1;
    Exit;
  end;
  draw(C);
  drawResizeControls(C);
end;

function TRectangle.saveToBuffer(var buff: TBuffer): Integer;
var
  p: Pointer;
begin
  Result := 2 * SizeOf(TColor) + SizeOf(Integer) + SizeOf(Boolean) + 5 * SizeOf(Real);
  GetMem(buff, Result);
  p := buff;
  resetRotatePoint(NilPoint);
  TSupport.rotate(_points[0], rotatePoint, -_h);
  TSupport.rotate(_points[1], rotatePoint, -_h);
  TSupport.rotate(_points[2], rotatePoint, -_h);
  TSupport.rotate(_points[3], rotatePoint, -_h);
  System.Move(_color, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_background, p^, SizeOf(TColor));
  p := Pointer(Cardinal(p) + SizeOf(TColor));
  System.Move(_hasBGColor, p^, SizeOf(Boolean));
  p := Pointer(Cardinal(p) + SizeOf(Boolean));
  System.Move(_width, p^, SizeOf(Integer));
  p := Pointer(Cardinal(p) + SizeOf(Integer));
  System.Move(_points[0].x, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_points[0].y, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_points[2].x, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_points[2].y, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  System.Move(_h, p^, SizeOf(Real));
  p := Pointer(Cardinal(p) + SizeOf(Real));
  TSupport.rotate(_points[0], rotatePoint, _h);
  TSupport.rotate(_points[1], rotatePoint, _h);
  TSupport.rotate(_points[2], rotatePoint, _h);
  TSupport.rotate(_points[3], rotatePoint, _h);
end;

constructor TRectangle.loadFromBuffer(var p: TBuffer; count: Integer);
var
  buff: Pointer;
  int: Integer;
  col: TColor;
  float: Real;
  point: TPoint;
  bool: Boolean;
begin
  Create();
  buff := p;
  System.Move(buff^, col, SizeOf(TColor));
  color := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, col, SizeOf(TColor));
  backgroundColor := col;
  buff := Pointer(Cardinal(buff) + SizeOf(TColor));
  System.Move(buff^, bool, SizeOf(Boolean));
  bgColorMode := bool;
  buff := Pointer(Cardinal(buff) + SizeOf(Boolean));
  System.Move(buff^, int, SizeOf(Integer));
  width := int;
  buff := Pointer(Cardinal(buff) + SizeOf(Integer));
  System.Move(buff^, float, SizeOf(Real));
  point.X := round(float);
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  point.Y := round(float);
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  addPoint(point);
  System.Move(buff^, float, SizeOf(Real));
  point.X := round(float);
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  System.Move(buff^, float, SizeOf(Real));
  point.Y := round(float);
  buff := Pointer(Cardinal(buff) + SizeOf(Real));
  addPoint(point);
  System.Move(buff^, float, SizeOf(Real));
  resetRotatePoint(nilPoint);
  TSupport.rotate(_points[0], rotatePoint, float);
  TSupport.rotate(_points[1], rotatePoint, float);
  TSupport.rotate(_points[2], rotatePoint, float);
  TSupport.rotate(_points[3], rotatePoint, float);
  _h := float;
end;

function TRectangle.addPoint(a: TPoint; where: Integer=-1): boolean;
begin
  Result := false;
  if (not created) then
  begin
    if (_n = 0) then
    begin
      _points[0] := TPrecisePoint.Create(a);
      _n := 1;
      Exit;
    end;
    if (_n = 1) then
    begin
      _points[1] := TPrecisePoint.Create(a.X, _points[0].y);
      _points[2] := TPrecisePoint.Create(a);
      _points[3] := TPrecisePoint.Create(_points[0].x, a.y);
      _n := 4;
    end;
  end;
end;

function TRectangle.removePoint(i: Integer): boolean;
begin
  Result := false;
end;

constructor TRectangle.Create(rect: TRect; color: TColor=clBlack; width: Integer=1);
begin
  SetLength(_points, 4);
  addPoint(rect.TopLeft);
  addPoint(rect.BottomRight);
  Self.rotatePoint := _points[0].clone();
  Self.color := color;
  Self.width := width;
  _zoom := 1;
  _actionPoint := TPrecisePoint.Create(NilPoint);
  _h := 0;
  _hasBGColor := false;
  _n := 4;
  deactivate();
end;

constructor TRectangle.Create();
begin
  _n := 0;
  _h := 0;
  SetLength(_points, 4);
  rotatePoint := TPrecisePoint.Create(NilPoint);
  _actionPoint := TPrecisePoint.Create(NilPoint);
  _zoom := 1;
  _hasBGColor := false;
  deactivate();
end;

//----------------TBezierCurve---------------

procedure TBezierCurve.draw(C: TCanvas);
var
  i, j: Integer;
  t: real;
  p: array of TPrecisePoint;
begin
  if (_n = 0) then
    Exit;
  C.Pen.Mode := pmCopy;
  C.Pen.Color := color;
  C.Pen.Width := width;
  C.Pen.Style := psSolid;
  C.MoveTo(_points[0].point.X+1, _points[0].point.Y);
  if (_n = 1) then
  begin
    C.LineTo(_points[0].point.X, _points[0].point.Y);
    Exit;
  end;
  SetLength(p, _n);
  for i := 0 to _n - 1 do
    p[i] := TPrecisePoint.Create(0, 0);
  t := 0;
  while (t <= 1 + BEZIER_PRECISION) do
  begin
    for i := 0 to _n - 1 do
    begin
      p[i].x := _points[i].x;
      p[i].y := _points[i].y;
    end;
    for i := _n - 1 downto 1 do
      for j := 1 to i do
      begin
        p[j - 1].x := p[j - 1].x + (p[j].x - p[j - 1].x)*t;
        p[j - 1].y := p[j - 1].y + (p[j].y - p[j - 1].y)*t;
      end;
    C.LineTo(p[0].point.X, p[0].point.Y);
    t := t + BEZIER_PRECISION;
  end;
  for i := 0 to _n - 1 do
    p[i].Free;
  SetLength(p, 0);
end;

function TBezierCurve.getType(): TShapeType;
begin
  Result := stBezierCurve;
end;

function TBezierCurve.distance(a: TPoint): Integer;
var
  i, j: Integer;
  t: real;
  p: array of TPrecisePoint;
begin
  if (_n = 1) then
  begin
    Result := round(TSupport.distance(a, _points[0].point));
    Exit;
  end;
  Result := MaxInt;
  SetLength(p, _n);
  for i := 0 to _n - 1 do
    p[i] := TPrecisePoint.Create(0, 0);
  t := 0;
  while (t <= 1 + BEZIER_PRECISION) do
  begin
    for i := 0 to _n - 1 do
    begin
      p[i].x := _points[i].x;
      p[i].y := _points[i].y;
    end;
    for i := _n - 1 downto 1 do
      for j := 1 to i do
      begin
        p[j - 1].x := p[j - 1].x + (p[j].x - p[j - 1].x)*t;
        p[j - 1].y := p[j - 1].y + (p[j].y - p[j - 1].y)*t;
      end;
    Result := min(Result, round(TSupport.distance(a, p[0].point)));
    t := t + BEZIER_PRECISION;
  end;
  for i := 0 to _n - 1 do
    p[i].Free;
  SetLength(p, 0);
end;

function TBezierCurve.saveToBuffer(var buff: TBuffer): Integer;
begin
  Result := inherited saveToBuffer(buff);
end;

constructor TBezierCurve.loadFromBuffer(var p: TBuffer; count: Integer);
begin
  inherited loadFromBuffer(p, count);
end;

function TBezierCurve.clone(): TShape;
begin
  Result := TBezierCurve.Create();
end;

constructor TBezierCurve.Create();
begin
  inherited Create();
end;

//--------------TShapeGroup------------------

function TShapesGroup.distance(a: TPoint): Integer;
begin
  Result := MaxInt;
end;

function TShapesGroup.getCreated(): boolean;
begin
  Result := true;
end;

function TShapesGroup.getType(): TShapeType;
begin
  Result := stGroup;
end;

procedure TShapesGroup.changeZoom(a: Real);
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
    _shapes[i].changeZoom(a);
  _zoom := a;
end;

procedure TShapesGroup.move(x, y: Integer);
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
    _shapes[i].move(x, y);
end;

procedure TShapesGroup.drawMoveControls(C: TCanvas);
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
    _shapes[i].drawMoveControls(C);
end;

procedure TShapesGroup.rotate(h: Real);
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
  begin
    _shapes[i].setRotatePoint(rotatePoint.clone());
    _shapes[i].rotate(h);
  end;
end;

procedure TShapesGroup.resetRotatePoint(p: TPoint);
var
  i: TPrecisePoint;
begin
  if (_n = 0) then
    Exit;
  FreeAndNil(_rotatePoint);
  _shapes[0].resetRotatePoint(p);
  i := _shapes[0].rotatePoint.clone;
  rotatePoint := i;
end;

procedure TShapesGroup.setRotatePoint(a: TPrecisePoint);
var
  i: Integer;
begin
  if (_rotatePoint <> nil) then
    _rotatePoint.Free;
  _rotatePoint := a;
  for i := 0 to _n - 1 do
    _shapes[i].setRotatePoint(rotatePoint.clone());
end;

function TShapesGroup.getRotateControls(): TPoints;
var
  p: TPoints;
begin
  SetLength(p, 2);
  SetLength(Result, 2);
  Result[0] := _rotatePoint.point;
  Result[1] := NilPoint;
  if (_n = 0) then
    Exit;
  p := _shapes[0].getRotateControls();
  Result[0] := p[0];
  Result[1] := p[1];
end;

procedure TShapesGroup.drawRotateControls(C: TCanvas);
var
  i: Integer;
begin
  if (_n = 0) then
    Exit;
  _shapes[0].drawRotateControls(C);
  for i := 1 to _n - 1 do
    _shapes[i].drawMoveControls(C);
end;

procedure TShapesGroup.movePoint(i: Integer; p: TPoint);
var
  pom: TPoints;
  j, max: Integer;
begin
  max := 0;
  for j := 0 to _n - 1 do
  begin
    pom := _shapes[j].getResizeControls();
    if (max + length(pom)) > i then
    begin
      _shapes[j].movePoint(i - max, p);
      break;
    end
    else
      max := max + Length(pom);
    SetLength(pom, 0);
  end;
end;

function TShapesGroup.removePoint(i: Integer): boolean;
var
  pom: TPoints;
  j, max: Integer;
begin
  Result := false;
  max := 0;
  for j := 0 to _n - 1 do
  begin
    pom := _shapes[j].getResizeControls();
    if (max + length(pom)) > i then
    begin
      Result := _shapes[j].removePoint(i - max);
      break;
    end
    else
      max := max + Length(pom);
    SetLength(pom, 0);
  end;
end;

procedure TShapesGroup.drawResizeControls(C: TCanvas);
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
  begin
    _shapes[i].drawResizeControls(C);
  end;
end;

function TShapesGroup.getResizeControls(): TPoints;
var
  i, j, m: Integer;
  p: TPoints;
begin
  SetLength(Result, 0);
  for i := 0 to _n - 1 do
  begin
    p := _shapes[i].getResizeControls();
    m := Length (Result);
    SetLength(Result, m + Length(p));
    for j := 0 to Length(p) - 1 do
      Result[m + j] := p[j];
    SetLength(p, 0);
  end;
end;

function TShapesGroup.addPoint(a: TPoint; where: Integer=-1): boolean;
var
  pom: TPoints;
  j, max: Integer;
begin
  Result := false;
  max := 0;
  for j := 0 to _n - 1 do
  begin
    pom := _shapes[j].getResizeControls();
    if (max + length(pom) + 1) > where then
    begin
      Result := _shapes[j].addPoint(a, where - max);
      break;
    end
    else
      max := max + Length(pom);
    SetLength(pom, 0);
  end;
end;

procedure TShapesGroup.drawCreatePreview(C: TCanvas; p: TPoint);
begin
  //nothing
end;

function TShapesGroup.clone(): TShape;
var
  i: Integer;
begin
  Result := TShapesGroup.Create;
  for i := 0 to _n - 1 do
    TShapesGroup(Result).add(_shapes[i]);
  Result.rotatePoint := rotatePoint.clone();
end;

procedure TShapesGroup.draw(C: TCanvas);
begin
  //nevykresluje sa, ziadne nove informacie by sa nepridali
end;

function TShapesGroup.toString(): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to _n - 1 do
  begin
    Result := Result + _shapes[i].toString();
  end;
end;

function TShapesGroup.getColor(): TColor;
begin
  Result := clBlack;
  if _n >= 1 then
    Result := _shapes[0].color;
end;

function TShapesGroup.getBGColor(): TColor;
begin
  Result := clWhite;
  if _n >= 1 then
    Result := _shapes[0].backgroundColor;
end;

function TShapesGroup.clickedOn(a: TPoint): boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to _n - 1 do
  begin
    Result := Result or _shapes[i].clickedOn(a);
  end;
end;

function TShapesGroup.clickedOn(x, y: Integer): boolean;
begin
  Result := clickedOn(Point(x, y))
end;

constructor TShapesGroup.Create();
begin
  _n := 0;
  SetLength(_shapes, 10);
  setRotatePoint(TPrecisePoint.Create(NilPoint));
  width := 1;
  _hasBGColor := false;
end;

destructor TShapesGroup.Destroy();
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
  begin
    _shapes[i].Free;
  end;
  SetLength(_shapes, 0);
  _rotatePoint.Free;
end;

destructor TShapesGroup.DestroyWithoutShapes;
begin
  SetLength(_shapes, 0);
  _rotatePoint.Free;
end;

procedure TShapesGroup.add(shape: TShape);
begin
  if shape = nil then
    Exit;
  if (_n >= length(_shapes)) then
    SetLength(_shapes, length(_shapes) + 10);
  _shapes[_n] := shape;
  _n := _n + 1;
end;

procedure TShapesGroup.remove(shape: TShape);
var
  i: Integer;
begin
  i := 0;
  while (i < _n) and (not (_shapes[i] = shape)) do
    i := i + 1;
  if (i >= _n) then
    Exit;
  for i := i + 1 to _n - 1 do
    _shapes[i - 1] := _shapes[i];
  _n := _n - 1;
end;

procedure TShapesGroup.setColor(color: TColor);
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
  begin
    _shapes[i].color := color;
  end;
  _color := color;
end;

procedure TShapesGroup.fill(color: TColor);
var
  i: Integer;
begin
  _background := color;
  for i := 0 to _n - 1 do
    _shapes[i].fill(color);
end;

procedure TShapesGroup.setBGMode(fill: Boolean);
var
  i: Integer;
begin
  _hasBGColor := fill;
  for i := 0 to _n - 1 do
    _shapes[i]._hasBGColor := fill;
end;

function TShapesGroup.getWidth(): Integer;
begin
  Result := 1;
  if _n >= 1 then
    Result := _shapes[0].width;
end;

function TShapesGroup.getBGMode(): Boolean;
begin
  Result := false;
  if _n >= 1 then
    Result := _shapes[0].bgColorMode;
end;

procedure TShapesGroup.unfill();
var
  i: Integer;
begin
  _hasBGColor := false;
  for i := 0 to _n - 1 do
    _shapes[i].unfill();
end;

procedure TShapesGroup.setWidth(width: Integer);
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
  begin
    _shapes[i].width := width;
  end;
  _width := width;
end;

function TShapesGroup.count(): Integer;
begin
  Result := _n;
end;

function TShapesGroup.getItem(i: Integer): TShape;
begin
  Result := nil;
  if (i >= 0) and  (i < _n) then
    Result := _shapes[i];
end;

function TShapesGroup.contains(shape: TShape): boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to _n - 1 do
    if (_shapes[i] = shape) then
      Result := true;
end;

function TShapesGroup.saveToBuffer(var buff: TBuffer): Integer;
begin
  Result := 0;
end;

constructor TShapesGroup.loadFromBuffer(var p: TBuffer; count: Integer);
begin
end;

//-------------------------------------------

end.
