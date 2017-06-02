unit NewFormUnit;

{$MODE Delphi}

interface

uses
  SysUtils, Forms, Dialogs, StdCtrls;

type
  TNewForm = class(TForm)
    Button1: TButton;
    WidthEdit: TEdit;
    HeightEdit: TEdit;
    Width: TLabel;
    Height: TLabel;
    VGA: TRadioButton;
    SVGA: TRadioButton;
    XGA: TRadioButton;
    Custom: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    _confirm: Boolean;
  public
    { Public declarations }
    function getWidth(): Integer;
    function getHeight(): Integer;
  end;

var
  NewForm: TNewForm;

implementation

{$R *.lfm}

function TNewForm.getWidth(): Integer;
var
  i: Integer;
begin
  Result := 0;
  if not _confirm then
    Exit;
  if VGA.Checked then Result := 640;
  if SVGA.Checked then Result := 800;
  if XGA.Checked then Result := 1024;
  if Custom.Checked then
  begin
    for i := 1 to Length(WidthEdit.Text) do
      if not (WidthEdit.Text[i] in ['0'..'9']) then
      begin
        Result := 0;
        Exit;
      end;
    Result := StrToInt(WidthEdit.Text);
  end;
end;

function TNewForm.getHeight(): Integer;
var
  i: Integer;
begin
  Result := 0;
  if not _confirm then
    Exit;
  if VGA.Checked then Result := 480;
  if SVGA.Checked then Result := 600;
  if XGA.Checked then Result := 768;
  if Custom.Checked then
  begin
    for i := 1 to Length(HeightEdit.Text) do
      if not (WidthEdit.Text[i] in ['0'..'9']) then
      begin
        Result := 0;
        Exit;
      end;
    Result := StrToInt(HeightEdit.Text);
  end;
end;

procedure TNewForm.FormCreate(Sender: TObject);
begin
  _confirm := false;
end;

procedure TNewForm.Button1Click(Sender: TObject);
var
  i: Integer;
begin
  _confirm := true;
  if not Custom.Checked then
  begin
    Close();
    Exit;
  end;
  for i := 1 to Length(WidthEdit.Text) do
    if not (WidthEdit.Text[i] in ['0'..'9']) then
      _confirm := false;
  for i := 1 to Length(HeightEdit.Text) do
    if not (HeightEdit.Text[i] in ['0'..'9']) then
      _confirm := false;
  if (Length(WidthEdit.Text) = 1) and (WidthEdit.Text[1] = '0') then _confirm := false;
  if (Length(HeightEdit.Text) = 1) and (HeightEdit.Text[1] = '0') then _confirm := false;
  if _confirm then
    Close()
  else
    MessageDlg('Width and height must be positive integers!', mtError, [mbOK], 0);
end;

procedure TNewForm.FormShow(Sender: TObject);
begin
  _confirm := false;
end;

end.
