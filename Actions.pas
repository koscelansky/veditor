unit Actions;

{$MODE Delphi}

interface

uses
  Controls, Classes, Types, Graphics, Math, Shapes, Undo, Support, Picture;

type
  TMouseArgs = class
    private
      _x, _y: Integer;
      _state: TShiftState;
      _button: TMouseButton;
      function getPoint(): TPoint;
    public
      constructor Create(x, y: Integer; state: TShiftState; button: TMouseButton); //mbmiddle znamena ze nil
      function leftButton(): boolean;
      function rightButton(): boolean;
      function onlyLeftButton(): boolean; 
      function onlyRightButton(): boolean;
      property x: Integer read _x;
      property y: Integer read _y;
      property point: TPoint read getPoint;
      property state: TShiftState read _state;
      property button: TMouseButton read _button;

  end;

  TAction = class
    protected
      _shape: TShape;
      _picture: TVectorPicture;
      _group: TShapesGroup;
      _refered: boolean;
      function getHasShape(): boolean; virtual;
      function getHasPicture(): boolean;
    public
      procedure draw(C: TCanvas); virtual; abstract;
      procedure changeShape(shape: TShape); virtual;

      //posuvanie shapu podla z-indexu
      function lower(): TUndoStrategy;
      function higher(): TUndoStrategy;
      function toBackground(): TUndoStrategy;
      function toFront(): TUndoStrategy;
      //menenie vlastnosti shapu
      function changeWidth(width: Integer): TUndoStrategy; virtual;
      function changeColor(color: TColor): TUndoStrategy; virtual;
      function changeBGColor(color: TColor): TUndoStrategy; virtual;
      function changeBGMode(fill: boolean): TUndoStrategy; virtual;
      procedure zoom(a: Real); virtual;
      //zistenie vlastnosti objektu
      function delete(): TUndoStrategy; virtual;
      //vymazanie shapu
      function getActualColor(): TColor; virtual;
      function getActualWidth(): Integer; virtual;
      function getActualBGColor(): TColor; virtual;
      function getActualBGMode(): Boolean; virtual;
      //vrati skupinu pouyivanych utvarov
      function getGroup(): TShapesGroup;

      function mouseDown(args: TMouseArgs): TUndoStrategy; virtual; abstract;
      function mouseMove(args: TMouseArgs): TUndoStrategy; virtual; abstract;
      function mouseUp(args: TMouseArgs): TUndoStrategy; virtual; abstract;

      destructor Destroy(); override;

      property hasPicture: boolean read getHasPicture;
      property hasShape: boolean read getHasShape;
  end;

  TMove = class(TAction)
    private
      _start: TPoint;     //zaciatocny bod
      _current: TPoint;   //aktualny bod
      _hold: boolean;
    public
      function mouseDown(args: TMouseArgs): TUndoStrategy; override;
      function mouseMove(args: TMouseArgs): TUndoStrategy; override;
      function mouseUp(args: TMouseArgs): TUndoStrategy; override;

      procedure draw(C: TCanvas); override;

      constructor Create(pic: TVectorPicture); overload;
      constructor Create(pic: TVectorPicture; group: TShapesGroup); overload;
  end;

  TRotate = class(TAction)
    private
      _start: TPoint;
      _current: TPoint;
      _angle: Real;
      _rotatePointHold: boolean;
      _actionPointHold: boolean;
    public
      function mouseDown(args: TMouseArgs): TUndoStrategy; override;
      function mouseMove(args: TMouseArgs): TUndoStrategy; override;
      function mouseUp(args: TMouseArgs): TUndoStrategy; override;

      procedure draw(C: TCanvas); override;

      constructor Create(pic: TVectorPicture); overload;
      constructor Create(pic: TVectorPicture; group: TShapesGroup); overload;
  end;

  TResize = class(TAction)
    private
      _start: TPoint;
      _current: TPoint;
      _hold: boolean;
      _number: Integer;
    public
      function mouseDown(args: TMouseArgs): TUndoStrategy; override;
      function mouseMove(args: TMouseArgs): TUndoStrategy; override;
      function mouseUp(args: TMouseArgs): TUndoStrategy; override;

      procedure draw(C: TCanvas); override;

      constructor Create(pic: TVectorPicture); overload;
      constructor Create(pic: TVectorPicture; group: TShapesGroup); overload;
  end;

  TCreate = class(TAction)
    private
      _color: TColor;
      _width: Integer;
      _BGcolor: TColor;
      _fill: boolean;
      _current: TPoint;
    public
      procedure changeShape(shape: TShape); override;
      function changeWidth(width: Integer): TUndoStrategy; override;
      function changeColor(color: TColor): TUndoStrategy; override;
      function delete(): TUndoStrategy; override; //neunduuje sa
      function getActualColor(): TColor; override;
      function getActualWidth(): Integer; override;
      function getActualBGColor(): TColor; override;
      function getActualBGMode(): Boolean; override;
      function changeBGColor(color: TColor): TUndoStrategy; override;
      function changeBGMode(fill: boolean): TUndoStrategy; override;

      function mouseDown(args: TMouseArgs): TUndoStrategy; override;
      function mouseMove(args: TMouseArgs): TUndoStrategy; override;
      function mouseUp(args: TMouseArgs): TUndoStrategy; override;

      procedure draw(C: TCanvas); override;

      constructor Create(shape: TShape; pic: TVectorPicture; color: TColor = clBlack; width: Integer = 1; backGroundColor: TColor = clWhite; hasBGColor: boolean = false);
      destructor Destroy(); override;
  end;

  TSelect = class(TAction)
    public
      function mouseDown(args: TMouseArgs): TUndoStrategy; override;
      function mouseMove(args: TMouseArgs): TUndoStrategy; override;
      function mouseUp(args: TMouseArgs): TUndoStrategy; override;

      procedure draw(C: TCanvas); override;
      constructor Create(pic: TVectorPicture); overload;
      constructor Create(pic: TVectorPicture; group: TShapesGroup); overload;
  end;

