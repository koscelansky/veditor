unit Undo;

{$MODE Delphi}

interface

uses
  Types, SysUtils, Graphics, Shapes, Picture;

type

  TUndoStrategy = class
    protected
      _shape: TShape;
      _currZoom: Real;
    public
      function getShape(): TShape; virtual;
      procedure undo(); virtual; abstract;
      procedure redo(); virtual; abstract;
      function toString(): AnsiString; override; abstract;

  end;

  TUndoStack = class
    private
      _stack: array of TUndoStrategy;
      _sp, _p: Integer;
      _undo: boolean;
    public
      procedure add(item: TUndoStrategy);
      procedure undo();
      procedure redo();
      function getShapes(): TShapes;  //vrati pole Shapov, ktore su zosmernikovane u op. undo

      constructor Create(n: integer = 4);
      destructor Destroy(); override;
  end;

  TUndoGroup = class(TUndoStrategy)
    private
      _n: Integer;
      _stack: array of TUndoStrategy;
    public
      procedure add(item: TUndoStrategy);
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create();
      
      destructor Destroy; override;
  end;

  TUndoRotate = class(TUndoStrategy)
    private
      _angle: Real;
      _point: TPoint;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; angle: Real; point: TPoint);
  end;

  TUndoColor = class(TUndoStrategy)
    private
      _prev, _next: TColor;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; prev, next: TColor);
  end;

  TUndoBGColor = class(TUndoStrategy)
    private
      _prev, _next: TColor;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; prev, next: TColor);
  end;

  TUndoBGMode = class(TUndoStrategy)
    private
      _prev, _next: Boolean;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; prev, next: Boolean);
  end;
  
  TUndoWidth = class(TUndoStrategy)
    private
      _prev, _next: Integer;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; prev, next: Integer);
  end;

  TUndoMove = class(TUndoStrategy)
    private
      _x, _y: Integer;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; x, y: Integer);
  end;

  TUndoDelete = class(TUndoStrategy)
    private
      _picture: TVectorPicture;
      _z: Integer;
      _undo: Boolean; //ci bola operacia odvolana a teda sa ma _shape znicit
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; picture: TVectorPicture; zindex: Integer);

      destructor Destroy; override;
  end;

  TUndoCreate = class(TUndoStrategy)
    private
      _picture: TVectorPicture;
      _z: Integer;
      _undo: Boolean;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; picture: TVectorPicture; zindex: Integer);

      destructor Destroy; override;
  end;

  TUndoZIndex = class(TUndoStrategy)
    private
      _n: Integer;
      _pic: TVectorPicture;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; picture: TVectorPicture; n: Integer);
  end;

  TUndoPointMove = class(TUndoStrategy) //k TResize
    private
      _i: Integer;
      _s, _e: TPoint;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; i: Integer; start, finish: TPoint);
  end;

  TUndoPointInsert = class(TUndoStrategy) //k TResize
    private
      _i: Integer;
      _p: TPoint;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; i: Integer; point: TPoint);
  end;

  TUndoPointDelete = class(TUndoStrategy) //k TResize
    private
      _i: Integer;
      _p: TPoint;
    public
      procedure undo(); override;
      procedure redo(); override;
      function toString(): string; override;

      constructor Create(shape: TShape; i: Integer; point: TPoint);
  end;

implementation

//-------------TUndoStack---------------

procedure TUndoStack.add(item: TUndoStrategy);
var
  i: Integer;
begin
  if item = nil then
    Exit;
  if _sp = Length(_stack) then
  begin
    _stack[0].Free;
    for i := 0 to _sp - 2 do
      _stack[i] := _stack[i+1];
    _stack[_sp - 1] := item;
  end
  else
  begin
    if _stack[_sp] <> nil then
      _stack[_sp].Free;
    _stack[_sp] := item;
    _sp := _sp + 1;
  end;
end;

function TUndoStack.getShapes(): TShapes;
var
  i, j: Integer;
begin
  SetLength(Result, Length(_stack));
  j := 0;
  for i := 0 to high(_stack) do
    if (_stack[i] <> nil) then
    begin
      Result[j] := _stack[i].getShape();
      j := j+1;
    end;
  SetLength(Result, j);
end;

