program VEditor;

{$MODE Delphi}

uses
  Forms, Interfaces,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  Actions in 'Actions.pas',
  Exceptions in 'Exceptions.pas',
  Shapes in 'Shapes.pas',
  Undo in 'Undo.pas',
  Support in 'Support.pas',
  Picture in 'Picture.pas',
  Main in 'Main.pas',
  Recognition in 'Recognition.pas',
  NewFormUnit in 'NewFormUnit.pas' {NewForm},
  AboutBoxUnit in 'AboutBoxUnit.pas' {AboutBox};

begin
  Application.Initialize;
  Application.Title := 'VEditor';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TNewForm, NewForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.Run;
end.
