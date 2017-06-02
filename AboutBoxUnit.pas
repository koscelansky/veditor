unit AboutBoxUnit;

{$MODE Delphi}

interface

uses Forms, StdCtrls, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    procedure OKButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.lfm}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  Close();
end;

end.
 