implementation

//--------------------TMouseArgs----------------------

constructor TMouseArgs.Create(x, y: Integer; state: TShiftState; button: TMouseButton);
begin
  _x := x;
  _y := y;
  _state := state;
  _button := button;
end;

function TMouseArgs.leftButton(): boolean;
begin
  Result := ssLeft in _state;
end;

function TMouseArgs.rightButton(): boolean;
begin
  Result := ssLeft in _state;
end;

function TMouseArgs.onlyLeftButton(): boolean;
begin
  Result := _button = mbLeft;
end;

function TMouseArgs.onlyRightButton(): boolean;
begin
  Result :=  _button = mbRight;
end;

function TMouseArgs.getPoint(): TPoint;
begin
  Result.X := x;
  Result.Y := y;
end;

//---------------------TAction---------------------

procedure TAction.changeShape(shape: TShape);
begin
  if (_group <> nil) then
    _group.add(shape);
  _shape := shape;
end;

procedure TAction.zoom(a: Real);
begin
  if (_group <> nil) then
    _group.zoom := a;
  if (hasShape) then
    _shape.zoom := a;
end;

function TAction.getHasShape(): boolean;
begin
  Result := (_shape <> nil);
end;

function TAction.getHasPicture(): boolean;
begin
  Result := _picture <> nil;
end;

function TAction.lower(): TUndoStrategy;
begin
  Result := nil;
  if (hasPicture and (_group <> nil) and (_group.count = 1)) then
  begin
    if (_picture.lower(_group[0]) <> 0) then
      Result := TUndoZIndex.Create(_group[0], _picture, -1);
  end;
end;

function TAction.higher(): TUndoStrategy;
begin
  Result := nil;
  if (hasPicture and (_group <> nil) and (_group.count = 1)) then
  begin
    if (_picture.higher(_group[0]) <> 0) then
      Result := TUndoZIndex.Create(_group[0], _picture, 1);
  end;
end;

function TAction.toBackground(): TUndoStrategy;
var
  n: Integer;
begin
  Result := nil;
  if (hasPicture and (_group <> nil) and (_group.count = 1)) then
  begin
    n := _picture.toBackground(_group[0]); //pocet znizeni
    if (n <> 0) then
      Result := TUndoZIndex.Create(_group[0], _picture, n);
  end;
end;

function TAction.toFront(): TUndoStrategy;
var
  n: Integer;
begin
  Result := nil;
  if (hasPicture and (_group <> nil) and (_group.count = 1)) then
  begin
    n := _picture.toFront(_group[0]); //pocet zvyseni
    if (n <> 0) then
      Result := TUndoZIndex.Create(_group[0], _picture, n);
  end;
