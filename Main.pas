unit Main;

{$MODE Delphi}

interface

(*
  Problem kto nici objekt args, docasne volajuci - asi aj ostane
*)

uses
  ExtCtrls, Classes, Graphics, Shapes, Actions, Picture, Undo, Math,
  SysUtils, Recognition, LazFileUtils;

type

  TMain = class
    private
      //smernik na vektorovy obrazok
      _picture: TVectorPicture;
      //smernik na prave vybranu akciu
      _action: TAction;
      //smernik na component Image, rozmery vytvoreneho obrazku
      _image: TImage;
      _width, _height: Integer;
      //zozmery oblasti do ktorej ho pomocou left a top musime napasovat
      _boundw, _boundh: Integer;
      //zmeni aktualnu akciu na tu v parametri
      _undo: TUndoStack;
      procedure changeAction(a: TAction);
      //menenie vlastnosti objektov
      procedure changeWidth(width: Integer);
      procedure changeColor(color: TColor);
      procedure changeBGColor(color: TColor);
      procedure changeBGMode(fill: Boolean);
      //ak budem potrebovat hrubku aktualneho utvaru / farbu
      function getActualColor(): TColor;
      function getActualBGColor(): TColor;
      function getActualBGMode(): Boolean;
      function getActualWidth(): Integer;
      //zoomovanie
      procedure zoomPicture(a: Real);
      function getZoom(): Real;
    public
      //load & save
      procedure loadFromFile(name: string);
      procedure saveToFile(name: string);
      procedure loadFromStream(s: TStream);
      procedure saveToStream(s: TStream);

      //prida do vektroveho obrazka novy utvar
      procedure addShape(shape: TShape);
      //manipulacia s objektami
      procedure moveAction();
      procedure rotateAction();
      procedure resizeAction();
      procedure selectAction();
      procedure recognizeAction(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
      //vytvaranie objektov
      procedure createPolyLine(color: TColor = clBlack; width: Integer = 1);
      procedure createSegmentLine(color: TColor = clBlack; width: Integer = 1);
      procedure createCircle(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
      procedure createEllipse(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
      procedure createPolygon(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
      procedure createRectangle(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
      procedure createBezierCurve(color: TColor = clBlack; width: Integer = 1);

      //pohyb po z osi
      procedure lower();
      procedure higher();
      procedure toFront();
      procedure toBackground();
      //undo
      procedure undo();
      procedure redo();
      //delete
      procedure delete();
      //procedury na odhandlovanie mysi
      procedure mouseDown(args: TMouseArgs);
      procedure mouseMove(args: TMouseArgs);
      procedure mouseUp(args: TMouseArgs);

      function getBitmap(): TBitmap;
      //vykresli vsetko potrebne do _image
      procedure draw();
      procedure drawTo(C: TCanvas);
      //vytvori objekt TMain do _image priradi parameter
      constructor Create(im: TImage); overload;
      constructor Create(im: TImage; width, height: Integer; boundw: Integer=-1; boundh: Integer=-1); overload;
      destructor Destroy(); override;
      //vola draw
      procedure AfterConstruction(); override;
      //property
      property color: TColor read getActualColor write changeColor;
      property width: Integer read getActualWidth write changeWidth;
      property bgColor: TColor read getActualBGColor write changeBGColor;
      property bgMode: Boolean read getActualBGMode write changeBGMode;
      property zoom: Real read getZoom write zoomPicture;
  end;

implementation

//---------------------TMain-------------------

procedure TMain.loadFromFile(name: string);
begin
  if FileExistsUTF8(name) then
    loadFromStream(TFileStream.Create(name, fmOpenRead))
  else
    raise Exception.Create('File "' + name + '" does not exists.');
end;

procedure TMain.saveToFile(name: string);
begin
  saveToStream(TFileStream.Create(name, fmCreate));
end;

procedure TMain.loadFromStream(s: TStream);
var
  p: Integer;
begin
  changeAction(nil);
  s.Read(p, SizeOf(Integer));
  _image.Width := p;
  _image.Picture.Graphic.Width := p;
  _width := p;
  s.Read(p, SizeOf(Integer));
  _image.Height := p;
  _image.Picture.Graphic.Height := p;
  _height := p;
  _picture.Free;
  _undo.Free;
  _undo := TUndoStack.Create(20);
  _picture := TVectorPicture.LoadFromStream(s);
  _picture.zoom := 1;
  Draw();
  s.Free;
end;

procedure TMain.saveToStream(s: TStream);
var
  z: Real;
begin
  changeAction(nil);
  s.Write(_width, SizeOf(Integer));
  s.Write(_height, SizeOf(Integer));
  z := _picture.zoom;
  _picture.zoom := 1;
  _picture.saveToStream(s);
  _picture.zoom := z;
  s.Free;
end;

procedure TMain.draw();
begin
  //vymazanie celej obrazovky
  _image.Canvas.Pen.Color := clWhite;
  _image.Canvas.Pen.Mode := pmCopy;
  _image.Canvas.Pen.Style := psSolid;
  _image.Canvas.Brush.Style := bsSolid;
  _image.Canvas.Brush.Color := clWhite;
  _image.Canvas.Rectangle(_image.ClientRect);
  //vykreslenie akcie
  _picture.draw(_image.Canvas);
  //vykreslenie pomocnych bodov akcie
  if (_action <> nil) then
    _action.draw(_image.Canvas);
end;

procedure TMain.addShape(shape: TShape);
begin
  _picture.addShape(shape);
end;

procedure TMain.mouseDown(args: TMouseArgs);
begin
  //ak je vybrana nejaka akcia
  if (_action <> nil) then
  begin
    _undo.add(_action.mouseDown(args));
  end;
  draw();
end;

procedure TMain.mouseMove(args: TMouseArgs);
begin
  //ak je v v _action nejaka akcia, potom sa zavola prislusna metoda
  if (_action <> nil) then
  begin
    _undo.add(_action.mouseMove(args));
  end;
  draw();
end;

procedure TMain.mouseUp(args: TMouseArgs);
begin
  //ak je v _action nejaka akcia, potom sa zavola prislusna metoda
  if (_action <> nil) then
  begin
    _undo.add(_action.mouseUp(args));
  end;
  draw();
end;

procedure TMain.changeAction(a: TAction);
begin
  //zmeni sa akcia na akciu definovanu v parametri
  if (_action <> nil) then
    _action.Free();
  _action := a;
  draw();
end;

procedure TMain.moveAction();
begin
  if (_action <> nil) then
    changeAction(TMove.Create(_picture, _action.getGroup()))
  else
    changeAction(TMove.Create(_picture));
end;

procedure TMain.rotateAction();
begin
  if (_action <> nil) then
    changeAction(TRotate.Create(_picture, _action.getGroup()))
  else
    changeAction(TRotate.Create(_picture));
end;

procedure TMain.resizeAction();
begin
  if (_action <> nil) then
    changeAction(TResize.Create(_picture, _action.getGroup()))
  else
    changeAction(TResize.Create(_picture));
end;

procedure TMain.selectAction();
begin
  if (_action <> nil) then
    changeAction(TSelect.Create(_picture, _action.getGroup()))
  else
    changeAction(TSelect.Create(_picture));
end;

procedure TMain.recognizeAction(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
begin
  changeAction(TRecognition.Create(_picture, color, width, bgcolor, bgmode));
end;

procedure TMain.createPolyLine(color: TColor = clBlack; width: Integer = 1);
begin
  changeAction(TCreate.Create(TPolyLine.Create, _picture, color, width));
end;

procedure TMain.createSegmentLine(color: TColor = clBlack; width: Integer = 1);
begin
  changeAction(TCreate.Create(TSegmentLine.Create, _picture, color, width));
end;

procedure TMain.createCircle(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
begin
  changeAction(TCreate.Create(TCircle.Create, _picture, color, width, bgcolor, bgmode));
end;

procedure TMain.createEllipse(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
begin
  changeAction(TCreate.Create(TEllipse.Create, _picture, color, width, bgcolor, bgmode));
end;

procedure TMain.createPolygon(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
begin
  changeAction(TCreate.Create(TPolygon.Create, _picture, color, width, bgcolor, bgmode));
end;

procedure TMain.createRectangle(color: TColor = clBlack; width: Integer = 1; bgcolor: TColor = clWhite; bgmode: boolean = false);
begin
  changeAction(TCreate.Create(TRectangle.Create, _picture, color, width, bgcolor, bgmode));
end;

procedure TMain.createBezierCurve(color: TColor = clBlack; width: Integer = 1);
begin
  changeAction(TCreate.Create(TBezierCurve.Create, _picture, color, width));
end;

procedure TMain.changeWidth(width: Integer);
begin
  if (_action <> nil) then
    _undo.add(_action.changeWidth(width));
  draw();
end;

procedure TMain.changeColor(color: TColor);
begin
  if (_action <> nil) then
    _undo.add(_action.changeColor(Color));
  draw();
end;

procedure TMain.changeBGColor(color: TColor);
begin
  if (_action <> nil) then
    _undo.add(_action.changeBGColor(color));
  draw();
end;

procedure TMain.changeBGMode(fill: Boolean);
begin
  if (_action <> nil) then
    _undo.add(_action.changeBGMode(fill));
  draw();
end;

procedure TMain.lower();
begin
  if (_action <> nil) then
    _undo.add(_action.lower());
  draw();
end;

function TMain.getBitmap(): TBitmap;
var
  z: Real;
begin
  Result := nil;
  if _picture = nil then
    Exit;
  Result := TBitmap.Create();
  Result.Width := _width;
  Result.Height := _height;
  z := _picture.zoom;
  _picture.zoom := 1;
  _picture.draw(Result.Canvas);
  _picture.zoom := z;
end;

procedure TMain.drawTo(C: TCanvas);
var
  z: Real;
  bmp: TBitmap;
begin;
  if _picture = nil then
    Exit;
  z := _picture.zoom;
  bmp := TBitmap.Create();
  bmp.Width := _width;
  bmp.Height := _height;
  _picture.zoom := 1;
  _picture.draw(bmp.Canvas);
  _picture.zoom := z;
  C.Draw(0, 0, bmp);
end;

procedure TMain.higher();
begin
  if (_action <> nil) then
    _undo.add(_action.higher());
  draw();
end;

procedure TMain.toFront();
begin
  if (_action <> nil) then
    _undo.add(_action.toFront());
  draw();
end;

procedure TMain.toBackground();
begin
  if (_action <> nil) then
    _undo.add(_action.toBackground());
  draw();
end;

procedure TMain.undo();
begin
  _undo.undo();
  if (_action <> nil) then
  begin
    _action.Free;
    _action := nil;
  end;
  draw();
end;

procedure TMain.redo();
begin
  _undo.redo;
  if (_action <> nil) then
  begin
    _action.Free;
    _action := nil;
  end;
  draw();
end;

function TMain.getZoom(): Real;
begin
  Result := _picture.zoom;
end;

procedure TMain.zoomPicture(a: Real);
begin
  if ((a >= 0.5) and (a <= 2)) then  //povoleny rozsah
  begin
    //zistenie rozmerov AOwnerera
    if ((_boundw > 0) and (_boundh > 0)) then
    begin
      _image.Width := round(_Width*a);
      _image.Picture.Graphic.Width := round(_Width*a);
      _image.Height := round(_Height*a);
      _image.Picture.Graphic.Height := round(_Height*a);
      _image.Left := Max(0, (_boundw - _image.Width) div 2);
      _image.Top := Max(0, (_boundh - _image.Height) div 2);
    end
    else
    begin
      _image.Width := round(_image.Width*(a/zoom));
      _image.Picture.Graphic.Width := round(_image.Width*(a/zoom));
      _image.Height := round(_image.Height*(a/zoom));
      _image.Picture.Graphic.Height := round(_image.Height*(a/zoom));
    end;
    //zmenenie objektov na obrazku
    _picture.zoom := a;
    if (_action <> nil) then
      _action.zoom(a);
    draw();
  end;
end;

procedure TMain.delete();
begin
  if (_action <> nil) then
    _undo.add(_action.delete);
  draw();
end;

function TMain.getActualColor(): TColor;
begin
  Result := clBlack;
  if (_action <> nil) then
    Result := _action.getActualColor;
end;

function TMain.getActualWidth(): Integer;
begin
  Result := 1;
  if (_action <> nil) then
    Result := _action.getActualWidth;
end;

function TMain.getActualBGColor(): TColor;
begin
  Result := clWhite;
  if (_action <> nil) then
    Result := _action.getActualBGColor;
end;

function TMain.getActualBGMode(): Boolean;
begin
  Result := false;
  if (_action <> nil) then
    Result := _action.getActualBGMode;
end;

constructor TMain.Create(im: TImage);
begin
  //nastavia sa pociatocne hodnoty
  _picture := TVectorPicture.Create();
  _picture.zoom := 1;
  _action := TSelect.Create(_picture);
  _undo := TUndoStack.Create();
  _image := im;
  _width := im.Width;
  _height := im.Height;
end;

constructor TMain.Create(im: TImage; width, height: Integer; boundw: Integer=-1; boundh: Integer=-1);
begin
  _picture := TVectorPicture.Create();
  _action := TSelect.Create(_picture);
  _undo := TUndoStack.Create(20);
  _picture.zoom := 1;
  _image := im;
  _width := width;
  _height := height;
  _boundw := boundw;
  _boundh := boundh;
  _image.Picture.Assign(nil);
  _image.Canvas.Create();
  _image.Height := _height;
  _image.Width := _width;
 if ((_boundw > 0) and (_boundh > 0)) then
  begin
    _image.Left := Max(0, (_boundw - _image.Width) div 2);
    _image.Top := Max(0, (_boundh - _image.Height) div 2);
  end;
  _image.Picture.Graphic.Width := _width;
  _image.Picture.Graphic.Height := _height;
end;

destructor TMain.Destroy();
var
  g: TShapes;
  i, j: Integer;
begin
  if (_action <> nil) then
    _action.Free();
  //blbe nicenie odpadu, ktore zatial inak neviem :( - uz je to lepsie
  g := _undo.getShapes();
  for i := 0 to high(g) do
  begin
    if (g[i] <> nil) then
    begin
      for j := i to high(g) do
        if (g[i] = g[j]) then
          g[j] := nil;
      if (not _picture.contains(g[i])) then
        g[i].Free;
    end;
  end;
  _undo.Free;
  _picture.Free();
end;

procedure TMain.AfterConstruction();
begin
  draw();
end;

//---------------------------------------------

end.