procedure TUndoStack.undo();
begin
  if _sp >= 1 then
  begin
    _undo := true;
    _stack[_sp - 1].undo();
    _sp := _sp - 1;
  end;
end;

procedure TUndoStack.redo();
begin
  if (_sp < length(_stack)) and (_stack[_sp] <> nil) then
  begin
    _stack[_sp].redo();
    _sp := _sp + 1;
  end
  else
    _undo := false;
end;

constructor TUndoStack.Create(n: integer = 4);
begin
  if (n < 0) then
    raise ERangeError.Create('Number of operation must be positive.');
  SetLength(_stack, n);
  _sp := 0;
  _p := 0;
  _undo := false;
end;

destructor TUndoStack.Destroy();
var
  i: Integer;
begin
  for i := 0 to high(_stack) do
  begin
    if (_stack[i] <> nil) then
      _stack[i].Free;
  end;
  SetLength(_stack, 0);
end;

//-------------TUndoStrategy--------------

function TUndoStrategy.getShape(): TShape;
begin
  Result := _shape;
end;

//-------------TUndoRotate--------------

procedure TUndoRotate.undo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.moveRotatePointTo(_point);
    _shape.rotate(-_angle);
    _shape.zoom := z;
  end;
end;

procedure TUndoRotate.redo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.moveRotatePointTo(_point);
    _shape.rotate(_angle);
    _shape.zoom := z;
  end;
end;

function TUndoRotate.toString(): string;
begin
  Result := '';
end;

constructor TUndoRotate.Create(shape: TShape; angle: Real; point: TPoint);
begin
  _shape := shape;
  _angle := angle;
  _point := point;
  _currZoom := _shape.zoom;
end;

//-------------TUndoColor-----------

procedure TUndoColor.undo();
begin
  _shape.color := _prev;
end;

procedure TUndoColor.redo();
begin
  _shape.color := _next;
end;

function TUndoColor.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoColor.Create(shape: TShape; prev, next: TColor);
begin
  _shape := shape;
  _prev := prev;
  _next := next;
end;

//----------TUndoBGMode------------     \

procedure TUndoBGMode.undo();
begin
  _shape.bgColorMode := _prev;
end;

procedure TUndoBGMode.redo();
begin
  _shape.bgColorMode := _next;
end;

function TUndoBGMode.toString(): string;
begin
   // :)
end;

constructor TUndoBGMode.Create(shape: TShape; prev, next: Boolean);
begin
  _shape := shape;
  _prev := prev;
  _next := next;
end;

//-------------TUndoWidth-----------

procedure TUndoWidth.undo();
begin
  _shape.width := _prev;
end;

procedure TUndoWidth.redo();
begin
  _shape.width := _next;
end;

function TUndoWidth.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoWidth.Create(shape: TShape; prev, next: Integer);
begin
  _shape := shape;
  _prev := prev;
  _next := next;
end;

//--------------TUndoMove-----------------

procedure TUndoMove.undo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.move(-_x, -_y);
    _shape.zoom := z;
  end;
end;

procedure TUndoMove.redo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.move(_x, _y);
    _shape.zoom := z;
  end;
end;

function TUndoMove.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoMove.Create(shape: TShape; x, y: Integer);
begin
  _shape := shape;
  _x := x;
  _y := y;
  _currZoom := _shape.zoom;
end;

//---------------TUndoDelete---------------

procedure TUndoDelete.undo();
var
  i: Integer;
begin
  _undo := true;
  _picture.addShape(_shape);
  _picture.toBackground(_shape);
  for i := 0 to _z-1 do
    _picture.higher(_shape);
end;

procedure TUndoDelete.redo();
begin
  _undo := false;
  _picture.removeShape(_shape);
end;

function TUndoDelete.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoDelete.Create(shape: TShape; picture: TVectorPicture; zindex: Integer);
begin
  _undo := false;
  _shape := shape;
  _picture := picture;
  _z := zindex;
end;

destructor TUndoDelete.Destroy;
begin
  if ((_shape <> nil) and (not _undo)) then
    _shape.Free;
end;

//-----------------TUndoCreate--------------

procedure TUndoCreate.undo();
begin
  _picture.removeShape(_shape);
  _undo := true;
end;

procedure TUndoCreate.redo();
var
  i: Integer;
begin
  _undo := false;
  _picture.addShape(_shape);
  _picture.toBackground(_shape);
  for i := 0 to _z-1 do
    _picture.higher(_shape);