end;

function TAction.changeWidth(width: Integer): TUndoStrategy;
var
  i: Integer;
begin
  Result := nil;
  if (_group <> nil) then
  begin
    Result := TUndoGroup.Create;
    for i := 0 to _group.count - 1 do
      TUndoGroup(Result).add(TUndoWidth.Create(_group[i], _group[i].width, width));
    _group.width := width;
  end;
end;

function TAction.changeColor(color: TColor): TUndoStrategy;
var
  i: Integer;
begin
  Result := nil;
  if (_group <> nil) then
  begin
    Result := TUndoGroup.Create;
    for i := 0 to _group.count - 1 do
      TUndoGroup(Result).add(TUndoColor.Create(_group[i], _group[i].color, color));
    _group.color := color;
  end;
end;

function TAction.changeBGColor(color: TColor): TUndoStrategy;
var
  i: Integer;
begin
  Result := nil;
  if (_group <> nil) then
  begin
    Result := TUndoGroup.Create;
    for i := 0 to _group.count - 1 do
      TUndoGroup(Result).add(TUndoBGColor.Create(_group[i], _group[i].backgroundColor, color));
    _group.backgroundColor := color;
  end;
end;

function TAction.changeBGMode(fill: boolean): TUndoStrategy;
var
  i: Integer;
begin
  Result := nil;
  if (_group <> nil) then
  begin
    Result := TUndoGroup.Create;
    for i := 0 to _group.count - 1 do
      TUndoGroup(Result).add(TUndoBGMode.Create(_group[i], _group[i].bgColorMode, fill));
    _group.bgColorMode := fill;
  end;
end;

function TAction.delete(): TUndoStrategy;
var
  i: Integer;
begin
  Result := nil;
  if (_group <> nil) then
  begin
    Result := TUndoGroup.Create;
    for i := 0 to _group.count - 1 do
    begin
      TUndoGroup(Result).add(TUndoDelete.Create(_group[i], _picture, _picture.getZIndex(_group[i])));
      _picture.removeShape(_group[i]);
    end;
  end;
  _group := TShapesGroup.Create;
end;

function TAction.getActualColor(): TColor;
begin
  Result := clBlack;
  if (_group <> nil) then
    Result := _group.color;
end;

function TAction.getActualWidth(): Integer;
begin
  Result := 1;
  if (_group <> nil) then
    Result := _group.width;
end;

function TAction.getActualBGColor(): TColor;
begin
  Result := clWhite;
  if (_group <> nil) then
    Result := _group.backGroundColor;
end;

function TAction.getActualBGMode(): Boolean;
begin
  Result := false;
  if (_group <> nil) then
    Result := _group.bgColorMode;
end;

function TAction.getGroup(): TShapesGroup;
begin
  if (_group <> nil) then
    Result := TShapesGroup(_group.clone())
  else
    Result := nil;
end;

destructor TAction.Destroy();
begin
  if (_group <> nil) and not(_refered) then
    _group.DestroyWithoutShapes;
end;

//----------------------TMove---------------------------

procedure TMove.draw(C: TCanvas);
begin
  if (_group <> nil) then
    _group.drawMoveControls(C);
end;

