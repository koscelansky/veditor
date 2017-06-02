unit MainFormUnit;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Types, StdCtrls,
  Dialogs, ExtCtrls, Actions, Main, ComCtrls, Spin, Menus, NewFormUnit, AboutBoxUnit,
  Buttons, Printers, PrintersDlgs, LazFileUtils;

type

  { TMainForm }

  TMainForm = class(TForm)
    Workspace: TImage;
    LineWidthTrack: TTrackBar;
    ColorDialog1: TColorDialog;
    LineWidthSpin: TSpinEdit;
    ScrollBox: TScrollBox;
    StatusBar: TStatusBar;
    ColorDialog2: TColorDialog;
    CheckBox1: TCheckBox;
    MainMenu: TMainMenu;
    FileMenuGroup: TMenuItem;
    NewDocumentMenuItem: TMenuItem;
    OpenMenuItem: TMenuItem;
    SaveMenuItem: TMenuItem;
    Saveas1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    ExportMenuItem: TMenuItem;
    PrintMenuItem: TMenuItem;
    ExitMenuItem: TMenuItem;
    ExportPicture: TSaveDialog;
    PrintDialog: TPrintDialog;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    InsertMenuGroup: TMenuItem;
    PolyLineMenuItem: TMenuItem;
    SegmentLineMenuItem: TMenuItem;
    CircleMenuItem: TMenuItem;
    EllipseMenuItem: TMenuItem;
    PolygonMenuItem: TMenuItem;
    RectangleMenuItem: TMenuItem;
    BezierCurveMenuItem: TMenuItem;
    N3: TMenuItem;
    ToolsMenuGroup: TMenuItem;
    SelectMenuItem: TMenuItem;
    ResizeMenuItem: TMenuItem;
    MoveMenuItem: TMenuItem;
    RotateMenuItem: TMenuItem;
    UndoMenuItem: TMenuItem;
    RedoMenuItem: TMenuItem;
    ToFrontMenuItem: TMenuItem;
    HigherMenuItem: TMenuItem;
    LowerMenuItem: TMenuItem;
    ToBackMenuItem: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    HandToolMenuItem: TMenuItem;
    N7: TMenuItem;
    DeleteMenuItem: TMenuItem;
    FGColor: TImage;
    BGColor: TImage;
    ColorOK: TButton;
    AboutMenuGroup: TMenuItem;
    AboutMenuItem: TMenuItem;
    LoadButton: TBitBtn;
    NewButton: TBitBtn;
    SaveButton: TBitBtn;
    ExportButton: TBitBtn;
    PrintButton: TBitBtn;
    UndoButton: TBitBtn;
    RedoButton: TBitBtn;
    DeleteButton: TBitBtn;
    SelectButton: TBitBtn;
    SegButton: TBitBtn;
    PolyButton: TBitBtn;
    BzierButton: TBitBtn;
    PolygonButton: TBitBtn;
    RectButton: TBitBtn;
    CircleButton: TBitBtn;
    EllipseButton: TBitBtn;
    HandButton: TBitBtn;
    MoveButton: TBitBtn;
    RotateButton: TBitBtn;
    ResizeButton: TBitBtn;
    LowerButton: TBitBtn;
    HigherButton: TBitBtn;
    ToBackButton: TBitBtn;
    ToFrontButton: TBitBtn;
    ZoomLevel: TComboBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure WorkspaceMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WorkspaceMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure WorkspaceMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure LineWidthTrackChange(Sender: TObject);
    procedure LineWidthSpinChange(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure ExitMenuItemClick(Sender: TObject);
    procedure ExportMenuItemClick(Sender: TObject);
    procedure PrintMenuItemClick(Sender: TObject);
    procedure Saveas1Click(Sender: TObject);
    procedure SaveMenuItemClick(Sender: TObject);
    procedure OpenMenuItemClick(Sender: TObject);
    procedure NewDocumentMenuItemClick(Sender: TObject);
    procedure PolyLineMenuItemClick(Sender: TObject);
    procedure SegmentLineMenuItemClick(Sender: TObject);
    procedure BezierCurveMenuItemClick(Sender: TObject);
    procedure CircleMenuItemClick(Sender: TObject);
    procedure EllipseMenuItemClick(Sender: TObject);
    procedure RectangleMenuItemClick(Sender: TObject);
    procedure PolygonMenuItemClick(Sender: TObject);
    procedure UndoMenuItemClick(Sender: TObject);
    procedure RedoMenuItemClick(Sender: TObject);
    procedure SelectMenuItemClick(Sender: TObject);
    procedure ResizeMenuItemClick(Sender: TObject);
    procedure MoveMenuItemClick(Sender: TObject);
    procedure RotateMenuItemClick(Sender: TObject);
    procedure ToFrontMenuItemClick(Sender: TObject);
    procedure LowerMenuItemClick(Sender: TObject);
    procedure HigherMenuItemClick(Sender: TObject);
    procedure ToBackMenuItemClick(Sender: TObject);
    procedure HandToolMenuItemClick(Sender: TObject);
    procedure DeleteMenuItemClick(Sender: TObject);
    procedure FGColorClick(Sender: TObject);
    procedure BGColorClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorOKClick(Sender: TObject);
    procedure AboutMenuItemClick(Sender: TObject);
    procedure ZoomLevelChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation


Uses
  Math;


{$R *.lfm}

var
  obrazok: TMain;
  currentfile: string;
  _bg: Boolean;
  _w: Integer;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (obrazok <> nil) then
    obrazok.Free();
end;

procedure TMainForm.WorkspaceMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  args: TMouseArgs;
begin
  args := TMouseArgs.Create(x, y, shift, Button);
  obrazok.mouseDown(args);
  if args.onlyRightButton then
    Exit;
  args.Free();
  FGColor.Canvas.Brush.Color := obrazok.Color;
  FGColor.Canvas.FloodFill(0, 0, FGColor.Canvas.Pixels[0, 0], fsSurface);
  BGColor.Canvas.Brush.Color := obrazok.bgColor;
  BGColor.Canvas.FloodFill(0, 0, BGColor.Canvas.Pixels[0, 0], fsSurface);
  LineWidthSpin.Value := obrazok.width;
  LineWidthTrack.Position := obrazok.width;
  CheckBox1.Checked := obrazok.bgMode;
end;

procedure TMainForm.WorkspaceMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  args: TMouseArgs;
begin
  args := TMouseArgs.Create(x, y, shift, Button);
  obrazok.mouseUp(args);
  if args.onlyRightButton then
  begin
    FGColor.Canvas.Brush.Color := ColorDialog1.Color;
    FGColor.Canvas.FloodFill(0, 0, FGColor.Canvas.Pixels[0, 0], fsSurface);
    BGColor.Canvas.Brush.Color := ColorDialog2.Color;
    BGColor.Canvas.FloodFill(0, 0, BGColor.Canvas.Pixels[0, 0], fsSurface);
    CheckBox1.Checked := _bg;
    LineWidthSpin.Value := _w;
    LineWidthTrack.Position := _w;
  end;
  args.Free();
end;

procedure TMainForm.WorkspaceMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  args: TMouseArgs;
begin
  args := TMouseArgs.Create(x, y, shift, mbMiddle);
  obrazok.mouseMove(args);
  StatusBar.Panels[1].Text := ('X: '+IntToStr(x)+' Y: '+IntToStr(Y));
  args.Free();
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
  obrazok.rotateAction();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  obrazok := TMain.Create(Workspace, 800, 600, ScrollBox.Width, ScrollBox.Height);
  StatusBar.Panels[2].Text := 'Zoom ' + IntToStr(round(obrazok.zoom*100)) + '%';
  DoubleBuffered := true;
  ScrollBox.DoubleBuffered := true;
  FGColor.Canvas.Brush.Color := ColorDialog1.Color;
  FGColor.Canvas.FloodFill(0, 0, FGColor.Canvas.Pixels[0, 0], fsSurface);
  BGColor.Canvas.Brush.Color := ColorDialog2.Color;
  BGColor.Canvas.FloodFill(0, 0, BGColor.Canvas.Pixels[0, 0], fsSurface);
  _bg := false;
  _w := 1;
  currentfile := '';
end;

procedure TMainForm.Button4Click(Sender: TObject);
begin
  obrazok.resizeAction();
end;

procedure TMainForm.LineWidthTrackChange(Sender: TObject);
begin
  LineWidthSpin.Value := LineWidthTrack.Position;
end;

procedure TMainForm.LineWidthSpinChange(Sender: TObject);
begin
  LineWidthTrack.Position := LineWidthSpin.Value;
end;

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  LineWidthTrack.Enabled := false;
  LineWidthTrack.Enabled := true;
  if Sign(WheelDelta) < 0 then
    obrazok.zoom := obrazok.zoom - 0.05
  else
    obrazok.zoom := obrazok.zoom + 0.05;
  StatusBar.Panels[2].Text := 'Zoom ' + IntToStr(round(obrazok.zoom*100)) + '%';
  ZoomLevel.Text := IntToStr(round(obrazok.zoom*100)) + '%';
end;

procedure TMainForm.ExitMenuItemClick(Sender: TObject);
begin
  Close();
end;

procedure TMainForm.ExportMenuItemClick(Sender: TObject);
var
  bmp: TBitmap;
begin
  if ExportPicture.Execute then
  begin
    bmp := obrazok.getBitmap();
    bmp.SaveToFile(ExportPicture.FileName + '.bmp');
    bmp.Free();
  end;
end;

procedure TMainForm.PrintMenuItemClick(Sender: TObject);
begin
  if PrintDialog.Execute then
  begin
    Printer.BeginDoc();
    obrazok.drawTo(Printer.Canvas);
    Printer.EndDoc();
  end;
end;

procedure TMainForm.Saveas1Click(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    if FileExistsUTF8(SaveDialog.FileName) { *Converted from FileExists* } then
    begin
      if MessageDlg('File exists! Overwrite?', mtWarning, [mbYes, mbNo], 0) = mrYes then
      begin
        obrazok.saveToFile(SaveDialog.FileName + '.vef');
        currentfile := SaveDialog.FileName + '.vef';
      end;
    end
    else
    begin
      obrazok.saveToFile(SaveDialog.FileName + '.vef');
      currentfile := SaveDialog.FileName + '.vef';
    end;
  end;
  Caption := Caption + '  [' + currentfile + ']';
end;

procedure TMainForm.SaveMenuItemClick(Sender: TObject);
begin
  if currentfile = '' then
    Saveas1Click(Sender)
  else
    obrazok.saveToFile(currentfile);
end;

procedure TMainForm.OpenMenuItemClick(Sender: TObject);
begin
  case MessageDlg('Save current picture?', mtWarning, [mbYes, mbNo], 0) of
    mrYes: Saveas1Click(Sender);
    mrCancel: Exit;
  end;
  if OpenDialog.Execute then
  begin
    obrazok.loadFromFile(OpenDialog.FileName);
    currentfile := OpenDialog.FileName;
  end;
  Caption := Caption + '  [' + currentfile + ']';
end;

procedure TMainForm.NewDocumentMenuItemClick(Sender: TObject);
var
  w, h: Integer;
begin
  NewForm.ShowModal();
  w := NewForm.getWidth();
  h := NewForm.getHeight();
  if (w > 0) and (h > 0) then
  begin
    if MessageDlg('Save current picture?', mtWarning, [mbYes, mbNo], 0) = mrYes then
      Saveas1Click(Sender);
    obrazok.Free;
    obrazok := TMain.Create(Workspace, w, h, ScrollBox.Width, ScrollBox.Height);
    currentfile := '';
  end;
end;

procedure TMainForm.PolyLineMenuItemClick(Sender: TObject);
begin
  obrazok.createPolyLine(ColorDialog1.Color, _w);
end;

procedure TMainForm.SegmentLineMenuItemClick(Sender: TObject);
begin
  obrazok.createSegmentLine(ColorDialog1.Color, _w);
end;

procedure TMainForm.BezierCurveMenuItemClick(Sender: TObject);
begin
  obrazok.createBezierCurve(ColorDialog1.Color, _w);
end;

procedure TMainForm.CircleMenuItemClick(Sender: TObject);
begin
  obrazok.createCircle(ColorDialog1.Color, _w, ColorDialog2.Color, CheckBox1.Checked);
end;

procedure TMainForm.EllipseMenuItemClick(Sender: TObject);
begin
  obrazok.createEllipse(ColorDialog1.Color, _w, ColorDialog2.Color, CheckBox1.Checked);
end;

procedure TMainForm.RectangleMenuItemClick(Sender: TObject);
begin
  obrazok.createRectangle(ColorDialog1.Color, _w, ColorDialog2.Color, CheckBox1.Checked);
end;

procedure TMainForm.PolygonMenuItemClick(Sender: TObject);
begin
  obrazok.createPolygon(ColorDialog1.Color, _w, ColorDialog2.Color, CheckBox1.Checked);
end;

procedure TMainForm.UndoMenuItemClick(Sender: TObject);
begin
  obrazok.undo();
end;

procedure TMainForm.RedoMenuItemClick(Sender: TObject);
begin
  obrazok.redo();
end;

procedure TMainForm.SelectMenuItemClick(Sender: TObject);
begin
  obrazok.selectAction();
end;

procedure TMainForm.ResizeMenuItemClick(Sender: TObject);
begin
  obrazok.resizeAction();
end;

procedure TMainForm.MoveMenuItemClick(Sender: TObject);
begin
  obrazok.moveAction();
end;

procedure TMainForm.RotateMenuItemClick(Sender: TObject);
begin
  obrazok.rotateAction();
end;

procedure TMainForm.ToFrontMenuItemClick(Sender: TObject);
begin
  obrazok.toFront();
end;

procedure TMainForm.LowerMenuItemClick(Sender: TObject);
begin
  obrazok.lower();
end;

procedure TMainForm.HigherMenuItemClick(Sender: TObject);
begin
  obrazok.higher();
end;

procedure TMainForm.ToBackMenuItemClick(Sender: TObject);
begin
  obrazok.toBackground();
end;

procedure TMainForm.HandToolMenuItemClick(Sender: TObject);
begin
  obrazok.recognizeAction(ColorDialog1.Color, _w, ColorDialog2.Color, CheckBox1.Checked);
end;

procedure TMainForm.DeleteMenuItemClick(Sender: TObject);
begin
  obrazok.delete();
end;

procedure TMainForm.FGColorClick(Sender: TObject);
begin
  ColorDialog1.Execute;
  obrazok.color := ColorDialog1.Color;
  FGColor.Canvas.Brush.Color := ColorDialog1.Color;
  FGColor.Canvas.FloodFill(0, 0, FGColor.Canvas.Pixels[0, 0], fsSurface);
end;

procedure TMainForm.BGColorClick(Sender: TObject);
begin
  ColorDialog2.Execute;
  obrazok.bgColor := ColorDialog2.Color;
  BGColor.Canvas.Brush.Color := ColorDialog2.Color;
  BGColor.Canvas.FloodFill(0, 0, BGColor.Canvas.Pixels[0, 0], fsSurface);
end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
  obrazok.bgMode := CheckBox1.Checked;
end;

procedure TMainForm.CheckBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  _bg := not CheckBox1.Checked;
end;

procedure TMainForm.ColorOKClick(Sender: TObject);
begin
  obrazok.width := LineWidthSpin.Value;
  _w := LineWidthSpin.Value;
end;

procedure TMainForm.AboutMenuItemClick(Sender: TObject);
begin
  AboutBox.Show();
end;

procedure TMainForm.ZoomLevelChange(Sender: TObject);
var
  i: Integer;
  bool: Boolean;
  s: string;
begin
  bool := true;
  for i := 1 to Length(ZoomLevel.Text) do
  begin
    if not (ZoomLevel.Text[i] in ['0'..'9']) then
    begin
      if (i = Length(ZoomLevel.Text)) and (ZoomLevel.Text[i] = '%') then
      begin
        s := ZoomLevel.Text;
        SetLength(s, Length(s) - 1);
        ZoomLevel.Text := s;
      end
      else
        bool := false;
    end;
  end;
  if bool then
  begin
    obrazok.zoom := StrToInt(ZoomLevel.Text) / 100;
    StatusBar.Panels[2].Text := 'Zoom ' + IntToStr(round(obrazok.zoom*100)) + '%';
  end;
  ZoomLevel.Text := IntToStr(round(obrazok.zoom * 100)) + '%';
end;

end.
