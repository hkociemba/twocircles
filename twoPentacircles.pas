unit twoPentacircles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

  TTileID = array [0 .. 17] of Integer;
  TTileOri = array [0 .. 17] of Integer;
  TPuzOri = array [0 .. 1] of Integer;

  TPuz = record
    id: TTileID;
    ori: TTileOri;
    pzo: TPuzOri;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var
  pz: TPuz;

procedure initPuzzle(var p: TPuz);
var
  i: Integer;
begin
  for i := 0 to 17 do
  begin
    p.id[i] := i;
    p.ori[i] := 0;
  end;
  p.pzo[0] := 0;
  p.pzo[1] := 0;
end;

procedure move(var p: TPuz; dir, cID: Integer);
var
  i, tmpID, tmpOri: Integer;
begin
  case dir of
    0: // clockwise turn
      begin
        if cID = 0 then
        begin
          tmpID := p.id[0];
          tmpOri := p.ori[0];
          for i := 0 to 8 do
          begin
            p.id[i] := p.id[i + 1];
            p.ori[i] := (p.ori[i + 1] + 1) mod 10;
          end;
          p.id[9] := tmpID;
          p.ori[9] := (tmpOri + 1) mod 10;
        end
        else
        begin
          tmpID := p.id[9];
          tmpOri := p.ori[9];
          for i := 9 to 16 do
          begin
            p.id[i] := p.id[i + 1];
            p.ori[i] := (p.ori[i + 1] + 1) mod 10;;
          end;
          p.id[17] := p.id[0];
          p.ori[17] := (p.ori[0] + 1) mod 10;
          p.id[0] := tmpID;
          p.ori[0] := (tmpOri + 1) mod 10;
        end;
        p.pzo[cID] := (p.pzo[cID] + 1) mod 10;
      end;
    1: // anticlockwise turn
      begin
        if cID = 0 then
        begin
          tmpID := p.id[9];
          tmpOri := p.ori[9];
          for i := 9 downto 1 do
          begin
            p.id[i] := p.id[i - 1];
            p.ori[i] := (p.ori[i - 1] + 9) mod 10;
          end;
          p.id[0] := tmpID;
          p.ori[0] := (tmpOri + 9) mod 10;
        end
        else
        begin
          tmpID := p.id[17];
          tmpOri := p.ori[17];
          for i := 17 downto 10 do
          begin
            p.id[i] := p.id[i - 1];
            p.ori[i] := (p.ori[i - 1] + 9) mod 10;;
          end;
          p.id[9] := p.id[0];
          p.ori[9] := (p.ori[0] + 9) mod 10;
          p.id[0] := tmpID;
          p.ori[0] := (tmpOri + 9) mod 10;
        end;
        p.pzo[cID] := (p.pzo[cID] + 9) mod 10;
      end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  pz: TPuz;
begin
  initPuzzle(pz);
  move(pz, 0, 0);
  move(pz, 1, 0);
  move(pz, 0, 1);
  move(pz, 1, 1);

end;

end.