function TMove.mouseDown(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if ((args.button = mbLeft) and args.onlyLeftButton) then
  begin
    if (_group.count = 0) then
      _group.add(_picture.getShape(args.point))
    else
      if (ssCtrl in args._state) then
        if (_group.contains(_picture.getShape(args.point))) then
          _group.remove(_picture.getShape(args.point))
        else
          _group.add(_picture.getShape(args.point));
    if (_group <> nil) and (_group.clickedOn(args.point)) then
    begin
      _start := args.point;
      _current := args.point;
      _hold := true;
    end;
  end;
  if (args.button = mbRight) and (_group <> nil) then
  begin
    _group.DestroyWithoutShapes;
    _group := TShapesGroup.Create;
  end;
end;

function TMove.mouseMove(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if ((_group <> nil) and (ssLeft in args.state) and _hold) then
  begin
    _group.move(args.X - _current.X, args.Y - _current.Y);
    _current := args.point;
  end;
end;

function TMove.mouseUp(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if ((_group <> nil) and (args.button = mbLeft)) then
  begin
    if ((_start.X <> _current.X) and (_start.Y <> _current.Y)) then
    begin
      Result := TUndoMove.Create(_group, _current.X - _start.X, _current.Y - _start.Y);
      _group := TShapesGroup(_group.clone);
    end;
    _hold := false;
  end;
end;

constructor TMove.Create(pic: TVectorPicture);
var
  p: TPoint;
begin
  p.X := 0;
  p.Y := 0;
  _start := p;
  _current := p;
  _shape := nil;
  _hold := false;
  _picture := pic;
  _group := TShapesGroup.Create;
  _refered := false;
end;

constructor TMove.Create(pic: TVectorPicture; group: TShapesGroup);
begin
  Create(pic);
  if group <> nil then
  begin
    _group.Free;
    _group := group;
  end;
end;

//------------------------TRotate------------------------

procedure TRotate.draw(C: TCanvas);
begin
  if (_group <> nil) then
    _group.drawRotateControls(C);
end;

function TRotate.mouseDown(args: TMouseArgs): TUndoStrategy;
var
  pom: TPoints;
begin
  Result := nil;
  if ((args.button = mbLeft) and args.onlyLeftButton) then
  begin
    if (_group.count = 0) then
    begin
      _group.add(_picture.getShape(args.point));
      _group.resetRotatePoint(args.point);
    end
    else
      if (ssCtrl in args._state) then
      begin
        if (_group.contains(_picture.getShape(args.point))) then
          _group.remove(_picture.getShape(args.point))
        else
          begin
            _group.add(_picture.getShape(args.point));
            if (_group.count = 1) then
              _group.resetRotatePoint(args.point);
          end;
      end;
    if (_group <> nil) and (_group.count > 0) then
    begin
      pom := _group.getRotateControls;
      if ((pom[0].x - 5 <= args.point.x) and (pom[0].x + 5 >= args.point.x)
        and (pom[0].y - 5 <= args.point.y) and (pom[0].y + 5 >= args.point.y)) then
      begin
        _rotatePointHold := true;
        _start := pom[0];
        _current := pom[0];
      end;
      if (TSupport.distance(pom[1], args.point) <= 5) then
      begin
        _actionPointHold := true;
        _angle := 0;
      end;
      SetLength(pom, 0);
    end;
  end;
  if (args.button = mbRight) and (_group <> nil) then
  begin
    _group.DestroyWithoutShapes;
    _group := TShapesGroup.Create;
  end;
end;


function TRotate.mouseMove(args: TMouseArgs): TUndoStrategy;
var
  u, v: TPlanarVector;
  pom: TPoints;
  angle: Real;
begin
  Result := nil;
  if ((_group <> nil) and (ssLeft in args.state) and _rotatePointHold) then
  begin
    _group.moveRotatePoint(args.point.x - _current.x, args.point.y - _current.y);
    _current := args.point;
  end;
  if ((_group <> nil) and (ssLeft in args.state) and _actionPointHold) then
  begin
    pom := _group.getRotateControls;
    v := TPlanarVector.Create(pom[0], pom[1]);
    u := TPlanarVector.Create(pom[0], args.point);
    angle := TSupport.angle(u, v);
    if (not (ssShift in args.state)) then    //ak je stlaceny shift rotuje sa po 45 stupnov
    begin
      if (abs(angle) >= 0.1) then
      begin
        _group.rotate(TSupport.angle(u, v));
        _angle := _angle + angle;
      end
    end
    else
    begin
      if (abs(angle) >= 45) then
      begin
        _group.rotate(Sign(angle)*45);
        _angle := _angle + Sign(angle)*45;
      end;
    end;
    u.Free();
    v.Free();
    SetLength(pom, 0);
  end;
end;

function TRotate.mouseUp(args: TMouseArgs): TUndoStrategy;
var
  pom: TPoints;
begin
  Result := nil;
  if ((_group <> nil) and (args.button = mbLeft)) then
  begin
    if (_actionPointHold) then
    begin
      pom := _group.getRotateControls();
      Result := TUndoRotate.Create(_group, _angle, pom[0]);
      _group := TShapesGroup(_group.clone);
      SetLength(pom, 0);
    end;
    _rotatePointHold := false;
    _actionPointHold := false;
  end;
end;

constructor TRotate.Create(pic: TVectorPicture);
var
  p: TPoint;
begin
  p.X := 0;
  p.Y := 0;
  _angle := 0;
  _start := p;
  _current := p;
  _picture := pic;
  _rotatePointHold := false;
  _actionPointHold := false;
  _shape := nil;
  _group := TShapesGroup.Create;
  _refered := false;
end;

constructor TRotate.Create(pic: TVectorPicture; group: TShapesGroup);
begin
  Create(pic);
  if group <> nil then
  begin
    _group.Free;
    _group := group;
    _group.resetRotatePoint(NilPoint);
  end;
end;

//----------------------TResize--------------------------

function TResize.mouseUp(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if ((_group <> nil) and (args.button = mbLeft)) then
  begin
    if (_hold and (_start.X <> _current.X) and (_start.Y <> _current.Y)) then
    begin
      Result := TUndoPointMove.Create(_group, _number, _start, _current);
      _group := TShapesGroup(_group.clone);
    end;
    _hold := false;
  end;
end;

function TResize.mouseMove(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if ((_group <> nil) and (ssLeft in args.state) and _hold) then
  begin
    _current := args.point;
    _group.movePoint(_number, _current);
  end;
end;

function TResize.mouseDown(args: TMouseArgs): TUndoStrategy;
var
  pom: TPoints;
  i: Integer;
  new: boolean; //ci sa ma vytvorit novy bod (teda ci sa nenasiel medzi vratenimy)
begin
  Result := nil;
  if ((args.button = mbLeft) and args.onlyLeftButton) then
  begin
    new := true;
    if (_group.count = 0) then
    begin
      _group.add(_picture.getShape(args.point));
      Exit;
    end
    else
      if (ssCtrl in args._state) then
      begin
        if (_group.contains(_picture.getShape(args.point))) then
          _group.remove(_picture.getShape(args.point))
        else
          _group.add(_picture.getShape(args.point));
        Exit;
      end;
    begin
      pom := _group.getResizeControls;
      if (pom = nil) then
        _hold := false
      else
        for i := 0 to high(pom) do
        begin
          if ((pom[i].x - 5 <= args.point.x) and (pom[i].x + 5 >= args.point.x)
            and (pom[i].y - 5 <= args.point.y) and (pom[i].y + 5 >= args.point.y)) then
          begin
            new := false;
            _number := i;
            if (ssDouble in args.state) then
            begin
              if (_group.removePoint(_number)) then
              begin
                Result := TUndoPointDelete.Create(_group, _number, pom[i]);
                _group := TShapesGroup(_group.clone);
              end;
              _hold := false;
            end
            else
            begin
              _hold := true;
              _start := pom[i];
              _current := pom[i];
            end;
            break;
          end;
        end;
        if (new and (_group.count = 1)) then
        begin
          _start := args.point;
          _current := args.point;
          _number := length(pom);
          if (_group.addPoint(_current)) then
          begin
            Result := TUndoPointInsert.Create(_group, _number, _current);
            _group := TShapesGroup(_group.clone);
          end;
        end;
      SetLength(pom, 0);
    end;
  end;
  if (args.button = mbRight) then
  begin
    _group.DestroyWithoutShapes;
    _group := TShapesGroup.Create;
  end;
end;

procedure TResize.draw(C: TCanvas);
begin
  if (_group <> nil) then
    _group.drawResizeControls(C);
end;

constructor TResize.Create(pic: TVectorPicture);
var
  p: TPoint;
begin
  p.X := 0;
  p.Y := 0;
  _start := p;
  _current := p;
  _picture := pic;
  _hold := false;
  _shape := nil;
  _group := TShapesGroup.Create;
end;

constructor TResize.Create(pic: TVectorPicture; group: TShapesGroup);
begin
  Create(pic);
  if group <> nil then
  begin
    _group.Free;
    _group := group;
    _group.resetRotatePoint(NilPoint);
  end;
end;

//----------------------TCreate--------------------------

procedure TCreate.changeShape(shape: TShape);
begin

end;

function TCreate.delete(): TUndoStrategy;
var
  pom: TShape;
begin
  Result := nil;
  pom := _shape;
  _shape := _shape.clone();
  _shape.width := _width;
  _shape.color := _color;
  _shape.backgroundColor := _BGcolor;
  _shape.bgColorMode := _fill;
  _shape.zoom := pom.zoom;
  pom.Free;
end;

function TCreate.changeWidth(width: Integer): TUndoStrategy;
begin
  Result := nil;
  if (hasShape) then
    _shape.width := width;
  _width := width;
end;

function TCreate.changeColor(color: TColor): TUndoStrategy;
begin
  Result := nil;
  if (hasShape) then
    _shape.color := color;
  _color := color;
end;

function TCreate.changeBGColor(color: TColor): TUndoStrategy;
begin
  Result := nil;
  if (hasShape) then
    _shape.backgroundColor := color;
  _BGcolor := color;
end;

function TCreate.changeBGMode(fill: boolean): TUndoStrategy;
begin
  Result := nil;
  if (hasShape) then
    _shape.bgColorMode := fill;
  _fill := fill;
end;

function TCreate.getActualColor(): TColor;
begin
  Result := _color;
end;

function TCreate.getActualWidth(): Integer;
begin
  Result := _width;
end;

function TCreate.getActualBGColor(): TColor;
begin
  Result := _BGcolor;
end;

function TCreate.getActualBGMode(): Boolean;
begin
  Result := _fill;
end;

function TCreate.mouseUp(args: TMouseArgs): TUndoStrategy;
var
  p: TShape;
begin
  Result := nil;
  if (mbRight = args.button) then
  begin
    if (_shape.created) then
    begin
      _picture.addShape(_shape);
      Result := TUndoCreate.Create(_shape, _picture, _picture.getZIndex(_shape));
      _shape := _shape.clone();
    end
    else
    begin
      p := _shape;
      _shape := _shape.clone();
      p.Free;
    end;
    _shape.width := _width;
    _shape.color := _color;
    _shape.bgColorMode := _fill;
    _shape.backgroundColor := _BGcolor;
    if (hasPicture) then
      _shape.zoom := _picture.zoom;
  end;
end;

procedure TCreate.draw(C: TCanvas);
begin
  if (hasShape) then
    _shape.drawCreatePreview(C, _current);
end;

function TCreate.mouseMove(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  _current := args.point;
end;

function TCreate.mouseDown(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if (hasPicture and hasShape and (args.button = mbLeft)) then
  begin
    _shape.addPoint(args.point);
  end;
end;

constructor TCreate.Create(shape: TShape; pic: TVectorPicture; color: TColor = clBlack; width: Integer = 1; backGroundColor: TColor = clWhite; hasBGColor: boolean = false);
begin
  _group := nil;
  _shape := shape;
  _picture := pic;
  _shape.color := color;
  _shape.width := width;
  _shape.fill(backGroundColor);
  _shape.bgColorMode := hasBGColor;
  if not(hasBGColor) then
    _shape.unfill();
  if (hasPicture) then
    _shape.zoom := _picture.zoom
  else
    _shape.zoom := 1;
  _BGcolor := backGroundColor;
  _fill := hasBGColor;
  _color := color;
  _width := width;
  _current := InfinityPoint;
end;

destructor TCreate.Destroy();
begin
  if (hasShape) then
    _shape.Free;
end;

//----------------------TSelect---------------------------

function TSelect.mouseDown(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  if ((args.button = mbLeft) and args.onlyLeftButton) then
  begin
    if (_group.count = 0) then
      _group.add(_picture.getShape(args.point))
    else
      if (ssCtrl in args._state) then
        if (_group.contains(_picture.getShape(args.point))) then
          _group.remove(_picture.getShape(args.point))
        else
          _group.add(_picture.getShape(args.point));
  end;
  if (args.button = mbRight) then
  begin
    _group.DestroyWithoutShapes;
    _group := TShapesGroup.Create;
  end;
end;

function TSelect.mouseMove(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  //nothing happen
end;

function TSelect.mouseUp(args: TMouseArgs): TUndoStrategy;
begin
  Result := nil;
  //nothing happen
end;

procedure TSelect.draw(C: TCanvas);
begin
  if (_group <> nil) then
    _group.drawMoveControls(C);
end;

constructor TSelect.Create(pic: TVectorPicture);
begin
  _picture := pic;
  _group := TShapesGroup.Create();
end;

constructor TSelect.Create(pic: TVectorPicture; group: TShapesGroup);
begin
  Create(pic);
  if group <> nil then
  begin
    _group.Free;
    _group := group;
    _group.resetRotatePoint(NilPoint);
  end;
end;

//--------------------------------------------------------

end.
