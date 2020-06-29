unit UDM;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB;

type
  TDM = class(TDataModule)
    DBconnection: TADOConnection;
    Badgeset: TADODataSet;
    Badgesource: TDataSource;
    Getbadges: TADOQuery;
    Achievementset: TADODataSet;
    Deckset: TADODataSet;
    Packset: TADODataSet;
    Packdeckset: TADODataSet;
    CardPackset: TADODataSet;
    Cardset: TADODataSet;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
Dbconnection.connectionstring:='Provider=Microsoft.ACE.OLEDB.12.0;Data Source='+Extractfilepath('MathsDB1.accdb')+'MathsDB1.accdb;Persist Security Info=False';
end;

end.