end;

function TUndoCreate.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoCreate.Create(shape: TShape; picture: TVectorPicture; zindex: Integer);
begin
  _shape := shape;
  _picture := picture;
  _z := zindex;
  _undo := false;
end;

destructor TUndoCreate.Destroy;
begin
  if ((_shape <> nil) and (_undo)) then
    _shape.Free;
end;

//-----------------TUndoZIndex---------------

procedure TUndoZIndex.undo();
var
  i: Integer;
begin
  for i := 1 to abs(_n) do
  begin
    if (_n < 0) then
      _pic.higher(_shape)
    else
      _pic.lower(_shape);
  end;
end;

procedure TUndoZIndex.redo();
var
  i: Integer;
begin
  for i := 1 to abs(_n) do
  begin
    if (_n < 0) then
      _pic.lower(_shape)
    else
      _pic.higher(_shape);
  end;
end;

function TUndoZIndex.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoZIndex.Create(shape: TShape; picture: TVectorPicture; n: Integer);
begin
  _n := n;
  _shape := shape;
  _pic := picture;
end;

//--------------TUndoPointMove-----------------

procedure TUndoPointMove.undo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.movePoint(_i, _s);
    _shape.zoom := z;
  end;
end;

procedure TUndoPointMove.redo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.movePoint(_i, _e);
    _shape.zoom := z;
  end;
end;

function TUndoPointMove.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoPointMove.Create(shape: TShape; i: Integer; start, finish: TPoint);
begin
  _shape := shape;
  _i := i;
  _s := start;
  _e := finish;
  _currZoom := _shape.zoom;
end;

//---------------TUndoPointInsert----------------

procedure TUndoPointInsert.undo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.removePoint(_i);
    _shape.zoom := z;
  end;
end;

procedure TUndoPointInsert.redo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.addPoint(_p, _i);
    _shape.zoom := z;
  end;
end;

function TUndoPointInsert.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoPointInsert.Create(shape: TShape; i: Integer; point: TPoint);
begin
  _p := Point;
  _i := i;
  _shape := shape;
  _currZoom := _shape.zoom;
end;

//--------------TUndoPointDelete------------------

procedure TUndoPointDelete.undo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.addPoint(_p, _i);
    _shape.zoom := z;
  end;
end;

procedure TUndoPointDelete.redo();
var
  z: Real;
begin
  if (_shape <> nil) then
  begin
    z := _shape.zoom;
    _shape.zoom := _currZoom;
    _shape.removePoint(_i);
    _shape.zoom := z;
  end;
end;

function TUndoPointDelete.toString(): string;
begin
  //not yet implemented
end;

constructor TUndoPointDelete.Create(shape: TShape; i: Integer; point: TPoint);
begin
  _p := Point;
  _i := i;
  _shape := shape;
  _currZoom := _shape.zoom;
end;

//-------------TUndoGroup----------------

procedure TUndoGroup.undo();
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
    _stack[i].undo;
end;

procedure TUndoGroup.redo();
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
    _stack[i].redo;
end;

function TUndoGroup.toString(): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to _n - 1 do
    Result := Result + _stack[i].toString + ' ';
end;

procedure TUndoGroup.add(item: TUndoStrategy);
begin
  if (_n = Length(_stack)) then
    SetLength(_stack, _n + 5);
  _stack[_n] := item;
  _n := _n + 1;
end;

constructor TUndoGroup.Create();
begin
  _shape := nil;
  _currZoom := 0;
  _n := 0;
  SetLength(_stack, 5);
end;

destructor TUndoGroup.Destroy;
var
  i: Integer;
begin
  for i := 0 to _n - 1 do
    _stack[i].Free;
  SetLength(_stack, 0);
end;

//-------------TUndoBGColor--------------

procedure TUndoBGColor.undo(); 
begin
  _shape.backgroundColor := _prev;
end;

procedure TUndoBGColor.redo();
begin
  _shape.backgroundColor := _next;
end;

function TUndoBGColor.toString(): string;
begin
  // :)
end;

constructor TUndoBGColor.Create(shape: TShape; prev, next: TColor);
begin
  _shape := shape;
  _prev := prev;
  _next := next;
end;

//------------------------------------------------

end.
