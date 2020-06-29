program PMathsFlashcard;

uses
  Vcl.Forms,
  UMainProgram in 'UMainProgram.pas' {Menu},
  UBadges in 'UBadges.pas',
  UDM in 'UDM.pas' {DM: TDataModule},
  UdeckPicker in 'UdeckPicker.pas',
  Uflashcard in 'Uflashcard.pas',
  UCreatecard in 'UCreatecard.pas',
  UMainstats in 'UMainstats.pas',
  UOptionsmenu in 'UOptionsmenu.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMenu, Menu);
  Application.CreateForm(TDM, DM);
  Application.Run;
end.
